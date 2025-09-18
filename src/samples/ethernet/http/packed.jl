function generateLinkLocalIpClaimerSystem(name)
    varp = generateArpMessageBlock("llipv4sys_$name")
    varptop = varp[begin]
    buf = generateBufferWithReadRandomAccess("llipv4sys_$name")
    linklocalipclaimer = generateLinkLocalIpClaimer(13 << 23, 7 << 24, 14 << 23, "llipv4sys_$name")

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

    return vall
end

function generateIcmpEchoServerSystem(name)
    recvParser = generateIcmpRecvParser("echosys_$name")
    echoServer = generateIcmpEchoServer("echosys_$name")
    vmessage = generateEchoMessageBlock("echosys_$name")
    echoMessage = vmessage[begin]

    buf = generateBufferWithReadRandomAccess("echosys_$name")

    dummyIo = Vmodule("dummyio_echosys_$name")
    vpush!(dummyIo, @ports (
        @in dummy1_1, dummy1_2, dummy1_3;
        @in 8 dummy8_1;
        @in 16 dummy16_1;
        @in 72 dummy72_1, dummy72_2;
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
    g(
        echoServer => dummyIo,
        @pconnect (
            debug_valid => dummy1_3,
            debug_data => dummy72_2
        )
    )

    vs = layer2vmod!(g, false, name="icmpEchoSystem_$name")
    append!(vs, vmessage[2:end])
    
    return vs
end


function generateSimpleTcpServerSystem(name)
    g = Vmodgraph()

    server = generateSimpleTcpServer("simTcpSrvSys_$name")
    rcvparser = generateTcpRecvParser("simTcpSrvSys_$name")
    vsendblock = generateTcpPacketSendBlock("simTcpSrvSys_$name")
    sender = vsendblock[begin]

    dummyIo = Vmodule("dummyio_tcpsrvsys_$name")
    vpush!(dummyIo, @ports (
        @in dummyin1_1, dummyin1_2;
        @in 2 dummyin2_1;
        @in 32 dummyin32_1;
        @out @logic dummyout1_1, dummyout1_0;
        @out @logic 16 dummyout16_128;
        @out @logic 32 dummyout32_0;
    ))
    vpush!(dummyIo, @always (
        dummyout1_1 = 1;
        dummyout1_0 = 0;
        dummyout16_128 = 0x80;
        dummyout32_0 = 0;
    ))

    macLoopBack = Vmodule("macLoopBack_tcpsrvsys_$name")
    vpush!(macLoopBack, @ports (
        @in CLK,RST;
        @in ufp_hwaddr_valid;
        @out @logic dfp_valid;
        @in dfp_ready;
        @in 48 ufp_hwaddr;
        @out @logic 48 dfp_hwaddr;
    ))
    vpush!(macLoopBack, @always (
        if ufp_hwaddr_valid
            dfp_hwaddr <= ufp_hwaddr
            dfp_valid <= 1
        end
    ))

    g(
        server => dummyIo,
        @pconnect (
            dfp_rx_data => dummyin32_1,
            dfp_rx_data_strb => dummyin2_1,
            dfp_rx_data_valid => dummyin1_1,

            ufp_tx_data_ready => dummyin1_2
        )
    )
    g(
        dummyIo => server,
        @pconnect (
            dummyout1_1 => dfp_rx_data_ready,

            dummyout1_0 => ufp_tx_data_valid,
            dummyout1_0 => ufp_tx_data_last,
            dummyout32_0 => ufp_tx_data,

            dummyout16_128 => config_src_port
        )
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
            commandReady => dfp_ready
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

    return vall
end
