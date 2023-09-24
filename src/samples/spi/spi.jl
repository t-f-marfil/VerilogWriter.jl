let
    @Randmmod SpiMaster

    cyclePerHalfSck = 1

    # width needed to indicate number of cycles for current transaction
    # 32 bit should be sufficient for most cases
    lenwid = 32
    # data bus width for those sent to devices. When cycles of sck is larger than this number,
    # data should be separated into multiple words, which is not yet implemented
    datasendwid = 32
    # bus width for data received from devices
    datarecvwid = 32

    @assert datasendwid > 0 && cyclePerHalfSck > 0

    cpol = 1
    cpha = 1

    cswaitcycles = 2cyclePerHalfSck

    widthToIndexBitLen(wid::Int) = max(1, Int(ceil(log(2, wid))))
    cycleCountWid = widthToIndexBitLen(cyclePerHalfSck)
    mosiIndexWid = widthToIndexBitLen(datasendwid)
    sampleWithSckPosedge = cpol == cpha
    csWaitCountWid = widthToIndexBitLen(cswaitcycles)

    sckInvertBeforeCsHigh = cpha == 1

    transphase = @FSM transphase spiidle, csinit, shifting, csfinish, sckinvert
    prts = @ports (
        @out @logic sck, mosi, cs;
        @in miso;
        @in $lenwid cycles;
        @in $datasendwid dataToSend;
        @out @logic $datarecvwid dataReceived;
        @in start;
        @out @logic ready;
    )

    transFromStateShifting = (
        if sckInvertBeforeCsHigh
            @tstate shifting => sckinvert
        else
            @tstate shifting => csfinish
        end
    )
    transadd!(transphase, [
        ((@wireexpr starttrans), @tstate spiidle => csinit),
        ((@wireexpr cswaitcounter == $(cswaitcycles-1)), @tstate csinit => shifting),
        ((@wireexpr finishShifting), transFromStateShifting),
        (cyclePerHalfSck <= 1 ? Wireexpr(1, 1) : (@wireexpr $(cyclePerHalfSck - 1) <= cycleCount), @tstate sckinvert => csfinish),
        ((@wireexpr cswaitcounter == $(cswaitcycles-1)), @tstate csfinish => spiidle)
    ])
    # SPI sends data from MSB to LSB, but in verilog better arrange data from LSB to MSB
    dataSendInv, patchSend = invertBitOrder((@wireexpr dataToSend), datasendwid)
    dataRecvInv, patchRecv = invertBitOrder((@wireexpr dataReceivedInternal), datarecvwid)
    alconfig = @always (
        starttrans = start;
        # dataToSendInternal = $dataSendInv;
        dataReceived = $dataRecvInv;
        sck = $(
            if cpol == 0
                @wireexpr sckInternal
            else
                @wireexpr ~sckInternal
            end
        );
        mosi = dataToSendInternal[mosiIndex];

        cs = ~csInternal;
        ready = transphase == spiidle
    )
    albody = @cpalways (
        finishShifting = 0;

        if $(transcond(transphase, @tstate spiidle => csinit))
            dataToSendInternal <= $dataSendInv
            dataReceivedInternal <= 0
        end;
        if $(transcond(transphase, @tstate spiidle => csinit))
            transCycles <= cycles
        end;
        if transphase == shifting
            # if cyclecount reached max, meaning SCK is now at either pos or neg edge
            if $(cyclePerHalfSck <= 1 ? Wireexpr(1, 1) : (@wireexpr $(cyclePerHalfSck - 1) <= cycleCount))
                cycleCount <= 0
                sckInternal <= ~sckInternal

                if $(sampleWithSckPosedge ? (@wireexpr sck == 0) : (@wireexpr sck == 1))
                    # sampling edge
                    sampledOnce <= $(Wireexpr(1, 1))
                else
                    # shifting edge
                    dataReceivedInternal[mosiIndex] <= miso
                    if sampledOnce # otherwise this SCK edge is the beginning of a transaction
                        if shiftedcount + 1 < transCycles
                            shiftedcount <= shiftedcount + $(Wireexpr(lenwid, 1))
                            if mosiIndex < $(datasendwid - 1)
                                mosiIndex <= mosiIndex + $(Wireexpr(mosiIndexWid, 1))
                            else
                                mosiIndex <= 0
                            end
                        else
                            mosiIndex <= 0
                            shiftedcount <= 0
                            finishShifting = $(Wireexpr(1, 1))
                        end
                    end
                end
            else
                cycleCount <= cycleCount + $(Wireexpr(cycleCountWid, 1))
            end;
        elseif transphase == csinit
            csInternal <= $(Wireexpr(1, 1))
            if $(transcond(transphase, @tstate csinit => shifting))
                cswaitcounter <= 0
            else
                cswaitcounter <= $(Wireexpr(csWaitCountWid, 1))
            end
        elseif transphase == csfinish
            if $(transcond(transphase, @tstate csfinish => spiidle))
                cswaitcounter <= 0
                csInternal <= 0
            else
                cswaitcounter <= $(Wireexpr(csWaitCountWid, 1))
            end
        elseif transphase == sckinvert
            if $(transcond(transphase, @tstate sckinvert => csfinish))
                cycleCount <= 0
                sckInternal <= ~sckInternal
            else
                cycleCount <= cycleCount + $(Wireexpr(cycleCountWid, 1))
            end
        end
    )
    # vshow(transphase)

    vpush!.(SpiMaster, (patchSend, patchRecv, (@decls @logic $datarecvwid dataReceivedInternal)))
    vpush!.(SpiMaster, (prts, alconfig, albody..., transphase, @ports (@in CLK, RST)))
    f = vfinalize(SpiMaster.vmod)
    vexport(f)
    vexport(string(getname(f), "wrapper.v"), wrappergen(f))
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