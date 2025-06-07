"""Utility module to communicate with axi-passthrough verilog module generated in this directory.

UART output from the verilog module offered in this sample directory
is currently implementation detail.

TODO: Define IO format in a readable manner (e.g. using Protocol Buffers)
"""

import time

from functools import reduce
from io import BytesIO
from typing import Union

import serial


def SendOneInstruction(ser:serial.Serial, opcode, addr, data:Union[int,bytes]):
    if opcode not in (1, 2):
        raise Exception("invalid opcode")
    
    opcodeBytes = opcode.to_bytes(1, "little")
    addrBytes = addr.to_bytes(2, "little")
    dataBytes = data
    if isinstance(data, int):
        dataBytes = data.to_bytes(4, "little")
    else:
        if not isinstance(data, bytes):
            raise Exception(f"type {type(data)} is not acceptable")
    
    dataAll = opcodeBytes + addrBytes + dataBytes
    ser.write(dataAll)
    return


def InvertByteOrderOfAsciiEncodedHexWord(data:bytes) -> bytes:
    return data[6:8] + data[4:6] + data[2:4] + data[0:2]


def UartOutDataToBytes(uartOutData:list) -> bytes:
    data = []
    for b in uartOutData:
        data.append(b[-2-8:-2])

    data = [InvertByteOrderOfAsciiEncodedHexWord(b) for b in data]

    asciiHex = reduce(lambda x,y : x+y, data)

    buf = BytesIO()
    for i in range(len(asciiHex) >> 1):
        byteNow = asciiHex[i<<1:(i+1)<<1]
        buf.write(int(byteNow, base=16).to_bytes(1, "little"))

    buf.seek(0)
    return buf.read()


def ReadOneWord(ser, addr) -> bytes:
    SendOneInstruction(ser, 2, addr, 0)
    return UartOutDataToBytes([ser.readline()])


def UpdateRecvPacket(ser:serial.Serial) -> bytes:
    regAddr = 0x17fc
    value = 0
    SendOneInstruction(ser, 1, regAddr, value)
    v = ser.readline()
    return v


def IsRecvPacketExist(ser:serial.Serial) -> int:
    addr = 0x17fc
    return int.from_bytes(ReadOneWord(ser, addr), byteorder="little")

def GetRecvEtherType(ser:serial.Serial):
    addr = 0x100C
    data = ReadOneWord(ser, addr)
    etherType = data[0:2]
    return int.from_bytes(etherType, byteorder="big")


def GetRecvIpTotalLength(ser:serial.Serial):
    # TODO: check VLAN tag and calculate correct offset
    addr = 0x1010
    b = ReadOneWord(ser, addr)
    return int.from_bytes(b[0:2], byteorder="big")


def GetRecvIpProtocol(ser:serial.Serial):
    # TODO: check VLAN tag
    addr = 0x1014
    b = ReadOneWord(ser, addr)
    return b[3]


def GetRecvUdpDestPort(ser:serial.Serial):
    # TODO: check VLAN tag and IHL, then calculate correct offset
    # UNTESTED
    addr = 0x1024
    w = ReadOneWord(ser, addr)
    return int.from_bytes(w[0:2], byteorder="big")


def ReadRecvPacketRaw(ser) -> list[bytes]:
    """Stack list of uart output bytes which are the result
    of reading the packet in ether mac core.
    """
    addrBase = 0x1000
    recvPacket = []

    words = 20
    etherType = GetRecvEtherType(ser)
    if etherType == 0x0800:
        ipTotalLength = GetRecvIpTotalLength(ser)
        ipLegthInWords = ipTotalLength >> 2
        words = 4 + ipLegthInWords
        print(f"IP Packet detected, read 4 + {words - 4} words (totalLength = {hex(ipTotalLength)[2:].upper().zfill(4)} ({ipTotalLength}))")

    # Last 4 nibbles may contain non zero value which derive from previous packet
    for i in range(words):
        SendOneInstruction(ser, 2, addrBase + i*4, 0)
        recvPacket.append(ser.readline())

    return recvPacket


def ReadRecvPacket(ser:serial.Serial) -> bytes:
    """Read packet and concatenate into one bytes object."""
    recvPacketRaw = ReadRecvPacketRaw(ser)
    u = UartOutDataToBytes(recvPacketRaw)
    return u
    

def WaitForDhcpPacket(ser:serial.Serial, initialUpdate=False):
    if initialUpdate:
        UpdateRecvPacket(ser)

    itermax = 500
    count = 0
    while True:
        if IsRecvPacketExist(ser) == 1:
            if GetRecvEtherType(ser) == 0x0800:
                if GetRecvIpProtocol(ser) == 17:
                    if GetRecvUdpDestPort(ser) in (67, 68):
                        print("DHCP detected")
                        return ReadRecvPacket(ser)
                    else:
                        print("UDP packet other than DHCP")
                else:
                    print(f"IP packet other than UDP")
            else:
                print("Ethernet Frame other than IP packet")

            UpdateRecvPacket(ser)
        else:
            print("No Packet Detected")
        
        count += 1
        if count > itermax:
            raise Exception("Iteration reached upper limit")
        
        time.sleep(0.05)
        

def SendEtherFrame(ser:serial.Serial, data:bytes):
    originalLen = len(data)
    data = data + (b"\x00" * ((4 - (len(data) % 4)) % 4))
    for i in range(len(data) >> 2):
        b = data[i<<2:(i+1)<<2]
        SendOneInstruction(ser, 1, i << 2, b)
    
    SendOneInstruction(ser, 1, 0x07F4, originalLen)
    SendOneInstruction(ser, 1, 0x07FC, 1)
    return
