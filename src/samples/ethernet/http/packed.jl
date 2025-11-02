function generateLinkLocalIpClaimerSystem(probe_timeout_cycle, probe_initial_wait_cycle, second_announce_wait_cycle, name)
    varp, _ = generateArpMessageBlock("llipv4sys_$name")
    varptop = varp[begin]
    buf = generateBufferWithReadRandomAccess("llipv4sys_$name")
    linklocalipclaimer = generateLinkLocalIpClaimer(probe_timeout_cycle, probe_initial_wait_cycle, second_announce_wait_cycle, "llipv4sys_$name")

    dummyIo = Vmodule("dummyio_llipv4sys_$name")
    vpush!(dummyIo, @ports (
        @in dummy1_1, dummy1_2;
        @in 13 dummy13_1;
        @in 72 dummy72_1, dummy72_2;
    ))

    g = Vmodgraph()

    g(
        buf => linklocalipclaimer,
        @pconnect (
            dfp_arready => rx_arready,
            dfp_rvalid => rx_rvalid,
            dfp_rinvalid => rx_rinvalid,
            dfp_rdata => rx_rdata,
            dfp_full => rx_full
        )
    )
    g(
        linklocalipclaimer => buf,
        @pconnect (
            rx_araddr => dfp_araddr,
            rx_flush => dfp_flush,
            rx_arvalid => dfp_arvalid
        )
    )

    g(
        linklocalipclaimer => varptop,
        @pconnect (
            tx_destMacAddr => destMacAddr,
            tx_etherType => etherType,
            tx_opcode => opcode,
            tx_senderIpAddr => senderProtAddr,
            tx_targetIpAddr => targetProtAddr,
            tx_etherFrameCommandValid => commandValid,
            tx_arpReqCommandValid => arp_command_valid
        )
    )
    g(
        varptop => linklocalipclaimer,
        @pconnect (
            commandReady => tx_etherFrameCommandReady,
            arp_command_ready => tx_arpReqCommandReady
        )
    )

    g(
        buf => dummyIo,
        @pconnect (
            debug_data => dummy72_1,
            debug_valid => dummy1_1,
            stored_length => dummy13_1
        )
    )
    g(
        linklocalipclaimer => dummyIo,
        @pconnect (
            debug_data => dummy72_2,
            debug_valid => dummy1_2
        )
    )

    vall = layer2vmod!(g, false, name="linkLocalIpClaimerSystem_$name")
    append!(vall, varp[2:end])

    return vall, g
end

function generateIcmpEchoServerSystem(name)
    recvParser = generateIcmpRecvParser("echosys_$name")
    echoServer = generateIcmpEchoServer("echosys_$name")
    vmessage, _ = generateEchoMessageBlock("echosys_$name")
    echoMessage = vmessage[begin]

    buf = generateBufferWithReadRandomAccess("echosys_$name")

    dummyIo = Vmodule("dummyio_echosys_$name")
    vpush!(dummyIo, @ports (
        @in dummy1_1, dummy1_2;
        @in 8 dummy8_1;
        @in 16 dummy16_1;
        @in 72 dummy72_1;
    ))

    g = Vmodgraph()

    g(
        recvParser => buf,
        @pconnect (
            dfp_valid => ufp_wvalid,
            dfp_last => ufp_wlast,
            dfp_data => ufp_wdata
        )
    )
    g(
        buf => recvParser,
        @pconnect (
            ufp_wready => dfp_ready
        )
    )

    g(
        recvParser => echoServer,
        @pconnect (
            total_length_data => rx_total_length_data,
            src_addr => rx_src_ipaddr,
            dest_addr => rx_dest_ipaddr,
            no_data_payload => rx_no_data_payload,
            _type => rx_type,
            identifier => rx_identifier,
            sequence_number => rx_sequence_number,
            checksum_data_only => rx_checksum_data_only,
            info_valid => rx_icmp_info_valid
        )
    )
    g(
        echoServer => recvParser,
        @pconnect (
            rx_icmp_info_ready => info_ready
        )
    )

    g(
        buf => echoServer,
        @pconnect (
            dfp_arready => rx_data_arready,
            dfp_rvalid => rx_data_valid,
            dfp_rinvalid => rx_data_invalid,
            dfp_rdata => rx_data,
            dfp_full => rx_data_full,
            stored_length => rx_data_count
        )
    )
    g(
        echoServer => buf,
        @pconnect (
            rx_data_araddr => dfp_araddr,
            rx_data_arvalid => dfp_arvalid,
            rx_data_flush => dfp_flush
        )
    )

    g(
        echoServer => echoMessage,
        @pconnect (
            tx_type => _type,
            tx_code => code,
            tx_total_length_data => total_length_data,
            tx_sequence_number => sequence_number,
            tx_identifier => identifier,
            tx_checksum_data_only => checksum_data,
            tx_icmp_misc_valid => ufp_misc_valid,
            tx_icmp_data_valid => ufp_valid,
            tx_icmp_data_last => ufp_last,
            tx_icmp_data => ufp_data,
            tx_src_ipaddr => sourceAddr,
            tx_dest_ipaddr => destAddr,
            tx_ipaddr_valid => ufp_addr_valid,
            tx_dest_hwaddr => destMacAddr,
            tx_hwaddr_valid => commandValid,
        )
    )
    g(
        echoMessage => echoServer,
        @pconnect (
            ufp_addr_ready => tx_ipaddr_ready,
            commandReady => tx_hwaddr_ready,
            ufp_ready => tx_icmp_data_ready,
            ufp_misc_ready => tx_icmp_misc_ready
        )
    )

    g(
        recvParser => dummyIo,
        @pconnect (
            code => dummy8_1,
            checksum => dummy16_1,
            info_core_valid => dummy1_1
        )
    )
    g(
        buf => dummyIo,
        @pconnect (
            debug_valid => dummy1_2,
            debug_data => dummy72_1
        )
    )

    vs = layer2vmod!(g, false, name="icmpEchoSystem_$name")
    append!(vs, vmessage[2:end])
    
    return vs, g
end


function generateSimpleTcpServerSystem(name)
    g = Vmodgraph()

    server = generateSimpleTcpServer("simTcpSrvSys_$name")
    rcvparser = generateTcpRecvParser("simTcpSrvSys_$name")
    vsendblock, _ = generateTcpPacketSendBlock("simTcpSrvSys_$name")
    sender = vsendblock[begin]

    dummyIo = Vmodule("dummyio_tcpsrvsys_$name")
    vpush!(dummyIo, @ports (
        # @in dummyin1_1, dummyin1_2;
        # @in 2 dummyin2_1;
        # @in 32 dummyin32_1;
        # @out @logic dummyout1_1, dummyout1_0;
        @out @logic 16 dummyout16_80;
        # @out @logic 32 dummyout32_0;
    ))
    vpush!(dummyIo, @always (
        # dummyout1_1 = 1;
        # dummyout1_0 = 0;
        dummyout16_80 = 80;
        # dummyout32_0 = 0;
    ))

    macLoopBack = Vmodule("macLoopBack_tcpsrvsys_$name")
    vpush!(macLoopBack, @ports (
        @in CLK,RST;
        @in ufp_hwaddr_valid;
        @out @logic dfp_valid;
        @in dfp_ready;
        @in 48 ufp_hwaddr;
        @out @logic 48 dfp_hwaddr;

        @in tx_misc_valid, tx_misc_ready;
    ))
    vpush!(macLoopBack, (@cpalways (
        if tx_misc_valid & tx_misc_ready
            # 32 bit is enough, for this logic is removed in the future (after implementing arp table)
            tx_trans_count <= $(Wireexpr(32, 1)) + tx_trans_count
        end;
        if dfp_ready & dfp_valid
            ether_trans_count <= ether_trans_count + $(Wireexpr(32, 1))
        end;
        if ufp_hwaddr_valid
            dfp_hwaddr <= ufp_hwaddr
        end;
        dfp_valid = ~(tx_trans_count == ether_trans_count)
    ))...)

    g(
        dummyIo => server,
        @pconnect (
            dummyout16_80 => config_src_port
        )
    )
    g(
        server => macLoopBack,
        @pconnect (tx_misc_valid => tx_misc_valid)
    )
    g(
        macLoopBack => sender,
        @pconnect (
            dfp_valid => commandValid,
            dfp_hwaddr => destMacAddr
        )
    )
    g(
        sender => macLoopBack,
        @pconnect (
            commandReady => dfp_ready,
            ufp_misc_ready => tx_misc_ready
        )
    )

    g(
        rcvparser => server,
        @pconnect (
            dfp_valid => rx_data_valid,
            dfp_last => rx_data_last,
            dfp_data => rx_data,
            src_addr => rx_src_addr,
            dest_addr => rx_dest_addr,
            dfp_no_data_payload => rx_no_data_payload,
            src_port => rx_src_port,
            dest_port => rx_dest_port,
            seq_number => rx_seq_number,
            ack_number => rx_ack_number,
            flags => rx_flags,
            window => rx_window,
            checksum => rx_checksum,
            urg_pointer => rx_urg_pointer,
            payload_length => rx_payload_length,
            info_valid => rx_misc_valid
        )
    )
    g(
        server => rcvparser,
        @pconnect (
            rx_misc_ready => info_ready,
            rx_data_ready => dfp_ready
        )
    )

    g(
        server => sender,
        @pconnect (
            tx_misc_valid => ufp_misc_valid,
            tx_src_addr => src_addr,
            tx_dest_addr => dest_addr,
            tx_src_port => src_port,
            tx_dest_port => dest_port,
            tx_seq_number => seq_number,
            tx_ack_number => ack_number,
            tx_flags => flags,
            tx_window => window,
            tx_urg_pointer => urg_pointer,
            tx_checksum_data_only => checksum_data_only,
            tx_total_length_data_only => total_length_data_only,
            tx_data_valid => ufp_data_valid,
            tx_data_last => ufp_data_last,
            tx_data => ufp_data,
        )
    )
    g(
        sender => server,
        @pconnect (
            ufp_misc_ready => tx_misc_ready,
            ufp_data_ready => tx_data_ready
        )
    )

    vall = layer2vmod!(g, false, name="TcpServerSystem_$name")
    append!(vall, vsendblock[2:end])

    return vall, g
end

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
