# miscellaneous functions

"""
ifadd!(ifblock::Ifelseblock, cond, ifcont)

Add `cond` and `ifcont` at the head of `ifblock`.

Intended to add if-clause to `Ifelseblock` constructed
from elseif-clause (because elseif-clause often parses first).
"""
function ifadd!(ifblock::Ifelseblock, cond, ifcont)
    pushfirst!(ifblock.conds, cond)
    pushfirst!(ifblock.contents, ifcont)
end

"""
    addatype!(x::Alwayscontent)

Infer type of always block (combinational or sequential) and
add the information to `x`.
"""
function addatype!(x::Alwayscontent)
    x.atype = atypealways(x)
    return x 
end

"""
    always(expr::Expr)

Parse AST into always block as [Alwayscontent](@ref) using `ralways`.

Also infers type of always using `addatype!`.

# Syntax 
## `<oneblock>;<oneblock>[;<oneblock>;...]`
`<oneblock>` is the expression that can be parsed by [oneblock](@ref).
`;` in between `<oneblock>`s are strictly needed.

## `@posedge <wirename>; <ifelsestatements>/<assignments>`
Set sensitivity list using macro syntax. `@negedge` is also possible. 
You must put `@posegde/@negedge` statement at the beginning, and only once.

# Examples

```jldoctest
a1 = always(:(
    w1 = w2;
    if b2 
        w1 = w3 
    end
))
vshow(a1)

# output

always_comb begin
    w1 = w2;
    if (b2) begin
        w1 = w3;
    end
end
type: Alwayscontent
```

```jldoctest
a1 = always(:(
    @posedge clk;
    
    if b1 == b2
        w1 <= w2 + w3 
    else
        w1 <= ~w1 
    end
))
vshow(a1)

# output

always_ff @( posedge clk ) begin
    if ((b1 == b2)) begin
        w1 <= (w2 + w3);
    end else begin
        w1 <= ~w1;
    end
end
type: Alwayscontent
```
"""
function always(expr::Expr)
    alcont = ralways(expr)
    return addatype!(alcont)
end

function always(expr...)
    alcont = ralways(expr...)
    return addatype!(alcont)
end

macro always(arg)
    return Expr(:call, always, Ref(arg))
end

function always(expr::Ref{T}) where {T}
    always(expr[])
end

"""
    invport(onep::Oneport)

Return [Oneport](@ref) object whose directions are reversed
from `onep`. Wiretype information (`reg`, `wire`, `logic`) is 
lost when inverted for `reg` cannot be at input port.
"""
function invport(onep::Oneport)
    # d = onep.decl
    Oneport(
        (onep.direc == pin ? pout : pin),
        onep.width,
        onep.name
    )
end

"""
    invports(ps::Ports)

Return [Ports](@ref) object whose directions are reversed
from `ps`.

# Examples 
```jldoctest
pts = @ports (
    @in 8 bus1, bus2;
    @out @reg bus3
)
ipts = invports(pts)
vshow(pts)
vshow(ipts)

# output

(
    input [7:0] bus1,
    input [7:0] bus2,
    output reg bus3
);
type: Ports
(
    output [7:0] bus1,
    output [7:0] bus2,
    input bus3
);
type: Ports
```
"""
function invports(ps::Ports)
    ans = Oneport[]
    for onep in ps.val 
        push!(ans, invport(onep))
    end
    Ports(ans)
end

"""
    declmergegen()

Declare `declmerge` for multiple types.
"""
function declmergegen()
    for T in (Parameters, Decls, Localparams, Ports)
        q = quote
            """
                declmerge(d::$($(T))...)

            Merge multiple `$($(T))` objects into one `$($(T))`.
            """
            function declmerge(d::$(T)...)
                $(T)(reduce(vcat, (i.val for i in d)))
            end
        end
        eval(q)
    end
end
declmergegen()

"""
    @sym2wire(arg::Symbol)

Declare new `Wireexpr` of name `arg`.
"""
macro sym2wire(arg::Symbol)
    quote 
        $(esc(arg)) = $(Wireexpr(string(arg)))
    end
end

"""
    @sym2wire(arg::Expr)

Declare new `Wireexpr`s of name `arg...`, respectively.

# Example
```jldoctest
julia> @sym2wire x, y, z;

julia> vshow(y);
y
type: Wireexpr
```
"""
macro sym2wire(arg::Expr)
    arg.head == :tuple || error("$(arg.head) is not allowed for @sym2wire.")
    
    lhss = [:($(esc(i))) for i in arg.args]
    rhss = [:($(Wireexpr(string(i)))) for i in arg.args]
    
    quote 
        $(reduce(qmerge, lhss)) = $(reduce(qmerge, rhss))
    end
end

"""
    qmerge(q1::Expr, q2)

Helper function for `@sym2wire`.
"""
function qmerge(q1::Expr, q2)
    if q1.head == :tuple
        Expr(:tuple, q1.args..., q2)
    else 
        Expr(:tuple, q1, q2)
    end
end

"""
    qmerge(q1, q2)

Helper function for `@sym2wire`.
"""
function qmerge(q1, q2) 
    Expr(:tuple, q1, q2)
end


"""
    alloutwtype(p::Ports, w::Wiretype)

Return a new `Ports` object all of whose output ports are `w`.
"""
function alloutwtype(p::Ports, w::Wiretype)
    Ports([
        (
            x.direc == pout ? 
            Oneport(pout, w, x.width, x.name) : 
            x
        ) for x in p.val
    ])
end

function alloutwire(p::Ports)
    alloutwtype(p, wire)
end

"""
    alloutreg(p::Ports)

Return a new `Ports` object all of whose output ports are of `reg`.
"""
function alloutreg(p::Ports)
    alloutwtype(p, reg)
end


"""
    naiveinst(vmod::Vmodule, iname::String)

Generate from `vmod` an `Vmodinst` object all ports of which are assigned a wire
whose name is the same as each port.
"""
function naiveinst(vmod::Vmodule, iname::String)
    Vmodinst(
        vmod.name,
        iname,
        [(s = prm.name; s => Wireexpr(s)) for prm in vmod.params.val],
        [(s = prt.name; s => Wireexpr(s)) for prt in vmod.ports.val]
    )
end

"""
    naiveinst(vmod::Vmodule)

Naive instantiation of `vmod` with default instance name.
"""
function naiveinst(vmod::Vmodule)
    iname = string("u", vmod.name)
    naiveinst(vmod, iname)
end


"""
    wrappergen(n, x::Vmodule)

Generate wrapper module named `n` for `x`.

It may sometimes be needed for in a certain CAD software
a block design does not accept system verilog, 
thus verilog wrapper is required.
"""
function wrappergen(n, x::Vmodule)
    Vmodule(
        n,
        Vmodenv(x.params, alloutwire(x.ports), Localparams(), Decls()),
        [naiveinst(x)],
        Alwayscontent[]
    )
    
end

"""
    @preport(pre::Symbol, pnames)

Helper macro for port assignment declaration in module instantiation.

For each <port name> in `pnames`, assign wire whose name is `pre * <port name>` (add prefix).

# Examples

## Unit Examples
```jldoctest
julia> p = @preport sub_ a,b
2-element Vector{Pair{String, Wireexpr}}:
 "a" => Wireexpr(id, "sub_a", Wireexpr[], -1, -1)
 "b" => Wireexpr(id, "sub_b", Wireexpr[], -1, -1)

julia> (x ->((a, b) = x; println(a, " => ", string(b)))).(p);
a => sub_a
b => sub_b
```

## In `Vmodinst`
```jldoctest
julia> v = Vmodinst("mod", "umod", (@preport p_ a,b,c), true); vshow(v);
mod umod (
    .a(p_a),
    .b(p_b),
    .c(p_c),
    .*
);
type: Vmodinst
```
"""
macro preport(pre::Symbol, pnames)
    ptup = pnames isa Symbol ? [pnames] : pnames.args
    plen = length(ptup)

    pvec = Vector{Expr}(undef, plen)
    
    for i in 1:plen
        pvec[i] = :(
            $(string(ptup[i])) 
            => $(Wireexpr(string(pre, ptup[i])))
        )
    end

    Expr(:vect, pvec...)
end

"""
    @preport(pnames)

Add no prefix at the head of each port name in `pnames`.
"""
macro preport(pnames)
    Expr(
        :macrocall, 
        Symbol("@preport"), 
        LineNumberNode(0, nothing),
        Symbol(), 
        pnames
    )
end

"""
    finalized(x::Vmodule)

Return new `Vmodule` object generated by applying 
`autoreset` and `autodecl` on `x`.
"""
function finalized(x::Vmodule)
    m = autoreset(x)
    autodecl(m)
end

"""
    vexport(x::Vmodule, fpath=""; systemverilog=true, mode="w")

Export `x` to a verilog/systemverilog file.
"""
function vexport(x::Vmodule, fpath=""; systemverilog=true, mode="w")
    vexport([x], fpath, systemverilog=systemverilog, mode=mode)
end

"""
    vexport(x::Vector{Vmodule}, fpath=""; systemverilog=true, mode="w")

Export `x` to a verilog/systemverilog file.
"""
function vexport(x::Vector{Vmodule}, fpath=""; systemverilog=true, mode="w")
    length(x) > 0 || error("empty vector given.")
    if fpath == ""
        fpath = string(x[1].name, systemverilog ? ".sv" : ".v")
    end

    open(fpath, mode) do io 
        for m in x
            write(io, string(m, systemverilog), "\n")
        end
    end
end