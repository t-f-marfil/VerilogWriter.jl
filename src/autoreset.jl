"""
    lhsextract(x::Ifcontent)

Extract all `Wireexpr`s on Lhs. May contain
more than one identical `Wireexpr`s.
"""
function lhsextract(x::Ifcontent)
    ans = Wireexpr[]
    map(x -> lhsextractcore!(ans, x), (x.assigns, x.ifelseblocks, x.cases))
    ans 
end

"""
    lhsextractcore!(ans, v)

A helper function for [`lhsextract`](@ref).
"""
function lhsextractcore!(ans, v)
    for item in lhsextract.(v)
        push!(ans, item...)
    end
end

"""
    lhsextract(x::Alassign)
"""
function lhsextract(x::Alassign)
    [x.lhs]
end

"""
    lhsextract(x::Ifelseblock)
"""
function lhsextract(x::Ifelseblock)
    ans = Wireexpr[]
    for item in lhsextract.(x.contents)
        push!(ans, item...)
    end

    ans 
end

"""
    lhsextract(x::Case)
"""
function lhsextract(x::Case)
    ans = Wireexpr[]
    for item in lhsextract.([i[2] for i in x.conds])
        push!(ans, item...)
    end
    ans 
end


"""
    lhsunify(wvec::Vector{Wireexpr})

Remove identical wires contained in `wvec` more than once.
"""
function lhsunify(wvec::Vector{Wireexpr})
    ans = Set{Wireexpr}()
    for wexpr in wvec
        # pick up Lhs
        if wexpr.operation == id 
            push!(ans, wexpr)
        elseif wexpr.operation == slice 
            push!(ans, wexpr.subnodes[1])
        end
    end
    vans = collect(ans)
    sort!(vans, by=(x -> x.name))
    vans
end


"""
    autoreset(x::Ifcontent; clk=Wireexpr("CLK"), rst=Wireexpr("RST"), edge=posedge)

Given `x::Ifcontent`, returns `always_ff/always` block that 
resets every `wire/reg`s appear at Lhs of `x`.

Detection of Lhs depends on [`lhsextract`](@ref) and [`lhsunify`](@ref).
"""
function autoreset(x::Ifcontent; clk=Wireexpr("CLK"), rst=Wireexpr("RST"), edge=posedge)
    ext = lhsextract(x)
    uniext = lhsunify(ext)

    rstcont = Ifcontent([Alassign(i, Wireexpr(0), ff) for i in uniext])

    ifb = Ifelseblock([rst], [rstcont, x])
    ans = Alwayscontent(ff, edge, clk, Ifcontent(ifb))
    ans 
end