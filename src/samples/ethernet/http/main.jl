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
    varpreqgen = generateArpMessageGenerator()

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
    buf = generateEtherFrameTxBuffer("echo")
    ethergen = generateEtherFrameGenerator("echo")
    ipgen = generateIpPacketSimpleGenerator()
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
            totalLength => totalLength
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
    vbuf = generateEtherFrameTxBuffer("recv")
    vrecvsel = generateRecvBufferSelector()
    vinter = generateControllerRecvInterface()

    g = Vmodgraph()

    g(
        vinter => vbuf,
        @pconnect (
            dfp_valid => ufp_valid,
            dfp_data => ufp_data,
            dfp_last => ufp_last
        )
    )
    g(
        vbuf => vinter,
        @pconnect (
            ufp_ready => dfp_ready
        )
    )
    g(
        vinter => vrecvsel,
        @pconnect (
            dfp_valid => ufp_wvalid,
            dfp_data => ufp_wdata,
            dfp_last => ufp_wlast
        )
    )

    g(
        vbuf => vrecvsel,
        @pconnect (
            ufp_ready => ufp_wready,

            dfp_awlen => bufout_awlen,
            dfp_awvalid => bufout_awvalid,

            dfp_wvalid => bufout_wvalid,
            dfp_wdata => bufout_wdata,
            dfp_wlast => bufout_wlast
        )
    )
    g(
        vrecvsel => vbuf,
        @pconnect (
            bufout_wready => dfp_wready,
            bufout_awready => dfp_awready,
        )
    )

    vs = layer2vmod!(g, name="RecvSelector")
    vs = vfinalize(vs)
    vexport(vs)
    wrapper = wrappergen(vs[begin])
    vexport("$(getname(wrapper)).v", wrapper)

    txt = dotgen(g)
    run(pipeline(`dot -Tpng -oRecvSelector.png`, stdin=IOBuffer(txt)))


    vendbuf = generateBufferWithReadRandomAccess()
    vendbuf = vfinalize(vendbuf)
    vexport(vendbuf)
    wrapper = wrappergen(vendbuf)
    vexport("$(getname(wrapper)).v", wrapper)
end


let
    v = generateLinkLocalIpClaimer(100, 100, 50)
    v = generateLinkLocalIpClaimer(13 << 23, 7 << 24, 14 << 23)

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
