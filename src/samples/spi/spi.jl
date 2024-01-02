let 
    @Randmmod SpiMaster

    cyclePerHalfSck = 2
    lenwid = 32
    dataSendWid = 32
    dataRecvWid = 32
    waitAfterCsEnable = cyclePerHalfSck
    waitBeforeCsDisable = waitAfterCsEnable

    sckCycleCountWid = 32

    @assert dataSendWid > 0  && dataRecvWid > 0
    @assert cyclePerHalfSck > 0
    @assert waitAfterCsEnable > 0 && waitBeforeCsDisable > 0

    cpol = 1
    cpha = 1

    widthToIndexBitLen(wid::Int) = max(1, Int(ceil(log(2, wid))))
    cycleCountWid = widthToIndexBitLen(cyclePerHalfSck)
    mosiIndexWid = widthToIndexBitLen(dataSendWid)
    sampleWithSckPosedge = cpol == cpha
    # csWaitCountWid = widthToIndexBitLen(cswaitcycles)

    sckInvertBeforeCsHigh = cpha == 1

    prts = @ports (
        @out @logic sck, mosi, cs, ready;
        @in miso;
        @in $lenwid cycles;
        @in $dataSendWid dataToSend;
        @out @logic $dataRecvWid dataReceived;
        @in start, txValid, rxAcceptable;
        @out @logic txUpdate, rxValid;
    )
    alConfig = @cpalways (
        ready = transphase == spiidle;
        if start
            currentTransLen <= cycles
        end
    )
    
    transphase = @FSM transphase spiidle, csinit, shifting, csfinish, sckinvert

    afterShiftingState = (
        if sckInvertBeforeCsHigh
            @tstate shifting => sckinvert
        else
            @tstate shifting => csfinish
        end
    )
    transadd!(transphase, [
        (@wireexpr(startTransaction), @tstate spiidle => csinit),
        (@wireexpr(startShifting), @tstate csinit => shifting),
        (@wireexpr(finishShifting), afterShiftingState),
        (@wireexpr(sckInvertDone), @tstate sckinvert => csfinish),
        (@wireexpr(endTransaction), @tstate csfinish => spiidle)
    ])

    alTransPhase = @cpalways (
        startTransaction = start;
        startShifting = $(Wireexpr(1, 0));
        finishShifting = $(Wireexpr(1, 0));
        sckInvertDone = $(Wireexpr(1, 0));
        endTransaction = $(Wireexpr(1, 0));

        if transphase == csinit
            if csWaitCounter < $(waitAfterCsEnable - 1)
                csWaitCounter <= csWaitCounter + $(Wireexpr(32, 1))
            else
                csWaitCounter <= 0
                startShifting = 1
            end
        elseif transphase == shifting
            if (currentTransLen <= currentTotalShiftedCount + 1) && shiftingNow
                finishShifting = 1
            end
        elseif transphase == sckinvert
            if $(cyclePerHalfSck - 1) <= sckInvCycleCount
                sckInvCycleCount <= 0
                sckInvertDone = 1
            else
                sckInvCycleCount <= sckInvCycleCount + $(Wireexpr(sckCycleCountWid, 1))
            end
        elseif transphase == csfinish
            if csWaitCounter < $(waitBeforeCsDisable - 1)
                csWaitCounter <= csWaitCounter + 1
            else
                csWaitCounter <= 0
                endTransaction = 1
            end
        end
    )

    sckStateBeforeSampling = Bool(xor(cpol, cpha)) ? 1 : 0
    sckStateBeforeShifting = Int(!Bool(sckStateBeforeSampling))
    
    sckIdleState = Bool(cpol) ? 1 : 0

    totalShiftedCountWid = lenwid
    # a little redundant
    sendDataIndexWid = lenwid
    recvDataIndexWid = lenwid
    txDataRawBuf, txBufPatch = interceptBuffer(@wireexpr(dataToSend), @wireexpr(dataToSendUpdate))
    txDataBuf, txBufInvPatch = invertBitOrder(txDataRawBuf, dataSendWid)
    rxDataBuf, rxBufInvPatch = invertBitOrder(@wireexpr(dataReceivedRaw), dataRecvWid)

    resetCurrentSendDataIndex = @wireexpr $dataSendWid <= currentSendDataIndex + 1
    resetCurrentRecvDataIndex = @wireexpr $dataRecvWid <= currentRecvDataIndex + 1
    alDataIndex = @always (
        if $(transcond(transphase, @tstate spiidle => csinit))
            currentTotalShiftedCount <= $(Wireexpr(totalShiftedCountWid, 0))
            currentSendDataIndex <= $(Wireexpr(sendDataIndexWid, 0))
            currentRecvDataIndex <= $(Wireexpr(recvDataIndexWid, 0))
        elseif transphase == shifting
            if shiftingNow
                currentTotalShiftedCount <= currentTotalShiftedCount + 1

                if $resetCurrentSendDataIndex
                    currentSendDataIndex <= 0
                else
                    currentSendDataIndex <= currentSendDataIndex + 1
                end
            end

            if samplingNow
                if $resetCurrentRecvDataIndex
                    currentRecvDataIndex <= 0
                else
                    currentRecvDataIndex <= currentRecvDataIndex + 1
                end
            end
        elseif transphase == csfinish
            currentTotalShiftedCount <= 0
            currentSendDataIndex <= 0
            currentRecvDataIndex <= 0
        end
    )
    # at shiftingNow cycle the value is updated, thus + 1
    requestNextSendData = @wireexpr $resetCurrentSendDataIndex && ~(currentTransLen <= currentTotalShiftedCount + 1)
    alDataSendBufferControl = @cpalways (
        dataToSendUpdate = 0;
        txUpdate = 0;
        if (
            shiftingNow && $requestNextSendData 
        ) || $(transcond(transphase, @tstate spiidle => csinit))
            dataToSendUpdate = txValid
            txUpdate = 1
            if ~dataToSendUpdate
                waitingSendDataUpdate <= $(Wireexpr(1, 1))
            end
        elseif waitingSendDataUpdate
            dataToSendUpdate = txValid
            txUpdate = 1
            if dataToSendUpdate
                waitingSendDataUpdate <= 0
            end
        end
    )
    # outputRecvData = @wireexpr $resetCurrentRecvDataIndex && (currentTransLen <= currentTotalShiftedCount + 1)
    outputRecvData = @wireexpr $resetCurrentRecvDataIndex && ($dataRecvWid <= currentTotalShiftedCount + 1)
    alDataRecvBufferControl = @cpalways (
        # rxValid = 0;
        if ((
            samplingNow && $outputRecvData
        ) || $(transcond(transphase, afterShiftingState)) # case where `currentTransLen` is not multiple of `lenwid`
        && ~rxValidOnce)
            rxValid <= 1
            rxValidOnce <= $(Wireexpr(1, 1))
            # if ~rxAcceptable
            #     waitingRecvDataUpdate <= $(Wireexpr(1, 1))
            # end
        # elseif waitingRecvDataUpdate
        elseif rxValid
            # rxValid = 1
            if rxAcceptable
                # waitingRecvDataUpdate <= 0
                rxValid <= 0
            end
        # end
        elseif transphase == csfinish
            rxValidOnce <= 0
        end
    )
    # maybe this works fine for bypassing?
    recvDataLsb, pRecvLsb = interceptBuffer(@wireexpr(miso), @wireexpr(samplingNow))
    alDataBufferIo = @cpalways (
        mosi = $txDataBuf[currentSendDataIndex];
        dataReceived = $rxDataBuf; # shosetsu, maybe msb dake sakiokuri?
        if samplingNow
            dataReceivedRaw[currentRecvDataIndex] <= miso;
        end
    )
    recvBufferDecl = @decls (@logic $dataRecvWid dataReceivedRaw)

    alCs = @always (
        if transphase == spiidle
            cs = 1
        else
            cs = 0
        end
    )
    alSck = @cpalways (
        shiftingNow = 0;
        samplingNow = 0;
        sck = $(Bool(cpol) ? @wireexpr(~sckInternal) : @wireexpr(sckInternal));
        if transphase == shifting
            if $(cyclePerHalfSck - 1) <= sckCycleCount
                if ~sendBusyNow && (sck == $sckStateBeforeShifting)
                    if sampledOnce
                        shiftingNow = 1
                    end
                    sckCycleCount <= 0
                    sckInternal <= ~sckInternal;
                elseif ~recvBusyNow && (sck == $sckStateBeforeSampling)
                    samplingNow = 1
                    sckCycleCount <= 0
                    sckInternal <= ~sckInternal
                    sampledOnce <= $(Wireexpr(1, 1))
                end
            else
                sckCycleCount <= sckCycleCount + $(Wireexpr(sckCycleCountWid, 1))
            end
        elseif $(transcond(transphase, @tstate sckinvert => csfinish))
            sckInternal <= ~sckInternal
        elseif transphase == csfinish
            sampledOnce <= 0
        end
    )
    alBusy = @always (
        sendBusyNow = $(Wireexpr(1, 0));
        recvBusyNow = $(Wireexpr(1, 0));
        if $requestNextSendData & ~txValid
            sendBusyNow = 1
        end;
        if $outputRecvData & ~rxAcceptable
            recvBusyNow = 1
        end
    )

    vpush!.(SpiMaster, (
        prts, transphase,
        alConfig..., alTransPhase...,
        alDataIndex, 
        alDataSendBufferControl...,
        alDataRecvBufferControl...,
        alDataBufferIo...,
        txBufPatch, txBufInvPatch, rxBufInvPatch,
        recvBufferDecl,
        alCs, alSck..., alBusy,
    ))
    vpush!(SpiMaster, @ports (@in CLK, RST))
    # vshow(alDataSend)
    m = vfinalize(SpiMaster.vmod)
    vexport(m)
end

let
    @Randmmod spiInputGenerator

    # cycles, bytes
    transactions::Vector{Tuple{Int, UInt32}} = [
        (32, 0x9f00_0000),
        # (32, 0x1234_0000)
    ]

    datarecvwid = 32
    datasendwid = 32
    lenwid = 32
    prts = @ports (
        @in ready;
        @out @logic start;
        @in $datarecvwid dataReceived;
        @out @logic $datasendwid dataToSend;
        @out @logic $lenwid cycles;
        @in btn;
    )

    # decls = @decls (
    #     @reg 
    # )

    w1, p1 = isAtRisingEdge(@wireexpr ~ready)
    albody = @cpalways (
        start = (transind < 1) & btn;
        if $w1
            transind <= transind + $(Wireexpr(32, 1))
        end;
        dataToSend = 0;
        cycles = 0;
        if transind == 0
            dataToSend = $(transactions[1][2])
            cycles = $(transactions[1][1])
        # elseif transind == 1
        #     dataToSend = $(transactions[2][2])
        #     cycles = $(transactions[2][1])
        else
        end
    )

    vpush!.(spiInputGenerator, (prts, p1, albody..., @ports(@in CLK,RST)))
    m = vfinalize(spiInputGenerator.vmod)
    # vshow(m)
    vexport(m)
    vexport(string(getname(m), "wrapper.v"), wrappergen(m))
end