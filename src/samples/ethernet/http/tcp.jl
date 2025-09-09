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

