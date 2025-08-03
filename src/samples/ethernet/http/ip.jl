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

let
    buf = generateEtherFrameTxBuffer("echo")
    ethergen = generateEtherFrameGenerator("echo")
    ipgen = generateIpPacketSimpleGenerator()
    echogen = generateIcmpEchoRequestGenerator()

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
            wdata => wdata_in,
            wvalid => wvalid_in,
            wlast => wlast_in,

            protocol => protocol,
            totalLength => totalLength
        )
    )
    g(
        ipgen => echogen,
        @pconnect (
            wready_out => wready
        )
    )

    vs = layer2vmod!(g, name="EchoRequestBlock")
    vs = vfinalize(vs)

    vexport(vs)
    wrapper = wrappergen(vs[begin])
    vexport("$(getname(wrapper)).v", wrapper)


    v = sampleEchoRequestGen()
    v = vfinalize(v)
    wrapper = wrappergen(v)
    vexport(v)
    vexport("$(getname(wrapper)).v", wrapper)
end
