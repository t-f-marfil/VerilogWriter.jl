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
    @out reg bus3
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