
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

function generateIcmpRecvParser()
    v = Vmodule("icmpRecvParser")
    prts = @ports (
        @in CLK, RST;

        @in ufp_valid, ufp_last;
        @out @logic ufp_ready;
        @in 32 ufp_data;

        @out @logic dfp_valid, dfp_last;
        @out @logic 32 dfp_data;
        @in dfp_ready;

        # info
        @out @logic 8 _type,code;
        @out @logic 16 checksum, identifier, sequence_number;
        @out @logic 16 checksum_data_only;
        @out @logic info_core_valid, info_valid;
        @in info_ready;
    )

    fsm = @FSM state init, busy, unknownError
    transadd!(fsm, @wireexpr(header_read_done), @tstate init => busy)
    transadd!(fsm, @wireexpr((ufp_last & ufp_valid & ufp_ready) & ~header_read_done), @tstate init => unknownError)

    transadd!(fsm, @wireexpr((prev_ufp_last | busy_trans_done) & (info_valid & info_ready)), @tstate busy => init)

    transadd!(fsm, @wireexpr(1), @tstate unknownError => init)

    header_dword_length = 2
    alfsm = @always (
        # primarily intended for echo operation
        header_read_done = (header_read_counter == $(header_dword_length - 1)) & (ufp_valid & ufp_ready);
        
        if state == busy
            info_valid = prev_ufp_last | busy_trans_done
        else
            info_valid = 0
        end
    )
    alchecksum = @cpalways (
        if state == busy
            if ufp_ready & ufp_valid
                checksum_with_carry = {$(Wireexpr(2, 0)), checksum} + {$(Wireexpr(2, 0)), ufp_data[31:16]} + {$(Wireexpr(2, 0)), ufp_data[15:0]} | $(Wireexpr(18, 0))
                checksum_data_only <= checksum_with_carry[15:0] + {$(Wireexpr(14, 0)), checksum_with_carry[17:16]}
            else
                checksum_with_carry = 0
            end
        else
            checksum_with_carry = 0
            checksum_data_only <= 0
        end
    )
    aldata = @always (
        if state == init
            if ufp_valid & ufp_ready
                header_read_counter <= header_read_counter + $(Wireexpr(8, 1))
                if header_read_counter == 0
                    _type <= ufp_data[31:24]
                    code <= ufp_data[23:16]
                    checksum <= {ufp_data[7:0], ufp_data[15:8]}
                elseif header_read_counter == 1
                    identifier <= {ufp_data[23:16], ufp_data[31:24]}
                    sequence_number <= {ufp_data[7:0], ufp_data[15:8]}
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
        alchecksum..., aldata, alio
    ))

    return v
end
