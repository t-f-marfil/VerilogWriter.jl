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

function patchmerge(ps::Vpatch...)
    return Vpatch(ps)
end

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
+ [1]: 1 if edge detected in either of two wires
+ [0]: 1 if edge in `earlier` was earlier than `later`
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
        $buffedlater = $buflater | $buflater | $(Wireexpr(1, 0));

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
function posedgePrec(earlier::Wireexpr, later::Wireexpr)
    posedgePrec(earlier, later, "")
end

"""
    bitbundle(wvec, name::AbstractString)

Return wire which bundles `Wireexpr`s in wvec.

Width of wires in `wvec` are supposed to be all one.
"""
function bitbundle(wvec, name::AbstractString)
    bundlename = string("_bitbundle_", name)
    buf = Vector{Alassign}(undef, length(wvec))
    for (i, w) in enumerate(wvec)
        buf[i] = @alassign_comb $bundlename[$(i-1)] = $w
    end
    
    return Wireexpr(bundlename), Vpatch(Alwayscontent(comb, Ifcontent(buf)))
end
function bitbundle(wvec)
    bitbundle(wvec, "")
end