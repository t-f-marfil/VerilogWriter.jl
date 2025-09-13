function generateTcpRecvParser(name)
    v = Vmodule("TcpRecvParser_$name")
    prts = @ports (
        @in CLK, RST;

        @in ufp_valid, ufp_last;
        @out @logic ufp_ready;
        @in 32 ufp_data;
        # @in ufp_no_data_payload;
        # IP address input
        # supposed to be valid whenever ufp_valid is high
        @in 32 ufp_src_addr, ufp_dest_addr;
        @in 16 ufp_total_length_data;

        # payload output
        @out @logic dfp_valid, dfp_last;
        @out @logic 32 dfp_data;
        @in dfp_ready;

        # info
        @out @logic 32 src_addr, dest_addr; # ip address of the packet
        @out @logic dfp_no_data_payload;
        @out @logic 16 src_port, dest_port;
        @out @logic 32 seq_number, ack_number;
        @out @logic 6 flags;
        @out @logic 16 window, checksum, urg_pointer;

        @in info_ready;
        @out @logic info_valid;
    )

    fsm = @FSM state read_header_core, read_option, read_data, explicitWaitDfpInfo
    transadd!(fsm, @wireexpr(header_read_done & option_detected), @tstate read_header_core => read_option)
    transadd!(fsm, @wireexpr(header_read_done & (~option_detected) & data_detected), @tstate read_header_core => read_data) 
    transadd!(fsm, @wireexpr(header_read_done & (~option_detected) & (~data_detected)), @tstate read_header_core => explicitWaitDfpInfo)

    transadd!(fsm, @wireexpr(option_read_done & ~dfp_no_data_payload), @tstate read_option => read_data)
    transadd!(fsm, @wireexpr(option_read_done & dfp_no_data_payload), @tstate read_option => explicitWaitDfpInfo)

    transadd!(fsm, @wireexpr(info_done), @tstate explicitWaitDfpInfo => read_header_core)

    alfsm = @always (
        if state == read_header_core
            header_read_done = ufp_valid & ufp_ready & (header_read_dword_count == 4)
            option_detected = $(Wireexpr(4, 5)) < data_offset
            data_detected = ({$(Wireexpr(12,0)), data_offset} << 2) < total_length_data_buf
        else
            header_read_done = 0
            option_detected = 0
            data_detected = 0
        end;

        if state == read_option
            option_read_done = ufp_valid & ufp_ready & (header_read_dword_count + 1 == data_offset)
        else
            option_read_done = 0
        end
    )
    alio = @always (
        if state == read_header_core
            ufp_ready = 1
        elseif state == read_option
            ufp_ready = 1
        elseif state == read_data
            ufp_ready = dfp_ready
        else
            ufp_ready = 0
        end;

        if state == read_data
            dfp_valid = ufp_valid
            dfp_last = ufp_last
            dfp_data = ufp_data
        else
            dfp_valid = 0
            dfp_last = 0
            dfp_data = 0
        end
    )
    alinfoctrl = @cpalways (
        if state == read_header_core
            info_valid = 0
            info_done <= $(Wireexpr(1, 0))
        elseif (state == read_option) | (state == read_data) | (state == explicitWaitDfpInfo)
            info_valid = ~info_done
            if info_valid & info_ready
                info_done <= 1
            end
        else
            info_valid = 0
        end
    )
    aldata = @always (
        if state == read_header_core
            if ufp_valid & ufp_ready
                src_addr <= ufp_src_addr
                dest_addr <= ufp_dest_addr
                total_length_data_buf <= ufp_total_length_data


                if header_read_dword_count == 0
                    src_port <= {ufp_data[7:0], ufp_data[15:8]}
                    dest_port <= {ufp_data[23:16], ufp_data[31:24]}
                elseif header_read_dword_count == 1
                    seq_number <= {ufp_data[7:0], ufp_data[15:8], ufp_data[23:16], ufp_data[31:24]}
                elseif header_read_dword_count == 2
                    ack_number <= {ufp_data[7:0], ufp_data[15:8], ufp_data[23:16], ufp_data[31:24]}
                elseif header_read_dword_count == 3
                    data_offset <= {ufp_data[7:4]}
                    flags <= {ufp_data[13:8]}
                    window <= {ufp_data[23:16], ufp_data[31:24]}
                elseif header_read_dword_count == 4
                    checksum <= {ufp_data[7:0], ufp_data[15:8]}
                    urg_pointer <= {ufp_data[23:16], ufp_data[31:24]}

                    dfp_no_data_payload <= ~data_detected
                end
            end
        elseif state == read_option
            # TODO: parse option
        end
    )
    almisc = @always (
        if (state == read_header_core) || (state == read_option)
            if ufp_valid & ufp_ready
                header_read_dword_count <= header_read_dword_count + $(Wireexpr(4, 1))
            end
        else
            header_read_dword_count <= 0
        end
    )

    vpush!.(v, (
        prts, fsm,
        alfsm, alio, alinfoctrl..., aldata,
        almisc
    ))

    return v
end

function generateSampleTcpPacketBuffer()
    v = Vmodule("sampleTcpPacketBuffer")
    prts = @ports (
        @in CLK, RST;

        @out @logic valid, last;
        @out @logic 32 data;
        @out @logic 32 sampleAddr1, sampleAddr2;
        @in ready;
        @out @logic constHigh
    )

    databuf = [
        0xFFFF_FFFF,
        0x0000_FFFF,
        0xCBFA_005E,
        # _type = 0x0800
        # version = 4, header length = 5
        # diffserv = 0
        0x0045_0008,
        # total length = 0x0020
        # id = 0
        0x0000_3000,
        # flags = 0, fragment offset = 0
        # ttl = 0x80 = 0d128, proto = 06 (TCP)
        0x0680_0000,
        0xFEA9_C2D2,
        0xFEA9_0B0A,
        # src port 0x0090
        0x9000_0C0A,
        # dest port 0x0080
        # seq num 0x12345678
        0x3412_8000,
        # ack num 90ABCDEF
        0xAB90_7856,
        # header = 5, flags = syn
        0x0250_EFCD,
        # window = 9876, checksum = 11
        0x1100_7698,
        # urg ptr = 0x4503,
        0x0123_0345,
        0x0789_0456,
        0x0000_0abc,
    ]

    al = @cpalways (
        constHigh = 1;
        sampleAddr1 = $(Wireexpr(32, 0x1200_3400));
        sampleAddr2 = $(Wireexpr(32, 0x0056_0078));
        valid = counter < $(length(databuf));
        last = counter == $(length(databuf) - 1);
        if valid & ready
            counter <= counter + $(Wireexpr(32, 1))
        end
    )

    
    ifconds = Vector{Wireexpr}(undef, 0)
    contents = Vector{Ifcontent}(undef, 0)

    for i in 1:length(databuf)
        push!(ifconds, @wireexpr(counter == $(i-1)))
        push!(contents, @ifcontent (
            data = $(Wireexpr(32, databuf[i]))
        ))
    end
    algenerated = @always (
        $(Ifelseblock(ifconds, contents))
    )

    vpush!.(v, (prts, al..., algenerated))

    return v
end

function generateTcpPacketGenerator(name)
    v = Vmodule("tcpPacketGenerator_$name")
    prts = @ports (
        @in CLK, RST;

        # info
        @in ufp_misc_valid;
        @out @logic ufp_misc_ready;
        @in 32 src_addr, dest_addr;
        @in 16 src_port, dest_port;
        @in 32 seq_number, ack_number;
        @in 6 flags;
        @in 16 window, urg_pointer;
        # endian same as other fields (little endian)
        @in 16 checksum_data_only;
        @in 16 total_length_data_only;

        # tcp payload
        @in ufp_data_valid, ufp_data_last;
        @out @logic ufp_data_ready;
        @in 32 ufp_data;

        # dfp misc
        @out @logic dfp_misc_valid;
        @in dfp_misc_ready;
        @out @logic 8 protocol;
        @out @logic 16 dfp_total_length_data_only;

        @out @logic dfp_addr_valid;
        @in dfp_addr_ready;
        @out @logic 32 dfp_src_addr, dfp_dest_addr;

        # dfp data
        @out @logic dfp_data_valid, dfp_data_last;
        @out @logic 32 dfp_data;
        @in dfp_data_ready;

        @out @logic debug_valid;
        @out @logic 72 debug_data;
    )

    # remember the case where no data (& no option in the future)
    fsm = @FSM state init,send_header,send_data
    transadd!(fsm, @wireexpr(ufp_misc_ready & ufp_misc_valid), @tstate init => send_header)
    # at send_header state both wait misc and data transaction done for in some cases there is no data
    transadd!(fsm, @wireexpr(misc_trans_done_comb & header_trans_done_comb & addr_trans_done_comb & (total_length_data_only_buf == 0)), @tstate send_header => init)
    transadd!(fsm, @wireexpr(misc_trans_done_comb & header_trans_done_comb & addr_trans_done_comb & ~(total_length_data_only_buf == 0)), @tstate send_header => send_data)
    transadd!(fsm, @wireexpr(dfp_data_last & dfp_data_valid & dfp_data_ready), @tstate send_data => init)

    aldebug = @always (
        if $(transcond(fsm, @tstate init => send_header))
            debug_valid = 1
            debug_data = 1
        elseif $(transcond(fsm, @tstate send_header => send_data))
            debug_data = 2
            debug_valid = 1
        elseif $(transcond(fsm, @tstate send_data => init))
            debug_data = 3
            debug_valid = 1
        else
            debug_data = 0
            debug_valid = 0
        end
    )
    alfsm = @always (
        misc_trans_done_comb = dfp_misc_done | (dfp_misc_ready & dfp_misc_valid);
        addr_trans_done_comb = dfp_addr_done | (dfp_addr_ready & dfp_addr_valid);
        header_trans_done_comb = ((header_counter == 4) & dfp_data_valid & dfp_data_ready) | (header_counter == 5);
    )
    alio = @always (
        header_dword_length = $(Wireexpr(4, 5));

        if state == init
            ufp_misc_ready = 1
        else
            ufp_misc_ready = 0
        end;

        if state == send_data
            ufp_data_ready = dfp_data_ready
        else
            ufp_data_ready = 0
        end;

        if state == send_header
            dfp_misc_valid = ~dfp_misc_done
            dfp_addr_valid = ~dfp_addr_done
        else
            dfp_misc_valid = 0
            dfp_addr_valid = 0
        end;
        if state == send_header
            dfp_data_valid = ~(header_counter == {$(Wireexpr(1, 0)), header_dword_length})
            dfp_data_last = (total_length_data_only_buf == 0) & (header_counter == 4)
            if header_counter == 0
                dfp_data = {dest_port_buf[7:0], dest_port_buf[15:8], src_port_buf[7:0], src_port_buf[15:8]}
            elseif header_counter == 1
                dfp_data = {seq_number_buf[7:0], seq_number_buf[15:8], seq_number_buf[23:16], seq_number_buf[31:24]}
            elseif header_counter == 2
                dfp_data = {ack_number_buf[7:0], ack_number_buf[15:8], ack_number_buf[23:16], ack_number_buf[31:24]}
            elseif header_counter == 3
                dfp_data = {window_buf[7:0], window_buf[15:8], $(Wireexpr(2, 0)), flags_buf, $(Wireexpr(4, 5)), $(Wireexpr(4, 0))}
            elseif header_counter == 4
                dfp_data = {urg_pointer_buf[7:0], urg_pointer_buf[15:8], ~headerallsum[7:0], ~headerallsum[15:8]}
            end
        elseif state == send_data
            dfp_data = ufp_data
            dfp_data_last = ufp_data_last
            dfp_data_valid = ufp_data_valid
        else
            dfp_data = 0
            dfp_data_last = 0
            dfp_data_valid = 0
        end;
    )
    alheader = @always (
        if state == send_header
            if dfp_data_valid & dfp_data_ready
                header_counter <= header_counter + $(Wireexpr(5, 1))
            end
        else
            header_counter <= 0
        end
    )
    almisc = @cpalways (
        dfp_total_length_data_only = total_length_data_only_buf + ({$(Wireexpr(12, 0)), header_dword_length} << 2);
        protocol = 0x06;
        dfp_src_addr = src_addr_buf;
        dfp_dest_addr = dest_addr_buf;

        if state == send_header
            if dfp_misc_ready & dfp_misc_valid
                dfp_misc_done <= 1
            end
            if dfp_addr_ready & dfp_addr_valid
                dfp_addr_done <= 1
            end
        else
            dfp_misc_done <= 0
            dfp_addr_done <= 0
        end
    )
    alsnapshot = @always (
        if state == init
            src_addr_buf <= src_addr
            dest_addr_buf <= dest_addr
            src_port_buf <= src_port
            dest_port_buf <= dest_port
            seq_number_buf <= seq_number
            ack_number_buf <= ack_number
            flags_buf <= flags
            window_buf <= window
            urg_pointer_buf <= urg_pointer
            total_length_data_only_buf <= total_length_data_only
            checksum_data_only_buf <= checksum_data_only
        end
    )
    alchecksum = @cpalways (
        # first
        header1sum_raw = {$(Wireexpr(1, 0)), src_port_buf} + {$(Wireexpr(1, 0)), dest_port_buf} | $(Wireexpr(17, 0));
        header1sum <= header1sum_raw[15:0] + {$(Wireexpr(15, 0)), header1sum_raw[16]};
        
        header2sum_raw = {$(Wireexpr(1, 0)), seq_number_buf[31:16]} + {$(Wireexpr(1, 0)), seq_number_buf[15:0]} | $(Wireexpr(17, 0));
        header2sum <= header2sum_raw[15:0] + {$(Wireexpr(15, 0)), header2sum_raw[16]};

        header3sum_raw = {$(Wireexpr(1, 0)), ack_number_buf[31:16]} + {$(Wireexpr(1, 0)), ack_number_buf[15:0]} | $(Wireexpr(17, 0));
        header3sum <= header3sum_raw[15:0] + {$(Wireexpr(15, 0)), header3sum_raw[16]};

        header4sum_raw = {$(Wireexpr(1, 0)), window_buf} + {$(Wireexpr(1, 0)), $(Wireexpr(4, 5)), $(Wireexpr(4, 0)), $(Wireexpr(2, 0)), flags_buf} | $(Wireexpr(17, 0));
        header4sum <= header4sum_raw[15:0] + {$(Wireexpr(15, 0)), header4sum_raw[16]};

        header5datasum_raw = {$(Wireexpr(1, 0)), urg_pointer_buf} + {$(Wireexpr(1, 0)), checksum_data_only_buf} | $(Wireexpr(17, 0));
        header5datasum <= header5datasum_raw[15:0] + {$(Wireexpr(15, 0)), header5datasum_raw[16]};

        pseudoheader1sum_raw = {$(Wireexpr(1, 0)), src_addr_buf[31:16]} + {$(Wireexpr(1, 0)), src_addr_buf[15:0]} | $(Wireexpr(17, 0));
        pseudoheader1sum <= pseudoheader1sum_raw[15:0] + {$(Wireexpr(15, 0)), pseudoheader1sum_raw[16]};

        pseudoheader2sum_raw = {$(Wireexpr(1, 0)), dest_addr_buf[31:16]} + {$(Wireexpr(1, 0)), dest_addr_buf[15:0]} | $(Wireexpr(17, 0));
        pseudoheader2sum <= pseudoheader2sum_raw[15:0] + {$(Wireexpr(15, 0)), pseudoheader2sum_raw[16]};

        pseudoheader3sum_raw = {$(Wireexpr(1, 0)), $(Wireexpr(8, 0)), $(Wireexpr(8, 0x06))} + {$(Wireexpr(1, 0)), dfp_total_length_data_only} | $(Wireexpr(17, 0));
        pseudoheader3sum <= pseudoheader3sum_raw[15:0] + {$(Wireexpr(15, 0)), pseudoheader3sum_raw[16]};

        # second
        header1_2sumraw = {$(Wireexpr(1, 0)), header1sum} + {$(Wireexpr(1, 0)), header2sum} | $(Wireexpr(17, 0));
        header1_2sum <= header1_2sumraw[15:0] + {$(Wireexpr(15, 0)), header1_2sumraw[16]};

        header3_4sumraw = {$(Wireexpr(1, 0)), header3sum} + {$(Wireexpr(1, 0)), header4sum} | $(Wireexpr(17, 0));
        header3_4sum <= header3_4sumraw[15:0] + {$(Wireexpr(15, 0)), header3_4sumraw[16]};

        header5_pseudo1sumraw = {$(Wireexpr(1, 0)), header5datasum} + {$(Wireexpr(1, 0)), pseudoheader1sum} | $(Wireexpr(17, 0));
        header5_pseudo1sum <= header5_pseudo1sumraw[15:0] + {$(Wireexpr(15, 0)), header5_pseudo1sumraw[16]};

        pseudoheader2_3sumraw = {$(Wireexpr(1, 0)), pseudoheader2sum} + {$(Wireexpr(1, 0)), pseudoheader3sum} | $(Wireexpr(17, 0));
        pseudoheader2_3sum <= pseudoheader2_3sumraw[15:0] + {$(Wireexpr(15, 0)), pseudoheader2_3sumraw[16]};

        # third
        header1_4sumraw = {$(Wireexpr(1, 0)), header1_2sum} + {$(Wireexpr(1, 0)), header3_4sum} | $(Wireexpr(17, 0));
        header1_4sum <= header1_4sumraw[15:0] + {$(Wireexpr(15, 0)), header1_4sumraw[16]};

        header5_pseudo3sumraw = {$(Wireexpr(1, 0)), header5_pseudo1sum} + {$(Wireexpr(1, 0)), pseudoheader2_3sum} | $(Wireexpr(17, 0));
        header5_pseudo3sum <= header5_pseudo3sumraw[15:0] + {$(Wireexpr(15, 0)), header5_pseudo3sumraw[16]};

        # fourth
        headerallsum_raw = {$(Wireexpr(1, 0)), header1_4sum} + {$(Wireexpr(1, 0)), header5_pseudo3sum} | $(Wireexpr(17, 0));
        headerallsum <= headerallsum_raw[15:0] + {$(Wireexpr(15, 0)), headerallsum_raw[16]};
    )

    vpush!.(v, (
        prts, fsm,
        aldebug,
        alfsm, alio,
        alheader, almisc...,
        alsnapshot, alchecksum...
    ))

    return v
end

function generateTcpPacketSendBlock(name)
    buf = generateEtherFrameTxBuffer("tcptx_$name")
    ethergen = generateEtherFrameGenerator("tcptx_$name")
    ipgen = generateIpPacketSimpleGenerator("tcptx_$name")
    tcpgen = generateTcpPacketGenerator("tcptx_$name")

    
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
        tcpgen => ipgen,
        @pconnect (
            dfp_data => wdata_in,
            dfp_data_valid => wvalid_in,
            dfp_data_last => wlast_in,

            dfp_misc_valid => ufp_misc_valid,
            protocol => protocol,
            dfp_total_length_data_only => totalLengthData,

            dfp_addr_valid => ufp_addr_valid,
            dfp_src_addr => sourceAddr,
            dfp_dest_addr => destAddr
        )
    )
    g(
        ipgen => tcpgen,
        @pconnect (
            wready_out => dfp_data_ready,
            ufp_misc_ready => dfp_misc_ready,

            ufp_addr_ready => dfp_addr_ready
        )
    )

    vs = layer2vmod!(g, false, name="TcpPacketSendBlock_$name")
    return vs
end

function generateSampleTcpSendCommand()
    v = Vmodule("sampleTcpSendCommand")
    prts = @ports (
        @in CLK, RST;
        @in btn;
        @out @logic consthigh;

        @out @logic misc_valid;
        @in misc_ready;
        @out @logic 32 src_addr, dest_addr;
        @out @logic 16 src_port, dest_port;
        @out @logic 32 seq_number, ack_number;
        @out @logic 6 flags;
        @out @logic 16 window, urg_pointer, checksum_data_only, total_length_data_only;

        @out @logic data_valid, data_last;
        @in data_ready;
        @out @logic 32 data;

        @out @logic 48 dest_mac_addr;
        @out @logic commandValid;
        @in commandReady;
    )

    alconst = @always (
        consthigh = 1;
        src_addr = $(Wireexpr(32, 0xA9FE_1011));
        dest_addr = $(Wireexpr(32, 0xA9FE_1233));
        src_port = $(Wireexpr(16, 0x3200));
        dest_port = $(Wireexpr(16, 0x4500));

        seq_number = $(Wireexpr(32, 0x1234_5678));
        ack_number = $(Wireexpr(32, 0xABCD_EF01));
        flags = 0x2;
        window = 0x11FF;
        urg_pointer = 1;
        checksum_data_only = $(Wireexpr(16, 0x4044));
        total_length_data_only = 8;

        dest_mac_addr = $(Wireexpr(48, 0x5566_7788_9911));
    )

    # count = 30
    count = (100 * (10 ^ 6))
    datacount = 2
    al = @cpalways (
        start = counter == $(Wireexpr(32, count));
        data_valid = datacounter < $datacount;
        if datacounter == 0
            data = $(Wireexpr(32, 0x1230_4567))
        elseif datacounter == 1
            data = $(Wireexpr(32, 0x9876_5432))
        else
            data = 0
        end;
        data_last = datacounter == $(datacount-1);
        misc_valid = start & ~misc_done;
        commandValid = start & ~command_done;

        if btn
            triggerred <= 1
        end;
        if data_valid & data_ready
            datacounter <= datacounter + $(Wireexpr(32, 1))
        end;
        if (counter < $count) & triggerred
            counter <= counter + $(Wireexpr(32, 1))
        end;
        if commandValid & commandReady
            command_done <= 1
        end;

        if misc_valid & misc_ready
            misc_done <= 1
        end
    )

    vpush!.(v, (
        prts,
        alconst, al...
    ))

    return v
end
