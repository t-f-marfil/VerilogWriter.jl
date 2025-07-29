# let
include("../dhcp/uartMisc.jl")
include("../dhcp/asciiEncoder.jl")

function generateAsciiEncoderForServer()
    # include("samples/ethernet/dhcp/uartMisc.jl")
    # include("samples/ethernet/dhcp/asciiEncoder.jl")

    g = Vmodgraph()

    baud = 115200
    freq = 100 * 10^6
    # freq = 4baud
    dwid = 64 + 8

    vs = generateAsciiEncoder!(g, @ports(@in $dwid data), 512, "")

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
        @in wlast_in;
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

        wlast = wlast_in;
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
        @out @logic wlast;

        @out @logic arvalid;
        @out @logic 13 araddr;
        @out @logic 8 arlen;
        @in arready;
        
        @out @logic rready;
        @in rvalid;
        @in rlast;
        @in 32 rdata;

        @in 32 wdata_in;

        # rupdate <=> raccept
        @in rupdate;
        @out @logic raccept;
        @out @logic 32 rdata_out;

        @out @logic rvalid_out;
        @out @logic rlast_out; # when one packet is fully read

        @in 8 awlen_in;
        @in awvalid_in;
        @out @logic awready_out;
        @in wvalid_in;
        @in wlast_in;
        @out @logic wready_out;

        @out @logic $debug_width debug_data;
        @out @logic debug_valid;
    )

    gie_addr = 0x07F8
    recv_ctrl_ping_addr = 0x17FC
    recv_ctrl_pong_addr = 0x1FFC

    recv_buf_ping_addr = 0x1000
    recv_buf_pong_addr = 0x1800

    send_ctrl_ping_addr = 0x07FC
    send_ctrl_pong_addr = 0x0FFC

    send_length_ping_addr = 0x07F4
    send_length_pong_addr = 0x0FF4

    send_buf_ping_addr = 0x0000
    send_buf_pong_addr = 0x0800

    # include ip total size
    initial_read_dword = 5
    
    fsm_settings = @FSM state_settings giesettings, verifygiesettings, setreadintr, verify_read_intr, donesettings
    transadd!(fsm_settings, @wireexpr(giesettingsdone), @tstate giesettings => verifygiesettings)
    transadd!(fsm_settings, @wireexpr(vgsdone), @tstate verifygiesettings => setreadintr)
    transadd!(fsm_settings, @wireexpr(readintrdone), @tstate setreadintr => verify_read_intr)
    transadd!(fsm_settings, @wireexpr(verify_read_intr_done), @tstate verify_read_intr => donesettings)

    # NOTE: prioritize packet read operation over write here
    fsm_packet = @FSM state_packet idle_packet, get_packet_size, get_packet_full, clear_recv_packet_field, test_send_possible, set_packet_data, set_send_packet_field, set_send_packet_length, trigger_send_packet
    transadd!(fsm_packet, @wireexpr(startreadpacket & arready & arvalid), @tstate idle_packet => get_packet_size)
    transadd!(fsm_packet, @wireexpr(rlast & packet_size_known), @tstate get_packet_size => get_packet_full)
    transadd!(fsm_packet, @wireexpr(rlast & ~packet_size_known), @tstate get_packet_size => clear_recv_packet_field)
    transadd!(fsm_packet, @wireexpr(rlast), @tstate get_packet_full => clear_recv_packet_field)
    transadd!(fsm_packet, @wireexpr(recv_flag_cleared), @tstate clear_recv_packet_field => idle_packet)
    
    transadd!(fsm_packet, @wireexpr(startreadsendctrl & arready & arvalid), @tstate idle_packet => test_send_possible)
    transadd!(fsm_packet, @wireexpr(tx_buffer_full), @tstate test_send_possible => idle_packet)
    transadd!(fsm_packet, @wireexpr(tx_buffer_empty), @tstate test_send_possible => set_send_packet_field)
    transadd!(fsm_packet, @wireexpr(tx_buffer_filled), @tstate set_send_packet_field => set_send_packet_length)
    transadd!(fsm_packet, @wireexpr(send_length_set), @tstate set_send_packet_length => trigger_send_packet)
    transadd!(fsm_packet, @wireexpr(send_flag_set), @tstate trigger_send_packet => idle_packet)

    alfsm = @always (
        giesettingsdone = awdone_settings & wdone_settings;
        vgsdone = rdone_vgs & ardone_vgs;
        readintrdone = awdone_setreadintr & wdone_setreadintr;
        verify_read_intr_done = ardone_verify_read_intr & rdone_verify_read_intr;

        # # TODO: separate transition condition in idle_packet
        # # but do not want to write in al_main for readability
        # startreadpacket = (state_settings == donesettings) & trigger_read_packet & arvalid & arready;
        # startreadsendctrl = (state_settings == donesettings) & (~trigger_read_packet) & awvalid_in & arvalid & arready;
        
        recv_flag_cleared = awdone_clear_recv_flag & wdone_clear_recv_flag;
        tx_buffer_full = rready & rvalid & rlast & rdata[0];
        tx_buffer_empty = rready & rvalid & rlast & (~rdata[0]);
        tx_buffer_filled = awdone_set_send_packet & wdone_set_send_packet;
        send_flag_set = awdone_trigger_send_packet & wdone_trigger_send_packet;
        send_length_set = awdone_set_send_length & wdone_set_send_length
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
        end;

        if state_packet == set_send_packet_field
            awdone_set_send_packet = (awready & awvalid) | awdone_set_send_packet_buf
            awdone_set_send_packet_buf <= awdone_set_send_packet

            wdone_set_send_packet = (wvalid & wready & wlast) | wdone_set_send_packet_buf
            wdone_set_send_packet_buf <= wdone_set_send_packet

            if awvalid & awready
                awlen_buf_set_send_packet <= awlen
            end
        else
            if ~(state_packet == set_send_packet_length)
                awlen_buf_set_send_packet <= 0
            end
            awdone_set_send_packet = 0
            awdone_set_send_packet_buf <= 0

            wdone_set_send_packet = 0
            wdone_set_send_packet_buf <= 0
        end;

        if state_packet == set_send_packet_length
            awdone_set_send_length = (awready & awvalid) | awdone_set_send_length_buf
            awdone_set_send_length_buf <= awdone_set_send_length

            wdone_set_send_length = (wvalid & wready) | wdone_set_send_length_buf
            wdone_set_send_length_buf <= wdone_set_send_length
        else
            awdone_set_send_length = 0
            awdone_set_send_length_buf <= 0

            wdone_set_send_length = 0
            wdone_set_send_length_buf <= 0
        end;

        if state_packet == trigger_send_packet
            awdone_trigger_send_packet = awdone_trigger_send_packet_buf | (awvalid & awready)
            awdone_trigger_send_packet_buf <= awdone_trigger_send_packet
            
            wdone_trigger_send_packet = wdone_trigger_send_packet_buf | (wvalid & wready)
            wdone_trigger_send_packet_buf <= wdone_trigger_send_packet
        else
            awdone_trigger_send_packet = 0
            awdone_trigger_send_packet_buf <= 0
            
            wdone_trigger_send_packet = 0
            wdone_trigger_send_packet_buf <= 0
        end
    )
    almain = @always (
        {awvalid, awaddr, awlen} = 0;
        {wvalid, wdata, wlast} = 0;
        {arvalid, araddr, arlen} = 0;
        rready = 0;
        {awready_out, wready_out} = 0;

        debug_valid = 0;
        debug_data = 0;

        startreadpacket = 0;
        startreadsendctrl = 0;

        if state_settings == giesettings
            awvalid = wait_after_rst_axi_spec & ~awdone_settings_buf
            awaddr = $gie_addr
            awlen = 0

            wdata = $(Wireexpr(32, 0x8000_0000))
            wvalid = ~wdone_settings_buf
            wlast = ~wdone_settings_buf

            debug_valid = awdone_settings & wdone_settings
            debug_data = (0x10 << 32) | (clk_counter << 40)
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
            wlast = ~wdone_setreadintr_buf

            debug_data = (0x30 << 32) | (clk_counter << 40)
            debug_valid = awdone_setreadintr & wdone_setreadintr
        elseif state_settings == verify_read_intr
            arvalid = ~ardone_verify_read_intr_buf
            araddr = $recv_ctrl_ping_addr
            arlen = 0

            rready = ~rdone_verify_read_intr_buf

            debug_data = (0x40 << 32) | (clk_counter << 40) | {$(Wireexpr(debug_width - 32, 0)), rdata}
            # debug_valid = 1
            debug_valid = rvalid
        else
            if state_packet == idle_packet
                # if (rupdate & ())
                if (1 & ~(intr_counter_prev == intr_counter_post))
                # if trigger_read_packet
                    arvalid = 1
                    araddr = recv_buf_addr
                    arlen = $(initial_read_dword-1)

                    startreadpacket = 1
                elseif awvalid_in
                    # query if transmit buffer is empty
                    # TODO: check if interval from last tx is wide enough
                    arvalid = 1
                    araddr = send_ctrl_addr
                    arlen = 0

                    startreadsendctrl = 1
                end
            elseif state_packet == get_packet_size
                rready = 1

                debug_data = (0x50 << 32) | (clk_counter << 40) | {$(Wireexpr(debug_width - 32, 0)), rdata}
                debug_valid = rready & rvalid

                packet_size_known = rlast & ((ether_type == 0x0806) || (ether_type == 0x0800))
            elseif state_packet == get_packet_full
                arvalid = ~ardone_get_packet_full_buf
                araddr = recv_buf_addr + $initial_read_dword
                arlen = remainder_arlen

                rready = 1
                if ~ardone_get_packet_full_buf
                    debug_valid = arready
                    debug_data = (0x60 << 32) | (clk_counter << 40) | {$(Wireexpr(debug_width - 32, 0)),ether_type, ip_length}
                else
                    debug_data = (0x70 << 32) | (clk_counter << 40) | {$(Wireexpr(debug_width - 32, 0)), rdata} | ({$(Wireexpr(debug_width - 1, 0)), rlast} << 32)
                    debug_valid = rready & rvalid
                end
            elseif state_packet == clear_recv_packet_field
                awvalid = ~awdone_clear_recv_flag_buf
                awaddr = recv_ctrl_addr
                awlen = 0

                wvalid = ~wdone_clear_recv_flag_buf
                wlast = ~wdone_clear_recv_flag_buf
                if recv_ctrl_addr == $recv_ctrl_ping_addr
                    wdata = 0x8
                else
                    wdata = 0
                end

                debug_valid = awdone_clear_recv_flag & wdone_clear_recv_flag
                debug_data = (0x80 << 32) | (clk_counter << 40)
            elseif state_packet == test_send_possible
                rready = 1

                debug_valid = rlast & rready & rvalid
                debug_data = (0x90 << 32) | (clk_counter << 40) | {$(Wireexpr(debug_width-1, 0)), rdata[0]}
            elseif state_packet == set_send_packet_field
                awvalid = awvalid_in & ~awdone_set_send_packet_buf
                awready_out = awready & ~awdone_set_send_packet_buf
                awaddr = send_buf_addr
                awlen = awlen_in
                
                wvalid = wvalid_in & ~wdone_set_send_packet_buf
                wready_out = wready & ~wdone_set_send_packet_buf
                wdata = wdata_in
                wlast = wlast_in & ~wdone_set_send_packet_buf

                debug_data = ({$(Wireexpr(debug_width-1,0)), wlast} << 32) | (0xA0 << 32) | (clk_counter << 40) | {$(Wireexpr(debug_width-32,0)), wdata}
                debug_valid = wready & wvalid
            elseif state_packet == set_send_packet_length
                awvalid = ~awdone_set_send_length_buf
                awlen = 0
                awaddr = send_length_addr

                wvalid = ~wdone_set_send_length_buf
                wlast = ~wdone_set_send_length_buf
                wdata = ({$(Wireexpr(32 - 8, 0)), awlen_buf_set_send_packet} << 2) + 2

                debug_data = (0xC0 << 32) | (clk_counter << 40)
                debug_valid = wdone_set_send_length & awdone_set_send_length
            elseif state_packet == trigger_send_packet
                awvalid = ~awdone_trigger_send_packet_buf
                awaddr = send_ctrl_addr
                awlen = 0

                wvalid = ~wdone_trigger_send_packet_buf
                wlast = ~wdone_trigger_send_packet_buf
                wdata = 0x1

                debug_valid = wdone_trigger_send_packet & awdone_trigger_send_packet
                debug_data = (0xB0 << 32) | (clk_counter << 40)
            end
        end
    )
    alpacket = @cpalways (
        clk_counter <= clk_counter + $(Wireexpr(debug_width, 1));
        intr_buf <= intr;
        intr_edge = intr & ~intr_buf;
        
        recv_ctrl_addr = $(Wireexpr(13, 0));
        recv_buf_addr = $(Wireexpr(13, 0));

        send_ctrl_addr = $(Wireexpr(13, 0));
        send_buf_addr = $(Wireexpr(13, 0));
        send_length_addr = $(Wireexpr(13, 0));

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

        if write_parity == $(Wireexpr(1, 0))
            send_buf_addr = $send_buf_ping_addr
            send_ctrl_addr = $send_ctrl_ping_addr
            send_length_addr = $send_length_ping_addr
        else
            send_buf_addr = $send_buf_pong_addr
            send_ctrl_addr = $send_ctrl_pong_addr
            send_length_addr = $send_length_pong_addr
        end;

        if $(transcond(fsm_packet, @tstate trigger_send_packet => idle_packet))
            write_parity <= ~write_parity
        end
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

function sampleArpPacketGen()
    v = Vmodule("sampleArpInput")
    prts = @ports (
        @in CLK, RST;
        @in awready;
        @out @logic awvalid;
        @out @logic 8 awlen;

        @in wready;
        @out @logic wvalid;
        @out @logic wlast;
        @out @logic 32 wdata;

        @in btn;
    )

    data = [
        0xFFFF_FFFF,
        0x0000_FFFF,
        0xCEFA_005E,
        0x0100_0608,
        0x0406_0008,
        0x0000_0100,
        0xCEFA_005E,
        0x0000_0000,
        0x0000_0000,
        0xFEA9_0000,
        0x0000_0A0A
    ]
    @assert length(data) > 0
    
    (datavalid, outdata), p = readOnlyQueueComb(32, data, @wireexpr(wready), @wireexpr(restart))

    al = @cpalways (
        awlen = $(length(data) - 1);
        awvalid = ~(wcounter == $(length(data)));

        wlast = 0;
        wdata = $outdata;
        restart = 0;
        wvalid = $datavalid & ~(wcounter == $(length(data)));
        if wcounter == awlen
            # if wvalid & wready
            #     wcounter <= 0
            # end
            wlast = 1;
        end;

        if wvalid & wready
            wcounter <= wcounter + 1
        end;

        if btn
            if (wcounter == $(length(data))) & (~(wvalid & wready))
                restart = $(Wireexpr(1,1))
                wcounter <= 0
            end
        end
    )

    vpush!.(v, (prts, p, al...))
    return v
end

let
    v = sampleArpPacketGen()
    v = vfinalize(v)

    vexport(v)
    wrapper = wrappergen(v)
    vexport("$(getname(wrapper)).v", wrapper)
end

function generateServerAll()
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
            wlast => wlast_in,

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

    dot = dotgen(g)
    println(dot)
end


generateAsciiEncoderForServer()
generateServerAll()