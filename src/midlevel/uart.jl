const STOPBIT_MARGIN = 0.9

"""
    uartRecv(baudrate, clkfreq; name="UARTRecv")

Generate UART Rx module. 

Supposed to be used inside `Midlayer` objects, otherwise 
`valid_to_lower` signal is not visible from outside the module.

`clkfreq` should be given as Hz value (not MHz).
"""
function uartRecv(baudrate, clkfreq; name="UARTRecv")
    m = Vmodule(name)

    cycleperbitRaw = clkfreq / baudrate
    cycleperbit = Int(round(cycleperbitRaw)) - 1
    cycleperhalfbit = Int(round(cycleperbitRaw / 2)) - 1
    cycleperbit > 0 && cycleperhalfbit > 0 || error("cycleper(|half)bit should be positive")
    cycleperbit != cycleperhalfbit || error("cycles for a bit and half a bit is the same, increase cycles per bit.")
    
    cycleperstop = Int(round(cycleperbitRaw*STOPBIT_MARGIN)) - 1

    rxprts = @ports (
        @in rx;
        @out @reg 8 dout
    )

    @sym2wire cyclecount, bitcount, nextbyte
    countfull = cyclecount == Wireexpr(32, cycleperbit)
    counthalf = cyclecount == Wireexpr(cycleperhalfbit)
    countstop = cyclecount == Wireexpr(cycleperstop)

    rxfsm = @FSM recvstate sidle, sstart, sdata, sstop
    transadd!(rxfsm, [
        ((@wireexpr rx == 0), @tstate sidle => sstart),
        (countfull, @tstate sstart => sdata),
        (countfull & (bitcount == Wireexpr(3, 7)), @tstate sdata => sstop),
        (countstop & nextbyte, @tstate sstop => sstart),
        (countstop & ~nextbyte, @tstate sstop => sidle)
    ])

    alnextbyte = @always (
        nextbyte = rx == 0
    )
    alcounters = @always (
        if (recvstate == sstop) && (cyclecount == $cycleperstop)
            cyclecount <= 0;
        elseif cyclecount == $cycleperbit
            cyclecount <= 0
        else
            if ~(recvstate == sidle)
                cyclecount <= cyclecount + 1
            end
        end;

        if $countfull & (recvstate == sdata)
            bitcount <= bitcount + 1
        end
    )
    aldout = @always (
        if $counthalf & (recvstate == sdata)
            dout[bitcount] <= rx
        elseif $counthalf & (recvstate == sstart)
            dout <= 0
        end
    )
    alil = @always (
        $(nametolower(ilvalid)) = (recvstate == sstop) & $counthalf
    )

    vpush!.(m, (rxprts, rxfsm, alnextbyte, alcounters, aldout, alil))

    # return m
    return Midlayer(name, lrand, m)
end

function uartSend(baudrate, clkfreq; name="UARTSend")
    cycleperbitRaw = clkfreq / baudrate
    cycleperbit = Int(round(cycleperbitRaw)) - 1
    cycleperbit > 0 || error("cycleperbit should be positive")

    txprts = @ports (
        @in 8 din;
        @out @logic tx
    )

    @sym2wire acceptNext, bitcount, cyclecount
    countfull = cyclecount == Wireexpr(32, cycleperbit)

    txfsm = @FSM sendstate sidle, sstart, sdata, sstop
    transadd!(txfsm, [
        (Wireexpr(nametoupper(ilvalid)), @tstate sidle => sstart),
        (countfull, @tstate sstart => sdata),
        (countfull & (bitcount == Wireexpr(3, 7)), @tstate sdata => sstop),
        (countfull & acceptNext, @tstate sstop => sstart),
        (countfull & ~acceptNext, @tstate sstop => sidle)
    ])

    alcounters = @always (
        if cyclecount == $cycleperbit
            cyclecount <= 0
        else
            if ~(sendstate == sidle)
                cyclecount <= cyclecount + 1
            end
        end;

        if $countfull & (sendstate == sdata)
            bitcount <= bitcount + 1
        end
    )
    alaccept = @always (
        acceptNext = 0;
        if $(nametoupper(ilvalid))
            if sendstate == sidle
                acceptNext = 1
            elseif (sendstate == sstop) && (cyclecount == $cycleperbit)
                acceptNext = 1
            end
        end
    )
    albuf = @always (
        if acceptNext
            dbuf <= din
        end
    )
    altx = @always (
        tx = 1;
        if sendstate == sstart
            tx = 0
        elseif sendstate == sdata
            tx = dbuf[bitcount]
        end
    )
    alupdate = @always (
        $(nametoupper(ilupdate)) = (
            ((sendstate == sstop) && (cyclecount == $cycleperbit))
            || sendstate == sidle
        )
    )

    m = Vmodule(name)
    vpush!.(m, (txprts, txfsm, alcounters, alaccept, albuf, altx, alupdate))
    send = Midlayer(name, lrand, m)

    return send
end