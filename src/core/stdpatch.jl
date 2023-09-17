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

# methods here return a tuple of wire and Vpatch
"""
    posedgePrec(earlier::Wireexpr, later::Wireexpr, name::AbstractString)

Return wireexpr which indicates if a rising edge in `earlier` occured 
earlier than that of `later`.

The wires `earlier` and `later` being high from the beginning 
is regarded as an edge at the beginning.

## Bit field
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
    bitbundle(wvec, name::AbstractString)

Return wire which bundles `Wireexpr`s in wvec.

Width of wires in `wvec` are supposed to be all one.
"""
function bitbundle(wvec::Vector{Wireexpr}, name::AbstractString)
    bundlename = string("_bitbundle_", name)
    buf = Vector{Alassign}(undef, length(wvec))
    for (i, w) in enumerate(wvec)
        buf[i] = @alassign_comb $bundlename[$(i-1)] = $w
    end
    
    return Wireexpr(bundlename), Vpatch(Alwayscontent(comb, Ifcontent(buf)))
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

## Bit field
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

    return ans, Vpatch(al)
end
nonegedgeCounter::Int = 0
function nonegedge(uno::Wireexpr)
    nonegedge(uno, string(global nonegedgeCounter+=1))
end

"""
    posedgeSync(uno::Wireexpr, dos::Wireexpr, name::AbstractString)

Return `Wireexpr` which indicates whether a rising edge is detected
at the same clock cycle in `uno` and `dos`.

## Bit field
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
