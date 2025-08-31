function generateRecvBufferSelector()
    depth = 8
    prts = @ports (
        @in CLK,RST;
        @in ufp_valid, ufp_last;
        @out @logic ufp_ready;
        @in 32 ufp_data;

        # valid at any dfp_valid cycle
        @out @logic 48 dest_addr, src_addr;

        @out @logic debug_valid;
        @out @logic 72 debug_data
    )
    basePorts = @ports (
        @in dfp_ready;
        @out @logic dfp_valid;
        @out @logic 32 dfp_data;
        @out @logic dfp_last;
    )

    arpPorts = renamedPorts(basePorts, x->"$(x)_arp")
    ipv4Ports = renamedPorts(basePorts, x->"$(x)_ipv4")

    fsm = @FSM state (
        init, 
        # testEther, connectArp,
        connectArp, connectIpv4,
        # testIp,
        explicitFlushBuffer
    )
    transadd!(fsm, @wireexpr(header_read_done & htype_arp), @tstate init => connectArp)
    transadd!(fsm, @wireexpr(header_read_done & htype_ipv4), @tstate init => connectIpv4)
    transadd!(fsm, @wireexpr(header_read_done), @tstate init => explicitFlushBuffer)

    transadd!(fsm, @wireexpr(ufp_valid & ufp_ready & ufp_last), @tstate connectArp => init)
    transadd!(fsm, @wireexpr(ufp_valid & ufp_ready & ufp_last), @tstate connectIpv4 => init)
    transadd!(fsm, @wireexpr(ufp_valid & ufp_ready & ufp_last), @tstate explicitFlushBuffer => init)
    
    # include first payload 2bytes
    header_dword_count = 4
    alfsm = @always (
        header_read_done = (header_read_counter == $(header_dword_count-1)) & ufp_ready & ufp_valid;
        htype_arp = ethertype_earliest == $(Wireexpr(16, 0x0806));
        htype_ipv4 = ethertype_earliest == $(Wireexpr(16, 0x0800))
    )
    alio = @always (
        if state == init
            ufp_ready = ~(header_read_counter == $header_dword_count)
        elseif state == connectArp
            ufp_ready = dfp_ready_arp
        elseif state == connectIpv4
            ufp_ready = dfp_ready_ipv4
        else
            ufp_ready = 1
        end;

        if state == connectArp
            dfp_valid_arp = ufp_valid
            dfp_last_arp = ufp_last
            dfp_data_arp = {ufp_data[15:0], payload_fallthrough}
        else
            dfp_valid_arp = 0
            dfp_last_arp = 0
            dfp_data_arp = 0
        end;

        if state == connectIpv4
            dfp_valid_ipv4 = ufp_valid
            dfp_last_ipv4 = ufp_last
            dfp_data_ipv4 = {ufp_data[15:0], payload_fallthrough}
        else
            dfp_valid_ipv4 = 0
            dfp_last_ipv4 = 0
            dfp_data_ipv4 = 0
        end;
    )
    alheadercomb = @always (
        # only used at the cycle where ufp_data is assigned to ethertype
        ethertype_earliest = {ufp_data[7:0],ufp_data[15:8]}
    )
    # dcls = @decls (
    #     # @logic 48 dest_addr, src_addr;
    #     # @logic 16 ethertype;
    # )
    aldata = @always (
        if state == init
            if ufp_ready & ufp_valid
                header_read_counter <= header_read_counter + $(Wireexpr(8, 1))

                if header_read_counter == 0
                    dest_addr[47:16] <= {ufp_data[7:0],ufp_data[15:8], ufp_data[23:16], ufp_data[31:24]}
                elseif header_read_counter == 1
                    dest_addr[15:0] <= {ufp_data[7:0],ufp_data[15:8]}
                    src_addr[47:32] <= {ufp_data[23:16], ufp_data[31:24]}
                elseif header_read_counter == 2
                    src_addr[31:0] <= {ufp_data[7:0],ufp_data[15:8], ufp_data[23:16], ufp_data[31:24]}
                elseif header_read_counter == 3
                    # ethertype <= {ufp_data[7:0],ufp_data[15:8]}
                    payload_fallthrough <= ufp_data[31:16]
                end
            end
        else
            header_read_counter <= 0
            if ufp_valid & ufp_ready
                payload_fallthrough <= ufp_data[31:16]
            end
        end
    )

    v = Vmodule("RecvBufferSelector_v2")
    vpush!.(v, (prts, arpPorts, ipv4Ports))
    vpush!.(v, (fsm, alfsm, alio, alheadercomb, aldata))

    return v
end

function generateBufferWithReadRandomAccess()
    # read as fifo, randomly accessible from dfp
    vname = "randomReadAccessBuffer"
    v = Vmodule(vname)
    prts = @ports (
        @in CLK, RST;

        @in ufp_wvalid;
        @in ufp_wlast;
        @in 32 ufp_wdata;
        @out @logic ufp_wready;

        @in 13 dfp_araddr; # word addressing
        @in dfp_arvalid;
        @out @logic dfp_arready;

        @out @logic dfp_rvalid, dfp_rinvalid;
        @out @logic 32 dfp_rdata;

        # force flush, also flush arready&arvalid transaction
        @in dfp_flush;
        @out @logic dfp_full;

        @out @logic debug_valid;
        @out @logic 72 debug_data;
    )

    width = 32
    depth = 13
    @sym2wire enread, enwrite, addrin, addrout, din
    dout, raminst = generateRamSdpRfInst(width, depth, enread, enwrite, addrin, addrout, din, vname)

    alctrl = @cpalways (
        dfp_full = full;
        ufp_wready = ~full;

        debug_data = 0;
        debug_valid = 0;

        if dfp_full & dfp_flush
            full <= 0
            wptr <= 0
        else
            if ufp_wvalid & ufp_wready
                debug_valid = 1
                debug_data = {$(Wireexpr(32-13-1, 0)), ufp_wlast, wptr, $(Wireexpr(8, 0)), ufp_wdata}

                wptr <= wptr + $(Wireexpr(depth, 1))
                if ufp_wlast
                    full <= $(Wireexpr(1, 1))
                end
            end
        end
    )

    alreadstallusage = @cpalways (
        if prev_read_stalling
            addrout = dfp_araddr_buf
        else
            addrout = dfp_araddr
        end;
        if read_stalling & ~prev_read_stalling
            dfp_araddr_buf <= dfp_araddr
        end;

        if dfp_full & dfp_flush
            prev_read_stalling <= 0
        else
            prev_read_stalling <= read_stalling
        end;
        dfp_arready = ~prev_read_stalling;
    )
    alread = @cpalways (
        dfp_rdata = $dout;
        enread = $(Wireexpr(1, 1));

        if (dfp_arvalid & dfp_arready) | prev_read_stalling
            if addrout < wptr
                dfp_rvalid <= 1
                dfp_rinvalid <= 0

                read_stalling = 0
            else
                if full
                    dfp_rvalid <= 0
                    dfp_rinvalid <= 1

                    read_stalling = 0
                else
                    dfp_rvalid <= 0
                    dfp_rinvalid <= 0

                    read_stalling = 1
                end
            end
        else
            read_stalling = 0
            dfp_rvalid <= 0
            dfp_rinvalid <= 0
        end
    )
    alwrite = @always (
        din = ufp_wdata;
        addrin = wptr;
        enwrite = (~full) & ufp_wvalid & ufp_wready;
    )

    vpush!.(v, (prts, raminst, alctrl..., alreadstallusage..., alread..., alwrite))
    return v
end
