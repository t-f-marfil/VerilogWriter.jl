"""
    pow2check(x::Int)::Bool

Check if x is the power of two. Called in [`fifogen`](@ref).
"""
function pow2check(x::Int)::Bool
    if x < 1
        false
    else
        sample = 1
        while sample < x 
            sample <<= 1
        end

        sample == x 
    end
end

"""
    fifogen(depth=8, width=32; name="")

Generate FIFO whose depth is `depth` and width is `width`, with its name `name`.
"""
function fifogen(depth=8, width=32; name="")
    depth > 1 || error("depth for this FIFO should be more than one.")
    pow2check(depth) || error("depth for this FIFO should be the power of two.")
    

    ptrwid = Int(ceil(log(2, depth)))
    # wptr == entry to write next 
    # rptr == entry to read next

    bufram = decls(:(
        @reg $(width) ram $(depth)
    ))

    
    ptrincr = Wireexpr(ptrwid, 1)
    flags = always(:(
        empty = wptr == rptr;
        full = wptr + $(ptrincr) == rptr
    ))
    ptrlogic = always(:(
        if wincr && ~full
            wptr <= wptr + $(ptrincr)
        end;

        if rincr && ~empty 
            rptr <= rptr + $(ptrincr)
        end
    ))

    dout = @always(
        dout = ram[rptr]
    )
    din = @always(
        if wincr && ~full 
            ram[wptr] <= din 
        end
    )

    # vshow.((bufram, flags, ptrlogic))
    nn = length(name) == 0 ? "fifo_$(width)_$(depth)" : name
    mod = Vmodule(nn)
    prts = @ports((
        @in CLK, RST;
        @in -1 din;
        @out @reg -1 dout;

        @out @reg full, empty;
        @in wincr, rincr
    ))
    vpush!(mod, prts)
    vpush!.(Ref(mod), (bufram, flags, ptrlogic, dout, din))
    # (mod = vfinalize(mod)) |> vshow

    vfinalize(mod)
end