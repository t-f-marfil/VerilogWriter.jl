let
    include("samples/ethernet/dhcp/uartMisc.jl")
    include("samples/ethernet/dhcp/asciiEncoder.jl")

    g = Vmodgraph()

    baud = 115200
    freq = 100 * 10^6
    # freq = 4baud
    dwid = 64 + 8

    vs = generateAsciiEncoder!(g, @ports (@in $dwid data))

    send = uartSend(baud, freq, name="UartSend_etherPassthru")
    g(
        vs[end] => send,
        @pconnect (
            dout => din,
            outValid => inValid
        )
    )
    g(
        send => vs[end],
        @pconnect (
            inUpdate => outUpdate
        )
    )

    vs = vfinalize(layer2vmod!(g, name="AsciiEncoder"))
    vexport(vs), vexport("$(getname(vs[begin]))_wrapper.v", wrappergen(vs[begin]))
end

function generateAxiControllerForEtherCore()
    prts = VerilogWriter.Core.generateAxi4Port(13, 32, 4, 4, true, "")
    v = Vmodule("EtherCoreAxiController")

    vpush!(v, prts)

    addrlen = 13
    datalen = 32
    
    # write from FIFO
    # input: wdatain, wwordcount, wdatavalid
    prts = @ports (
        @in awvalid_in;
        @in $addrlen awaddr_in;
        @in 8 awlen_in;
        @out @logic awready_out;
        
        @in wvalid_in;
        @in $datalen wdata_in;
        @out @logic wready_out;

        @in arvalid_in;
        @in $addrlen araddr_in;
        @in 8 arlen_in;
        @out @logic arready_out;

        @in rready_in;
        @out @logic rvalid_out;
        @out @logic rlast_out;
        @out @logic $datalen rdata_out;
    )
    vpush!(v, prts)

    al_passthru = @always (
        wdata = wdata_in;
        awlen = awlen_in;
        awaddr = awaddr_in;

        # wvalid = wvalid_in & wacceptable;
        # wready_out = wready & wacceptable;
        if wacceptable
            wvalid = wvalid_in
            wready_out = wready
        else
            wvalid = 0
            wready_out = 0
        end;

        if (awptr == wptr) | (awptr + ptrincr == wptr)
            awready_out = awready
            awvalid = awvalid_in
        else # awptr == wptr + ptrincr
            awready_out = 0
            awvalid = 0
        end;
    )
    al_write = @cpalways (
        ptrincr = 1;

        # never increment awptr when the previous write transaction is not done
        if (awptr == wptr) | (awptr + ptrincr == wptr)
            if awvalid & awready
                awptr <= awptr + $(Wireexpr(32, 1))
            end
        end;
        if wlast & wvalid & wready
            wptr <= wptr + $(Wireexpr(32, 1))
        end;

        wacceptable = $(Wireexpr(1, 0));
        # when wptr goes ahead stop accepting
        if awptr == wptr
            if awvalid
                wacceptable = 1
            end
        elseif awptr == (wptr + ptrincr)
            wacceptable = 1
        end;

        # not awvalid_in
        if awvalid
            awlen_in_buffer <= awlen_in
        end;

        # 0 if wptr is ahead
        wlast = 0;
        if awptr == wptr + ptrincr
            wlast = (awlen_in_buffer == wcounter) & wvalid
        elseif awptr == wptr
            # awlen == 0
            wlast = awvalid & (awlen_in == wcounter)
        end;

        if wvalid & wready
            if wlast
                wcounter <= 0
            else
                wcounter <= wcounter + 1
            end
        end
    )
    alread = @always (
        araddr = araddr_in;
        arvalid = arvalid_in;
        arlen = arlen_in;
        arready_out = arready;

        rready = rready_in;
        rvalid_out = rvalid;
        rlast_out = rlast;
        rdata_out = rdata;
    )
    alconst = @always (
        bready = 1;

        awid = 0;
        awsize = 2; # 4 byte = 32 bit
        awburst = 1; # INCR
        awlock = 0; # normal
        awcache = 0; # non bufferable
        awprot = 0; # may be data, secure, unprivileged
        awqos = 0;
        awregion = 0;
        awuser = 0;

        wuser = 0;
        wstrb = ~0;

        arid = 0;
        arsize = 2; # (1 << 2) = 4 byte = 32 bit
        arburst = 1; # INCR
        arlock = 0; # normal
        arcache = 0; # non bufferable
        arprot = 0; # may be data, secure, unprivileged
        arqos = 0;
        arregion = 0;
        aruser = 0;
    )

    vpush!(v, al_write..., al_passthru, alread, alconst)
    vpush!(v, @ports (@in CLK, RST))
    
    return v
end

function generateEtherCoreController()
    v = Vmodule("EtherCoreFunctionController")

    debug_width = 64 + 8

    prts = @ports (
        @in CLK, RST;

        @in intr;
        
        @out @logic awvalid;
        @out @logic 13 awaddr;
        @out @logic 8 awlen;
        @in awready;

        @out @logic wvalid;
        @out @logic 32 wdata;
        @in wready;

        @out @logic arvalid;
        @out @logic 13 araddr;
        @out @logic 8 arlen;
        @in arready;
        
        @out @logic rready;
        @in rvalid;
        @in rlast;
        @in 32 rdata;

        @out @logic 32 rdata_out;
        @in 32 wdata_in;

        # rupdate <=> raccept
        @in rupdate;
        @out @logic raccept;

        @out @logic rvalid_out;
        @out @logic rlast_out; # when one packet is fully read

        @out @logic $debug_width debug_data;
        @out @logic debug_valid;
    )

    gie_addr = 0x07F8
    recv_ctrl_ping_addr = 0x17FC
    recv_ctrl_pong_addr = 0x1FFC

    recv_buf_ping_addr = 0x1000
    recv_buf_pong_addr = 0x1800

    # include ip total size
    initial_read_dword = 5
    
    fsm_settings = @FSM state_settings giesettings, verifygiesettings, setreadintr, verify_read_intr, donesettings
    transadd!(fsm_settings, @wireexpr(giesettingsdone), @tstate giesettings => verifygiesettings)
    transadd!(fsm_settings, @wireexpr(vgsdone), @tstate verifygiesettings => setreadintr)
    transadd!(fsm_settings, @wireexpr(readintrdone), @tstate setreadintr => verify_read_intr)
    transadd!(fsm_settings, @wireexpr(verify_read_intr_done), @tstate verify_read_intr => donesettings)

    fsm_packet = @FSM state_packet idle_packet, get_packet_size, get_packet_full, clear_recv_packet_field
    transadd!(fsm_packet, @wireexpr(startreadpacket), @tstate idle_packet => get_packet_size)
    transadd!(fsm_packet, @wireexpr(rlast & packet_size_known), @tstate get_packet_size => get_packet_full)
    transadd!(fsm_packet, @wireexpr(rlast & ~packet_size_known), @tstate get_packet_size => clear_recv_packet_field)
    transadd!(fsm_packet, @wireexpr(rlast), @tstate get_packet_full => clear_recv_packet_field)
    transadd!(fsm_packet, @wireexpr(recv_flag_cleared), @tstate clear_recv_packet_field => idle_packet)

    alfsm = @always (
        giesettingsdone = awdone_settings & wdone_settings;
        vgsdone = rdone_vgs & ardone_vgs;
        readintrdone = awdone_setreadintr & wdone_setreadintr;
        verify_read_intr_done = ardone_verify_read_intr & rdone_verify_read_intr;

        startreadpacket = (state_settings == donesettings) & arvalid & arready;
        recv_flag_cleared = awdone_clear_recv_flag & wdone_clear_recv_flag;
    )
    almisc = @cpalways (
        wait_after_rst_axi_spec <= $(Wireexpr(1, 1));

        if state_settings == giesettings
            awdone_settings = awdone_settings_buf | (awvalid & awready)
            wdone_settings = wdone_settings_buf | (wvalid & wready)
            
            awdone_settings_buf <= awdone_settings
            wdone_settings_buf <= wdone_settings
        elseif state_settings == verifygiesettings
            ardone_vgs = ardone_vgs_buf | (arvalid & arready)
            rdone_vgs = rdone_vgs_buf | (rvalid & rready)

            ardone_vgs_buf <= ardone_vgs
            rdone_vgs_buf <= rdone_vgs
        elseif state_settings == setreadintr
            awdone_setreadintr = awdone_setreadintr_buf | (awvalid & awready)
            wdone_setreadintr = wdone_setreadintr_buf | (wvalid & wready)

            awdone_setreadintr_buf <= awdone_setreadintr
            wdone_setreadintr_buf <= wdone_setreadintr
        elseif state_settings == verify_read_intr
            ardone_verify_read_intr = ardone_verify_read_intr_buf | (arvalid & arready)
            rdone_verify_read_intr = rdone_verify_read_intr_buf | (rvalid & rready)

            ardone_verify_read_intr_buf <= ardone_verify_read_intr
            rdone_verify_read_intr_buf <= rdone_verify_read_intr
        else
            awdone_settings = 0;
            wdone_settings = 0;
            ardone_vgs = 0;
            rdone_vgs = 0;
            awdone_setreadintr = 0;
            wdone_setreadintr = 0;

            rdone_verify_read_intr = 0;
            ardone_verify_read_intr = 0;
        end;

        if state_packet == clear_recv_packet_field
            awdone_clear_recv_flag = awdone_clear_recv_flag_buf | (awvalid & awready)
            wdone_clear_recv_flag = wdone_clear_recv_flag_buf | (wvalid & wready)

            awdone_clear_recv_flag_buf <= awdone_clear_recv_flag;
            wdone_clear_recv_flag_buf <= wdone_clear_recv_flag;
        else
            awdone_clear_recv_flag = 0
            wdone_clear_recv_flag = 0
            awdone_clear_recv_flag_buf <= 0
            wdone_clear_recv_flag_buf <= 0
        end;

        if state_packet == get_packet_full
            ardone_get_packet_full_buf <= ardone_get_packet_full_buf | (arvalid & arready)
        else
            ardone_get_packet_full_buf <= 0
        end
    )
    almain = @always (
        {awvalid, awaddr, awlen} = 0;
        {wvalid, wdata} = 0;
        {arvalid, araddr, arlen} = 0;
        rready = 0;

        debug_valid = 0;
        debug_data = 0;

        if state_settings == giesettings
            awvalid = wait_after_rst_axi_spec & ~awdone_settings_buf
            awaddr = $gie_addr
            awlen = 0

            wdata = $(Wireexpr(32, 0x8000_0000))
            wvalid = ~wdone_settings_buf

            debug_valid = awdone_settings & wdone_settings
            debug_data = (0xC0 << 32) | (clk_counter << 40)
        elseif state_settings == verifygiesettings
            arvalid = ~ardone_vgs_buf
            araddr = $gie_addr
            arlen = 0

            rready = ~rdone_vgs_buf

            debug_data = (0x20 << 32) | {$(Wireexpr(debug_width - 32, 0)), rdata} | ({$(Wireexpr(debug_width - 1, 0)), rlast} << 32) | (clk_counter << 40);
            debug_valid = rvalid
        elseif state_settings == setreadintr
            awvalid = ~awdone_setreadintr_buf
            awaddr = $recv_ctrl_ping_addr
            awlen = 0

            # force clear buffer at the same time for simplicity
            wdata = 0x8
            wvalid = ~wdone_setreadintr_buf

            debug_data = (0x30 << 32) | (clk_counter << 40)
            debug_valid = awdone_setreadintr & wdone_setreadintr
        elseif state_settings == verify_read_intr
            arvalid = ~ardone_verify_read_intr_buf
            araddr = $recv_ctrl_ping_addr
            arlen = 0

            rready = ~rdone_verify_read_intr_buf

            debug_data = (0x60 << 32) | (clk_counter << 40) | {$(Wireexpr(debug_width - 32, 0)), rdata}
            # debug_valid = 1
            debug_valid = rvalid
        else
            if state_packet == idle_packet
                # if (rupdate & ())
                if (1 & ~(intr_counter_prev == intr_counter_post))
                    arvalid = 1
                    araddr = recv_buf_addr
                    arlen = $(initial_read_dword-1)
                end
            elseif state_packet == get_packet_size
                rready = 1

                debug_data = (0x40 << 32) | (clk_counter << 40) | {$(Wireexpr(debug_width - 32, 0)), rdata}
                debug_valid = rready & rvalid

                packet_size_known = rlast & ((ether_type == 0x0806) || (ether_type == 0x0800))
            elseif state_packet == get_packet_full
                arvalid = ~ardone_get_packet_full_buf
                araddr = recv_buf_addr + $initial_read_dword
                arlen = remainder_arlen

                rready = 1
                if ~ardone_get_packet_full_buf
                    debug_valid = arready
                    debug_data = (0xD0 << 32) | (clk_counter << 40) | {$(Wireexpr(debug_width - 32, 0)),ether_type, ip_length}
                else
                    debug_data = (0x70 << 32) | (clk_counter << 40) | {$(Wireexpr(debug_width - 32, 0)), rdata} | ({$(Wireexpr(debug_width - 1, 0)), rlast} << 32)
                    debug_valid = rready & rvalid
                end
            elseif state_packet == clear_recv_packet_field
                awvalid = ~awdone_clear_recv_flag_buf
                awaddr = recv_ctrl_addr
                awlen = 0

                wvalid = ~wdone_clear_recv_flag_buf
                if recv_ctrl_addr == $recv_ctrl_ping_addr
                    wdata = 0x8
                else
                    wdata = 0
                end

                debug_valid = awdone_clear_recv_flag & wdone_clear_recv_flag
                debug_data = (0x50 << 32) | (clk_counter << 40)
            end
        end
    )
    alpacket = @cpalways (
        clk_counter <= clk_counter + $(Wireexpr(debug_width, 1));
        intr_buf <= intr;
        intr_edge = intr & ~intr_buf;
        
        recv_ctrl_addr = $(Wireexpr(13, 0));
        recv_buf_addr = $(Wireexpr(13, 0));

        if intr_counter_prev[0]
            recv_buf_addr = $recv_buf_ping_addr
            recv_ctrl_addr = $recv_ctrl_ping_addr
        else
            recv_buf_addr = $recv_buf_pong_addr
            recv_ctrl_addr = $recv_ctrl_pong_addr
        end;

        if (intr_edge)
            intr_counter_prev <= intr_counter_prev + $(Wireexpr(2, 1))
        end;

        if $(transcond(fsm_packet, @tstate clear_recv_packet_field => idle_packet))
            intr_counter_post <= intr_counter_post + $(Wireexpr(2, 1))
        end;
    )

    algetsizeutil = @always (
        if state_packet == get_packet_size
            if rvalid & rready
                initial_read_dword_counter <= initial_read_dword_counter + $(Wireexpr(3, 1))
                if initial_read_dword_counter == 3
                    ether_type <= {rdata[7:0], rdata[15:8]}
                end
                if initial_read_dword_counter == 4
                    ip_length <= ip_length_comb
                    if ether_type == 0x0806
                        # ARP, 28 bytes of payload (7 DWORDs)
                        # additional 6 DWORD needed
                        remainder_arlen <= 5
                    elseif ether_type == 0x0800
                        # IP, (ip_length >> 2) + (1 if ip_length[1:0]) DWORDs in total
                        # (ip_length >> 2) + (1 or 0) - 1 additional DWORDs needed
                        # = (ip_length >> 2) - (0 or 1) DWORDS
                        if |(ip_length_comb[1:0])
                            remainder_arlen <= ip_length_comb[9:2] + minusone_arlen
                        else
                            remainder_arlen <= ip_length_comb[9:2] + minustwo_arlen
                        end
                    end
                end
            end
        # elseif state_packet == get_packet_full
        #     # pass, preserve ip_length and ether_type
        else
            initial_read_dword_counter <= 0
            if state_packet == get_packet_full
                # pass, preserve ip_length and ether_type
            else
                ether_type <= $(Wireexpr(16, 0))
                ip_length <= $(Wireexpr(16, 0))
            end
        end
    )
    algetsizeutil_comb = @always (
        ip_length_comb = {rdata[7:0], rdata[15:8]};
        minusone_arlen = ~$(Wireexpr(8, 0));
        minustwo_arlen = ~$(Wireexpr(8, 1));
    )

    vpush!(v, prts)
    vpush!(v, fsm_settings)
    vpush!(v, fsm_packet)
    vpush!.(v, (
        alfsm, almisc..., almain, alpacket...,
        algetsizeutil, algetsizeutil_comb
    ))

    return v
end

let
    g = Vmodgraph()

    v_axi_controller = generateAxiControllerForEtherCore()
    v_func_controller = generateEtherCoreController()

    g(
        v_func_controller => v_axi_controller,
        @pconnect (
            awvalid => awvalid_in,
            awaddr => awaddr_in,
            awlen => awlen_in,

            wvalid => wvalid_in,
            wdata => wdata_in,

            arvalid => arvalid_in,
            araddr => araddr_in,
            arlen => arlen_in,

            rready => rready_in,
        )
    )
    g(
        v_axi_controller => v_func_controller,
        @pconnect (
            awready_out => awready,
            wready_out => wready,

            arready_out => arready,
            rvalid_out => rvalid,
            rlast_out => rlast,
            rdata_out => rdata,
        )
    )

    vs = layer2vmod!(g, name="VServer")
    vs = vfinalize(vs)
    vexport(vs)


    wrapper_raw = wrappergen(vs[begin])

    vwrapper = Vmodule("VServer_wrapper")
    vpush!(vwrapper, wrapper_raw.insts)

    axi_controller_name = getname(v_axi_controller)

    for p in wrapper_raw.ports
        if occursin("$axi_controller_name", getname(p))
            newname = replace(getname(p), "_$axi_controller_name" => "")
            newp = Oneport(p.direc, p.direc == pin ? p.wtype : reg, p.width, newname)
            vpush!(vwrapper, newp)

            if p.direc == pin
                vpush!(vwrapper, @always (
                    $(getname(p)) = $(getname(newp))
                ))
                vpush!(vwrapper, @decls @reg $(p.width) $(getname(p)))
            else
                vpush!(vwrapper, @always (
                    $(getname(newp)) = $(getname(p))
                ))
                vpush!(vwrapper, @decls @wire $(p.width) $(getname(p)))
            end
        else
            vpush!(vwrapper, p)
        end
    end
    
    vwrapper = vfinalize(vwrapper)
    open("$(getname(vwrapper)).v", "w") do io
        write(io, string(vwrapper, false))
    end
end