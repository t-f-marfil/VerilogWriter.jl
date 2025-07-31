"""
    generateRamSdpRfInst(width::Integer, addrlen::Integer, enread, enwrite, addrin, addrout, din, name::AbstractString)

Require external verilog source file for module ram_sdp_rf.
"""
function generateRamSdpRfInst(width::Integer, addrlen::Integer, enread, enwrite, addrin, addrout, din, name::AbstractString)
    pvg = PrivateWireNameGen("ramSdpRfInst_$name")
    instname = pvg("_inst")
    # width = 32
    # addrlen = 11
    clk = Wireexpr("CLK")
    dout = Wireexpr("dout_" |> pvg)
    raminst = Vmodinst(
        "ram_sdp_rf", instname,
        [
            "addrlen" => Wireexpr(addrlen),
            "datawid" => Wireexpr(width)
        ],
        [
            "clk" => clk,
            "enread" => enread,
            "enwrite" => enwrite,
            "addrin" => addrin,
            "addrout" => addrout,
            "din" => din,
            "dout" => dout
        ]
    )

    return dout, raminst
end

function generateEtherFrameTxBuffer()
    # first word fall through
    v = Vmodule("etherFrameTxBuffers")
    @sym2wire enread, enwrite, addrin, addrout, din
    width = 32
    depth = 8
    dout, raminst = generateRamSdpRfInst(width, depth, enread, enwrite, addrin, addrout, din, "")

    prts = @ports (
        @in CLK, RST;
        @in ufp_valid;
        @in $width ufp_data;
        @in ufp_last;
        @out @logic ufp_ready;
        
        # @out @logic full;

        @in dfp_wready;
        @out @logic dfp_wvalid;
        @out @logic $width dfp_wdata;
        @out @logic dfp_wlast;

        @out @logic $depth dfp_awlen;
        @out @logic dfp_awvalid;
        @in dfp_awready;
        # @in dfp_clear;
    )
    al = @cpalways (
        addrin = wptr;
        addrout = rptr;
        din = ufp_data;
        enread = $(Wireexpr(1, 1));
        enwrite = 0;

        ufp_ready = ~full;

        dfp_wlast = full & (wptr == rptr + 1);
        dfp_wvalid = ~(prev_wptr == rptr);
        dfp_wdata = $dout;

        dfp_awvalid = full & ~awdone;
        dfp_awlen = awlen_buf;


        # if dfp_clear
        if full & (wptr == rptr) & awdone
            wptr <= 0
            rptr <= 0
            awlen_buf <= 0
            full <= 0
            prev_wptr <= 0
            # prev_prev_wptr <= 0
            awdone <= 0
        else
            prev_wptr <= wptr
            # prev_prev_wptr <= prev_wptr

            awdone <= awdone | (dfp_awvalid & dfp_awready)

            if ~full
                if ufp_valid
                    enwrite = $(Wireexpr(1, 1))
                    wptr <= wptr + $(Wireexpr(depth, 1))
                    if ufp_last
                        awlen_buf <= wptr;
                        full <= 1
                    end
                end
            end
            if dfp_wvalid & dfp_wready
                addrout = rptr + $(Wireexpr(depth, 1))
                rptr <= rptr + $(Wireexpr(depth, 1))
            end
        end
    )

    vpush!.(v, (raminst, prts, al...))
    return v
end

function generateEtherFrameGenerator()
    v = Vmodule("etherFrameGenerator")

    prts = @ports (
        @in CLK, RST;

        # static source MAC address (00:00:5E:00:FA:CE)
        @in 48 destMacAddr;
        @in 16 etherType;
        @in commandValid;
        @out @logic commandReady;

        @out @logic 32 wdata;
        @out @logic wvalid;
        @out @logic wlast;
        @in wready;

        # payload input ports
        @in wvalid_in;
        @in 32 wdata_in;
        @in wlast_in;
        @out @logic wready_out;
    )

    fsm = @FSM state idle, header, payload, lastpayload
    transadd!(fsm, @wireexpr(commandValid & commandReady), @tstate idle => header)
    transadd!(fsm, @wireexpr((headerCounter == 2) & wvalid & wready), @tstate header => payload)
    transadd!(fsm, @wireexpr(wlast_in & wvalid & wready), @tstate payload => lastpayload)
    transadd!(fsm, @wireexpr(wvalid & wready), @tstate lastpayload => idle)

    almain = @always (
        commandReady = 0;
        {wdata, wvalid, wlast} = 0;
        wready_out = 0;

        if state == idle
            commandReady = 1
        elseif state == header
            wvalid = 1
            if headerCounter == 0
                wdata = {destMacAddrBuf[23:16],destMacAddrBuf[31:24],destMacAddrBuf[39:32],destMacAddrBuf[47:40]}
            elseif headerCounter == 1
                # 00:00:5E:00:FA:CE
                wdata = {sourceMacAddr[39:32], sourceMacAddr[47:40], destMacAddrBuf[7:0],destMacAddrBuf[15:8]}
            elseif headerCounter == 2
                wdata = {sourceMacAddr[7:0], sourceMacAddr[15:8], sourceMacAddr[23:16], sourceMacAddr[31:24]}
            end
        elseif state == payload
            wvalid = wvalid_in
            wready_out = wready
            wdata = {wdata_in[15:0], wdataHalfWordBuf}
        elseif state == lastpayload
            wlast = 1
            wdata = {$(Wireexpr(16, 0)), wdataHalfWordBuf}
            wvalid = 1
        end
    )
    almisc = @cpalways (
        sourceMacAddr = $(Wireexpr(48, 0x00_00_5E_00_FA_CE));
        if state == idle
            destMacAddrBuf <= destMacAddr
        end;
        if state == header
            if wvalid & wready
                headerCounter <= headerCounter + $(Wireexpr(3, 1))
            end
        else
            headerCounter <= 0
        end;
        if state == idle
            wdataHalfWordBuf <= etherType
        elseif state == payload
            if wvalid & wready
                wdataHalfWordBuf <= wdata_in[31:16]
            end
        end
    )

    vpush!.(v, (prts, fsm, almain, almisc...))
    return v
end

function generateArpRequestGenerator()
    v = Vmodule("ArpRequestGenerator")
    prts = @ports (
        @in CLK, RST;
        # static source MAC address
        # 00:00:5E:00:FA:CE
        @in 32 senderProtAddr;
        @in 32 targetProtAddr;
        @in commandValid;
        @out @logic commandReady;

        @out @logic 32 wdata;
        @out @logic wlast;
        @out @logic wvalid;
        @in wready;
    )

    fsm = @FSM state idle, busy
    transadd!(fsm, @wireexpr(commandReady & commandValid), @tstate idle => busy)
    transadd!(fsm, @wireexpr(wlast & wvalid & wready), @tstate busy => idle)

    almain = @always (
        {wvalid, wdata, wlast} = 0;
        if state == busy
            wvalid = 1
            if wcounter == 0
                # ethernet -> ar$hrd = 1
                # ip -> ar$pro = 0x0800
                wdata = 0x0008_0100
            elseif wcounter == 1
                # ar$hln = 6
                # ar$pln = 4
                # REQUEST -> ar$op = 1
                wdata = 0x0100_0406
            elseif wcounter == 2
                # sender hardware address
                # 00:00:5E:00:FA:CE
                wdata = 0x005E_0000
            elseif wcounter == 3
                # sender protocol address
                wdata = {senderProtAddrBuf[23:16], senderProtAddrBuf[31:24], $(Wireexpr(16, 0xCEFA))}
            elseif wcounter == 4
                # target hardware address -> whatever (should be ignored)
                # for now fill 0
                wdata = {$(Wireexpr(16,0)), senderProtAddrBuf[7:0], senderProtAddrBuf[15:8]}
            elseif wcounter == 5
                wdata = 0
            elseif wcounter == 6
                wdata = {targetProtAddrBuf[7:0], targetProtAddrBuf[15:8], targetProtAddrBuf[23:16], targetProtAddrBuf[31:24]}
                wlast = 1
            end
        end
    )
    almisc = @cpalways (
        commandReady = state == idle;
        if state == idle
            wcounter <= $(Wireexpr(4, 0))
            senderProtAddrBuf <= senderProtAddr
            targetProtAddrBuf <= targetProtAddr
        elseif state == busy
            if wvalid & wready
                wcounter <= wcounter + 1
            end
        end
    )

    vpush!.(v, (prts, fsm, almain, almisc...))
    return v
end

function sampleEtherRequestGen()
    v = Vmodule("sampleEtherRequestGen")
    prts = @ports (
        @out @logic 48 destMacAddr;
        @out @logic 16 etherType;

        @out @logic 32 senderIp, targetIp;

        @out @logic etherFrameCommandValid, arpReqCommandValid;
        @in etherFrameCommandReady, arpReqCommandReady;

        @out @logic constHigh;
        @in btn;
        @in CLK,RST;
    )

    al = @cpalways (
        etherType = 0x0608;
        senderIp = 0;
        targetIp = 0xA9_FE_0A_0A;
        destMacAddr = ~0;
        constHigh = 1;

        etherFrameCommandValid = ~etherFrameDone;
        arpReqCommandValid = ~arpReqDone;

        if etherFrameCommandReady & etherFrameCommandValid
            etherFrameDone <= 1
        elseif btn & etherFrameDone & arpReqDone
            etherFrameDone <= 0
        end;

        if arpReqCommandReady & arpReqCommandValid
            arpReqDone <= 1
        elseif btn & etherFrameDone & arpReqDone
            arpReqDone <= 0
        end;            
    )

    vpush!.(v, (prts, al...))

    v = vfinalize(v)
    wrapper = wrappergen(v)
    vexport(v)
    vexport("$(getname(wrapper)).v", wrapper)
end

let
    sampleEtherRequestGen()
    
    vbuf = generateEtherFrameTxBuffer()
    vethergen = generateEtherFrameGenerator()
    varpreqgen = generateArpRequestGenerator()

    g = Vmodgraph()

    g(
        varpreqgen => vethergen,
        @pconnect (
            wdata => wdata_in,
            wvalid => wvalid_in,
            wlast => wlast_in
        )
    )
    g(
        vethergen => varpreqgen,
        @pconnect (
            wready_out => wready
        )
    )

    g(
        vethergen => vbuf,
        @pconnect (
            wvalid => ufp_valid,
            wdata => ufp_data,
            wlast => ufp_last
        )
    )
    g(
        vbuf => vethergen,
        @pconnect (
            ufp_ready => wready
        )
    )
    
    vs = layer2vmod!(g, name="ArpRequestBlock")
    vs = vfinalize(vs)
    
    vexport(vs)
    wrapper = wrappergen(vs[begin])
    vexport("$(getname(wrapper)).v", wrapper)

    txt = dotgen(g)
    cmd = `dot -Tpng -oEtherReq.png`
    run(pipeline(cmd, stdin=IOBuffer(txt)))
end
