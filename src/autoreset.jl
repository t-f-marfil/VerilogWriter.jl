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
    autoreset(x::Ifcontent; clk=Wireexpr("CLK"), rst=Wireexpr("RST"), edge=posedge)

Given `x::Ifcontent`, returns `always_ff/always` block that 
resets every `wire/reg`s appear at Lhs of `x`.

# Example 
```jldoctest
c = @ifcontent (
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
function autoreset(x::Ifcontent; clk=defclk, rst=defrst, edge=posedge)
    ext = lhsextract(x)
    uniext = lhsunify(ext)

    rstcont = Ifcontent([Alassign(i, Wireexpr(0), ff) for i in uniext])

    ifb = Ifelseblock([rst], [rstcont, x])
    ans = Alwayscontent(ff, edge, clk, Ifcontent(ifb))
    (atp = atypealways(ans); atp == ff) || error("atype == $(atp).")
    
    ans 
end

"""
    autoreset(x::Alwayscontent; clk=defclk, rst=defrst, edge=posedge)

Automatically reset wires which appear in `x::Alwayscontent`.

Sensitivity list in the original `Alwayscontent` will be ignored.
"""
function autoreset(x::Alwayscontent; clk=defclk, rst=defrst, edge=posedge)
    if x.atype == comb 
        x 
    else
        autoreset(x.content, clk=clk, rst=rst, edge=edge)
    end
end