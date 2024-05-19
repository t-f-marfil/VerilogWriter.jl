struct PrivateWireNameGen
    suffix::String
end
function (cls::PrivateWireNameGen)(n::AbstractString)
    return string(n, cls.suffix)
end

"""
Wrapper object to add logics and wire declarations to `Vmodule`.
"""
struct Vpatch{T<:Tuple}
    data::T
end
Vpatch(args...) = Vpatch(args)

function vpush!(v::Vmodule, p::Vpatch)
    vpush!.(v, p.data)
    return
end

"""
    extractTypedArguments(expr::Expr)

From an expression of the whole function, extract 
arguments with type.
"""
function extractTypedArguments(expr::Expr)
    ans = Vector{Tuple{Symbol, Union{Symbol, Expr}}}()
    funarguments = expr.args[begin]
    funarguments.head == :call || error("parametric type and return type not implemented yet")
    for arg in funarguments.args[2:end]
        if arg isa Expr && arg.head == :(::)
            argname, argtype = arg.args
            push!(ans, (argname, argtype))
        else
            push!(ans, (arg, :Any))
        end
    end

    return ans
end

"""
    extractFunName(expr::Expr)

Extract the name of a function from the whole function expression.
"""
function extractFunName(expr::Expr)
    return expr.args[begin].args[begin]
end

"""
    @vstdpatch(expr)

Attached at methods generating a pair of `Wireexpr` and `Vpatch`.
Methods should take `name::AbstractString` as the last argument.
The macro additionally defines the method which does not take `name` argument,
and which internally passes as `name` an `Int` value which is incremented
everytime the method without `name` argument is called.

To summarize, when this macro takes
```
function Foo(arg1::T1, arg2::T2, name::AbstractString)
    ...
end
```
as its argument, it generates
```
# The original method definition
function Foo(arg1::T1, arg2::T2, name::AbstractString)
    ...
end

# Int value
FooCounter::Int = 0

# Additional method without `name`
function Foo(arg1::T1, arg2::T2)
    return Foo(arg1, arg2, string(global FooCounter += 1))
end
```
"""
macro vstdpatch(expr)
    funname = extractFunName(expr)
    args = extractTypedArguments(expr)
    if args[end] != (:name, :AbstractString)
        error("the last argument should be name::AbstractString, given $(args[end])")
    end
    argnames = [i for (i, j) in args]
    countername = Symbol(funname, "Counter")

    qgenerated = quote
        $expr
        $countername::Int = 0
        function $funname($([j == :Any ? :($i) : :($i::$j) for (i, j) in args[begin:end-1]]...))
            return $funname($(argnames[begin:end-1]...), string(global $countername += 1))
        end
    end
    return esc(qgenerated)
end

# methods here return a tuple of wire and Vpatch
"""
    posedgePrec(earlier::Wireexpr, later::Wireexpr, name::AbstractString)

Return wireexpr which indicates if a rising edge in `earlier` occured 
earlier than that of `later`.

The wires `earlier` and `later` being high from the beginning 
is regarded as an edge at the beginning.

## Return Wire
+ (1): 1 if edge detected in either of two wires
+ (0): 1 if edge in `earlier` was earlier than `later`
"""
function posedgePrec(earlier::Wireexpr, later::Wireexpr, name::AbstractString)
    answire = string("_posedgePrec_", name)
    pvg = PrivateWireNameGen(answire)

    bufearlier = pvg("_bufearlier")
    buflater = pvg("_buflater")
    buffedearlier = pvg("_buffedearlier")
    buffedlater = pvg("_buffedlater")
    ans1buf = pvg("_ans1buf")
    triggerednow = pvg("_triggerednow")
    ans0buf = pvg("_ans0buf")
    preans0 = pvg("_preans0")

    als = @cpalways (
        $bufearlier <= $earlier | $bufearlier;
        $buflater <= $later | $buflater;

        $buffedearlier = $bufearlier | $earlier | $(Wireexpr(1, 0));
        $buffedlater = $buflater | $later | $(Wireexpr(1, 0));

        $answire[1] = $buffedearlier | $buffedlater;
        $ans1buf <= $answire[1] | $ans1buf;

        $triggerednow = $answire[1] & ~$ans1buf;
        $preans0 = $earlier & ~$later;
        if $triggerednow
            $ans0buf <= $preans0
        end;
        $answire[0] = ($preans0 & $triggerednow) | $ans0buf
    )

    return Wireexpr(answire), Vpatch(als..., @decls @logic 2 $answire)
end
posedgePrecCounter::Int = 0
function posedgePrec(earlier::Wireexpr, later::Wireexpr)
    posedgePrec(earlier, later, string(global posedgePrecCounter+=1))
end

"""
    bitbundle(wvec::Vector{Wireexpr}, name::AbstractString)

Return wire which bundles `Wireexpr`s in wvec.

Width of wires in `wvec` are supposed to be all one.
"""
function bitbundle(wvec::Vector{Wireexpr}, name::AbstractString)
    bundlename = string("_bitbundle_", name)
    buf = Vector{Alassign}(undef, length(wvec))
    for (i, w) in enumerate(wvec)
        buf[i] = @alassign_comb $bundlename[$(i-1)] = $w
    end
    
    return Wireexpr(bundlename), Vpatch((@decls @logic $(length(wvec)) $bundlename), Alwayscontent(comb, Ifcontent(buf)))
end
bitbundleCounter::Int = 0
function bitbundle(wvec)
    bitbundle(wvec, string(global bitbundleCounter+=1))
end

"""
    nonegedge(uno::Wireexpr, name::AbstractString)

Return wire which shows whether wire `uno` underwent a
falling edge.

Wire `uno` must be single-bit wide or fails in width inference.

## Return Wire
+ (0): 1 if wire `uno` has never encountered a falling edge
"""
function nonegedge(uno::Wireexpr, name::AbstractString)
    ans = string("_nonegedge_", name)
    pvg = PrivateWireNameGen(ans)

    negedgenow = pvg("_nedge")
    prevwire = pvg("_prev")
    negedgebuf = pvg("_ansbuf")
    al = @cpalways (
        $prevwire <= $uno;
        $negedgebuf <= $negedgenow | $negedgebuf;

        $negedgenow = $prevwire & ~$uno;
        $ans = $(Wireexpr(1, 0)) | ~($negedgenow | $negedgebuf);
    )

    return Wireexpr(ans), Vpatch(al)
end
nonegedgeCounter::Int = 0
function nonegedge(uno::Wireexpr)
    nonegedge(uno, string(global nonegedgeCounter+=1))
end

"""
    posedgeSync(uno::Wireexpr, dos::Wireexpr, name::AbstractString)

Return `Wireexpr` which indicates whether a rising edge is detected
at the same clock cycle in `uno` and `dos`.

## Return Wire
+ (1): 1 if edge detected in either of two wires
+ (0): 1 if edge in `earlier` was earlier than `later`
"""
function posedgeSync(uno::Wireexpr, dos::Wireexpr, name::AbstractString)
    answire = string("_posedgeSync_", name)
    pvg = PrivateWireNameGen(answire)

    edgedetectedbuf = pvg("_edgedetectedbuf")
    edgedetectedcomb = pvg("_edgedetectedcomb")
    firstedge = pvg("_firstedge")

    unoaccum = pvg("_unobuf")
    dosaccum = pvg("_dosbuf")

    ansbuf0 = pvg("_ansbuf0")

    als = @cpalways (
        $edgedetectedcomb = $uno | $dos | $(Wireexpr(1, 0));
        $edgedetectedbuf <= $edgedetectedcomb | $edgedetectedbuf;
        $answire[1] = $edgedetectedcomb | $edgedetectedbuf;
        $firstedge = ~$edgedetectedbuf & $edgedetectedcomb;

        $answire[0] = 0;
        if $firstedge
            $answire[0] = $uno & $dos
            $ansbuf0 <= $answire[0]
        elseif $edgedetectedbuf
            $answire[0] = $ansbuf0
        end
    )

    return Wireexpr(answire), Vpatch(als..., @decls @logic 2 $answire)
end
posedgeSyncCounter::Int = 0
function posedgeSync(uno::Wireexpr, dos::Wireexpr)
    posedgeSync(uno, dos, string(global posedgeSyncCounter+=1))
end


function invertBitOrder(w::Wireexpr, wid::Int, name::AbstractString)
    answire = Wireexpr(string("_invertBitOrder_", name))
    assigns = [(@alassign_comb $answire[$(i-1)] = $w[$(wid-i)]) for i in 1:wid]
    return answire, Vpatch((@decls @logic $wid $answire), @always $(assigns...))
end
invertBitOrderCounter::Int = 0
function invertBitOrder(w::Wireexpr, wid::Int)
    return invertBitOrder(w, wid, string(global invertBitOrderCounter+=1))
end

@vstdpatch function isAtRisingEdge(w::Wireexpr, name::AbstractString)
    retname = string("_risingEdge_", name)
    pvg = PrivateWireNameGen(retname)

    prev = pvg("_prev")

    al = @cpalways (
        $prev <= $w;
        $retname = ($prev == $(Wireexpr(1, 0))) & ($w == $(Wireexpr(1, 1)))
    )
    
    return Wireexpr(retname), Vpatch(al...)
end
"""
    isAtRisingEdge(w::Wireexpr, name::AbstractString)

Return wire whose value is 1 iff the wire `w` is at the rising edge.

## Return Wire
+ (0): 1 at the cycle at which a rising edge is detected.
"""
isAtRisingEdge


@vstdpatch function interceptBuffer(data::Wireexpr, update::Wireexpr, name::AbstractString)
    answire = string("_interceptBuffer_", name)
    pvg = PrivateWireNameGen(answire)
    buffer = pvg("_buffer")

    al = @cpalways (
        if $update
            $answire = $data
            $buffer <= $data
        else
            $answire = $buffer
        end
    )

    return Wireexpr(answire), Vpatch(al...)
end
"""
    interceptBuffer(data::Wireexpr, update::Wireexpr, name::AbstractString)

Buffer that changes its data at the exact cycle at which `update` is triggerred.

Should be careful on the critical path on using this buffer.

## Return Wire
+ (length(data)-1:0): Buffer output
"""
interceptBuffer


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
function readOnlyQueueComb(width::Int, data::V, update, restart, name::AbstractString) where {T,V<:AbstractVector{T}}
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
readOnlyQueueCombCounter::Int = 0
function readOnlyQueueComb(width::Int, data::V, update, restart) where {T,V<:AbstractVector{T}}
    readOnlyQueueComb(width, data, update, restart, string(global readOnlyQueueCombCounter += 1))
end

"""
    readOnlyQueue(width::Int, depth::Int, update, restart, memfilename, name::AbstractString)

Generate a buffer queue whose data is initalized with `memfile` using initial statement.

Output is same as that of [`readOnlyQueueComb`](@ref).
"""
function readOnlyQueue(width::Int, depth::Int, update, restart, memfilename, name::AbstractString)
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
readOnlyQueueCounter::Int = 0
function readOnlyQueue(width::Int, depth::Int, update, restart, memfilename)
    readOnlyQueue(width, depth, update, restart, memfilename, string(global readOnlyQueueCounter += 1))
end

@vstdpatch function onceHigh(wire::Wireexpr, restart::Wireexpr, name::AbstractString)
    pvg = PrivateWireNameGen(string("_onceAtRisingEdge_", name))
    ans = pvg("_ans")
    buf = pvg("_buf")
    al = @cpalways (
        $ans = $buf | $wire;
        if $restart
            $buf <= 0
        else
            $buf <= $buf | $wire
        end
    )
    return @wireexpr($ans), Vpatch(al...)
end

@vstdpatch function zipSpike(wires::Vector{Wireexpr}, name::AbstractString)
    spikeName = string("_zippedSpike_", name)
    pvg = PrivateWireNameGen(spikeName)

    zipped = pvg("_zipped")
    prevZipped = pvg("_prevzipped")

    highs = [onceHigh(w, @wireexpr($zipped)) for w in wires]

    bundled, pbundled = bitbundle([w for (w, _) in highs])
    
    al = @cpalways (
        $prevZipped <= $zipped;
        $zipped = &($bundled)
    )

    return @wireexpr($zipped), Vpatch([p for (_, p) in highs]..., pbundled, al...)
end