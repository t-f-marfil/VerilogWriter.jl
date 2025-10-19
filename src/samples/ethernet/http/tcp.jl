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
        @out @logic 16 payload_length;

        @in info_ready;
        @out @logic info_valid;

        @out @logic debug_valid_rcvparse;
        @out @logic 72 debug_data_rcvparse;
    )

    fsm = @FSM state read_header_core, read_option, read_data, explicitWaitDfpInfo
    transadd!(fsm, @wireexpr(header_read_done & option_detected), @tstate read_header_core => read_option)
    transadd!(fsm, @wireexpr(header_read_done & (~option_detected) & data_detected), @tstate read_header_core => read_data) 
    transadd!(fsm, @wireexpr(header_read_done & (~option_detected) & (~data_detected)), @tstate read_header_core => explicitWaitDfpInfo)

    transadd!(fsm, @wireexpr(option_read_done & ~dfp_no_data_payload), @tstate read_option => read_data)
    transadd!(fsm, @wireexpr(option_read_done & dfp_no_data_payload), @tstate read_option => explicitWaitDfpInfo)

    transadd!(fsm, @wireexpr(info_done), @tstate explicitWaitDfpInfo => read_header_core)
    transadd!(fsm, @wireexpr(dfp_valid & dfp_ready & dfp_last & (info_done | (info_ready & info_valid))), @tstate read_data => read_header_core)
    transadd!(fsm, @wireexpr(dfp_valid & dfp_ready & dfp_last & ~(info_done | (info_ready & info_valid))), @tstate read_data => explicitWaitDfpInfo)

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
    altotallength = @always (
        if state == read_header_core
            payload_length <= total_length_data_buf + $(Wireexpr(16, 1)) + ~({$(Wireexpr(12,0)), data_offset} << 2)
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

    aldebug = @cpalways (
        prev_debug_data_rcvparse <= debug_data_rcvparse;
        debug_data_rcvparse = {
            $(Wireexpr(60, 0)),
            $(Wireexpr(2, 0)), state, 
            {$(Wireexpr(1, 0)), dfp_last, dfp_valid, dfp_ready},
            {$(Wireexpr(1, 0)), ufp_last, ufp_valid, ufp_ready}
            };
        
        debug_valid_rcvparse = ~(prev_debug_data_rcvparse == debug_data_rcvparse);
    )

    vpush!.(v, (
        prts, fsm,
        alfsm, alio, alinfoctrl..., aldata,
        almisc, altotallength,
        aldebug...
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
        @out @logic 16 samplePort;
        @in ready;
        @out @logic constHigh
    )

    databuf1 = [
        0xFFFF_FFFF,
        0x0000_FFFF,
        0xCBFA_005E,
        # _type = 0x0800
        # version = 4, header length = 5
        # diffserv = 0
        0x0045_0008,
        # total length = 0x0028
        # id = 0
        0x0000_2800,
        # flags = 0, fragment offset = 0
        # ttl = 0x80 = 0d128, proto = 06 (TCP)
        0x0680_0000,
        0xFEA9_C2D2,
        0xFEA9_0B0A,
        # src port 0x0090
        0x9000_0C0A,
        # dest port 0x0050
        # seq num 0x12345678
        0x3412_5000,
        # ack num 90ABCDEF
        0xAB90_7856,
        # header = 5, flags = syn
        0x0250_EFCD,
        # window = 9876, checksum = 11
        0x1100_7698,
        # urg ptr = 0x4503,
        0x0000_0345,
    ]


    databuf2 = [
        0xFFFF_FFFF,
        0x0000_FFFF,
        0xCBFA_005E,
        # _type = 0x0800
        # version = 4, header length = 5
        # diffserv = 0
        0x0045_0008,
        # total length = 0x0028
        # id = 0
        0x0000_2800,
        # flags = 0, fragment offset = 0
        # ttl = 0x80 = 0d128, proto = 06 (TCP)
        0x0680_0000,
        0xFEA9_C2D2,
        0xFEA9_0B0A,
        # src port 0x0090
        0x9000_0C0A,
        # dest port 0x0050
        # seq num 0x12345678 + 1
        0x3412_5000,
        # ack num 0x9876_1234 + 1
        0x7698_7956,
        # header = 5, flags = ack
        0x1050_3512,
        # window = 9876, checksum = 11
        0x1100_7698,
        # urg ptr = 0x4503,
        0x0000_0345,
    ]


    databuf3 = [
        0xFFFF_FFFF,
        0x0000_FFFF,
        0xCBFA_005E,
        # _type = 0x0800
        # version = 4, header length = 5
        # diffserv = 0
        0x0045_0008,
        # total length = 0x0030
        # id = 0
        0x0000_3000,
        # flags = 0, fragment offset = 0
        # ttl = 0x80 = 0d128, proto = 06 (TCP)
        0x0680_0000,
        0xFEA9_C2D2,
        0xFEA9_0B0A,
        # src port 0x0090
        0x9000_0C0A,
        # dest port 0x0050
        # seq num 0x12345678 + 1
        0x3412_5000,
        # ack num 0x9876_1234 + 1
        0x7698_7956,
        # header = 5, flags = ack
        0x1050_3512,
        # window = 9876, checksum = 11
        0x1100_7698,
        # urg ptr = 0x4503,
        0x5665_0345,
        0x1221_3443,
        0x0000_6556,
    ]

    databuf4 = [
        0xFFFF_FFFF,
        0x0000_FFFF,
        0xCBFA_005E,
        # _type = 0x0800
        # version = 4, header length = 5
        # diffserv = 0
        0x0045_0008,
        # total length = 0x0028
        # id = 0
        0x0000_2800,
        # flags = 0, fragment offset = 0
        # ttl = 0x80 = 0d128, proto = 06 (TCP)
        0x0680_0000,
        0xFEA9_C2D2,
        0xFEA9_0B0A,
        # src port 0x0090
        0x9000_0C0A,
        # dest port 0x0050
        # seq num 0x12345678 + 1 + 8
        0x3412_5000,
        # ack num 0x9876_1234 + 1
        0x7698_8156,
        # header = 5, flags = ack, fin
        0x1150_3512,
        # window = 9876, checksum = 11
        0x1100_7698,
        # urg ptr = 0x4503,
        0x0000_0345,
    ]



    databuf5 = [
        0xFFFF_FFFF,
        0x0000_FFFF,
        0xCBFA_005E,
        # _type = 0x0800
        # version = 4, header length = 5
        # diffserv = 0
        0x0045_0008,
        # total length = 0x0028
        # id = 0
        0x0000_2800,
        # flags = 0, fragment offset = 0
        # ttl = 0x80 = 0d128, proto = 06 (TCP)
        0x0680_0000,
        0xFEA9_C2D2,
        0xFEA9_0B0A,
        # src port 0x0090
        0x9000_0C0A,
        # dest port 0x0050
        # seq num 0x12345678 + 1 + 8 + 1
        0x3412_5000,
        # ack num 0x9876_1234 + 1 + 1
        0x7698_8256,
        # header = 5, flags = ack
        0x1050_3612,
        # window = 9876, checksum = 11
        0x1100_7698,
        # urg ptr = 0x4503,
        0x0000_0345,
    ]

    databuf6 = [
        0xFFFF_FFFF,
        0x0000_FFFF,
        0xCBFA_005E,
        # _type = 0x0800
        # version = 4, header length = 5
        # diffserv = 0
        0x0045_0008,
        # total length = 0x0020
        # id = 0
        0x0000_2200,
        # flags = 0, fragment offset = 0
        # ttl = 0x80 = 0d128, proto = 01
        0x0180_0000,
        0xFEA9_C2D2,
        0xFEA9_0B0A,
        0x0008_0C0A,
        0x0100_434d,
        0x6261_1800,
        0x6665_6463,
        0x6a69_6867,
        0x6e6d_6c6b,
        0x7271_706f,
        0x7675_7473,
        0x6362_6177,
        0x6766_6564,
        0x0000_6968,
    ]

    packetcount4waitmax = 20
    al = @cpalways (
        constHigh = 1;
        sampleAddr1 = $(Wireexpr(32, 0xA9FE_0A0C));
        sampleAddr2 = $(Wireexpr(32, 0x0056_0078));
        samplePort = 0x0080;

        if packetcount == 4
            if packetcount4wait < $packetcount4waitmax
                packetcount4wait <= packetcount4wait + $(Wireexpr(32, 1))
            end
        else
            packetcount4wait <= 0
        end;

        if packetcount == 0
            valid = counter < $(length(databuf1))
            last = counter == $(length(databuf1) - 1)
        elseif packetcount == 1
            valid = counter < $(length(databuf2))
            last = counter == $(length(databuf2) - 1)
        elseif packetcount == 2
            valid = counter < $(length(databuf3))
            last = counter == $(length(databuf3) - 1)
        elseif packetcount == 3
            valid = counter < $(length(databuf4))
            last = counter == $(length(databuf4) - 1)
        elseif packetcount == 4
            valid = (counter < $(length(databuf5))) & (packetcount4wait == $packetcount4waitmax)
            last = counter == $(length(databuf5) - 1)
        elseif packetcount == 5
            valid = (counter < $(length(databuf6)))
            last = counter == $(length(databuf6) - 1)
        else
            valid = 0
            last = 0
        end;
        if valid & ready
            if last
                counter <= 0
            else
                counter <= counter + $(Wireexpr(32, 1))
            end
        end;

        if valid & ready & last
            packetcount <= packetcount + $(Wireexpr(32, 1))
        end
    )

    ifcv = Vector{Vector{Wireexpr}}(undef, 0)
    contv = Vector{Vector{Ifcontent}}(undef, 0)

    dbufv = [databuf1, databuf2, databuf3, databuf4, databuf5, databuf6]
    for v in dbufv
        ifconds = Vector{Wireexpr}(undef, 0)
        contents = Vector{Ifcontent}(undef, 0)

        for i in 1:length(v)
            push!(ifconds, @wireexpr(counter == $(i-1)))
            push!(contents, @ifcontent (
                data = $(Wireexpr(32, v[i]))
            ))
        end

        push!(ifcv, ifconds)
        push!(contv, contents)
    end


    algenerated = @always (
        if packetcount == 0
            $(Ifelseblock(ifcv[1], contv[1]))
        elseif packetcount == 1
            $(Ifelseblock(ifcv[2], contv[2]))
        elseif packetcount == 2
            $(Ifelseblock(ifcv[3], contv[3]))
        elseif packetcount == 3
            $(Ifelseblock(ifcv[4], contv[4]))
        elseif packetcount == 4
            $(Ifelseblock(ifcv[5], contv[5]))
        elseif packetcount == 5
            $(Ifelseblock(ifcv[6], contv[6]))
        else
            data = 0
        end 
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
    return vs, g
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

function generateSimpleTcpServer(name)
    v = Vmodule("SimpleTcpServer_$name")
    prts = @ports (
        @in CLK, RST;

        # configuration
        @in config_valid;
        @in 16 config_src_port;
        @in 32 config_src_addr;


        # rx
        @in 32 rx_src_addr, rx_dest_addr;
        @in rx_no_data_payload;
        @in 16 rx_src_port, rx_dest_port;
        @in 32 rx_seq_number, rx_ack_number;
        @in 6 rx_flags;
        @in 16 rx_window, rx_checksum, rx_urg_pointer;
        @in 16 rx_payload_length;
        @in rx_misc_valid;
        @out @logic rx_misc_ready;

        @in rx_data_valid, rx_data_last;
        @out @logic rx_data_ready;
        @in 32 rx_data;


        # payload data IO
        @out @logic 32 dfp_rx_data;
        # strb but 2'b11 for 32 bit full of data, 2'b10 for 16 bit only
        @out @logic 2 dfp_rx_data_strb;
        @out @logic dfp_rx_data_valid;
        @in dfp_rx_data_ready;

        @in 32 ufp_tx_data;
        @in ufp_tx_data_valid, ufp_tx_data_last;
        @out @logic ufp_tx_data_ready;
        @in 16 ufp_tx_checksum_data_only, ufp_tx_total_length_data_only;


        # tx
        @out @logic tx_misc_valid;
        @in tx_misc_ready;
        @out @logic 32 tx_src_addr, tx_dest_addr;
        @out @logic 16 tx_src_port, tx_dest_port;
        @out @logic 32 tx_seq_number, tx_ack_number;
        @out @logic 6 tx_flags;
        @out @logic 16 tx_window, tx_urg_pointer;
        @out @logic 16 tx_checksum_data_only, tx_total_length_data_only;

        @out @logic tx_data_valid, tx_data_last;
        @out @logic 32 tx_data;
        @in tx_data_ready;

        @out @logic debug_valid_srv;
        @out @logic 72 debug_data_srv;
    )


    alconfig = @always (
        if config_valid
            config_src_addr_buf <= config_src_addr
            config_src_port_buf <= config_src_port
        end
    )


    connection_state = @FSM connection_state closed,listen,syn_rcvd,estab,close_wait,last_ack
    close_wait_sub_state = @FSM close_wait_sub_state close_wait_init,close_wait_flush_tx,close_wait_send_ack,close_wait_send_fin
    rx_state = @FSM rx_state rx_read_header,rx_idle,rx_read_data,rx_discard_data
    tx_state = @FSM tx_state tx_idle,tx_send_header,tx_send_data

    transadd!(rx_state, @wireexpr(rx_misc_ready & rx_misc_valid & ~rx_no_data_payload & ~rx_discard), @tstate rx_read_header => rx_read_data)
    transadd!(rx_state, @wireexpr(rx_misc_ready & rx_misc_valid & ~rx_no_data_payload & rx_discard), @tstate rx_read_header => rx_discard_data)
    transadd!(rx_state, @wireexpr(rx_misc_ready & rx_misc_valid & rx_no_data_payload), @tstate rx_read_header => rx_idle)
    transadd!(rx_state, @wireexpr(rx_data_ready & rx_data_valid & rx_data_last), @tstate rx_read_data => rx_idle)
    transadd!(rx_state, @wireexpr(rx_data_ready & rx_data_valid & rx_data_last), @tstate rx_discard_data => rx_idle)
    transadd!(rx_state, @wireexpr(rx_next), @tstate rx_idle => rx_read_header)

    transadd!(tx_state, @wireexpr(tx_next), @tstate tx_idle => tx_send_header)
    transadd!(tx_state, @wireexpr(tx_misc_ready & tx_misc_valid & (tx_no_data_payload | tx_trans_done_comb)), @tstate tx_send_header => tx_idle)
    transadd!(tx_state, @wireexpr(tx_misc_ready & tx_misc_valid & (~tx_no_data_payload) & (~tx_trans_done_comb)), @tstate tx_send_header => tx_send_data)
    transadd!(tx_state, @wireexpr(tx_trans_done_comb), @tstate tx_send_data => tx_idle)

    transadd!(connection_state, @wireexpr(config_valid), @tstate closed => listen)
    transadd!(connection_state, @wireexpr((syn_detected_buf | syn_detected) & rx_fsm_to_idle), @tstate listen => syn_rcvd)
    transadd!(connection_state, @wireexpr((syn_ack_detected_buf | syn_ack_detected) & rx_fsm_to_idle), @tstate syn_rcvd => estab)
    transadd!(connection_state, @wireexpr((fin_detected_buf | fin_detected) & rx_fsm_to_idle), @tstate estab => close_wait)
    
    transadd!(close_wait_sub_state, transcond(connection_state, @tstate estab => close_wait), @tstate close_wait_init => close_wait_flush_tx)
    transadd!(close_wait_sub_state, @wireexpr(tx_state == tx_idle), @tstate close_wait_flush_tx => close_wait_send_ack)
    transadd!(close_wait_sub_state, transcond(tx_state, @tstate tx_send_header => tx_idle), @tstate close_wait_send_ack => close_wait_send_fin)
    transadd!(close_wait_sub_state, transcond(tx_state, @tstate tx_send_header => tx_idle), @tstate close_wait_send_fin => close_wait_init)
    
    transadd!(connection_state, transcond(close_wait_sub_state, @tstate close_wait_send_fin => close_wait_init), @tstate close_wait => last_ack)
    transadd!(connection_state, @wireexpr(fin_ack_detected), @tstate last_ack => closed)
    

    static_init_seq_number = 0x9876_1234
    static_init_window_size = 0x1000
    altcb = @always (
        if $(transcond(connection_state, @tstate listen => syn_rcvd))
            tx_init_seq_number <= $(Wireexpr(32, static_init_seq_number))
            tx_rcv_window <= $(Wireexpr(16, static_init_window_size))
            
            if rx_state == rx_read_header
                rx_init_seq_number <= rx_seq_number
                # rx window but this is send window
                rx_init_window <= rx_window
                # TODO: ignore packets from other ports if once established
                connection_dest_port <= rx_src_port
                connection_dest_addr <= rx_src_addr
            else
                # in case where syn had some data (discarding them now)
                rx_init_seq_number <= rx_seq_number_buf
                rx_init_window <= rx_window_buf
                connection_dest_port <= rx_src_port_buf
                connection_dest_addr <= rx_src_addr_buf
            end
        end;

        if $(transcond(connection_state, @tstate syn_rcvd => estab))
            snd_nxt <= tx_init_seq_number + 1
            snd_una <= tx_init_seq_number + 1
            snd_wnd <= rx_init_window

            rcv_nxt <= rx_init_seq_number + 1
        elseif (connection_state == estab) | (connection_state == close_wait) | (connection_state == last_ack)
            if (rx_misc_ready & rx_misc_valid) & rx_acceptable_packet
                snd_una <= rx_ack_number
                # TODO: must be able to reorder recv data
                if fin_detected
                    rcv_nxt <= rx_seq_number + {$(Wireexpr(16, 0)), rx_payload_length} + 1
                else
                    rcv_nxt <= rx_seq_number + {$(Wireexpr(16, 0)), rx_payload_length}
                end
            end
            
            # TODO: send data and update snd_nxt, snd_wnd
            if tx_misc_ready & tx_misc_valid
                if tx_flags[0]
                    snd_nxt <= snd_nxt + {$(Wireexpr(16, 0)), tx_total_length_data_only} + 1
                else
                    snd_nxt <= snd_nxt + {$(Wireexpr(16, 0)), tx_total_length_data_only}
                end
            end
        end
    )
    altcbutil = @always (
        if snd_una <= snd_nxt
            # no wrap
            rx_ack_valid = (snd_una <= rx_ack_number) & (rx_ack_number <= snd_nxt)
        else
            # wrapped
            rx_ack_valid = (snd_una <= rx_ack_number) | (rx_ack_number <= snd_nxt)
        end;
        rx_seq_valid = (rcv_nxt == rx_seq_number)
    )
    altcbupdate = @always (
        prev_rcv_nxt <= rcv_nxt;
        prev_connection_state <= connection_state;
        if connection_state == estab
            # note that on syn_rcvd => estab edge rcv_nxt is initialized, but of course no ack is needed
            if ~(prev_rcv_nxt == rcv_nxt) & ~(prev_connection_state == syn_rcvd)
                ack_update_required <= $(Wireexpr(1, 1))
            elseif $(transcond(tx_state, @tstate tx_idle => tx_send_header))
                ack_update_required <= 0
            end
        else
            ack_update_required <= 0
        end
    )

    alconnection = @cpalways (
        rx_target_self = (rx_dest_addr == config_src_addr_buf) & (rx_dest_port == config_src_port);
        rx_acceptable_packet = rx_target_self & rx_ack_valid & rx_seq_valid & rx_flags[4];
        
        rx_fsm_to_idle = (
            $(transcond(rx_state, @tstate rx_read_header => rx_idle))
            | $(transcond(rx_state, @tstate rx_discard_data => rx_idle))
            | $(transcond(rx_state, @tstate rx_read_data => rx_idle))
        );
        tx_fsm_to_idle = $(transcond(tx_state, @tstate tx_send_header => tx_idle)) | $(transcond(tx_state, @tstate tx_send_data => tx_idle));
        
        if connection_state == listen
            syn_detected_buf <= syn_detected | syn_detected_buf
            if (rx_state == rx_read_header) & rx_misc_ready & rx_misc_valid
                syn_detected = rx_target_self & (rx_flags == 0x2)
            else
                syn_detected = 0
            end
        else
            syn_detected_buf <= 0
            syn_detected = 0
        end;

        if connection_state == syn_rcvd
            syn_ack_detected_buf <= syn_ack_detected_buf | syn_ack_detected
            if (rx_state == rx_read_header) & rx_misc_ready & rx_misc_valid
                syn_ack_detected = rx_target_self & (rx_flags == 0x10) & (rx_ack_number == (tx_init_seq_number + 1)) & (rx_seq_number == (rx_init_seq_number + 1))
            else
                syn_ack_detected = 0
            end
        else
            syn_ack_detected = 0
            syn_ack_detected_buf <= 0
        end;

        if connection_state == estab
            fin_detected_buf <= fin_detected_buf | fin_detected
            if (rx_state == rx_read_header) & rx_misc_ready & rx_misc_valid
                fin_detected = rx_acceptable_packet & rx_flags[0]
            else
                fin_detected = 0
            end
        else
            fin_detected = 0
            fin_detected_buf <= 0
        end;

        if connection_state == last_ack
            if (rx_state == rx_read_header) & rx_misc_ready & rx_misc_valid
                # last ack
                fin_ack_detected = rx_acceptable_packet & (rx_ack_number == snd_nxt)
            else
                fin_ack_detected = 0
            end
        else
            fin_ack_detected = 0
        end
    )

    alrxfsm = @always (
        if connection_state == estab
            rx_discard = ~rx_acceptable_packet
        else
            rx_discard = 1
        end;
        
        rx_next = $(Wireexpr(1, 1))
    )
    alrxctrl = @always (
        if rx_state == rx_read_header
            rx_misc_ready = 1
        else
            rx_misc_ready = 0
        end;

        if rx_state == rx_read_data
            dfp_rx_data_valid = rx_data_valid
            rx_data_ready = dfp_rx_data_ready
            dfp_rx_data = rx_data
            if rx_read_data_counter + 1 == rx_payload_dword_count
                dfp_rx_data_strb = rx_payload_last_strb
            else
                dfp_rx_data_strb = 0
            end
        elseif rx_state == rx_discard_data
            dfp_rx_data_valid = 0
            rx_data_ready = 1
            dfp_rx_data = 0
            dfp_rx_data_strb = 0
        else
            dfp_rx_data_valid = 0
            rx_data_ready = 0
            dfp_rx_data = 0
            dfp_rx_data_strb = 0
        end
    )
    alrxutil = @always (
        if rx_state == rx_read_data
            if rx_data_valid & rx_data_ready
                rx_read_data_counter <= rx_read_data_counter + 1
            end
        else
            rx_read_data_counter <= 0
        end
    )
    alrxstrb = @always (
        rx_payload_last_strb = rx_payload_length_buf[1:0];
        rx_payload_not_aligned = |(rx_payload_last_strb);
        rx_payload_dword_count = (rx_payload_length_buf >> 2) + {$(Wireexpr(15, 0)), rx_payload_not_aligned};
    )
    alrxsnapshot = @always (
        if rx_state == rx_read_header
            rx_src_addr_buf <= rx_src_addr
            rx_dest_addr_buf <= rx_dest_addr
            rx_no_data_payload_buf <= rx_no_data_payload
            rx_src_port_buf <= rx_src_port
            rx_dest_port_buf <= rx_dest_port
            rx_seq_number_buf <= rx_seq_number
            rx_ack_number_buf <= rx_ack_number
            rx_flags_buf <= rx_flags
            rx_window_buf <= rx_window
            rx_checksum_buf <= rx_checksum
            rx_urg_pointer_buf <= rx_urg_pointer
            rx_payload_length_buf <= rx_payload_length
        end
    )


    altxdispatch = @always (
        if connection_state == syn_rcvd
            tx_next = ~tx_dispatched_syn_rcvd
        elseif connection_state == estab
            # TODO: send on both 1. updated ack value 2. send data
            tx_next = ack_update_required | ufp_tx_data_valid
        elseif connection_state == close_wait
            if close_wait_sub_state == close_wait_send_ack
                tx_next = 1
            elseif close_wait_sub_state == close_wait_send_fin
                tx_next = 1
            else
                tx_next = 0
            end
        else
            tx_next = 0
        end
    )
    altxutil = @always (
        if connection_state == syn_rcvd
            if $(transcond(tx_state, @tstate tx_idle => tx_send_header))
                tx_dispatched_syn_rcvd <= 1
            end
        else
            tx_dispatched_syn_rcvd <= 0
        end
    )
    altxmisc = @always (
        tx_src_addr = config_src_addr_buf;
        tx_src_port = config_src_port_buf;
        
        tx_dest_addr = connection_dest_addr;
        tx_dest_port = connection_dest_port;

        if connection_state == syn_rcvd
            tx_seq_number = tx_init_seq_number
            tx_ack_number = rx_init_seq_number + 1

            tx_flags = $(Wireexpr(6, 0x12))

            tx_window = tx_rcv_window
            tx_urg_pointer = 0
            tx_checksum_data_only = 0
            tx_total_length_data_only = 0
        elseif connection_state == estab
            tx_seq_number = snd_nxt
            # TODO: current implementation may send redundant ack when rcv_nxt is updated during tx_send_header state
            tx_ack_number = rcv_nxt

            tx_flags = 0x10

            # TODO: handle window
            tx_window = tx_rcv_window
            # TODO: send data, currently only return ACK
            tx_urg_pointer = 0

            if (tx_state == tx_send_header) & ufp_tx_data_valid_buf
                tx_checksum_data_only = ufp_tx_checksum_data_only_buf
                tx_total_length_data_only = ufp_tx_total_length_data_only_buf
            else
                tx_checksum_data_only = 0
                tx_total_length_data_only = 0
            end
        elseif connection_state == close_wait
            if close_wait_sub_state == close_wait_send_ack
                tx_seq_number = snd_nxt
                tx_ack_number = rcv_nxt

                tx_flags = 0x10

                # TODO: handle window
                tx_window = tx_rcv_window
                # TODO: send data, currently only return ACK
                tx_urg_pointer = 0
                tx_checksum_data_only = 0
                tx_total_length_data_only = 0
            elseif close_wait_sub_state == close_wait_send_fin
                tx_seq_number = snd_nxt
                tx_ack_number = rcv_nxt

                # FIN,ACK
                tx_flags = 0x11

                # TODO: handle window
                tx_window = tx_rcv_window
                # TODO: send data, currently only return ACK
                tx_urg_pointer = 0
                tx_checksum_data_only = 0
                tx_total_length_data_only = 0
            end
        else
            tx_seq_number = 0
            tx_ack_number = 0

            tx_flags = 0
            tx_window = 0
            tx_urg_pointer = 0
            tx_checksum_data_only = 0
            tx_total_length_data_only = 0
        end
    )
    altxmiscctrl = @always (
        if tx_state == tx_send_header
            tx_misc_valid = 1
        else
            tx_misc_valid = 0
        end;

        if connection_state == syn_rcvd
            tx_no_data_payload = 1
        elseif (connection_state == estab) | (connection_state == close_wait)
            if (tx_state == tx_send_header) | (tx_state == tx_send_data)
                if ufp_tx_data_valid_buf
                    tx_no_data_payload = 0
                else
                    tx_no_data_payload = 1
                end
            else
                tx_no_data_payload = 1
            end
        else
            # TODO: send data in estab / close_wait
            tx_no_data_payload = 1
        end;

        # put here only to separate always block from altxctrl for assignment order
        if (tx_state == tx_send_header) | (tx_state == tx_send_data)
            tx_trans_done_comb = tx_trans_done | (tx_data_last & tx_data_valid & tx_data_ready)
        else
            tx_trans_done_comb = 0
        end
    )
    altxctrl = @cpalways (
        if tx_state == tx_idle
            ufp_tx_data_valid_buf <= ufp_tx_data_valid
            ufp_tx_checksum_data_only_buf <= ufp_tx_checksum_data_only
            ufp_tx_total_length_data_only_buf <= ufp_tx_total_length_data_only
        end;
        if (tx_state == tx_send_header) | (tx_state == tx_send_data)
            # TODO: separate data related  connection to one always block
            if (~tx_no_data_payload) & (~tx_trans_done)
                tx_data_valid = ufp_tx_data_valid
                tx_data_last = ufp_tx_data_last
                ufp_tx_data_ready = tx_data_ready
                tx_data = ufp_tx_data
            else
                tx_data_valid = 0
                tx_data_last = 0
                ufp_tx_data_ready = 0
                tx_data = 0
            end

            if tx_data_last & tx_data_valid & tx_data_ready
                tx_trans_done <= 1
            end
        else
            tx_trans_done <= 0
            # tx_trans_done_comb = 0

            tx_data_valid = 0
            tx_data_last = 0
            ufp_tx_data_ready = 0
            tx_data = 0
        end
    )

    aldebug = @cpalways (
        transcond_rx_to_read_data = $(transcond(rx_state, @tstate rx_read_header => rx_read_data));
        debug_data_srv = {
            # $(Wireexpr(12, 0)),
            $(Wireexpr(1, 0)), connection_state,
            # $(Wireexpr(2, 0)), 
            rx_state,
            # $(Wireexpr(2, 0)), 
            tx_state,
            # {dfp_rx_data_strb, dfp_rx_data_valid, dfp_rx_data_ready},
            # $(Wireexpr(1, 0)), rx_data_last, rx_data_valid, rx_data_ready,
            # dfp_rx_data,
            snd_una, rcv_nxt,
            # $(Wireexpr(8, 0))
            };

        prev_debug_data_srv <= debug_data_srv;
        debug_valid_srv = ~(debug_data_srv == prev_debug_data_srv);
    )

    vpush!.(v, (
        prts,
        alconfig,
        connection_state, close_wait_sub_state, rx_state, tx_state,
        altcb, altcbutil, altcbupdate,
        alconnection...,
        alrxfsm, alrxctrl, alrxutil, alrxstrb, alrxsnapshot,
        altxdispatch, altxutil, altxmisc, altxmiscctrl, altxctrl...,
        aldebug...
    ))
    return v
end
