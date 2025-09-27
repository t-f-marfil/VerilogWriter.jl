function generateBramFifo(name)
    v = Vmodule("fifoOnBram_$name")
    @sym2wire enread, enwrite, addrin, addrout, din
    width = 32 + 1
    depth = 8
    dout, raminst = generateRamSdpRfInst(width, depth, enread, enwrite, addrin, addrout, din, "")

    prts = @ports (
        @in CLK, RST;

        # wlast and rlast here is only a supplementary info,
        # fifo keep on running no matter what value wlast and rlast are
        @in wvalid, wlast;
        @out @logic wready;
        @in 32 wdata;

        @out @logic rvalid, rlast;
        @in rready;
        @out @logic 32 rdata;
    )
    alconst = @always (
        ptrincr = $(Wireexpr(depth, 1))
    )
    alio = @always (
        rincr = rready;
        rvalid = ~empty;

        wincr = wvalid;
        wready = ~full;
    )
    alflags = @always (
        empty = prevwptr == rptr;
        full = wptr + ptrincr == rptr
    )
    alnrptrlogic = @nralways (
        if RST
            rptrincr <= 1
        else
            if rincr & ~empty 
                rptrincr <= rptrincr + ptrincr
            end
        end
    )
    alcombptrlogic = @always (
        if rincr & ~empty
            raddr = rptrincr
        else
            raddr = rptr
        end
    )
    alptrlogic = @always (
        if wincr & ~full
            wptr <= wptr + ptrincr
        end;

        prevwptr <= wptr;

        if rincr & ~empty 
            rptr <= rptr + ptrincr
        end
    )
    alram = @always (
        enread = $(Wireexpr(1, 1));
        enwrite = wvalid & wready;
        addrin = wptr;
        addrout = raddr;
        din = {wdata, wlast} | $(Wireexpr(width, 0));
        {rdata, rlast} = $dout | $(Wireexpr(width, 0));
    )

    vpush!.(v, (
        raminst,
        prts,
        alconst, alio, alflags,
        alnrptrlogic, alptrlogic, alcombptrlogic,
        alram
    ))
    return v
end