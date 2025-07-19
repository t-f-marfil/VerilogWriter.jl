import random

from .packet import (
    IpAddress, MacAddress, BROADCAST_MAC_ADDRESS, LIMITED_BROADCAST_IP_ADDRESS,
    EtherFrame, EtherType,
    IpPacket, IpNumbers,
    UdpPacket,
    DHCP_CLIENT_PORT, DHCP_SERVER_PORT,
    DhcpMessage, DhcpOp, DhcpMessageType, DhcpOption
)


def PacketFieldEncode(x:int, length:int):
    return x.to_bytes(length, byteorder="big")


def GenerateDhcpOfferDhcpMessage(discover:DhcpMessage, yiaddr:IpAddress, siaddr:IpAddress, sname, file, serverId:IpAddress, options=None):
    """Generate DHCPOFFER message.

    Refer to RFC 2131 / 2132 for details.

    Args:
        discover: DHCPDISCOVER message received from client
        yiaddr: Address to assign to client
        siaddr: Next server for bootstrap
        sname: sname field value
        file: file field value
        serverId: server identifier, which is IP address of server
        options: other options
    """
    op = PacketFieldEncode(DhcpOp.BOOTREPLY, 1)
    htype = PacketFieldEncode(1, 1)
    hlen = PacketFieldEncode(6, 1)
    hops = PacketFieldEncode(0, 1)
    xid = discover.xid
    secs = PacketFieldEncode(0, 2)
    flags = discover.flags
    ciaddr = PacketFieldEncode(0, 4)
    # giaddr = 0 if client and server are in the same subnet (section 4.1 in RFC 2131)
    giaddr = discover.giaddr
    chaddr = discover.chaddr

    # options
    if options is None:
        options = {}
    
    options[DhcpOption.dhcpMessageType] = DhcpMessageType.OFFER.to_bytes(1, "big")
    options[DhcpOption.serverIdentifier] = serverId.to_bytes()

    message = DhcpMessage(
        op, htype, hlen, hops,
        xid,
        secs, flags,
        ciaddr,
        yiaddr.to_bytes(),
        siaddr.to_bytes(),
        giaddr,
        chaddr,
        sname,
        file,
        options
    )
    return message


def GenerateDhcpAckDhcpMessage(request:DhcpMessage, yiaddr:IpAddress, siaddr:IpAddress, sname, file, serverId:IpAddress, options=None):
    op = PacketFieldEncode(DhcpOp.BOOTREPLY, 1)
    htype = PacketFieldEncode(1, 1)
    hlen = PacketFieldEncode(6, 1)
    hops = PacketFieldEncode(0, 1)
    xid = request.xid
    secs = PacketFieldEncode(0, 2)
    # Table 3 in RFC 2131 says ciaddr in DHCPREQUEST may be set to zero.
    ciaddr = request.ciaddr
    flags = request.flags
    giaddr = request.giaddr
    chaddr = request.chaddr

    if options is None:
        options = {}

    options[DhcpOption.dhcpMessageType] = DhcpMessageType.ACK.to_bytes(1, "big")
    options[DhcpOption.serverIdentifier] = serverId.to_bytes()

    message = DhcpMessage(
        op, htype, hlen, hops,
        xid,
        secs, flags,
        ciaddr,
        yiaddr.to_bytes(),
        siaddr.to_bytes(),
        giaddr,
        chaddr,
        sname,
        file,
        options
    )
    return message
    

def GenerateDhcpNakDhcpMessage(request:DhcpMessage, serverId:IpAddress, options=None):
    op = PacketFieldEncode(DhcpOp.BOOTREPLY, 1)
    htype = PacketFieldEncode(1, 1)
    hlen = PacketFieldEncode(6, 1)
    hops = PacketFieldEncode(0, 1)
    xid = request.xid
    secs = PacketFieldEncode(0, 2)
    ciaddr = PacketFieldEncode(0, 4)
    yiaddr = PacketFieldEncode(0, 4)
    siaddr = PacketFieldEncode(0, 4)
    flags = request.flags
    giaddr = request.giaddr
    chaddr = request.chaddr
    sname = PacketFieldEncode(0, 64)
    file = PacketFieldEncode(0, 128)

    if options is None:
        options = {}

    options[DhcpOption.dhcpMessageType] = PacketFieldEncode(DhcpMessageType.NAK, 1)
    options[DhcpOption.serverIdentifier] = serverId.to_bytes()

    message = DhcpMessage(
        op, htype, hlen, hops,
        xid,
        secs, flags,
        ciaddr,
        yiaddr,
        siaddr,
        giaddr,
        chaddr,
        sname,
        file,
        options
    )
    return message


def ChaddrToMacAddress(chaddr:bytes):
    assert len(chaddr) == 16
    assert int.from_bytes(chaddr[6:], "big") == 0

    return MacAddress.from_bytes(chaddr[:6])


def CalcDhcpOfferAckDestAddress(discover:DhcpMessage, yiaddr:IpAddress):
    if int.from_bytes(discover.giaddr, "big") != 0:
        raise NotImplementedError("Relay Agent Hardware Address should be given")
    
    # RFC 2131 Section 4.3.1
    assert int.from_bytes(discover.ciaddr, "big") == 0

    if (discover.flags[0] >> 3) == 1:
        return BROADCAST_MAC_ADDRESS, LIMITED_BROADCAST_IP_ADDRESS
    
    # SHOULD be unicast to client even though client configuration is not yet done,
    # see section 4.1 in RFC 2131 for detail.
    # However, it seems many implementations do not unicast in this case
    # and rather broadcast regardless of the broadcast bit.
    # Indeed this behavior does not immediately violate RFC 2131, as in section 4.1 it says
    # "If unicasting is not possible, the message MAY be sent as an IP broadcast."
    return ChaddrToMacAddress(discover.chaddr), yiaddr


def CalcDhcpNakDestAddress(request:DhcpMessage):
    if int.from_bytes(request.giaddr, "big") != 0:
        raise NotImplementedError("Relay Agent Hardware Address should be given")

    return BROADCAST_MAC_ADDRESS, LIMITED_BROADCAST_IP_ADDRESS


def GenerateDhcpUdpPacketFromServer(dhcpMessage:DhcpMessage, srcAddr:IpAddress, destAddr:IpAddress):
    """Generate UDP packet for DHCPOFFER.
    """
    packet = UdpPacket(
        PacketFieldEncode(DHCP_SERVER_PORT, 2), PacketFieldEncode(DHCP_CLIENT_PORT, 2),
        PacketFieldEncode(0, 2), PacketFieldEncode(0, 2),
        dhcpMessage.to_bytes()
    )
    packet.calcLength(update=True)
    packet.calcChecksum(srcAddr.to_bytes(), destAddr.to_bytes(), update=True)
    return packet


def GenerateDhcpIpPacket(udpPacket:UdpPacket, srcAddr:IpAddress, destAddr:IpAddress):
    """Generate IP packet for DHCP message.

    Don't Fragment flag is set here.
    """
    version = PacketFieldEncode(4, 1)
    ihl = PacketFieldEncode(5, 1)
    # for now leave diffserv field to 0
    diffserv = PacketFieldEncode(0, 1)
    totalLength = PacketFieldEncode(0, 2)
    identification = PacketFieldEncode(random.randint(0, 0xFFFF), 2)
    flagsAndFragmentOffset = PacketFieldEncode(0x2 << 13, 2)
    ttl = PacketFieldEncode(128, 1)
    protocol = PacketFieldEncode(IpNumbers.userDatagram, 1)
    headerChecksum = PacketFieldEncode(0, 2)

    packet = IpPacket(
        version, ihl, diffserv, totalLength,
        identification, flagsAndFragmentOffset,
        ttl, protocol, headerChecksum,
        srcAddr.to_bytes(),
        destAddr.to_bytes(),
        udpPacket.to_bytes()
    )
    packet.calcTotalLength(update=True)
    packet.calcHeaderChecksum(update=True)
    return packet


def GenerateIpEtherFrame(ipPacket:IpPacket, srcMac:MacAddress, destMac:MacAddress):
    frame = EtherFrame(
        destMac.to_bytes(),
        srcMac.to_bytes(),
        EtherType.ipv4.to_bytes(2, "big"),
        ipPacket.to_bytes()
    )
    return frame
