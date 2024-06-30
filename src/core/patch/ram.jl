@vstdpatch function readOnlyQueueComb(width::Int, data::V, update, restart, name::AbstractString) where {T,V<:AbstractVector{T}}
    wireId = string("_readOnlyQueueComb_", name)
    pvg = PrivateWireNameGen(wireId)

    totalBitWidth = width * length(data)
    dataReadOnly = pvg("data")
    dataVecDecl = @decls @logic $totalBitWidth $dataReadOnly
    dataAssignList = Vector{Alassign}(undef, length(data))

    for i in eachindex(data)
        msbIndex = width * i - 1
        asgn = @alassign_comb $(dataReadOnly)[($msbIndex)-:($width)] = $(Wireexpr(width, data[i]))
        dataAssignList[i] = asgn
    end

    dataAssignAlways = Alwayscontent(comb, dataAssignList)

    counter = pvg("counter")
    counterWidth = (
        (ceil(log(2, length(data)) + 1) |> Int)
        # allocate enough width for indexed part select
        # (counter width should be equal to index for part select below)
        + (ceil(log(2, width) + 1) |> Int)
    )
    dataValid = pvg("valid")
    alvalid = @always (
        $dataValid = ~($counter == $(Wireexpr(counterWidth, length(data))))
    )
    alCounter = @always (
        if $restart
            $counter <= 0
        elseif $update
            if $dataValid
                $counter <= $counter + 1
            end
        end
    )

    outData = pvg("outData")
    dataSliceIndex = pvg("sliceIndex")
    alSliceIndex = @always ( 
        $dataSliceIndex = 0;
        if ~$dataValid
            $dataSliceIndex = $counter
        else
            $dataSliceIndex = $counter + 1
        end;
    )
    alOutData = @always (
        $outData = $dataReadOnly[($dataSliceIndex * $width - 1)-:($width)]
    )
    
    patch = Vpatch(
        dataVecDecl,
        alvalid,
        alCounter,
        alSliceIndex,
        alOutData,
        dataAssignAlways
    )
    return (dataValid, outData), patch
end
"""
    readOnlyQueueComb(width::Int, data::V, update, restart, name::AbstractString) where {T,V<:AbstractVector{T}}

Generate queue which outputs value in `data` in the order which they are aligned in `data`.
Implemented with 1d reg and always_comb.

Each item in `data` is converted to a wire in verilog with width `width`.

## Input Wires
+ `update` : Wire to be asserted to request next data to the queue.
+ `restart` : When asserted the queue starts outputting value in `data` from the first item.

## Return Wires

### dataValid
+ (0): High indicates that the output from the queue is valid.

### outData
+ (`width`-1:0): Data from the queue.
"""
readOnlyQueueComb

@vstdpatch function readOnlyQueue(width::Int, depth::Int, update, restart, memfilename, name::AbstractString)
    pvg = PrivateWireNameGen(string("_readonlyqueue_", name))
    reg = pvg("_reg")

    d = @decls @reg $(width) $reg $depth

    outData = pvg("_outdata")
    index = pvg("_index")
    preindex = pvg("_preindex")
    indexWidth = Int(log(2, depth) |> ceil)

    valid = pvg("_valid")
    iterdone = pvg("_iterdone")

    accepted = @wireexpr $update & $valid

    alIndex = @cpalways (
        $index = 0;
        if $restart
            $index = 0
        elseif $accepted
            if $preindex == $(depth - 1)
                $index = 0
            else
                $index = $preindex + 1
            end
        else
            $index = $preindex
        end;

        if $restart
            $preindex <= 0
            $iterdone <= 0
        elseif $accepted
            if ($preindex == $(depth - 1))
                $preindex <= $(Wireexpr(indexWidth, 0))
                $iterdone <= $(Wireexpr(1, 1))
            else
                $preindex <= $preindex + 1
            end
        end
    )
    initWait = pvg("_initWait")

    alValid = @cpalways (
        $initWait <= $(Wireexpr(1, 1));
        $valid = $initWait & ~$iterdone
    )
    alReg = @nralways (
        $outData <= $reg[$index]
    )
    readmem = Readmemh(memfilename, reg, 0, depth - 1)

    return (valid, outData), Vpatch(d, alIndex..., alValid..., alReg, readmem)
end
"""
    readOnlyQueue(width::Int, depth::Int, update, restart, memfilename, name::AbstractString)

Generate a buffer queue whose data is initalized with `memfile` using initial statement.

Output is same as that of [`readOnlyQueueComb`](@ref).
"""
readOnlyQueue


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

@vstdpatch function fifoPatch(depth, width, inputData, inputValid, updateOutput, name::AbstractString)
    pvg = PrivateWireNameGen(string("_fifoPatch_", name))

    depth > 1 || error("depth for FIFO should be larger than 0, $depth given")
    pow2check(depth) || error("depth for this FIFO should be the power of two, $depth given.")

    ptrwid = Int(ceil(log(2, depth)))

    # wptr == entry to write next 
    # rptr == entry to read next
    ram = pvg("_ram")
    wptr, rptr = pvg.(["_wptr", "_rptr"])
    prevwptr = pvg("_prevwptr")
    rptrComb = pvg("_rptrComb")
    wincr, rincr = pvg.(["_wincr", "_rincr"])
    empty, full = pvg.(["_empty", "_full"])

    dout, doutRam, doutBypassed = pvg.(["_dout", "_doutRam", "_doutBypassed"])
    outValid = pvg("_outvalid")
    inReady = pvg("_inready")

    bufram = @decls (
        @reg $width $ram $depth
    )

    ptrincr = Wireexpr(ptrwid, 1)
    flags = @always (
        $empty = $wptr == $rptr;
        $full = ($wptr + $ptrincr) == $rptr
    )
    ptrlogic = @cpalways (
        if $wincr && ~$full
            $wptr <= ($wptr + $ptrincr)
        end;

        $prevwptr <= $wptr;

        $rptrComb = $rptr;
        if $rincr && ~$empty 
            $rptr <= ($rptr + $ptrincr)
            $rptrComb = ($rptr + $ptrincr)
        end
    )

    alDoutRam = @always (
        $doutRam <= $ram[$rptrComb]
    )
    alDout = @cpalways (
        $doutBypassed <= $inputData;
        if $prevwptr == $rptr
            $dout = $doutBypassed
        else
            $dout = $doutRam
        end
    )
    alDin = @nralways (
        if $wincr && ~$full 
            $ram[$wptr] <= $inputData
        end
    )

    alcontrol = @always (
        $outValid = ~$empty;
        $rincr = $updateOutput;

        $inReady = ~$full;
        $wincr = $inputValid
    )

    return (inReady, outValid, dout), Vpatch(bufram, flags, ptrlogic..., alDoutRam, alDout..., alDin, alcontrol)
end
"""
    fifoPatch(depth, width, inputData, inputValid, updateOutput, name::AbstractString)

Implement FIFO in a so-called first-word-fall-through style.

## Input Wires

### inputData
+ (`width`-1:0): Data input to FIFO.

### inputValid
+ (0): 1 if `inputData` contains valid data.

### updateOutput
+ (0): 1 when requesting next data to FIFO. After `updateOutput` is set to 1, `dout` would contain valid data at the first cycle at which `outValid` is set to 1.

## Return Wires

### inReady
+ (0): 1 if fifo is ready to accept new input.

### outValid
+ (0): 1 if `dout` contains valid data.

### dout
+ (`width-1`:0): Data output from FIFO.
"""
fifoPatch