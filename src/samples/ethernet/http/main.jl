function generateSimpleNetworkSystem(name)
    g = Vmodgraph()
    name = "snsys_$name"
    vmisc = Vector{Vmodule}(undef, 0)

    # generate Vmodule

    ## dummy IO to suppress port lifting
    dummyIo = Vmodule("dummyio_$name")

    ## rx parsing
    etherBufferSelector = generateRecvBufferSelector(name)
    ipv4BufferSelector = generateIpv4BufferSelector(name)

    packetbuf_icmp = generateBramFifo("icmp_$name")
    packetbuf_tcp = generateBramFifo("tcp_$name")

    ## tx buffer selector
    txBufferSelector = generateBufferSelector(3, name)

    ## core
    ### link local ip
    probe_timeout_cycle, probe_initial_wait_cycle, second_announce_wait_cycle = 13 << 23, 7 << 24, 14 << 23
    # probe_timeout_cycle, probe_initial_wait_cycle, second_announce_wait_cycle = 100, 100, 50 # for simulation
    linkLocalIpClaimerVmods, _ = generateLinkLocalIpClaimerSystem(probe_timeout_cycle, probe_initial_wait_cycle, second_announce_wait_cycle, name)
    linkLocalIpClaimer = linkLocalIpClaimerVmods[begin]
    vmisc = vcat(vmisc, linkLocalIpClaimerVmods[2:end])

    ### ICMP Echo reply
    icmpEchoServerVmods, _ = generateIcmpEchoServerSystem(name)
    icmpEchoServer = icmpEchoServerVmods[begin]
    vmisc = vcat(vmisc, icmpEchoServerVmods[2:end])

    ### tcp server
    tcpServerVmods, _ = generateSimpleTcpServerSystem(name)
    tcpServer = tcpServerVmods[begin]
    vmisc = vcat(vmisc, tcpServerVmods[2:end])


    ### http server
    data = nothing
    open(joinpath(dirname(@__FILE__), "sample_response.txt")) do io
        data = read(io)
    end
    httpServer = generateHttpResponseGenerator(data, name)

    # Connect all
    ## rx parsing
    ### ether buffer selector to ipv4 buffer selector
    g(
        etherBufferSelector => ipv4BufferSelector,
        @pconnect (
            dest_addr => ether_dest_addr_in,
            src_addr => ether_src_addr_in,

            dfp_valid_ipv4 => ufp_valid,
            dfp_data_ipv4 => ufp_data,
            dfp_last_ipv4 => ufp_last
        )
    )
    g(
        ipv4BufferSelector => etherBufferSelector,
        @pconnect (
            ufp_ready => dfp_ready_ipv4
        )
    )

    ### ipv4 buffer selector to FIFO
    g(
        ipv4BufferSelector => packetbuf_icmp,
        @pconnect (
            dfp_valid_icmp => wvalid,
            dfp_data_icmp => wdata,
            dfp_last_icmp => wlast
        )
    )
    g(
        packetbuf_icmp => ipv4BufferSelector,
        @pconnect (
            wready => dfp_ready_icmp
        )
    )

    g(
        ipv4BufferSelector => packetbuf_tcp,
        @pconnect (
            dfp_valid_tcp => wvalid,
            dfp_data_tcp => wdata,
            dfp_last_tcp => wlast
        )
    )
    g(
        packetbuf_tcp => ipv4BufferSelector,
        @pconnect (
            wready => dfp_ready_tcp
        )
    )

    ## core
    ### link local ip
    #### directly connect to ether buffer selector for now
    # TODO: share arp packet with other modules
    g(
        etherBufferSelector => linkLocalIpClaimer,
        @pconnect (
            dfp_valid_arp => ufp_wvalid,
            dfp_data_arp => ufp_wdata,
            dfp_last_arp => ufp_wlast,
        )
    )
    g(
        linkLocalIpClaimer => etherBufferSelector,
        @pconnect (
            ufp_wready => dfp_ready_arp
        )
    )

    #### to tx selector
    g(
        linkLocalIpClaimer => txBufferSelector,
        @pconnect (
            dfp_awvalid => ufp_awvalid_1,
            dfp_awlen => ufp_awlen_1,
            dfp_wvalid => ufp_wvalid_1,
            dfp_wdata => ufp_wdata_1,
            dfp_wlast => ufp_wlast_1
        )
    )
    g(
        txBufferSelector => linkLocalIpClaimer,
        @pconnect (
            ufp_awready_1 => dfp_awready,
            ufp_wready_1 => dfp_wready
        )
    )

    ### ICMP Echo Server
    #### configure ip address
    g(
        linkLocalIpClaimer => icmpEchoServer,
        @pconnect (
            ip_addr_valid => ip_addr_configured,
            ip_addr => configured_ip_addr,
        )
    )

    #### data from buffer
    g(
        packetbuf_icmp => icmpEchoServer,
        @pconnect (
            rvalid => ufp_valid,
            rdata => ufp_data,
            rlast => ufp_last,

            # for hwaddr configuration, remove this when arp cache is implemented
            rlast => rx_icmp_last
        )
    )
    g(
        icmpEchoServer => packetbuf_icmp,
        @pconnect (
            ufp_ready => rready
        )
    )

    #### misc from ipv4 selector
    g(
        ipv4BufferSelector => icmpEchoServer,
        @pconnect (
            total_length_data => ufp_total_length_data,
            source_address => ufp_src_addr,
            destination_address => ufp_dest_addr,

            # TODO: remove this after implementing arp cache
            ether_src_addr_out => rx_src_hwaddr,
            ether_dest_addr_out => rx_dest_hwaddr
        )
    )
    
    #### to tx selector
    g(
        icmpEchoServer => txBufferSelector,
        @pconnect (
            dfp_awvalid => ufp_awvalid_2,
            dfp_awlen => ufp_awlen_2,
            dfp_wvalid => ufp_wvalid_2,
            dfp_wdata => ufp_wdata_2,
            dfp_wlast => ufp_wlast_2
        )
    )
    g(
        txBufferSelector => icmpEchoServer,
        @pconnect (
            ufp_awready_2 => dfp_awready,
            ufp_wready_2 => dfp_wready
        )
    )

    ### TCP Server
    #### configure ip address
    g(
        linkLocalIpClaimer => tcpServer,
        @pconnect (
            ip_addr_valid => config_valid,
            ip_addr => config_src_addr
        )
    )

    #### data from buffer
    g(
        packetbuf_tcp => tcpServer,
        @pconnect (
            rvalid => ufp_valid,
            rdata => ufp_data,
            rlast => ufp_last
        )
    )
    g(
        tcpServer => packetbuf_tcp,
        @pconnect (
            ufp_ready => rready
        )
    )

    #### misc from ipv4 buffer selector
    g(
        ipv4BufferSelector => tcpServer,
        @pconnect (
            total_length_data => ufp_total_length_data,
            source_address => ufp_src_addr,
            destination_address => ufp_dest_addr,

            # TODO: remove this after implementing arp cache
            ether_src_addr_out => ufp_hwaddr,
            dfp_valid_tcp => ufp_hwaddr_valid
        )
    )

    #### to tx selector
    g(
        tcpServer => txBufferSelector,
        @pconnect (
            dfp_awvalid => ufp_awvalid_3,
            dfp_awlen => ufp_awlen_3,
            dfp_wvalid => ufp_wvalid_3,
            dfp_wdata => ufp_wdata_3,
            dfp_wlast => ufp_wlast_3
        )
    )
    g(
        txBufferSelector => tcpServer,
        @pconnect (
            ufp_awready_3 => dfp_awready,
            ufp_wready_3 => dfp_wready
        )
    )

    ### http server
    g(
        tcpServer => httpServer,
        @pconnect (
            dfp_rx_data_valid => rx_valid,
            dfp_rx_data => rx_data,
            dfp_rx_data_strb => rx_strb,

            ufp_tx_data_ready => tx_ready
        )
    )
    g(
        httpServer => tcpServer,
        @pconnect (
            rx_ready => dfp_rx_data_ready,

            tx_valid => ufp_tx_data_valid,
            tx_last => ufp_tx_data_last,
            tx_data => ufp_tx_data,
            tx_checksum => ufp_tx_checksum_data_only,
            tx_total_length => ufp_tx_total_length_data_only
        )
    )

    ### Unused ports
    vpush!(dummyIo, @ports (
        @in dummy1_1, dummy1_2, dummy1_3, dummy1_4, dummy1_5, dummy1_6;
        @in 72 dummy72_1, dummy72_2, dummy72_3, dummy72_4, dummy72_5, dummy72_6;
    ))
    g(
        etherBufferSelector => dummyIo,
        @pconnect (
            debug_valid => dummy1_1,
            debug_data => dummy72_1
        )
    )
    g(
        ipv4BufferSelector => dummyIo,
        @pconnect (
            debug_valid => dummy1_2,
            debug_data => dummy72_2
        )
    )
    g(
        icmpEchoServer => dummyIo,
        @pconnect (
            debug_valid => dummy1_3,
            debug_data => dummy72_3
        )
    )
    g(
        tcpServer => dummyIo,
        @pconnect (
            debug_valid => dummy1_4,
            debug_data => dummy72_4,

            debug_valid_rcvparse => dummy1_5,
            debug_data_rcvparse => dummy72_5
        )
    )
    g(
        txBufferSelector => dummyIo,
        @pconnect (
            debug_valid => dummy1_6,
            debug_data => dummy72_6
        )
    )

    return vmisc, g
end

let
    vmisc, g = generateSimpleNetworkSystem("1")
    vmods = layer2vmod!(g, false, name="SimpleNetworkSystem")
    vmods = vcat(vmods, vmisc)

    vmods = vfinalize(vmods)
    vexport(vmods)

    wrapper = wrappergen(vmods[begin])
    vexport("$(getname(wrapper)).v", wrapper)

    open("$(getname(vmods[begin])).pu", "w") do io
        umlgen!(io, g)
    end
end
