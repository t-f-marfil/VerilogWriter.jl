let
    # 2 byte address + 4 byte data
    vparse = Vmodule("InputParser")

    opcodeBytes = 1
    opWrite = 1
    opRead = 2
    
    addrBytes, dataBytes = 2, 4
    totalBytes = opcodeBytes + addrBytes + dataBytes
    
    opcodeWidth = 8opcodeBytes
    addrWidth = 8addrBytes
    dataWidth = 8dataBytes
    prts = @ports (
        @in 8 din;
        @in inValid;
        @out @logic inUpdate;

        @out @logic wAddrValid, rAddrValid;
        @in wAddrUpdate, rAddrUpdate;
        @out @logic $addrWidth addrData;

        @out @logic wDataValid;
        @in wDataUpdate;
        @out @logic $dataWidth wData;

        @in $dataWidth rData;
        @out @logic rDataUpdate;
        @in rDataValid;

        @out @logic transEnd;
        @out @logic $dataWidth transData;
        @out @logic $opcodeWidth opcode;
    )
    alParse = @cpalways (
        bothAccepted = addrAccepted & dataAccepted;
        transEnd = bothAccepted;
        inUpdate = counter < $totalBytes;

        if inUpdate & inValid
            counter <= counter + $(Wireexpr(32, 1))
        elseif transEnd
            counter <= 0
        end;

        wAddrValid = 0;
        wDataValid = 0;
        rAddrValid = 0;
        rDataUpdate = 0;
        if counter == $totalBytes
            if opcode == $opWrite
                wAddrValid = ~addrAccepted
                wDataValid = ~dataAccepted

                if bothAccepted
                    addrAccepted <= 0
                    dataAccepted <= 0
                else
                    if wAddrUpdate
                        addrAccepted <= $(Wireexpr(1, 1))
                    end
                    if wDataUpdate
                        dataAccepted <= $(Wireexpr(1, 1))
                    end
                end
            elseif opcode == $opRead
                rAddrValid = ~addrAccepted
                rDataUpdate = ~dataAccepted

                if bothAccepted
                    addrAccepted <= 0
                    dataAccepted <= 0
                else
                    if rAddrUpdate
                        addrAccepted <= 1
                    end
                    if rDataValid
                        dataAccepted <= 1
                        rDataBuffer <= rData
                    end
                end
            end
        end;

        zero32 = $(Wireexpr(32, 0));
        minusOne32 = ~zero32;
        bufferIndexHead = ((counter + 1) << 3) + minusOne32;

        if inUpdate & inValid
            buffer[bufferIndexHead-:8] <= din
        end;

        opcode = buffer[$(opcodeWidth - 1):0];
        addrData = buffer[$(addrWidth + opcodeWidth - 1):$opcodeWidth];
        wData = buffer[$(addrWidth + dataWidth + opcodeWidth - 1):$(addrWidth + opcodeWidth)];

        transData = 0;
        if opcode == $opWrite
            transData = wData
        elseif opcode == $opRead
            transData = rDataBuffer
        end
    )
    vpush!.(vparse, (prts, alParse..., @decls @logic $(8totalBytes) buffer))
    
    baud = 115200
    freq = 100 * 10^6
    # baud = 9600
    # freq = 4baud
    
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
    # mfifo = Midmodule(fifo).vmod
    mfifo = fifo
    recv = uartRecv(baud, freq, name="UartRecv_etherBypass")
    send = uartSend(baud, freq, name="UartSend_etherBypass")

    g = Vmodgraph()

    g(
        recv => mfifo,
        @pconnect (
            outValid => inValid,
            dout => din
        )
    )
    g(
        # mfifo => Midmodule(vparse),
        mfifo => vparse,
        @pconnect (
            dout => din,
            outValid => inValid
        )
    )
    g(
        # Midmodule(vparse) => mfifo,
        vparse => mfifo,
        @pconnect inUpdate => outUpdate
    )

    include("samples/ethernet/uartMisc.jl")
    include("samples/ethernet/asciiEncoder.jl")

    portsToEncode = @ports (
        @in $opcodeWidth opcode;
        @in $addrWidth addrData;
        @in $dataWidth data
    )
    vsource, vfifo, vencode = generateAsciiEncoder!(g, portsToEncode)

    g(
        # Midmodule(vparse) => msource,
        vparse => vsource,
        @pconnect (
            opcode => opcode,
            addrData => addrData,
            transData => data,
            transEnd => inValid
        )
    )
    g(
        vencode => send,
        @pconnect (
            dout => din,
            outValid => inValid
        )
    )
    g(send => vencode, @pconnect inUpdate => outUpdate)



    # Ethernet Core Access
    core = Vmodule("CoreWrite")

    addrWidth = 13
    dataWidth = 32

    addrPorts = @ports (
        @in wAddrValid;
        @out @logic wAddrUpdate;
        @in $addrWidth wAddrIn;

        @in rAddrValid;
        @out @logic rAddrUpdate;
        @in $addrWidth rAddrIn;
    )
    dataPorts = @ports (
        @in wDataValid;
        @out @logic wDataUpdate;
        @in $dataWidth wDataIn;

        @out @logic $dataWidth rDataOut;
        @out @logic rDataValid;
        @in rDataUpdate;
    )
    strbPorts = @ports (
        @in strbValid;
        @out @logic strbUpdate;
        @in $(Int(dataWidth / 8)) strbIn
    )

    vpush!.(core, (addrPorts, dataPorts, strbPorts))
    addAxiLitePort!(core, addrWidth, dataWidth, true)

    alBypass = @always (
        awaddr = wAddrIn;
        wdata = wDataIn;
        wstrb = strbIn;

        wvalid = strbValid & wDataValid;
        wDataUpdate = wready & strbValid;
        strbUpdate = wready & wDataValid;

        awvalid = wAddrValid;
        wAddrUpdate = awready;

        # TODO: handle bresp
        bready = 1;

        
        araddr = rAddrIn;
        arvalid = rAddrValid;
        rAddrUpdate = arready;

        rready = rDataUpdate;
        rDataValid = rvalid;
        rDataOut = rdata
        # TODO: handle rresp
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
        # Midmodule(vparse) => Midmodule(core),
        vparse => core,
        @pconnect (
            wAddrValid => wAddrValid,
            rAddrValid => rAddrValid,
            # addrData => addrIn,

            wDataValid => wDataValid,
            wData => wDataIn,

            rDataUpdate => rDataUpdate,
        )
    )
    g(
        # Midmodule(vparse) => Midmodule(vinter),
        vparse => vinter,
        @pconnect addrData => addrIn
    )
    g(
        # Midmodule(vinter) => Midmodule(core),
        vinter => core,
        @pconnect (
            addrOut => wAddrIn,
            addrOut => rAddrIn,
        )
    )
    g(
        # Midmodule(core) => Midmodule(vparse),
        core => vparse,
        @pconnect (
            wAddrUpdate => wAddrUpdate,
            rAddrUpdate => rAddrUpdate,
            wDataUpdate => wDataUpdate,

            rDataOut => rData,
            rDataValid => rDataValid,
        )
    )
    g(
        # Midmodule(strbSrc) => Midmodule(core),
        strbSrc => core,
        @pconnect dout => strbIn, valid => strbValid
    )
    
    g(
        # Midmodule(core) => Midmodule(vaxi),
        core => vaxi,
        [getname(p) => string(getname(p), "_ufp") for p in generateAxiLitePort(addrWidth, dataWidth, true, "") if getdirec(p) == pout]
    )
    g(
        # Midmodule(vaxi) => Midmodule(core),
        vaxi => core,
        [string(getname(p), "_ufp") => getname(p) for p in generateAxiLitePort(addrWidth, dataWidth, true, "") if getdirec(p) == pin]
    )
    
    encoders = vfinalize(layer2vmod!(g, name="SampleAsciiEncoder"))
    wrapper = wrappergen(encoders[begin])

    txt = dotgen(g, dpi=196)
    cmd = `dot -Tpng -oSampleAsciiEncoder.png`
    run(pipeline(cmd, stdin=IOBuffer(txt)))

    wrappername = "$(getname(wrapper)).v"
    vexport(encoders), vexport(wrappername, wrapper)
    
    txt = nothing
    open(wrappername) do io
        txt = read(io, String)
    end

    txt = replace(txt, r"_dfp_AxiControl([\),])" => s"\1")
    open(wrappername, "w") do io
        write(io, txt)
    end


end