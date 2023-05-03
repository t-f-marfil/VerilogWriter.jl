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
            @assert wexpr.subnodes[1].operation == id
            push!(ans, wexpr.subnodes[1])
        elseif wexpr.operation == ipselm
            wexpr.subnodes[1].operation == id || error("$(string(wexpr.subnodes[1].operation)) for indexed part select.")
            push!(ans, wexpr.subnodes[1])
        end
    end
    vans = collect(ans)
    sort!(vans, by=(x -> x.name))
    vans
end

"Default value of clocking signal."
const defclk = Wireexpr("CLK")
"Default value of resetting signal."
const defrst = Wireexpr("RST")

# Detection of Lhs depends on [`lhsextract`](@ref) and [`lhsunify`](@ref).
"""
    autoreset(x::Ifcontent; clk=defclk, rst=defrst, edge=posedge, reg2d::Dict{String, Wireexpr}=Dict{String, Wireexpr}())

Given `x::Ifcontent`, returns `always_ff/always` block that 
resets every `wire/reg`s appear at Lhs of `x`.

This is synchronous reset.
`reg2d` is a pair of "name of wire" and "ram depth in wireexpr".
"""
function autoreset(x::Ifcontent; clk=defclk, rst=defrst, edge=posedge, reg2d::Dict{String, Wireexpr}=Dict{String, Wireexpr}())
    if isreset(x, rst=rst)
        ans = Alwayscontent(ff, edge, clk, x)
    else
        ext = lhsextract(x)
        uniext = lhsunify(ext)

        prerstcont = Alassign[]
        # reg2d is a pair of "name of wire" and "ram depth in wireexpr"
        for i in uniext 
            if i.name in keys(reg2d)
                regdepth = reg2d[i.name]
                regdepth.operation == literal || error("$(string(regdepth)) is currently not acceptable as reg depth.")

                depthnum = regdepth.value
                push!(prerstcont, reduce(
                    vcat,
                    [alassign_ff(:($(Symbol(i.name))[$(ind-1)] <= 0)) for ind in 1:depthnum]
                )...)
            else
                push!(prerstcont, Alassign(i, Wireexpr(0), ff))
            end
        end
        rstcont = Ifcontent(prerstcont)
        # rstcont = Ifcontent([Alassign(i, Wireexpr(0), ff) for i in uniext])

        ifb = Ifelseblock([rst], [rstcont, x])
        ans = Alwayscontent(ff, edge, clk, Ifcontent(ifb))
    end

    (atp = atypealways(ans); atp == ff) || error("atype == $(atp).")
        
    ans 
end


"""
    autoreset(x::Alwayscontent; clk=defclk, rst=defrst, edge=posedge, reg2d::Dict{String, Wireexpr}=Dict{String, Wireexpr}())

Automatically reset wires which appear in `x::Alwayscontent`.

Sensitivity list in the original `Alwayscontent` will be ignored.


# Example 
```jldoctest
c = @always (
    r1 <= r2;
    if b1 
        r2 <= 0
        r3 <= r3 + r4
    else 
        r3 <= 0
    end
) 
r = autoreset(c; clk=(@wireexpr clk), rst=(@wireexpr ~resetn))
vshow(r)

# output

always_ff @( posedge clk ) begin
    if (~resetn) begin
        r1 <= 0;
        r2 <= 0;
        r3 <= 0;
    end else begin
        r1 <= r2;
        if (b1) begin
            r2 <= 0;
            r3 <= (r3 + r4);
        end else begin
            r3 <= 0;
        end
    end
end
type: Alwayscontent
```
"""
function autoreset(x::Alwayscontent; clk=defclk, rst=defrst, edge=posedge, reg2d::Dict{String, Wireexpr}=Dict{String, Wireexpr}())
    if x.atype == comb 
        x
    else
        autoreset(x.content, clk=clk, rst=rst, edge=edge, reg2d=reg2d)
    end
end

"""
    autoreset(x::Vmodule; clk=defclk, rst=defrst, reg2d::Dict{String, Wireexpr}=Dict{String, Wireexpr}())

Return a new `Vmodule` object whose `Alwayscontent`s are all reset.
"""
function autoreset(x::Vmodule; clk=defclk, rst=defrst, reg2d::Dict{String, Wireexpr}=Dict{String, Wireexpr}())
    Vmodule(
        x.name, 

        x.params,
        x.ports, 
        x.lparams, 
        x.decls,

        x.insts,
        x.assigns,
        autoreset.(x.always, clk=clk, rst=rst, reg2d=reg2d)
    )
end

"""
    autoreset!(x::Alwayscontent; clk=defclk, rst=defrst, reg2d::Dict{String, Wireexpr}=Dict{String, Wireexpr}())

Update `x` itself with synchronous reset statements.
"""
function autoreset!(x::Alwayscontent; clk=defclk, rst=defrst, reg2d::Dict{String, Wireexpr}=Dict{String, Wireexpr}())
    r = autoreset(x, clk=clk, rst=rst, reg2d=reg2d)

    x.atype = r.atype
    x.sens = r.sens 
    x.content = r.content
    return nothing 
end

function autoreset!(x::Vmodule; clk=defclk, rst=defrst, reg2d::Dict{String, Wireexpr}=Dict{String, Wireexpr}())
    autoreset!.(x.always, clk=clk, rst=rst, reg2d=reg2d)
    return nothing
end

"""
    isreset(x::Alwayscontent; rst=defrst)

Check if `x` contains synchronous reset statements.
"""
function isreset(x::Alwayscontent; rst=defrst)
    ifc = x.content
    isreset(ifc, rst=rst)
end

"""
    isreset(x::Ifcontent; rst=defrst)

Check if `x` contains synchronous reset statements.
"""
function isreset(x::Ifcontent; rst=defrst)
    ifcontformat = (
        length(x.assigns) == 0 
        && length(x.ifelseblocks) == 1
        && length(x.cases) == 0
    )
    if ifcontformat
        ifb = x.ifelseblocks[1]
        ifblockformat = (
            length(ifb.conds) == 1
        )
        if ifblockformat
            rstw = ifb.conds[1]
            rstcheck = isequal(rstw, rst)

            return rstcheck
        end
    end

    return false
end