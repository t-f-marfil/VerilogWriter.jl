function generateLinkLocalIpClaimer(probe_timeout_cycle, probe_initial_wait_cycle, second_announce_wait_cycle)
    v = Vmodule("LinkLocalIpClaimer")

    prts = @ports (
        @in CLK,RST;

        @in start;

        @out @logic 48 tx_destMacAddr;
        @out @logic 16 tx_etherType, tx_opcode;
        @out @logic 32 tx_senderIpAddr, tx_targetIpAddr;

        @out @logic tx_etherFrameCommandValid, tx_arpReqCommandValid;
        @in tx_etherFrameCommandReady, tx_arpReqCommandReady;

        @out @logic 13 rx_araddr;
        @out @logic rx_arvalid;
        @in rx_arready;

        @in rx_rvalid, rx_rinvalid;
        @in 32 rx_rdata;

        @out @logic rx_flush;
        @in rx_full;

        @out @logic debug_valid;
        @out @logic 72 debug_data;
    )

    PROBE_NUM = 3

    tx_fsm = @FSM txfsm idle,probing,announcing1,configured,announcing2,responding,defending
    transadd!(tx_fsm, @wireexpr(start & (rx_flush_state == rx_hold_frame_now)), @tstate idle => probing)
    transadd!(tx_fsm, @wireexpr(probe_conflict), @tstate probing => idle)
    transadd!(tx_fsm, @wireexpr(probe_done), @tstate probing => announcing1)
    transadd!(tx_fsm, @wireexpr(tx_etherFrameDone & tx_arpReqCommandDone), @tstate announcing1 => configured)

    transadd!(tx_fsm, @wireexpr(second_announce_timer == $(Wireexpr(48, second_announce_wait_cycle))), @tstate configured => announcing2)
    transadd!(tx_fsm, @wireexpr(tx_etherFrameDone & tx_arpReqCommandDone), @tstate announcing2 => configured)

    transadd!(tx_fsm, @wireexpr(rx_arp_response_needed), @tstate configured => responding)
    transadd!(tx_fsm, @wireexpr(tx_etherFrameDone & tx_arpReqCommandDone), @tstate responding => configured)

    transadd!(tx_fsm, @wireexpr(rx_arp_defense_needed), @tstate configured => defending)
    transadd!(tx_fsm, @wireexpr(tx_etherFrameDone & tx_arpReqCommandDone), @tstate defending => configured)

    altx = @always (
        {tx_destMacAddr, tx_etherType, tx_senderIpAddr, tx_targetIpAddr} = 0;
        tx_etherFrameCommandValid = 0;
        tx_arpReqCommandValid = 0;
        tx_opcode = 0;
        
        tx_etherType = 0x0806;

        if txfsm == probing
            tx_destMacAddr = ~0
            tx_opcode = 1 # request
            tx_senderIpAddr = 0
            tx_targetIpAddr = claiming_ip

            if tx_probe_timeout_state == trigger_probe
                tx_etherFrameCommandValid = ~tx_etherFrameDone_buf
                tx_arpReqCommandValid = ~tx_arpReqCommandDone_buf
            end
        elseif (txfsm == announcing1) || (txfsm == announcing2) || (txfsm == defending)
            tx_destMacAddr = ~0
            tx_opcode = 1 # request

            tx_senderIpAddr = claiming_ip
            tx_targetIpAddr = claiming_ip

            tx_etherFrameCommandValid = ~tx_etherFrameDone_buf
            tx_arpReqCommandValid = ~tx_arpReqCommandDone_buf
        elseif txfsm == responding
            tx_destMacAddr = rx_sender_mac
            tx_opcode = 2 # response

            tx_senderIpAddr = claiming_ip
            tx_targetIpAddr = rx_sender_ip

            tx_etherFrameCommandValid = ~tx_etherFrameDone_buf
            tx_arpReqCommandValid = ~tx_arpReqCommandDone_buf
        end
    )
    max_rx_words = 5
    dcls = @decls (
        @logic 32 rx_sender_ip, rx_target_ip;
        @logic 48 rx_sender_mac;
    )
    alrx = @always (
        if (txfsm == probing) & (rx_rcounter == $max_rx_words)
            # 1. compare rx sender ip <=> probing ip
            # 2. (if sender ip == 0, i.e. probe) compare target ip <=> probing ip
            #   also check hardware address to ensure that the packet is not of loopback
            # if rx_arvalid & rx_arready
            #     rx_arcounter <= rx_arcounter + $(Wireexpr(8, 1))
            # end
            rx_sender_ip_conflict = rx_sender_ip == claiming_ip;
            rx_hardware_addr_is_self = rx_sender_mac == self_mac;
            rx_target_ip_is_self = rx_target_ip == claiming_ip;
            
            probe_conflict = rx_sender_ip_conflict | ((rx_sender_ip == 0) & rx_target_ip_is_self & ~rx_hardware_addr_is_self)
        else
            rx_sender_ip_conflict = 0
            rx_hardware_addr_is_self = 0
            rx_target_ip_is_self = 0
            probe_conflict = 0
        end;

        if (txfsm == configured) & (rx_rcounter == $max_rx_words)
            rx_arp_response_needed = (rx_target_ip == claiming_ip) & ~(rx_sender_mac == self_mac)
            rx_arp_defense_needed = (rx_sender_ip == claiming_ip) & ~(rx_sender_mac == self_mac)
        else
            rx_arp_response_needed = 0
            rx_arp_defense_needed = 0
        end
    )
    al_second_announce = @always (
        if $(transcond(tx_fsm, @tstate announcing1 => configured))
            second_announce_timer_start <= $(Wireexpr(1, 1))
        elseif $(transcond(tx_fsm, @tstate announcing2 => configured))
            second_announce_timer_start <= 0
        end;

        if $(transcond(tx_fsm, @tstate announcing2 => configured))
            second_announce_timer <= 0
        elseif second_announce_timer_start
            if ~(second_announce_timer == $(Wireexpr(48, second_announce_wait_cycle)))
                second_announce_timer <= second_announce_timer + 1
            end
        end
    )
    rx_flush_fsm = @FSM rx_flush_state rx_hold_frame_now,rx_flush_frame_now
    transadd!(rx_flush_fsm, @wireexpr(rx_read_frame_done), @tstate rx_hold_frame_now => rx_flush_frame_now)
    transadd!(rx_flush_fsm, @wireexpr(rx_flush & rx_full), @tstate rx_flush_frame_now => rx_hold_frame_now)
    alrxmisc = @always (
        if ~(txfsm == idle)
            if $(transcond(rx_flush_fsm, @tstate rx_hold_frame_now => rx_flush_frame_now))
                rx_arcounter <= 0
                rx_rcounter <= 0

                rx_rinvalid_buf <= 0
                rx_sender_mac <= 0
                rx_sender_ip <= 0
                rx_target_ip <= 0
            elseif rx_flush_state == rx_hold_frame_now
                if rx_rvalid
                    rx_rcounter <= rx_rcounter + $(Wireexpr(8, 1))
                    if rx_rcounter == 0
                        rx_sender_mac[47:32] <= {rx_rdata[23:16], rx_rdata[31:24]}
                    elseif rx_rcounter == 1
                        rx_sender_mac[31:0] <= {rx_rdata[7:0], rx_rdata[15:8], rx_rdata[23:16], rx_rdata[31:24]}
                    elseif rx_rcounter == 2
                        rx_sender_ip <= {rx_rdata[7:0], rx_rdata[15:8], rx_rdata[23:16], rx_rdata[31:24]}
                    elseif rx_rcounter == 3
                        rx_target_ip[31:16] <= {rx_rdata[23:16], rx_rdata[31:24]}
                    elseif rx_rcounter == 4
                        rx_target_ip[15:0] <= {rx_rdata[7:0], rx_rdata[15:8]}
                    end
                end

                if rx_arvalid & rx_arready
                    rx_arcounter <= rx_arcounter + $(Wireexpr(8, 1))
                end

                if rx_rinvalid
                    rx_rinvalid_buf <= $(Wireexpr(1, 1))
                end
            end
        else
            rx_arcounter <= 0
            rx_rcounter <= 0

            rx_rinvalid_buf <= 0
            rx_sender_mac <= 0
            rx_sender_ip <= 0
            rx_target_ip <= 0
        end
    )
    alrxflushfsm = @always (
        # prioritize 2nd announcement over rx parsing
        if (txfsm == probing)
            rx_read_frame_done = (rx_rcounter == $(max_rx_words-1)) & rx_rvalid
        elseif ((txfsm == configured)
            # Must flush if trivial arp packet found,
            # But also must not flush if response/defense needed
             & ~$(transcond(tx_fsm, @tstate configured => announcing2))
             & ~$(transcond(tx_fsm, @tstate configured => responding))
             & ~$(transcond(tx_fsm, @tstate configured => defending)))
            rx_read_frame_done = (rx_rcounter == $max_rx_words)
        elseif ($(transcond(tx_fsm, @tstate responding => configured))
            || $(transcond(tx_fsm, @tstate defending => configured)))
            rx_read_frame_done = 1
        else
            # hold packet after announcing1 if busy
            rx_read_frame_done = 0
        end
    )
    alrxctrl = @always (
        rx_flush = 0;
        rx_araddr = 0;
        rx_arvalid = 0;

        if txfsm == idle
            rx_flush = 1
        else
            if rx_flush_state == rx_hold_frame_now
                rx_arvalid = ~(rx_arcounter == $max_rx_words)

                if rx_arcounter == 0
                    rx_araddr = 5
                elseif rx_arcounter == 1
                    rx_araddr = 6
                elseif rx_arcounter == 2
                    rx_araddr = 7
                elseif rx_arcounter == 3
                    rx_araddr = 9
                elseif rx_arcounter == 4
                    rx_araddr = 10
                end
            elseif rx_flush_state == rx_flush_frame_now
                rx_flush = 1
            end
        end
    )
    
    @assert probe_timeout_cycle > 2
    tx_probe_timeout_fsm = @FSM tx_probe_timeout_state probe_idle,probe_initial_wait,trigger_probe,probe_interval
    transadd!(tx_probe_timeout_fsm, transcond(tx_fsm, @tstate idle => probing), @tstate probe_idle => probe_initial_wait)
    transadd!(tx_probe_timeout_fsm, @wireexpr(probe_initial_wait_done), @tstate probe_initial_wait => trigger_probe)
    transadd!(tx_probe_timeout_fsm, @wireexpr(probe_triggered), @tstate trigger_probe => probe_interval)
    transadd!(tx_probe_timeout_fsm, @wireexpr(end_probe_interval & ~probe_all_done), @tstate probe_interval => trigger_probe)
    transadd!(tx_probe_timeout_fsm, @wireexpr(end_probe_interval & probe_all_done), @tstate probe_interval => probe_idle)

    transadd!(tx_probe_timeout_fsm, @wireexpr(probe_conflict), @tstate probe_initial_wait => probe_idle)
    transadd!(tx_probe_timeout_fsm, @wireexpr(probe_conflict), @tstate trigger_probe => probe_idle)

    altxprobefsm = @always (
        probe_triggered = tx_etherFrameDone & tx_arpReqCommandDone;
        end_probe_interval = probe_timeout_counter == $(Wireexpr(48, probe_timeout_cycle));
        probe_all_done = probe_counter == $PROBE_NUM;
    )
    altxprobe = @cpalways (
        if tx_probe_timeout_state == probe_initial_wait
            probe_initial_wait_counter <= probe_initial_wait_counter + $(Wireexpr(48, 1))
            probe_initial_wait_done = probe_initial_wait_counter == $(Wireexpr(48, probe_initial_wait_cycle))
        else
            probe_initial_wait_done = 0
            probe_initial_wait_counter <= 0
        end;

        if ((tx_probe_timeout_state == trigger_probe)
            || (txfsm == announcing1)
            || (txfsm == announcing2)
            || (txfsm == responding)
            || (txfsm == defending))
            tx_etherFrameDone = tx_etherFrameDone_buf | (tx_etherFrameCommandReady & tx_etherFrameCommandValid)
            tx_arpReqCommandDone = tx_arpReqCommandDone_buf | (tx_arpReqCommandReady & tx_arpReqCommandValid)

            tx_etherFrameDone_buf <= tx_etherFrameDone
            tx_arpReqCommandDone_buf <= tx_arpReqCommandDone
        else
            tx_etherFrameDone = 0
            tx_arpReqCommandDone = 0

            tx_etherFrameDone_buf <= 0
            tx_arpReqCommandDone_buf <= 0
        end;

        if tx_probe_timeout_state == probe_interval
            probe_timeout_counter <= probe_timeout_counter + $(Wireexpr(48, 1))
        else
            probe_timeout_counter <= 0
        end;

        if tx_probe_timeout_state == trigger_probe
            if tx_etherFrameDone & tx_arpReqCommandDone
                probe_counter <= probe_counter + $(Wireexpr(8, 1))
            end
        elseif tx_probe_timeout_state == probe_interval
            # pass
        else
            probe_counter <= 0
        end
    )
    
    almisc = @always (
        claiming_ip = $(Wireexpr(32, 0xA9_FE_0A_12));
        self_mac = $(Wireexpr(48, 0x00_00_5E_00_FA_CE));
        probe_done = $(transcond(tx_probe_timeout_fsm, @tstate probe_interval => probe_idle))
    )

    aldebug = @always (
        debug_valid = 0;
        debug_data = 0;

        if txfsm == probing
            if probe_timeout_counter == $(Wireexpr(48, probe_timeout_cycle-1))
                debug_data = {$(Wireexpr(24, 0)), {$(Wireexpr(6, 0)), tx_etherFrameDone, tx_etherFrameDone}, probe_counter, tx_targetIpAddr}
                debug_valid = 1
            end
        end
    )

    vpush!.(v, (
        prts,
        tx_fsm, altx,
        dcls,
        # altxctrl,
        alrx, al_second_announce, alrxmisc, rx_flush_fsm, alrxflushfsm, alrxctrl,
        tx_probe_timeout_fsm, altxprobefsm, altxprobe..., 

        almisc, aldebug
    ))

    return v
end

let
    v = generateLinkLocalIpClaimer(100, 100, 50)
    v = generateLinkLocalIpClaimer(1 << 25, 7 << 23, 3 << 24)

    v = vfinalize(v)
    wrapper = wrappergen(v)

    vexport(v)
    vexport("$(getname(v))_wrapper.v", wrapper)
end

function generateSampleArpFrameBuffer()
    v = Vmodule("sampleArpFrameBuffer")

    prts = @ports (
        @in CLK, RST;
        @in wready;
        @out @logic wvalid, wlast;
        @out @logic 32 wdata
    )

    arppacketdwordcount = 11
    dbuf = [
        0xFFFF_FFFF,
        0x0000_FFFF,
        0xCEFA_005E,
        0x0100_0608, # htype, ethertype
        0x0406_0008, #  heln=6,plen=4,ptype=0800
        0x0000_0100, # 5 operation = 1
        0xCEFA_005F, # 6 sendermac = 00:00:5E:00:FA:CE
        0x120A_FEA9, # 7 Sender IP = 0.0.0.0
        0x0000_0000, # 8 targetmac = 0
        0xFEA9_0000, # 9 target ip = 169.254
        0x0000_100A, # 10
    ]

    # delay_max = 4000
    delay_max = 10
    al = @cpalways (
        wlast = localCounter == $(arppacketdwordcount-1);
        wvalid = (delayCounter == $(Wireexpr(48, delay_max))) & ~(totalCounter == $(length(dbuf)));

        if delayCounter == $(Wireexpr(48, delay_max))
            # pass
        else
            delayCounter <= delayCounter + 1
        end;
        if wvalid & wready
            totalCounter <= totalCounter + $(Wireexpr(48, 1))
            if wlast
                localCounter <= $(Wireexpr(48, 0))
            else
                localCounter <= localCounter + 1
            end
        end
    )

    ifconds = Vector{Wireexpr}(undef, 0)
    contents = Vector{Ifcontent}(undef, 0)

    for i in 1:length(dbuf)
        push!(ifconds, @wireexpr(totalCounter == $(i-1)))
        push!(contents, @ifcontent (
            wdata = $(Wireexpr(32, dbuf[i]))
        ))
    end
    algenerated = @always (
        $(Ifelseblock(ifconds, contents))
    )


    vpush!.(v, (prts, al..., algenerated))
    return v
end

let
    v = vfinalize(generateSampleArpFrameBuffer())
    wrapper = wrappergen(v)

    vexport(v)
    vexport("$(getname(v))_wrapper.v", wrapper)
end
