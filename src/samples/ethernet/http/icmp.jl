# deprecated
function generateIcmpEchoRequestGenerator()
    prts = @ports (
        @in CLK,RST;
        
        @out @logic 32 wdata;
        @out @logic wvalid;
        @out @logic wlast;
        @in wready;

        # const values
        @out @logic 8 protocol;
        @out @logic 16 totalLength;
    )

    fsm = @FSM state idle, busy
    transadd!(fsm, @wireexpr(1), @tstate idle => busy)
    transadd!(fsm, @wireexpr(wvalid & wready & wlast), @tstate busy => idle)

    # const data, generate identifier and seqnum internally
    seqInitOffset = 0x1234
    idInitOffset = 0x789A
    almain = @always (
        if state == busy
            wvalid = 1
            wlast = dataCounter == 2

            if dataCounter == 0
                wdata = {checksum[7:0], checksum[15:8], $(Wireexpr(16, 0x0008))}
            elseif dataCounter == 1
                wdata = {seqnum[7:0], seqnum[15:8], identifier[7:0], identifier[15:8]}
            else
                wdata = {data[7:0], data[15:8], data[23:16], data[31:24]}
            end
        else
            wdata = 0
            wlast = 0
            wvalid = 0
        end
    )
    
    
    almisc = @cpalways (
        protocol = 0x01;
        totalLength = 12;

        seqnum = counter + $seqInitOffset;
        identifier = counter + $idInitOffset;
        data = {$(Wireexpr(16, 0xABCD)), counter} | $(Wireexpr(32, 0));

        sumh1 = {$(Wireexpr(3, 0)), $(Wireexpr(16, 0x08_00))} | $(Wireexpr(19, 0));
        sumh2 = {$(Wireexpr(3, 0)), identifier} + {$(Wireexpr(3, 0)), seqnum};
        sumh3 = {$(Wireexpr(3, 0)), data[31:16]} + {$(Wireexpr(3, 0)), data[15:0]};
        sumh1_2 = sumh1 + sumh2;

        sum_second = {$(Wireexpr(1, 0)), sum_first[15:0]} + {$(Wireexpr(14, 0)), sum_first[18:16]} | $(Wireexpr(17, 0));
        sum_third = sum_second[15:0] + {$(Wireexpr(15, 0)), sum_second[16]};
        checksum = ~sum_third;


        if $(transcond(fsm, @tstate busy => idle))
            counter <= counter + $(Wireexpr(16, 1))
        end;
        if state == idle
            sum_first <= sumh1_2 + sumh3

            dataCounter <= 0
        elseif state == busy
            if wvalid & wready
                dataCounter <= dataCounter + $(Wireexpr(3, 1))
            end
        end
    )

    v = Vmodule("EchoRequestSimpleGenerator")
    vpush!.(v, (prts, fsm, almain, almisc...))
    return v
end

# deprecated
function sampleEchoRequestGen()
    prts = @ports (
        @in CLK, RST;

        @in btn;

        @out @logic 48 destMacAddr;
        @out @logic 32 sourceIp, destIp;

        @out @logic etherCommandValid, ipCommandValid;
        @in etherCommandReady, ipCommandReady;
    )

    almain = @cpalways (
        destMacAddr = $(Wireexpr(48, 0x12_34_56_78_9A_BC));
        sourceIp = $(Wireexpr(32, 0xA9_FE_0A_0B));
        destIp = $(Wireexpr(32, 0xA9_FE_0A_0C));

        {etherCommandValid, ipCommandValid} = 0;

        if busy
            etherDone <= etherDone | (etherCommandValid & etherCommandReady)
            ipDone <= ipDone | (ipCommandReady & ipCommandValid)

            etherCommandValid = ~etherDone
            ipCommandValid = ~ipDone

            if ipDone & etherDone
                busy <= 0
            end
        else
            etherDone <= 0
            ipDone <= 0
            if btn
                busy <= $(Wireexpr(1, 1))
            end
        end
    )

    v = Vmodule("sampleEchoRequestGen")
    vpush!.(v, (prts, almain...))
    return v
end

function generateIcmpRecvParser(name)
    v = Vmodule("icmpRecvParser_$name")
    prts = @ports (
        @in CLK, RST;

        @in ufp_valid, ufp_last;
        @out @logic ufp_ready;
        @in 32 ufp_data;
        # IP address input
        @in 32 ufp_src_addr, ufp_dest_addr;
        @in 16 ufp_total_length_data;

        @out @logic dfp_valid, dfp_last;
        @out @logic 32 dfp_data;
        @in dfp_ready;

        # info
        @out @logic 16 total_length_data;
        @out @logic 32 src_addr, dest_addr; # ip address of the packet
        @out @logic no_data_payload;
        @out @logic 8 _type,code;
        @out @logic 16 checksum, identifier, sequence_number;
        @out @logic 16 checksum_data_only;
        # info_core_valid has no ready output, asserted when info other than checksum_data_only is already valid
        @out @logic info_core_valid, info_valid;
        @in info_ready;
    )

    fsm = @FSM state init, busy, unknownError
    transadd!(fsm, @wireexpr(header_read_done), @tstate init => busy)
    transadd!(fsm, @wireexpr((ufp_last & ufp_valid & ufp_ready) & ~header_read_done), @tstate init => unknownError)

    transadd!(fsm, @wireexpr((prev_ufp_last | busy_trans_done) & ((info_valid & info_ready) | info_done)), @tstate busy => init)

    transadd!(fsm, @wireexpr(1), @tstate unknownError => init)

    header_dword_length = 2
    alfsm = @always (
        # primarily intended for echo operation
        header_read_done = (header_read_counter == $(header_dword_length - 1)) & (ufp_valid & ufp_ready);
        
        if state == busy
            info_valid = (prev_ufp_last | busy_trans_done) & ~info_done
        else
            info_valid = 0
        end
    )
    almisc = @always (
        if state == busy
            if info_valid & info_ready
                info_done <= 1
            end
        else
            info_done <= 0
        end
    )
    alchecksum = @cpalways (
        if state == busy
            if ufp_ready & ufp_valid
                checksum_with_carry = {$(Wireexpr(2, 0)), checksum_data_only} + {$(Wireexpr(2, 0)), ufp_data[23:16], ufp_data[31:24]} + {$(Wireexpr(2, 0)), ufp_data[7:0], ufp_data[15:8]} | $(Wireexpr(18, 0))
                checksum_with_carry_last = {$(Wireexpr(1, 0)), checksum_with_carry[15:0]} + {$(Wireexpr(15, 0)), checksum_with_carry[17:16]} | $(Wireexpr(17, 0))
                checksum_data_only <= checksum_with_carry_last[15:0] + {$(Wireexpr(15, 0)), checksum_with_carry_last[16]}
            else
                checksum_with_carry = 0
                checksum_with_carry_last = 0
            end
        else
            checksum_data_only <= 0
            checksum_with_carry = 0
            checksum_with_carry_last = 0
        end
    )
    aldata = @always (
        if state == init
            if ufp_valid & ufp_ready
                src_addr <= ufp_src_addr;
                dest_addr <= ufp_dest_addr;
                total_length_data <= ufp_total_length_data + 1 + ~$(Wireexpr(16, 8));

                header_read_counter <= header_read_counter + $(Wireexpr(8, 1))
                if header_read_counter == 0
                    _type <= ufp_data[7:0]
                    code <= ufp_data[15:8]
                    checksum <= {ufp_data[23:16], ufp_data[31:24]}
                elseif header_read_counter == 1
                    identifier <= {ufp_data[7:0], ufp_data[15:8]}
                    sequence_number <= {ufp_data[23:16], ufp_data[31:24]}
                end
            end
        else
            header_read_counter <= 0
        end;

        if $(transcond(fsm, @tstate init => busy))
            prev_ufp_last <= ufp_last
        elseif $(transcond(fsm, @tstate busy => init))
            prev_ufp_last <= 0
        end;

        if state == busy
            if ufp_valid & ufp_ready & ufp_last
                busy_trans_done <= $(Wireexpr(1, 1))
            end
        else
            busy_trans_done <= 0
        end;
    )
    alio = @always (
        no_data_payload = prev_ufp_last;
        info_core_valid = state == busy;

        if (state == busy) & ~(busy_trans_done)
            dfp_valid = ufp_valid
            dfp_last = ufp_last
            dfp_data = ufp_data
        else
            dfp_valid = 0
            dfp_last = 0
            dfp_data = 0
        end;

        if state == init
            ufp_ready = 1
        elseif (state == busy) & ~(busy_trans_done)
            ufp_ready = dfp_ready
        else
            ufp_ready = 0
        end
    )

    vpush!.(v, (
        prts,
        fsm, alfsm,
        alchecksum..., aldata, alio, almisc
    ))

    return v
end

function generateSampleIcmpEchoRequestBuffer()
    v = Vmodule("sampleIcmpEchoRequestBuffer")

    prts = @ports (
        @in CLK, RST;
        @in wready;
        @out @logic wvalid, wlast;
        @out @logic 32 wdata;

        @out @logic constHigh;
        @out @logic 32 dest_ip;
    )
    dbuf = [
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

    delay_max = 10
    al = @cpalways (
        constHigh = 1;
        dest_ip = $(Wireexpr(32, 0xA9FE_0A0C));

        if ~($delay_max == delay_counter)
            delay_counter <= delay_counter + $(Wireexpr(48, 1))
        end;

        if wvalid & wready
            counter <= counter + $(Wireexpr(48, 1))
        end;

        wvalid = (delay_counter == $delay_max) & ~(counter == $(length(dbuf)));
        wlast = (counter == $(length(dbuf)-1));
    )

    ifconds = Vector{Wireexpr}(undef, 0)
    contents = Vector{Ifcontent}(undef, 0)

    for i in 1:length(dbuf)
        push!(ifconds, @wireexpr(counter == $(i-1)))
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

function generateIcmpEchoMessageGenerator(name)
    v = Vmodule("icmpEchoMessageGenerator_$name")
    prts = @ports (
        @in CLK,RST;
        
        @out @logic 32 dfp_data;
        @out @logic dfp_valid;
        @out @logic dfp_last;
        @in dfp_ready;
        
        @out @logic dfp_misc_valid;
        @in dfp_misc_ready;
        @out @logic 16 total_length;
        @out @logic 8 protocol;

        @in ufp_misc_valid;
        @out @logic ufp_misc_ready;
        # _type : 8 for request, 0 for reply
        @in 8 _type, code;
        @in 16 identifier, sequence_number;
        @in 16 total_length_data;
        # output value to which ~ operation not applied yet
        # endian same as other fields (little endian)
        @in 16 checksum_data;

        @in ufp_valid, ufp_last;
        @in 32 ufp_data;
        @out @logic ufp_ready;
    )

    header_dword_length = 2
    fsm = @FSM state read_misc,send_header,send_data_body
    transadd!(fsm, @wireexpr(ufp_misc_ready & ufp_misc_valid), @tstate read_misc => send_header)
    transadd!(fsm, @wireexpr(header_send_done & ~dfp_last), @tstate send_header => send_data_body)
    transadd!(fsm, @wireexpr(header_send_done & dfp_last), @tstate send_header => read_misc)
    transadd!(fsm, @wireexpr(dfp_valid & dfp_ready & dfp_last), @tstate send_data_body => read_misc)

    alfsm = @always (
        if state == send_header
            header_send_done = (header_send_count == $(header_dword_length-1)) & dfp_valid & dfp_ready
        else
            header_send_done = 0
        end
    )
    alufp = @always (
        if state == read_misc
            ufp_misc_ready = 1
        else
            ufp_misc_ready = 0
        end;

        if state == send_data_body
            ufp_ready = dfp_ready
        else
            ufp_ready = 0
        end
    )
    aldfp = @always (
        protocol = 0x01;
        total_length = total_length_data_buf + 8;
        if (state == send_header) | (state == send_data_body)
            dfp_misc_valid = ~dfp_misc_done
        else
            dfp_misc_valid = 0
        end;

        if state == send_header
            dfp_valid = 1
            if header_send_count == 0
                dfp_last = 0
                dfp_data = {checksum_total[7:0], checksum_total[15:8], code_buf, type_buf}
            elseif header_send_count == 1
                dfp_last = total_length_data_buf == 0
                dfp_data = {sequence_number_buf[7:0], sequence_number_buf[15:8], identifier_buf[7:0], identifier_buf[15:8]}
            else
                # not supposed to be here
                dfp_last = 0
                dfp_data = 0
            end
        elseif state == send_data_body
            # TODO: check if ufp_last satisfies total_length constraint
            dfp_valid = ufp_valid
            dfp_last = ufp_last
            dfp_data = ufp_data
        else
            dfp_valid = 0
            dfp_last = 0
            dfp_data = 0
        end
    )
    alchecksum = @cpalways (
        if state == read_misc
            checksum_with_carry1 = {$(Wireexpr(2, 0)), identifier} + {$(Wireexpr(2, 0)), sequence_number} | $(Wireexpr(18, 0))
            checksum_with_carry2 = {$(Wireexpr(2, 0)), code, _type} + {$(Wireexpr(2, 0)), checksum_data}
            checksum_with_carry_all = checksum_with_carry1 + checksum_with_carry2
            checksum_total_pre = {$(Wireexpr(1, 0)), checksum_with_carry_all[15:0]} + {$(Wireexpr(15, 0)), checksum_with_carry_all[17:16]} | $(Wireexpr(17, 0))
            checksum_total <= ~(checksum_total_pre[15:0] + {$(Wireexpr(15, 0)), checksum_total_pre[16]})
        else
            checksum_with_carry1 = 0
            checksum_with_carry2 = 0
            checksum_with_carry_all = 0
            checksum_total_pre = 0
        end
    )
    alctrl = @always (
        if state == send_header
            if dfp_valid & dfp_ready
                header_send_count <= header_send_count + $(Wireexpr(8, 1))
            end
        else
            header_send_count <= 0
        end
    )
    almiscctrl = @always (
        if state == read_misc
            identifier_buf <= identifier
            sequence_number_buf <= sequence_number
            total_length_data_buf <= total_length_data
            # checksum_data_buf <= checksum_data
            type_buf <= _type
            code_buf <= code
        end;

        if state == read_misc
            dfp_misc_done <= 0
        elseif (state == send_header) | (state == send_data_body)
            if dfp_misc_valid & dfp_misc_ready
                dfp_misc_done <= $(Wireexpr(1, 1))
            end
        end
    )

    vpush!.(v, (
        prts, fsm,
        alfsm,
        alufp, aldfp,
        alchecksum...,
        alctrl, almiscctrl
    ))

    return v
end

function generateSampleEchoMessageGenerator()
    v = Vmodule("sampleEchoMessageGen")
    prts = @ports (
        @in CLK, RST;
        @out @logic 8 _type, code;
        @out @logic 16 identifier, sequence_number, total_length_data, checksum_data;
        
        @out @logic misc_valid;
        @in misc_ready;

        @out @logic valid, last;
        @in ready;
        @out @logic 32 data;

        @out @logic 48 destMacAddr;
        @out @logic 32 sourceIp, destIp;

        @out @logic etherCommandValid, ipCommandValid;
        @in etherCommandReady, ipCommandReady;

        @out @logic constHigh
    )

    al = @always (
        valid = 1;
        last = 0;
        data = 0;
        constHigh = 1;

        destMacAddr = $(Wireexpr(48, 0x12_34_56_78_9A_BC));
        sourceIp = $(Wireexpr(32, 0xA9_FE_0A_0B));
        destIp = $(Wireexpr(32, 0xA9_FE_0A_0C));

        misc_valid = start & ~misc_done;
        etherCommandValid = start & ~etherCommandDone;
        ipCommandValid = start & ~ipCommandDone;
        if start
            _type = 8
            code = 0
            identifier = 0xABCD
            sequence_number = 0x5678
            total_length_data = 0
            checksum_data = 0x12
        else
            _type = 0
            code = 0
            sequence_number = 0
            total_length_data = 0
            checksum_data = 0
        end
    )

    alctrl = @always (
        start <= $(Wireexpr(1, 1));

        if etherCommandReady & etherCommandValid
            etherCommandDone <= $(Wireexpr(1, 1))
        end;

        if ipCommandReady & ipCommandValid
            ipCommandDone <= $(Wireexpr(1,1))
        end;
        if misc_ready & misc_valid
            misc_done <= $(Wireexpr(1, 1))
        end
    )

    vpush!.(v, (
        prts, al, alctrl
    ))

    return v
end


function generateEchoMessageBlock(name)
    buf = generateEtherFrameTxBuffer("echo_$name")
    ethergen = generateEtherFrameGenerator("echo_$name")
    ipgen = generateIpPacketSimpleGenerator("echo_$name")
    echogen = generateIcmpEchoMessageGenerator("echo_$name")

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
        echogen => ipgen,
        @pconnect (
            dfp_data => wdata_in,
            dfp_valid => wvalid_in,
            dfp_last => wlast_in,

            dfp_misc_valid => ufp_misc_valid,
            protocol => protocol,
            total_length => totalLengthData
        )
    )
    g(
        ipgen => echogen,
        @pconnect (
            wready_out => dfp_ready,
            ufp_misc_ready => dfp_misc_ready
        )
    )

    vs = layer2vmod!(g, false, name="IcmpEchoMessageBlock_$name")
    return vs
end

function generateIcmpEchoServer(name)
    v = Vmodule("icmpEchoServer_$name")

    prts = @ports (
        @in CLK, RST;

        # config
        @in ip_addr_configured;
        @in 32 configured_ip_addr;

        # icmp & ip
        @in 8 rx_type;
        @in 16 rx_sequence_number, rx_identifier;
        @in 16 rx_checksum_data_only;
        @in rx_no_data_payload;
        @in rx_icmp_info_valid;
        @out @logic rx_icmp_info_ready;
        @in 32 rx_src_ipaddr, rx_dest_ipaddr;
        @in 16 rx_total_length_data;

        # icmp data buffer
        @in 32 rx_data;
        @in rx_data_valid, rx_data_invalid, rx_data_full;
        @in 13 rx_data_count;
        @out @logic rx_data_flush;
        @out @logic 13 rx_data_araddr;
        @out @logic rx_data_arvalid;
        @in rx_data_arready;

        # ether
        # TODO: remove this from here
        @in 48 rx_src_hwaddr, rx_dest_hwaddr;
        @in rx_icmp_last;

        # dfp icmp
        @out @logic 8 tx_type, tx_code;
        @out @logic 16 tx_total_length_data;
        @out @logic 16 tx_sequence_number, tx_identifier, tx_checksum_data_only;
        @out @logic tx_icmp_misc_valid;
        @in tx_icmp_misc_ready;
        @out @logic tx_icmp_data_valid, tx_icmp_data_last;
        @in tx_icmp_data_ready;
        @out @logic 32 tx_icmp_data;
        # dfp ip
        @out @logic 32 tx_src_ipaddr, tx_dest_ipaddr;
        @out @logic tx_ipaddr_valid;
        @in tx_ipaddr_ready;

        # dfp ether
        # TODO: remove this from here
        @out @logic 48 tx_dest_hwaddr;
        @out @logic tx_hwaddr_valid;
        @in tx_hwaddr_ready;

        @out @logic debug_valid;
        @out @logic 72 debug_data;
    )

    fsm = @FSM state idle,force_flush,replying
    # if noreply and buffer is also empty, then stay at idle
    transadd!(fsm, @wireexpr(rx_icmp_info_ready & rx_icmp_info_valid & noreply_flush), @tstate idle => force_flush)
    transadd!(fsm, @wireexpr(rx_icmp_info_ready & rx_icmp_info_valid & doreply), @tstate idle => replying)
    transadd!(fsm, @wireexpr(rx_data_flush & rx_data_full), @tstate force_flush => idle)
    transadd!(fsm, @wireexpr(reply_all_done), @tstate replying => force_flush)

    almisc = @always (
        addr_minusone = ~$(Wireexpr(13, 0));
    )
    alfsm = @always (
        noreply = (~ip_addr_configured) | ~(configured_ip_addr == rx_dest_ipaddr);
        doreply = ip_addr_configured & (configured_ip_addr == rx_dest_ipaddr);
        
        noreply_flush = noreply & ~rx_no_data_payload;

        reply_all_done = tx_icmp_misc_done & tx_ipaddr_done & tx_hwaddr_done & (buffer_read_done_counter == rx_data_count)
    )
    alether = @always (
        if state == idle
            # for simplicity assume that the latest rx addresses is of the packet currently parsed here
            # TODO: refer to arp cache for hwaddresses
            if rx_icmp_last
                rx_src_hwaddr_buf <= rx_src_hwaddr
            end
        end
    )
    alsnapshot = @always (
        if state == idle
            rx_no_data_payload_buf <= rx_no_data_payload
            if rx_icmp_info_ready & rx_icmp_info_valid & doreply
                rx_sequence_number_buf <= rx_sequence_number
                rx_identifier_buf <= rx_identifier
                rx_checksum_data_only_buf <= rx_checksum_data_only
                rx_src_ipaddr_buf <= rx_src_ipaddr
                rx_total_length_data_buf <= rx_total_length_data
            end
        end
    )
    aldfp = @always (
        tx_dest_hwaddr = rx_src_hwaddr_buf;

        tx_type = 0;
        tx_code = 0;
        tx_sequence_number = rx_sequence_number_buf;
        tx_identifier = rx_identifier_buf;
        tx_checksum_data_only = rx_checksum_data_only_buf;
        tx_total_length_data = rx_total_length_data_buf;

        tx_src_ipaddr = configured_ip_addr;

        if state == replying
            tx_icmp_misc_valid = ~tx_icmp_misc_done

            tx_ipaddr_valid = ~tx_ipaddr_done
            tx_dest_ipaddr = rx_src_ipaddr_buf

            if rx_no_data_payload_buf
                tx_icmp_data_valid = 0
                tx_icmp_data_last = 0
                tx_icmp_data = 0
            else
                # control both tx data handshake and ufp addr handshake
                tx_icmp_data_valid = (buffer_read_addr == buffer_read_done_counter + 1) & (rx_data_valid | tx_icmp_data_valid_carry)
                tx_icmp_data_last = (buffer_read_done_counter + 1 == rx_data_count)
                tx_icmp_data = rx_data
            end

            tx_hwaddr_valid = ~tx_hwaddr_done
        else
            tx_icmp_misc_valid = 0

            tx_ipaddr_valid = 0
            tx_dest_ipaddr = 0

            tx_icmp_data_valid = 0
            tx_icmp_data_last = 0
            tx_icmp_data = 0

            tx_hwaddr_valid = 0
        end
    )
    aldfpctrl = @always (
        if state == replying
            if tx_icmp_data_valid | tx_icmp_data_valid_carry
                if tx_icmp_data_ready
                    tx_icmp_data_valid_carry <= 0
                else
                    tx_icmp_data_valid_carry <= 1
                end
            end

            if tx_icmp_misc_valid & tx_icmp_misc_ready
                tx_icmp_misc_done <= 1
            end
            if tx_ipaddr_valid & tx_ipaddr_ready
                tx_ipaddr_done <= 1
            end

            if tx_hwaddr_valid & tx_hwaddr_ready
                tx_hwaddr_done <= 1
            end
        else
            tx_icmp_misc_done <= 0
            tx_ipaddr_done <= 0

            tx_hwaddr_done <= 0
        end
    )
    alufpicmp = @always (
        if state == idle
            rx_icmp_info_ready = 1
        else
            rx_icmp_info_ready = 0
        end
    )

    buffer_fsm = @FSM buffer_state bufempty,bufreading
    transadd!(buffer_fsm, @wireexpr(rx_data_full), @tstate bufempty => bufreading)
    transadd!(buffer_fsm, @wireexpr(rx_data_flush & rx_data_full), @tstate bufreading => bufempty)

    alufpbuf = @always (
        if state == force_flush
            rx_data_flush = 1
        else
            rx_data_flush = 0
        end;

        if state == replying
            if buffer_state == bufreading
                if (buffer_read_addr == buffer_read_done_counter) | (tx_icmp_data_valid & tx_icmp_data_ready)
                    rx_data_araddr = buffer_read_addr
                else
                    # hold rx_data value if not read from tx module
                    rx_data_araddr = buffer_read_addr + addr_minusone
                end
                # need to wait for tx_icmp_data_ready
                if buffer_read_addr == rx_data_count
                    rx_data_arvalid = 0
                else
                    rx_data_arvalid = (buffer_read_addr == buffer_read_done_counter) | (tx_icmp_data_valid & tx_icmp_data_ready)
                end
            else
                rx_data_araddr = 0
                rx_data_arvalid = 0
            end
        else
            rx_data_araddr = 0
            rx_data_arvalid = 0
        end
    )
    alufpctrl = @always (
        if state == replying
            if rx_data_arvalid & rx_data_arready
                buffer_read_addr <= buffer_read_addr + 1
            end
            # tx but relates to ufp buffer control
            if tx_icmp_data_valid & tx_icmp_data_ready
                buffer_read_done_counter <= buffer_read_done_counter + 1
            end
        else
            buffer_read_addr <= 0
            buffer_read_done_counter <= 0
        end
    )

    vpush!.(v, (
        prts,
        fsm,
        almisc, alfsm, alether,
        alsnapshot, aldfp, aldfpctrl, alufpicmp,
        buffer_fsm, alufpbuf, alufpctrl
    ))

    return v
end
