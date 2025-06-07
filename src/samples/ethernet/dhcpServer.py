import serial

import pyAxiPassthru.packet as pkt
import pyAxiPassthru.axiPassthruIpUtil as abu
import pyAxiPassthru.dhcp as dhcp

from pyAxiPassthru.packet import *
from pyAxiPassthru.dhcp import PacketFieldEncode


def ParseDhcpMessageAllLayer(data:bytes):
    ethf = pkt.EtherFrame.ParseEtherFrame(data)
    ipp = pkt.IpPacket.ParseIpPacket(ethf.payload)
    udpp = pkt.UdpPacket.ParseUdpPacket(ipp.rest)
    dhcpMes = pkt.DhcpMessage.ParseDhcpMessage(udpp.rest)

    return ethf, ipp, udpp, dhcpMes


def CheckClientIdentifier(mes:DhcpMessage):
    cliId = None
    if DhcpOption.clientIdentifier in mes.options.keys():
        cliId = mes.options[DhcpOption.clientIdentifier]

    return cliId


def DhcpServer(ser:serial.Serial):
    """Lease one IP address to one DHCP client at INIT state.

    Currently this server can only handle one DISCOVER and one REQUEST
    from one server. Rebinding or Renewing functionality is not implemented yet.
    """
    # Sample server IP Address
    serverIpAddr = IpAddress(10, 11, 12, 13)
    # Sample IP Address to assign to client
    yiaddr = IpAddress(10, 14, 15, 16)


    # Default value of Ether Mac Lite Core
    srcMacAddr = MacAddress(0x00, 0x00, 0x5E, 0x00, 0xFA, 0xCE)

    # Sample sname, file value
    sname = "abcdef".encode(encoding="ascii")
    sname, file = sname + b"\x00"*(64 - len(sname)), PacketFieldEncode(0, 128)

    options = {
        DhcpOption.subnetMask: b"\xFF\x80\x00\x00",
        # lease for 32 seconds
        DhcpOption.ipAddrLeaseTime: b"\x00\x00\x00\x20",
        # T1 = 16 seconds
        DhcpOption.renewalTimeValue: b"\x00\x00\x00\x10",
        # T2 = 28 seconds
        DhcpOption.rebindingTimeValue: b"\x00\x00\x00\x1C",
    }

    # status
    # TODO: calculate states at which clients are (REBINDING, INIT, etc.)
    clientStatus = {}

    # Maximum number of DHCP messages this server will accept
    maxIter = 3
    count = 0
    while count < maxIter:
        recv = abu.WaitForDhcpPacket(ser)

        recvEthf, recvIpp, recvUdpp, recvDhcpMes = ParseDhcpMessageAllLayer(recv)
        print(recvDhcpMes)
        # TODO: check UDP port number
        recvMessageType = DhcpMessageType(int.from_bytes(recvDhcpMes.options[DhcpOption.dhcpMessageType], "big"))

        destIpAddr = None
        destMacAddr = None
        sendDhcpMes = None
        print(f"[Server] Transaction Id: {pkt.zfillHex(recvDhcpMes.xid)}")
        print(f"clientStatus: {clientStatus}")
        match recvMessageType:
            case DhcpMessageType.DISCOVER:
                print("[Server] Received DHCPDISCOVER")
                cliId = CheckClientIdentifier(recvDhcpMes)
                if cliId:
                    print(f"[Server] ClientIdentifier found: {pkt.zfillHex(cliId)}")
                else:
                    raise NotImplementedError("ClientIdentifier not found")
                
                clientStatus[cliId] = DhcpMessageType.DISCOVER
                
                destMacAddr, destIpAddr = dhcp.CalcDhcpOfferAckDestAddress(recvDhcpMes, yiaddr)
                print(f"Dest MAC/IP Addres : {destMacAddr}, {destIpAddr}")

                sendDhcpMes = dhcp.GenerateDhcpOfferDhcpMessage(recvDhcpMes, yiaddr, serverIpAddr, sname, file, serverIpAddr, options)

            case DhcpMessageType.REQUEST:
                print("[Server] Received DHCPREQUEST")
                if DhcpOption.serverIdentifier not in recvDhcpMes.options.keys():
                    raise NotImplementedError("ServerIdentifier Option is not found in DHCP Request")
                
                recvServerId = recvDhcpMes.options[DhcpOption.serverIdentifier]
                if serverIpAddr != IpAddress.from_bytes(recvServerId):
                    raise NotImplementedError("DHCP message to other server")

                cliId = CheckClientIdentifier(recvDhcpMes)
                if cliId is None:
                    raise NotImplementedError("Client Identifier not found")
                
                if clientStatus[cliId] != DhcpMessageType.DISCOVER:
                    raise NotImplementedError(f"previous message was {clientStatus[cliId]}")
                
                destMacAddr, destIpAddr = dhcp.CalcDhcpOfferAckDestAddress(recvDhcpMes, yiaddr)
                print(f"Dest MAC/IP Addres : {destMacAddr}, {destIpAddr}")
                sendDhcpMes = dhcp.GenerateDhcpAckDhcpMessage(recvDhcpMes, yiaddr, serverIpAddr, sname, file, serverIpAddr, options)

            case _:
                for p in (recvEthf, recvIpp, recvUdpp, recvDhcpMes):
                    print(p)
                raise NotImplementedError("Unknown message")

        sendUdpp = dhcp.GenerateDhcpUdpPacketFromServer(sendDhcpMes, serverIpAddr, destIpAddr)
        sendIpp = dhcp.GenerateDhcpIpPacket(sendUdpp, serverIpAddr, destIpAddr)
        sendEthf = dhcp.GenerateIpEtherFrame(sendIpp, srcMacAddr, destMacAddr)

        abu.SendEtherFrame(ser, sendEthf.to_bytes())
        lines = ser.readlines()

        abu.UpdateRecvPacket(ser)

        count += 1


if __name__ == "__main__":
    ser = serial.Serial()
    ser.baudrate = 115200
    ser.port = "COM4"
    ser.timeout = 3

    ser.open()
    DhcpServer(ser)
    