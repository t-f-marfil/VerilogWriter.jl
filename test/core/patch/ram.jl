function fifoTest()
    v = Vmodule("dut")
    fifoDepth = 4
    (ready, valid, dout), p = fifoPatch(fifoDepth, 32, "din", "senderValid", "recvUpdate")
    vpush!(v, p)
    vpush!(v, @ports @in CLK, RST)

    dataSize = 10
    alSender = @cpalways (
        din = senderCounter;
        senderValid = senderCounter < $dataSize;
        if $ready && senderValid
            senderCounter <= senderCounter + 1
        end
    )
    initialRecvWait = 100
    alRecv = @cpalways (
        if initialRecvWaitCounter < $initialRecvWait
            initialRecvWaitCounter <= initialRecvWaitCounter + $(Wireexpr(32, 1))
        end;
        recvUpdate = initialRecvWaitCounter == $initialRecvWait;
        if recvUpdate && $valid
            recvCounter <= recvCounter + $(Wireexpr(32, 1))
        end
    )

    alTp = @cpalways (
        tp[$(dataSize-1):0] = dataTp;
        if recvUpdate && $valid
            dataTp[recvCounter] <= ($dout == recvCounter)
        end;

        tp[$(dataSize+0)] = invalidFromFifoWhenFullDetected;
        if (senderCounter == $fifoDepth - 1) && ~$ready
            invalidFromFifoWhenFullDetected <= 1
        end;

        finishWithEmpty <= ~$valid;
        tp[$(dataSize+1)] = finishWithEmpty
    )
    
    tpMisc = 2
    vpush!(v, @ports @out @logic $(dataSize + tpMisc) tp)
    vpush!.(v, (alSender..., alRecv..., alTp...))

    @test verilatorSimrun(vfinalize(v), dataSize+tpMisc, 200)
end

fifoTest()