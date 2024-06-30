let
    # 2 byte address + 4 byte data
    vparse = Vmodule("InputParser")

    addrBytes, dataBytes = 2, 4
    totalBytes = addrBytes + dataBytes
    addrWidth = 8addrBytes
    dataWidth = 8dataBytes
    prts = @ports (
        @in 8 din;
        @in inValid;
        @out @logic inUpdate;

        @out @logic addrValid;
        @in addrUpdate;
        @out @logic $addrWidth addrData;

        @out @logic dataValid;
        @in dataUpdate;
        @out @logic $dataWidth dataData;

        @out @logic bothAccepted
    )
    alParse = @cpalways (
        bothAccepted = addrAccepted & dataAccepted;
        inUpdate = counter < $totalBytes;

        if inUpdate & inValid
            counter <= counter + $(Wireexpr(32, 1))
        elseif bothAccepted
            counter <= 0
        end;

        addrValid = 0;
        dataValid = 0;
        if counter == $totalBytes
            addrValid = ~addrAccepted
            dataValid = ~dataAccepted

            if bothAccepted
                addrAccepted <= 0
                dataAccepted <= 0
            else
                if addrUpdate
                    addrAccepted <= $(Wireexpr(1, 1))
                end
                if dataUpdate
                    dataAccepted <= $(Wireexpr(1, 1))
                end
            end
        end;

        zero32 = $(Wireexpr(32, 0));
        minusOne32 = ~zero32;
        bufferIndexHead = ((counter + 1) << 3) + minusOne32;

        if inUpdate & inValid
            buffer[bufferIndexHead-:8] <= din
        end;
        addrData = buffer[$(addrWidth - 1):0];
        dataData = buffer[$(addrWidth + dataWidth - 1):$(addrWidth)]
    )
    vpush!.(vparse, (prts, alParse..., @decls @logic $(8totalBytes) buffer))
    
    baud = 115200
    freq = 100 * 10^6
    
    fifo = Vmodule("fifoForUart")
    depth = 512
    width = 8
    (inready, outvalid, dout), p = fifoPatch(depth, width, @wireexpr(din), @wireexpr(inValid), @wireexpr(outUpdate))
    prts = @ports (
        @in inValid, outUpdate;
        @in 8 din;
        @out @logic 8 dout;
        @out @logic outValid
    )
    al = @always (
        outValid = $outvalid;
        dout = $dout
    )
    vpush!.(fifo, (p, prts, al))
    mfifo = Midmodule(fifo)
    recv = uartRecv(baud, freq)
    send = uartSend(baud, freq)

    g = Mmodgraph()

    g(
        recv => mfifo,
        @pconnect (
            outValid => inValid,
            dout => din
        )
    )
    g(
        mfifo => Midmodule(vparse),
        @pconnect (
            dout => din,
            outValid => inValid
        )
    )
    g(Midmodule(vparse) => mfifo, @pconnect inUpdate => outUpdate)

    include("uartMisc.jl")
    include("asciiEncoder.jl")

    portsToEncode = @ports (
        @in $addrWidth addrData;
        @in $dataWidth dataData
    )
    msource, mfifo, mencode = generateAsciiEncoder!(g, portsToEncode)

    g(
        Midmodule(vparse) => msource,
        @pconnect (
            addrData => addrData,
            dataData => dataData,
            bothAccepted => inValid
        )
    )
    g(
        mencode => send,
        @pconnect (
            dout => din,
            outValid => inValid
        )
    )
    g(send => mencode, @pconnect inUpdate => outUpdate)



    # Ethernet Core Access
    core = Vmodule("CoreWrite")

    addrWidth = 13
    dataWidth = 32

    addrPorts = @ports (
        @in addrValid;
        @out @logic addrUpdate;
        @in $addrWidth addrIn
    )
    dataPorts = @ports (
        @in dataValid;
        @out @logic dataUpdate;
        @in $dataWidth dataIn
    )
    strbPorts = @ports (
        @in strbValid;
        @out @logic strbUpdate;
        @in $(Int(dataWidth / 8)) strbIn
    )

    vpush!.(core, (addrPorts, dataPorts, strbPorts))
    addAxiLitePort!(core, addrWidth, dataWidth, true)

    alBypass = @always (
        awaddr = addrIn;
        wdata = dataIn;
        wstrb = strbIn;

        wvalid = strbValid & dataValid;
        dataUpdate = wready & strbValid;
        strbUpdate = wready & dataValid;

        awvalid = addrValid;
        addrUpdate = awready;

        # TODO: handle bresp
        bready = 1;

        # ignore read ports
        araddr = 0;
        arvalid = 0;
        rready = 0;
    )

    vpush!(core, alBypass)

    strbSrc = Vmodule("StrbSrc")
    vpush!(strbSrc, @ports (
        @out @logic valid;
        @out @logic $(Int(dataWidth / 8)) dout
    ))
    vpush!(strbSrc, @always (
        valid = 1;
        dout = ~0;
    ))


    vaxi = Vmodule("AxiControl")
    ufpSuffix, dfpSuffix = "_ufp", "_dfp"
    addAxiLitePort!(vaxi, addrWidth, dataWidth, false, ufpSuffix)
    addAxiLitePort!(vaxi, addrWidth, dataWidth, true, dfpSuffix)

    alassignVec = Vector{Alassign}(undef, 0)
    for p in generateAxiLitePort(addrWidth, dataWidth, true, "")
        if any(pat -> startswith(getname(p), pat), ("awvalid", "awready", "wvalid", "wready"))
            continue
        end
        pname = getname(p)
        if getdirec(p) == pout
            push!(alassignVec, @alassign_comb $(string(pname, "_dfp")) = $(string(pname, "_ufp")))
        else
            push!(alassignVec, @alassign_comb $(string(pname, "_ufp")) = $(string(pname, "_dfp")))
        end
    end
    vpush!(vaxi, @always $(alassignVec...))
    
    delayCount = 50
    alDelay = @cpalways (
        awvalidCtrl = awCounter == 0;
        awreadyCtrl = awCounter == 0;
        wvalidCtrl = wCounter == 0;
        wreadyCtrl = wCounter == 0;

        awvalid_dfp = awvalid_ufp & awvalidCtrl;
        awready_ufp = awready_dfp & awreadyCtrl;

        wvalid_dfp = wvalid_ufp & wvalidCtrl;
        wready_ufp = wready_dfp & wreadyCtrl;

        if awvalid_ufp & awready_ufp
            awCounter <= $(Wireexpr(32, delayCount))
        elseif ~(awCounter == 0)
            awCounter <= awCounter + ~0
        end;
        if wvalid_ufp & wready_ufp
            wCounter <= $(Wireexpr(32, delayCount))
        elseif ~(wCounter == 0)
            wCounter <= wCounter + ~0
        end;
    )
    vpush!.(vaxi, alDelay)
    
    
    vinter = Vmodule("WidthIntermediate")
    vpush!.(vinter, (
        (@ports (@in 16 addrIn; @out @logic 13 addrOut)),
        (@always addrOut = addrIn[12:0])
    ))
    g(
        Midmodule(vparse) => Midmodule(core),
        @pconnect (
            addrValid => addrValid,
            # addrData => addrIn,

            dataValid => dataValid,
            dataData => dataIn
        )
    )
    g(Midmodule(vparse) => Midmodule(vinter), @pconnect addrData => addrIn)
    g(Midmodule(vinter) => Midmodule(core), @pconnect addrOut => addrIn)
    g(
        Midmodule(core) => Midmodule(vparse),
        @pconnect (
            addrUpdate => addrUpdate,
            dataUpdate => dataUpdate
        )
    )
    g(
        Midmodule(strbSrc) => Midmodule(core),
        @pconnect dout => strbIn, valid => strbValid
    )
    
    g(
        Midmodule(core) => Midmodule(vaxi),
        [getname(p) => string(getname(p), "_ufp") for p in generateAxiLitePort(addrWidth, dataWidth, true, "") if getdirec(p) == pout]
    )
    g(
        Midmodule(vaxi) => Midmodule(core),
        [string(getname(p), "_ufp") => getname(p) for p in generateAxiLitePort(addrWidth, dataWidth, true, "") if getdirec(p) == pin]
    )
    
    encoders = vfinalize(layer2vmod!(g, name="SampleAsciiEncoder"))
    wrapper = wrappergen(encoders[begin])

    txt = dotgen(g, dpi=196)
    cmd = `dot -Tpng -oSampleAsciiEncoder.png`
    run(pipeline(cmd, stdin=IOBuffer(txt)))

    vexport(encoders), vexport("$(getname(wrapper)).v", wrapper)
end