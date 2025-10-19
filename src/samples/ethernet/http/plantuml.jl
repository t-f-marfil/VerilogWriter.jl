let
    open("samples/ethernet/http/diagram/src/ArpMessageBlock.pu", "w") do io
        _, g = generateArpMessageBlock("pu")
        umlgen!(io, g)
    end

    open("samples/ethernet/http/diagram/src/LinkLocalIpClaimerSystem.pu", "w") do io
        _, g = generateLinkLocalIpClaimerSystem(13 << 23, 7 << 24, 14 << 23,"pu")
        umlgen!(io, g)
    end

    open("samples/ethernet/http/diagram/src/EchoMessageBlock.pu", "w") do io
        _, g = generateEchoMessageBlock("pu")
        umlgen!(io, g)
    end

    open("samples/ethernet/http/diagram/src/IcmpEchoServerSystem.pu", "w") do io
        _, g = generateIcmpEchoServerSystem("pu")
        umlgen!(io, g)
    end

    open("samples/ethernet/http/diagram/src/TcpPacketSendBlock.pu", "w") do io
        _, g = generateTcpPacketSendBlock("pu")
        umlgen!(io, g)
    end

    open("samples/ethernet/http/diagram/src/SimpleTcpServerSystem.pu", "w") do io
        _, g = generateSimpleTcpServerSystem("pu")
        umlgen!(io, g)
    end

    open("samples/ethernet/http/diagram/src/SimpleNetworkSystem.pu", "w") do io
        _, g = generateSimpleNetworkSystem("pu")
        umlgen!(io, g)
    end
end