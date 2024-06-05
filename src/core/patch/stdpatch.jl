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
    args = nothing
    parametric = nothing
    if funarguments.head == :call
        args = funarguments.args
    else
        # parametric type
        funarguments.head == :where || error("Unknown arg: $(dump(funarguments))")
        args = funarguments.args[begin].args
        parametric = funarguments.args[2:end]
    end

    for arg in args[2:end]
        if arg isa Expr && arg.head == :(::)
            argname, argtype = arg.args
            push!(ans, (argname, argtype))
        else
            push!(ans, (arg, :Any))
        end
    end

    return ans, parametric
end

"""
    extractFunName(expr::Expr)

Extract the name of a function from the whole function expression.
"""
function extractFunName(expr::Expr)
    if expr.args[begin].head == :where
        # parametric type
        return expr.args[begin].args[begin].args[begin]
    else
        return expr.args[begin].args[begin]
    end
end

"""
    @vstdpatch(expr)

Attached at methods generating a pair of something (usually wires) and `Vpatch`.
Methods should take `name::AbstractString` as the last argument.
The macro additionally defines the method which does not take `name` argument,
and which internally passes to `name` an `Int` value which is incremented
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

# Additional method without `name`
function Foo(arg1::T1, arg2::T2)
    return Foo(arg1, arg2, string(global FooCounter += 1))
end
```
"""
macro vstdpatch(expr)
    funname = extractFunName(expr)
    args, parametric = extractTypedArguments(expr)
    if args[end] != (:name, :AbstractString)
        error("the last argument should be name::AbstractString, given $(args[end])")
    end
    argnames = [i for (i, j) in args]
    countername = Symbol("StdpatchCounter")

    qgenerated = nothing
    if isnothing(parametric)
        qgenerated = quote
            $expr
            function $funname($([j == :Any ? :($i) : :($i::$j) for (i, j) in args[begin:end-1]]...))
                return $funname($(argnames[begin:end-1]...), string(global $countername += 1))
            end
        end
    else
        qgenerated = quote
            $expr
            function $funname($([j == :Any ? :($i) : :($i::$j) for (i, j) in args[begin:end-1]]...)) where {$(parametric...)}
                return $funname($(argnames[begin:end-1]...), string(global $countername += 1))
            end
        end
    end
    return esc(qgenerated)
end

StdpatchCounter::Int = 0

export resetStdpatchCounter

function resetStdpatchCounter()
    global StdpatchCounter = 0
end

# methods here return a tuple of wire and Vpatch

@vstdpatch function posedgePrec(earlier::Wireexpr, later::Wireexpr, name::AbstractString)
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
posedgePrec


@vstdpatch function bitbundle(wvec::Vector{Wireexpr}, name::AbstractString)
    bundlename = string("_bitbundle_", name)
    buf = Vector{Alassign}(undef, length(wvec))
    for (i, w) in enumerate(wvec)
        buf[i] = @alassign_comb $bundlename[$(i-1)] = $w
    end
    
    return Wireexpr(bundlename), Vpatch((@decls @logic $(length(wvec)) $bundlename), Alwayscontent(comb, Ifcontent(buf)))
end
"""
    bitbundle(wvec::Vector{Wireexpr}, name::AbstractString)

Return wire which bundles `Wireexpr`s in wvec.

Width of wires in `wvec` are supposed to be all one.
"""
bitbundle


@vstdpatch function nonegedge(uno::Wireexpr, name::AbstractString)
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
"""
    nonegedge(uno::Wireexpr, name::AbstractString)

Return wire which shows whether wire `uno` underwent a
falling edge.

Wire `uno` must be single-bit wide or fails in width inference.

## Return Wire
+ (0): 1 if wire `uno` has never encountered a falling edge
"""
nonegedge


@vstdpatch function posedgeSync(uno::Wireexpr, dos::Wireexpr, name::AbstractString)
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
"""
    posedgeSync(uno::Wireexpr, dos::Wireexpr, name::AbstractString)

Return `Wireexpr` which indicates whether a rising edge is detected
at the same clock cycle in `uno` and `dos`.

## Return Wire
+ (1): 1 if edge detected in either of two wires
+ (0): 1 if edge in `earlier` was earlier than `later`
"""
posedgeSync


@vstdpatch function invertBitOrder(w::Wireexpr, wid::Int, name::AbstractString)
    answire = Wireexpr(string("_invertBitOrder_", name))
    assigns = [(@alassign_comb $answire[$(i-1)] = $w[$(wid-i)]) for i in 1:wid]
    return answire, Vpatch((@decls @logic $wid $answire), @always $(assigns...))
end
"""
    invertBitOrder(w::Wireexpr, wid::Int)

Invert bit order of wire `w`.

## Return Wire
+ (`wid`-1:0): Bit order of `w` is inverted.
"""
invertBitOrder

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

@vstdpatch function onceHigh(wire::Wireexpr, restart::Wireexpr, name::AbstractString)
    pvg = PrivateWireNameGen(string("_onceHigh_", name))
    ans = pvg("_ans")
    buf = pvg("_buf")
    al = @cpalways (
        $ans = $buf | $wire;
        if $restart
            $buf <= $(Wireexpr(1, 0))
        else
            $buf <= $buf | $wire
        end
    )
    return @wireexpr($ans), Vpatch(al...)
end
"""
    onceHigh(wire::Wireexpr, restart::Wireexpr)

Check if `wire` is once asserted.

## Input Wires

### restart
+ (0): Restart checking if `wire` is asserted.

## Return wire
+ (0): 1 if wire is asserted once after restart is deasserted.
"""
onceHigh

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
"""
    zipSpike(wires::Vector{Wireexpr})

Zip rising edges of wires in `wires`.

## Return Wire
+ (0): 1 if all wire in `wires` experienced rising edge after this wire is previously asserted.
"""
zipSpike