"""Define classes that represent network packet format.

This sample directory primarily targets at DHCP transaction, and hence
here we define Ethernet, IP, UDP, DHCP packet (or frame) format.
"""

from enum import IntEnum
from functools import reduce
from io import BytesIO, StringIO


def zfillHex(x:bytes):
    return "h'" + hex(int.from_bytes(x, byteorder="big")).upper()[2:].zfill(len(x) << 1) + "'"


def OnesComplementSum(var:list, windowsize:int):
    result = sum(var)
    mask = (1 << windowsize) - 1
    while (result & mask) != result:
        result = (result & mask) + (result >> windowsize)

    return result ^ mask


class IpAddress():
    def __init__(self, s0, s1, s2, s3) -> None:
        self.s0 = s0
        self.s1 = s1
        self.s2 = s2
        self.s3 = s3
        self.ss:list[int] = [s0, s1, s2, s3]

    @classmethod
    def from_bytes(cls, b:bytes):
        assert len(b) == 4
        return cls(*[bb for bb in b])
    
    def __eq__(self, other) -> bool:
        return self.ss == other.ss
    
    def to_bytes(self):
        buf = BytesIO()
        for s in self.ss:
            buf.write(s.to_bytes(1, byteorder="big"))

        buf.seek(0)
        return buf.read()
    
    def __repr__(self) -> str:
        return f"{self.s0}.{self.s1}.{self.s2}.{self.s3}"


class MacAddress():
    def __init__(self, s0, s1, s2, s3, s4, s5) -> None:
        self.s0 = s0
        self.s1 = s1
        self.s2 = s2
        self.s3 = s3
        self.s4 = s4
        self.s5 = s5
        self.ss:list[int] = [s0, s1, s2, s3, s4, s5]

    def to_bytes(self):
        buf = BytesIO()
        for s in self.ss:
            buf.write(s.to_bytes(1, "big"))
        
        buf.seek(0)
        return buf.read()
    
    @classmethod
    def from_bytes(cls, b):
        assert len(b) == 6
        return cls(*[bb for bb in b])

    def __repr__(self) -> str:
        return reduce(lambda x,y: x + ":" + y, [hex(i)[2:].upper().zfill(2) for i in self.ss])


BROADCAST_MAC_ADDRESS = MacAddress(0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF)
LIMITED_BROADCAST_IP_ADDRESS = IpAddress(0xFF, 0xFF, 0xFF, 0xFF)


class EtherType(IntEnum):
    ipv4 = 0x0800
    arp = 0x0806


class EtherFrame():
    """Ethernet II

    Preamble and SFD are stripped off by ethernet IP Core,
    and those are not inclueded in this class attributes.
    (FCS is also ignored now)
    """
    @classmethod
    def ParseEtherFrame(cls, data:bytes):
        destMac = data[0:6]
        srcMac = data[6:12]

        etherType = data[12:14]

        # TODO: parse VLAN tag
        payload = data[14:]

        return cls(destMac, srcMac, etherType, payload)

    def __init__(self, dest, src, etherType, payload) -> None:
        self.dest = dest
        self.src = src
        self.etherType = etherType
        self.payload = payload

    def to_bytes(self):
        buf = BytesIO()
        buf.write(self.dest)
        buf.write(self.src)
        buf.write(self.etherType)
        buf.write(self.payload)

        buf.seek(0)
        return buf.read()

    def __repr__(self) -> str:
        buf = StringIO()
        
        buf.write("== EthernetFrame ==\n")
        buf.write(f"dest: {zfillHex(self.dest)}\n")
        buf.write(f"src : {zfillHex(self.src)}\n")
        buf.write(f"type: {zfillHex(self.etherType)}\n")
        buf.write(f"data: {zfillHex(self.payload)}")

        buf.seek(0)
        return buf.read()
    

def WordToIpAddrStr(data:bytes):
    intConverted = [b for b in data]

    return reduce(lambda x,y: x+"."+y, [str(i) for i in intConverted])


class IpNumbers(IntEnum):
    # Assigned Internet Protocol Numbers RFC 790
    icmp = 1
    tcp = 6
    userDatagram = 17


class IpPacket():
    # RFC 791 and later
    @classmethod
    def ParseIpPacket(cls, data:bytes):
        # version = int(chr(data[0]))
        # ihl = int(chr(data[1]))
        version = (data[0] >> 4).to_bytes(1, byteorder="big")
        ihl = (data[0] & 0b1111).to_bytes(1, byteorder="big")
        diffServ = data[1:2]
        totalLength = data[2:4]
        identification = data[4:6]
        flagAndfragmentOffset = data[6:8]
        ttl = data[8:9]
        protocol = data[9:10]
        headerChecksum = data[10:12]
        srcAddr = data[12:16]
        destAddr = data[16:20]
        # TODO: separate payload and header options
        rest = data[20:(int.from_bytes(totalLength, byteorder="big"))]

        return cls(
            version, ihl, diffServ, totalLength,
            identification, flagAndfragmentOffset,
            ttl, protocol, headerChecksum,
            srcAddr,
            destAddr,
            rest
        )
    
    def __init__(self, version, ihl, diffServ, totalLength,
                 identification, flagAndfragmentOffset,
                 ttl, protocol, headerChecksum,
                 srcAddr,
                 destAddr,
                 rest) -> None:
        self.version = version
        self.ihl = ihl
        self.diffServ = diffServ
        self.totalLength = totalLength
        self.identification = identification
        self.flagAndfragmentOffset = flagAndfragmentOffset
        self.ttl = ttl
        self.protocol = protocol
        self.headerChecksum = headerChecksum
        self.srcAddr = srcAddr
        self.destAddr = destAddr
        self.rest = rest

    def to_bytes(self):
        buf = BytesIO()
        verIhl:int = (self.version[0] << 4) | self.ihl[0]
        for b in (
            verIhl.to_bytes(1, byteorder="big"),
            self.diffServ,
            self.totalLength,
            self.identification,
            self.flagAndfragmentOffset,
            self.ttl,
            self.protocol,
            self.headerChecksum,
            self.srcAddr,
            self.destAddr,
            self.rest
        ):
            buf.write(b)
        
        buf.seek(0)
        return buf.read()
    
    def calcTotalLength(self, update=False):
        total = len(self.rest) + int.from_bytes(self.ihl, "big") * 4
        if update:
            self.totalLength = total.to_bytes(2, "big")
        return total
    
    def calcHeaderChecksum(self, update=False):
        v = [
            (self.version[0] << 12) | (self.ihl[0] << 8) | int.from_bytes(self.diffServ, byteorder="big"),
            int.from_bytes(self.totalLength, byteorder="big"),
            int.from_bytes(self.identification, byteorder="big"),
            int.from_bytes(self.flagAndfragmentOffset, byteorder="big"),
            (self.ttl[0] << 8) | self.protocol[0],
            (self.srcAddr[0] << 8) | self.srcAddr[1],
            (self.srcAddr[2] << 8) | self.srcAddr[3],
            (self.destAddr[0] << 8) | self.destAddr[1],
            (self.destAddr[2] << 8) | self.destAddr[3],
        ]

        calculated = OnesComplementSum(v, 16)

        if update:
            self.headerChecksum = calculated.to_bytes(2, byteorder="big")

        return calculated

    def __repr__(self) -> str:
        buf = StringIO()

        buf.write("== IP Packet ==\n")
        buf.write(f"version : {zfillHex(self.version)}\n")
        buf.write(f"ihl : {zfillHex(self.ihl)}\n")
        buf.write(f"diffServ : {zfillHex(self.diffServ)}\n")
        buf.write(f"totalLength : {int.from_bytes(self.totalLength, byteorder='big')} ({zfillHex(self.totalLength)})\n")
        buf.write(f"identification : {int.from_bytes(self.identification, byteorder='big')} ({zfillHex(self.identification)})\n")
        buf.write(f"flagAndfragmentOffset : {zfillHex(self.flagAndfragmentOffset)}\n")
        buf.write(f"ttl : {int.from_bytes(self.ttl, byteorder='big')} ({zfillHex(self.ttl)})\n")
        buf.write(f"protocol : {int.from_bytes(self.protocol, byteorder='big')} ({zfillHex(self.protocol)})\n")
        buf.write(f"headerChecksum : {zfillHex(self.headerChecksum)}\n")
        buf.write(f"srcAddr : {WordToIpAddrStr(self.srcAddr)} ({zfillHex(self.srcAddr)})\n")
        buf.write(f"destAddr : {WordToIpAddrStr(self.destAddr)} ({zfillHex(self.destAddr)})\n")
        buf.write(f"rest : {zfillHex(self.rest)}")

        buf.seek(0)
        return buf.read()


DHCP_SERVER_PORT = 67
DHCP_CLIENT_PORT = 68


class UdpPacket():
    # RFC 768
    @classmethod
    def ParseUdpPacket(cls, data:bytes):
        srcPort = data[0:2]
        destPort = data[2:4]
        length = data[4:6]
        checksum = data[6:8]
        rest = data[8:]

        return cls(srcPort, destPort, length, checksum, rest)
    
    def __init__(self, srcPort, destPort, length, checksum, rest) -> None:
        self.src = srcPort
        self.dest = destPort
        self.length = length
        self.checksum = checksum
        self.rest = rest

    def to_bytes(self):
        buf = BytesIO()

        for b in (
            self.src,
            self.dest,
            self.length,
            self.checksum,
            self.rest
        ):
            buf.write(b)

        buf.seek(0)
        return buf.read()
    
    def calcLength(self, update=False):
        total = sum([len(b) for b in (self.src, self.dest, self.length, self.checksum, self.rest)])
        if update:
            self.length = total.to_bytes(2, "big")
        return total
    
    def calcChecksum(self, srcAddr, destAddr, update=False):
        vPseudoHeader = [
            (srcAddr[0] << 8) | srcAddr[1],
            (srcAddr[2] << 8) | srcAddr[3],

            (destAddr[0] << 8) | destAddr[1],
            (destAddr[2] << 8) | destAddr[3],

            0x11,
            8 + len(self.rest)
        ]
        vHeader = [int.from_bytes(b, byteorder="big") for b in (self.src, self.dest, self.length)]
        vData = [int.from_bytes(self.rest[i<<1:(i+1)<<1], byteorder="big") for i in range(len(self.rest) >> 1)]

        calculated = OnesComplementSum(vPseudoHeader+vHeader+vData, 16)
        if update:
            self.checksum = calculated.to_bytes(2, byteorder="big")
        return calculated

    def __repr__(self) -> str:
        buf = StringIO()

        buf.write("== UDP Packet ==\n")
        buf.write(f"src: {int.from_bytes(self.src, byteorder='big')} ({zfillHex(self.src)})\n")
        buf.write(f"dest: {int.from_bytes(self.dest, byteorder='big')} ({zfillHex(self.dest)})\n")
        buf.write(f"length: {int.from_bytes(self.length, byteorder='big')} ({zfillHex(self.length)})\n")
        buf.write(f"checksum: {zfillHex(self.checksum)}\n")
        buf.write(f"rest: {zfillHex(self.rest)}")

        buf.seek(0)
        return buf.read()
    

class DhcpNoDataOption(IntEnum):
    pad = 0
    end = 255


class DhcpOption(IntEnum):
    # RFC 2132

    # RFC 1497 Vendor Extensions
    subnetMask = 1
    timeOffset = 2
    routerOption = 3
    timeServerOption = 4
    nameServerOption = 5
    domainNameServerOption = 6
    logServerOption = 7
    cookieServerOption = 8
    lprServerOption = 9
    impressServerOption = 10
    resourceLocationServerOption = 11
    hostNameOption = 12
    bootFileSizeOption = 13
    meritDumpFile = 14
    domainName = 15
    swapServer = 16
    rootPath = 17
    extensionsPath = 18

    # IP Layer Parameter per Host
    ipForwardingEnDis = 19
    nonLocalSrcRoutingEnDis = 20
    policyFilter = 21
    maxDatagramReassemblySize = 22
    defaultIpTtl = 23
    pathMtuAgingTimeout = 24
    pathMtuPlateauTable = 25

    # IP Layer Parameter per Interface
    interfaceMtu = 26
    allSubnetsAreLocal = 27
    broadcastAddress = 28
    performMaskDiscovery = 29
    maskSupplier = 30
    performRouterDiscovery = 31
    routerSolicitationAddress = 32
    staticRoute = 33

    # Link Layer Parameters per Interface
    trailerEncapsulation = 34
    arpCacheTimeout = 35
    etherEncapsulation = 36

    # TCP Parameters
    tcpDefaultTtl = 37
    tcpKeepaliveInterval = 38
    tcpKeepaliveGarbage = 39

    # Application and Service Parameters
    networkInfoServiceDomain = 40
    networkInfoServers = 41
    networkTimeProtocolServers = 42
    vendorSpecificInfo = 43
    netBiosOverTcpIpNameServer = 44
    netBiosOverTcpIpDatagramDistServer = 45
    netBiosOverTcpIpNodeType = 46
    netBiosOverTcpIpScope = 47
    xwindowSystemFontServer = 48
    xwindowSystemDisplayManager = 49
    networkInfoServicePlusDomain = 64
    networkInfoServicePlusServers = 65
    mobileIpHomeAgent = 68
    smtpServer = 69
    pop3Server = 70
    nntpServer = 71
    defaultWwwServer = 72
    defaultFingerServer = 73
    defaultIrcServer = 74
    streetTalkServer = 75
    streetTalkDirectoryAssistanceServer = 76

    # DHCP Extensions
    requestedIpAddr = 50
    ipAddrLeaseTime = 51
    optionOverload = 52
    tftpServerName = 66
    bootfileName = 67
    dhcpMessageType = 53
    serverIdentifier = 54
    paramRequestList = 55
    message = 56
    maxDhcpMessageSize = 57
    # T1
    renewalTimeValue = 58
    # T2
    rebindingTimeValue = 59
    vendorClassIdentifier = 60
    clientIdentifier = 61


class DhcpMessageType(IntEnum):
    DISCOVER = 1
    OFFER = 2
    REQUEST = 3
    DECLINE = 4
    ACK = 5
    NAK = 6
    RELEASE = 7
    INFORM = 8


class DhcpOp(IntEnum):
    BOOTREQUEST = 1
    BOOTREPLY = 2


class DhcpMessage():
    magicCookie = b"\x63\x82\x53\x63"

    noDataOptionsSet = set([int(i) for i in DhcpNoDataOption])
    optionsSet = set([int(i) for i in DhcpOption])

    @classmethod
    def ParseDhcpOptions(cls, data:bytes):
        index = 0
        options:dict[DhcpOption,bytes] = {}
        endDetected = False

        if (len(data) >= 4) and (data[0:4] == cls.magicCookie):
            index = 4

        while index < len(data):
            code = data[index]
            index += 1
            if endDetected:
                if code != int(DhcpNoDataOption.pad):
                    raise Exception(f"{str(code)} after End Option")
            
            if code == int(DhcpNoDataOption.end):
                endDetected = True
            elif code == int(DhcpNoDataOption.pad):
                pass
            elif code in cls.optionsSet:
                codeEnum = DhcpOption(code)
                lengthVal = data[index]
                index += 1
                value = data[index:index+lengthVal]
                index += lengthVal

                if codeEnum in options.keys():
                    raise Exception(f"Duplicate option : {str(codeEnum)}")
                options[codeEnum] = value
            else:
                # TODO: handle unknown option
                # In RFC 2132 it says:
                # Any options defined subsequent to this document MUST contain a length
                # octet even if the length is fixed or zero.
                print(f"Unknown option {hex(code)}")
                lengthVal = data[index]
                value = data[index:index+lengthVal]
                index += lengthVal

        return options

    @classmethod
    def ParseDhcpMessage(cls, data:bytes):
        op = data[0:1]
        htype = data[1:2]
        hlen = data[2:3]
        hops = data[3:4]

        xid = data[4:8]

        secs = data[8:10]
        flags = data[10:12]

        ciaddr = data[12:16]

        yiaddr = data[16:20]

        siaddr = data[20:24]

        giaddr:bytes = data[24:28]

        chaddr = data[28:44]

        sname = data[44:108]

        file = data[108:236]

        options = data[236:]

        return cls(op, htype, hlen, hops, 
                 xid, 
                 secs, flags, 
                 ciaddr, 
                 yiaddr, 
                 siaddr, 
                 giaddr, 
                 chaddr, 
                 sname, 
                 file, 
                 cls.ParseDhcpOptions(options))

    def __init__(self, op, htype, hlen, hops, 
                 xid, 
                 secs, flags, 
                 ciaddr, 
                 yiaddr, 
                 siaddr, 
                 giaddr, 
                 chaddr, 
                 sname, 
                 file, 
                 options) -> None:
        self.op = op
        self.htype = htype
        self.hlen = hlen
        self.hops = hops
        self.xid = xid
        self.secs = secs
        self.flags = flags
        self.ciaddr = ciaddr
        self.yiaddr = yiaddr
        self.siaddr = siaddr
        self.giaddr = giaddr
        self.chaddr = chaddr
        self.sname = sname
        self.file = file
        self.options:dict[DhcpOption,bytes] = options

    def to_bytes(self):
        buf = BytesIO()

        for b in (
            self.op, self.htype, self.hlen, self.hops,
            self.xid,
            self.secs, self.flags,
            self.ciaddr,
            self.yiaddr,
            self.siaddr,
            self.giaddr,
            self.chaddr,
            self.sname,
            self.file,
        ):
            buf.write(b)

        if len(self.options) > 0:
            buf.write(self.magicCookie)
        for (k, v) in self.options.items():
            buf.write(int(k).to_bytes(1, byteorder="big"))
            buf.write(len(v).to_bytes(1, byteorder="big"))
            buf.write(v)

        if len(self.options) > 0:
            buf.write(int(DhcpNoDataOption.end).to_bytes(1, byteorder="big"))
        
        buf.seek(0)
        data = buf.read()
        if len(data) % 4 != 0:
            pad = int(DhcpNoDataOption.pad).to_bytes(1, byteorder="big")
            data += pad * (4 - (len(data) % 4))

        return data
        
    def __repr__(self) -> str:
        buf = StringIO()

        buf.write("== DHCP Message ==\n")
        buf.write(f"op: {zfillHex(self.op)}\n")
        buf.write(f"htype: {zfillHex(self.htype)}\n")
        buf.write(f"hlen: {zfillHex(self.hlen)}\n")
        buf.write(f"hops: {zfillHex(self.hops)}\n")
        buf.write(f"xid: {zfillHex(self.xid)}\n")
        buf.write(f"secs: {zfillHex(self.secs)}\n")
        buf.write(f"flags: {zfillHex(self.flags)}\n")
        buf.write(f"ciaddr: {zfillHex(self.ciaddr)}\n")
        buf.write(f"yiaddr: {zfillHex(self.yiaddr)}\n")
        buf.write(f"siaddr: {zfillHex(self.siaddr)}\n")
        buf.write(f"giaddr: {zfillHex(self.giaddr)}\n")
        buf.write(f"chaddr: {zfillHex(self.chaddr)}\n")
        buf.write(f"sname: {zfillHex(self.sname)}\n")
        buf.write(f"file: {zfillHex(self.file)}\n")
        
        buf.write(f"Options:")
        for k, v in self.options.items():
            match k:
                case DhcpOption.dhcpMessageType:
                    assert len(v) == 1
                    intval = v[0]
                    mesTypeStr = f"{intval} (NOT IMPLEMENTED)"
                    if intval in [int(i) for i in DhcpMessageType]:
                        mesTypeStr = f"{str(DhcpMessageType(intval))} ({intval})"
                    buf.write(f"\n{str(k)} : {mesTypeStr}")
                case DhcpOption.paramRequestList:
                    buf.write(f"\n{str(k)} ({int(k)}) :")
                    for b in v:
                        optionStr = f"{b} (NOT IMPLEMENTED)"
                        if b in self.optionsSet:
                            optionStr = str(DhcpOption(b))
                        buf.write(f"\n  > {optionStr} ({b})")
                case _:
                    buf.write(f"\n{str(k)} ({int(k)}) : {zfillHex(v)}")

        buf.seek(0)
        return buf.read()