let
    # etherController
    generateAsciiEncoderForServer()
    generateServerAll()
end


let
    sampleEtherRequestGen()

    v = generateBufferSelector(3)
    v = vfinalize(v)
    vexport(v)
    wrapper = wrappergen(v)
    vexport("$(getname(wrapper)).v", wrapper)
    
    vbuf = generateEtherFrameTxBuffer("arp")
    vethergen = generateEtherFrameGenerator("arp")
    # varpreqgen = generateArpRequestGenerator()
    varpreqgen = generateArpMessageGenerator("arp")

    g = Vmodgraph()

    g(
        varpreqgen => vethergen,
        @pconnect (
            wdata => wdata_in,
            wvalid => wvalid_in,
            wlast => wlast_in
        )
    )
    g(
        vethergen => varpreqgen,
        @pconnect (
            wready_out => wready
        )
    )

    g(
        vethergen => vbuf,
        @pconnect (
            wvalid => ufp_valid,
            wdata => ufp_data,
            wlast => ufp_last
        )
    )
    g(
        vbuf => vethergen,
        @pconnect (
            ufp_ready => wready
        )
    )
    
    vs = layer2vmod!(g, name="ArpRequestBlock")
    vs = vfinalize(vs)
    
    vexport(vs)
    wrapper = wrappergen(vs[begin])
    vexport("$(getname(wrapper)).v", wrapper)

    txt = dotgen(g)
    cmd = `dot -Tpng -oEtherReq.png`
    run(pipeline(cmd, stdin=IOBuffer(txt)))
end


let
    buf = generateEtherFrameTxBuffer("echoreq")
    ethergen = generateEtherFrameGenerator("echoreq")
    ipgen = generateIpPacketSimpleGenerator("echoreq")
    echogen = generateIcmpEchoRequestGenerator()

    g = Vmodgraph()
    g(
        ethergen => buf,
        @pconnect (
            wvalid => ufp_valid,
            wdata => ufp_data,
            wlast => ufp_last
        )
    )
    g(
        buf => ethergen,
        @pconnect (
            ufp_ready => wready
        )
    )


    g(
        ipgen => ethergen,
        @pconnect (
            wdata => wdata_in,
            wvalid => wvalid_in,
            wlast => wlast_in,
            etherType => etherType
        )
    )
    g(
        ethergen => ipgen,
        @pconnect (
            wready_out => wready
        )
    )

    g(
        echogen => ipgen,
        @pconnect (
            wdata => wdata_in,
            wvalid => wvalid_in,
            wlast => wlast_in,

            protocol => protocol,
            totalLength => totalLengthData
        )
    )
    g(
        ipgen => echogen,
        @pconnect (
            wready_out => wready
        )
    )

    vs = layer2vmod!(g, name="EchoRequestBlock")
    vs = vfinalize(vs)

    vexport(vs)
    wrapper = wrappergen(vs[begin])
    vexport("$(getname(wrapper)).v", wrapper)


    v = sampleEchoRequestGen()
    v = vfinalize(v)
    wrapper = wrappergen(v)
    vexport(v)
    vexport("$(getname(wrapper)).v", wrapper)
end

let
    v = generateRecvBufferSelector()
    v = vfinalize(v)

    wrapper = wrappergen(v)

    vexport(v)
    vexport("$(getname(v))_wrapper.v", wrapper)


    vendbuf = generateBufferWithReadRandomAccess("etherrecv")
    vendbuf = vfinalize(vendbuf)
    vexport(vendbuf)
    wrapper = wrappergen(vendbuf)
    vexport("$(getname(wrapper)).v", wrapper)
end


let
    v = generateLinkLocalIpClaimer(100, 100, 50, "")
    v = generateLinkLocalIpClaimer(13 << 23, 7 << 24, 14 << 23, "")

    v = vfinalize(v)
    wrapper = wrappergen(v)

    vexport(v)
    vexport("$(getname(v))_wrapper.v", wrapper)
end


let
    v = vfinalize(generateSampleArpFrameBuffer())
    wrapper = wrappergen(v)

    vexport(v)
    vexport("$(getname(v))_wrapper.v", wrapper)
end

let
    vipv4sel = generateIpv4BufferSelector() |> vfinalize

    vicmprecv = generateIcmpRecvParser("") |> vfinalize

    vexport(vipv4sel)
    wrapper = wrappergen(vipv4sel)
    vexport("$(getname(wrapper)).v", wrapper)

    vexport(vicmprecv)
    wrapper = wrappergen(vicmprecv)
    vexport("$(getname(wrapper)).v", wrapper)
end

let
    v = generateSampleIcmpEchoRequestBuffer() |> vfinalize
    vexport(v)
    wrapper = wrappergen(v)
    vexport("$(getname(wrapper)).v", wrapper)
end


let
    vs = generateEchoMessageBlock("")
    vs = vfinalize(vs)

    vexport(vs)
    wrapper = wrappergen(vs[begin])
    vexport("$(getname(wrapper)).v", wrapper)
    

    v = generateSampleEchoMessageGenerator() |> vfinalize
    vexport(v)
    wrapper = wrappergen(v)
    vexport("$(getname(v))_wrapper.v", wrapper)
end


let
    v = generateIcmpEchoServer("") |> vfinalize
    vexport(v)

    wrapper = wrappergen(v)
    vexport("$(getname(wrapper)).v", wrapper)
end

let
    vs = generateLinkLocalIpClaimerSystem("1")
    vs = vfinalize(vs)

    vexport(vs)

    wrapper = wrappergen(vs[begin])
    vexport("$(getname(wrapper)).v", wrapper)
end


let
    vs = generateIcmpEchoServerSystem("1")
    vs = vfinalize(vs)
    vexport(vs)

    wrapper = wrappergen(vs[begin])
    vexport("$(getname(wrapper)).v", wrapper)
end

let
    v = generateTcpRecvParser("1") |> vfinalize
    vexport(v)

    wrapper = wrappergen(v)
    vexport("$(getname(wrapper)).v", wrapper)


    v = generateSampleTcpPacketBuffer() |> vfinalize
    vexport(v)

    wrapper = wrappergen(v)
    vexport("$(getname(wrapper)).v", wrapper)
end

let
    vs = generateTcpPacketSendBlock("1") |> vfinalize

    vexport(vs)

    wrapper = wrappergen(vs[begin])
    vexport("$(getname(wrapper)).v", wrapper)


    v = generateSampleTcpSendCommand() |> vfinalize
    vexport(v)

    wrapper = wrappergen(v)
    vexport("$(getname(wrapper)).v", wrapper)

end

let
    vsys = generateSimpleTcpServerSystem("1") |> vfinalize
    vexport(vsys)

    wrapper = wrappergen(vsys[begin])
    vexport("$(getname(wrapper)).v", wrapper)
end
