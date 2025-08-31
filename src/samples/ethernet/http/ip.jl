function generateIpPacketSimpleGenerator()
    # no ip opions available
    # ttl = 128
    # diffserv = 0
    # incremental identification for now
    prts = @ports (
        @in CLK,RST;

        @out @logic wvalid;
        @out @logic 32 wdata;
        @out @logic wlast;
        @in wready;

        @in 32 wdata_in;
        @in wvalid_in;
        @in wlast_in;
        @out @logic wready_out;

        @in commandValid;
        @out @logic commandReady;
        # total length of ip data field only
        @in 16 totalLength;
        @in 32 sourceAddr, destAddr;
        @in 8 protocol;

        @out @logic 16 etherType;
    )

    fsm = @FSM state idle, header, payload
    transadd!(fsm, @wireexpr(commandReady & commandValid), @tstate idle => header)
    transadd!(fsm, @wireexpr((headerCounter == 4) & wvalid & wready), @tstate header => payload)
    transadd!(fsm, @wireexpr(wvalid & wready & wlast), @tstate payload => idle)
    
    # maximum carry in the first checksum calculation : 9 (for no option is available here)
    # -> 4 bit + 16 bit
    almain = @always (
        if state == header
            wvalid = 1
            wready_out = 0
            wlast = 0

            if headerCounter == 0
                wdata = {totalLengthIp[7:0], totalLengthIp[15:8], $(Wireexpr(16, 0x00_45))}
            elseif headerCounter == 1
                wdata = {$(Wireexpr(16, 0)), identification[7:0], identification[15:8]}
            elseif headerCounter == 2
                wdata = {checksum[7:0], checksum[15:8], protocolBuf, ttl}
            elseif headerCounter == 3
                wdata = {sourceAddrBuf[7:0], sourceAddrBuf[15:8], sourceAddrBuf[23:16], sourceAddrBuf[31:24]}
            else
                wdata = {destAddrBuf[7:0], destAddrBuf[15:8], destAddrBuf[23:16], destAddrBuf[31:24]}
            end

        elseif state == payload
            wvalid = wvalid_in
            wdata = wdata_in
            wlast = wlast_in
            wready_out = wready
        else
            wvalid = 0
            wdata = 0
            wlast = 0
            wready_out = 0
        end
    )
    almisc = @cpalways (
        etherType = 0x0800;
        totalLengthIp = totalLengthBuf + 20;
        ttl = $(Wireexpr(8, 128));
        
        sumh1 = {$(Wireexpr(4, 0)), $(Wireexpr(16, 0x4500))} + {$(Wireexpr(4, 0)), totalLengthIp};
        sumh2 = {$(Wireexpr(4, 0)), identification} + {$(Wireexpr(4, 0)), ttl, protocolBuf};
        sumh4 = {$(Wireexpr(4, 0)), sourceAddrBuf[31:16]} + {$(Wireexpr(4, 0)), sourceAddrBuf[15:0]};
        sumh5 = {$(Wireexpr(4, 0)), destAddrBuf[31:16]} + {$(Wireexpr(4, 0)), destAddrBuf[15:0]};

        sum_first = (sumh1_2 + sumh4_5) | $(Wireexpr(20, 0));
        sum_second = ({$(Wireexpr(1, 0)), sum_first[15:0]} + {$(Wireexpr(13, 0)), sum_first[19:16]}) | $(Wireexpr(17, 0));

        checksum = 0;
        commandReady = 0;
        
        if state == header
            if headerCounter == 0
                sumh1_2 <= sumh1 + sumh2
                sumh4_5 <= sumh4 + sumh5
            elseif headerCounter == 1
                sum_third <= sum_second[15:0] + {$(Wireexpr(15, 0)), sum_second[16]}
            elseif headerCounter == 2
                checksum = ~sum_third
            end
        end;
        if state == idle
            commandReady = 1
            if commandReady & commandValid
                totalLengthBuf <= totalLength
                sourceAddrBuf <= sourceAddr
                destAddrBuf <= destAddr
                protocolBuf <= protocol
            end
        end;

        if state == header
            if wvalid & wready
                # IHL is 4bit wide
                headerCounter <= headerCounter + $(Wireexpr(4, 1))
            end
        else
            headerCounter <= 0
        end;

        if $(transcond(fsm, @tstate payload => idle))
            identification <= identification + $(Wireexpr(16, 1))
        end
    )

    v = Vmodule("IpPacketSimpleGenerator")
    vpush!.(v, (prts, fsm, almain, almisc...))
    return v
end

function generateIpv4BufferSelector()
    v = Vmodule("ipv4BufferSelector")
    prts = @ports (
        @in CLK, RST;
        
        @in ufp_valid, ufp_last;
        @in 32 ufp_data;
        @out @logic ufp_ready;

        @out @logic debug_valid;
        @out @logic 72 debug_data;

        @out @logic 32 source_address, destination_address;

        # TODO: this is not ipv4
        @in 48 ether_src_addr_in, ether_dest_addr_in;
        @out @logic 48 ether_src_addr_out, ether_dest_addr_out;
    )
    basePorts = @ports (
        @in dfp_ready;
        @out @logic dfp_valid;
        @out @logic 32 dfp_data;
        @out @logic dfp_last;
    )

    alnonipv4 = @always (
        if ufp_valid & ufp_ready
            ether_src_addr_out <= ether_src_addr_in
            ether_dest_addr_out <= ether_dest_addr_in
        end
    )

    icmpPorts = renamedPorts(basePorts, x->"$(x)_icmp")

    # least prioritize transition to explicitFlushBuffer (except for unknownError)
    fsm = @FSM state (
        init,
        connectIcmp,
        explicitFlushBuffer,
        unknownError
    )

    transadd!(fsm, @wireexpr(header_read_done & protocol_icmp), @tstate init => connectIcmp)
    transadd!(fsm, @wireexpr(invalid_ip_packet | header_read_done), @tstate init => explicitFlushBuffer)

    transadd!(fsm, @wireexpr(ufp_valid & ufp_ready & ufp_last), @tstate connectIcmp => init)
    transadd!(fsm, @wireexpr(ufp_valid & ufp_ready & ufp_last), @tstate explicitFlushBuffer => init)

    transadd!(fsm, @wireexpr(ufp_valid & ufp_ready & ufp_last), @tstate init => unknownError)
    transadd!(fsm, @wireexpr(1), @tstate unknownError => init)

    common_header_dword_count = 5
    alfsm = @always (
        ihl_minusone = ihl + ~0;

        if state == init
            invalid_ip_packet = (0 < header_read_counter) & (ihl < $common_header_dword_count)

            header_read_done = (header_read_counter == {$(Wireexpr(4, 0)), ihl_minusone}) & ufp_valid & ufp_ready
            protocol_icmp = protocol == 0x01
        end
    )

    alio = @always (
        if state == init
            ufp_ready = (header_read_counter < $common_header_dword_count) | (header_read_counter < {$(Wireexpr(4, 0)), ihl})
        elseif state == connectIcmp
            ufp_ready = dfp_ready_icmp
        elseif state == explicitFlushBuffer
            ufp_ready = 1
        else
            ufp_ready = 0
        end;

        if state == connectIcmp
            dfp_valid_icmp = ufp_valid
            dfp_last_icmp = ufp_last
            dfp_data_icmp = ufp_data
        else
            dfp_valid_icmp = 0
            dfp_last_icmp = 0
            dfp_data_icmp = 0
        end
    )

    aldata = @always (
        if state == init
            if ufp_valid & ufp_ready
                header_read_counter <= header_read_counter + $(Wireexpr(8, 1))

                if header_read_counter == 0
                    version <= ufp_data[7:4]
                    ihl <= ufp_data[3:0]
                    diffserv <= ufp_data[15:8]
                    total_length <= {ufp_data[23:16], ufp_data[31:24]} | $(Wireexpr(16, 0))
                elseif header_read_counter == 1
                    identification <= {ufp_data[7:0], ufp_data[15:8]} | $(Wireexpr(16, 0))
                    flags <= ufp_data[23:21]
                    fragment_offset <= {ufp_data[20:16], ufp_data[31:24]} | $(Wireexpr(13, 0))
                elseif header_read_counter == 2
                    ttl <= ufp_data[7:0]
                    protocol <= ufp_data[15:8]
                    header_checksum <= {ufp_data[23:16], ufp_data[31:24]} | $(Wireexpr(16, 0))
                elseif header_read_counter == 3
                    source_address <= {ufp_data[7:0],ufp_data[15:8], ufp_data[23:16], ufp_data[31:24]}
                elseif header_read_counter == 4
                    destination_address <= {ufp_data[7:0],ufp_data[15:8], ufp_data[23:16], ufp_data[31:24]}
                end
            end
        else
            header_read_counter <= 0
        end
    )

    vpush!.(v, (
        prts, icmpPorts,
        alnonipv4,
        fsm, alfsm,
        alio, aldata
    ))

    return v
end
