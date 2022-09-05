"""
    removelinenumbernode(args::Vector{T}) where {T}

Remove `LineNumberNode` from `args`.
"""
function removelinenumbernode(args::Vector{T}) where {T}
    args[(x -> !(x isa LineNumberNode)).(args)]
end

"""
    oneparam(expr::Expr)

One parameter. 

# Syntax 
## `<paramname> = <val::Int>`

```jldoctest
julia> vshow(oneparam(:(x = 10)));
parameter x = 10
type: Oneparam
```
"""
function oneparam(expr::Expr)
    args = expr.args
    Oneparam(args[1], wireexpr(args[2]))
end

"""
    oneparam(expr::Ref{T}) where {T}

For macro call.
"""
function oneparam(expr::Ref{T}) where {T}
    oneparam(expr[])
end

"""
    oneparam(arg)

Macro call.
"""
macro oneparam(arg)
    Expr(:call, oneparam, Ref(arg))
end


"""
    parameters(expr::Expr)

Multiple parameters.

Using `convert` and `localparams` inside.

# Example 
```jldoctest
v = parameters(:(
    x = 10;
    y = 20;
    z = 30
))
vshow(v)

# output

#(
    parameter x = 10,
    parameter y = 20,
    parameter z = 30
)
type: Parameters
```
"""
function parameters(expr::Expr)
    convert(Parameters, localparams(expr))
end

"""
    parameters(expr::Ref{T}) where {T}

For macro call.
"""
function parameters(expr::Ref{T}) where {T}
    parameters(expr[])
end

"""
    parameters(arg)

Macro call.
"""
macro parameters(arg)
    Expr(:call, parameters, Ref(arg))
end


"""
    onelocalparam(expr::Expr)

One localparam object. The syntax is the same as `oneparam`.
# Example 
```jldoctest
julia> vshow(onelocalparam(:(x = 100)))
localparam x = 100;
type: Onelocalparam
```
"""
function onelocalparam(expr::Expr)
    args = expr.args
    Onelocalparam(args[1], wireexpr(args[2]))
end

"""
    onelocalparam(expr::Ref{T}) where {T}

For macro call.
"""
function onelocalparam(expr::Ref{T}) where {T}
    onelocalparam(expr[])
end

"""
    onelocalparam(arg)

Macro call.
"""
macro onelocalparam(arg)
    Expr(:call, onelocalparam, Ref(arg))
end


"""
    localparams(expr::Expr)

Multiple localparams.
# Examples
```jldoctest
julia> p = localparams(:(x = 10)); vshow(p);
localparam x = 10;
type: Localparams
```
```jldoctest
p = localparams(:(
    a = 111;
    b = 222;
    c = 333
))
vshow(p)

# output

localparam a = 111;
localparam b = 222;
localparam c = 333;
type: Localparams
```
"""
function localparams(expr::Expr)
    localparams(expr, Val(expr.head))
end

function localparams(expr::Expr, ::Val{:(=)})
    Localparams(onelocalparam(expr))
end

function localparams(expr::Expr, ::Val{:block})
    ansv = Onelocalparam[]

    for item in expr.args
        if item isa LineNumberNode 
        elseif item isa Oneparam || item isa Onelocalparam 
            push!(ansv, item)
        elseif item isa Parameters || item isa Localparams 
            push!(ansv, item.val...)
        else
            push!(ansv, onelocalparam(item))
        end
    end

    Localparams(ansv)
end

"""
    localparams(expr::Ref{T}) where {T}

For macro call.
"""
function localparams(expr::Ref{T}) where {T}
    localparams(expr[])
end

"""
    localparams(arg)

Macro version.
"""
macro localparams(arg)
    Expr(:call, localparams, Ref(arg))
end


"""
    oneblock(expr::T) where {T <: Union{Symbol, Int}}

Convert `expr` to `Wireexpr`. Needed in parsing `block`.
"""
function oneblock(expr::T) where {T <: Union{Symbol, Int}}
    return Wireexpr(expr)
end

"""
    oneblock(expr::UInt8)

UInt8 may be given when user writes e.g. 0b10, 0x1f.
Used when parsing `block`
"""
function oneblock(expr::UInt8)
    return Wireexpr(Int(expr))
end

"""
    oneblock(expr::Expr)

Parse AST in Julia grammar to one if-else statement or 
one assignment inside always blocks in Verilog, 
which are [Ifelseblock](@ref) and [Alassign](@ref), respectively. 

As using Julia expression and Julia parser as if 
it is of Verilog, there can be difference in grammatical matters 
between what can be given as the `expr` and real Verilog 
(e.g. operator precedence of `<=`).

# Syntax 
## `<wirename1> = <wireoperation>`
One blocking assignment. (Note that bit width cannot be 
specified yet, nor can it be printed.)
`<wireoperation>` is a expression accepted by [wireexpr](@ref).

## If-else statement
```
if <wireoperation>
    <oneassignment>
    <oneassignment>
    ...
elseif <wireoperation> 
    <oneassignment>
    <ifelsestatement>
    ...
else
    <ifelsestatement>
    ...
end
```
If-else statement written in 'Julia syntax', not in Verilog 
syntax, can be accepted. `else` block and `elseif` are not compulsory.
Since `if` `end` are at the top level no `;` inside if-else statement is needed.
Nested if-else statement can be also accepted as in usual Julia.

# Examples 
```jldoctest
julia> a1 = oneblock(:(w1 <= w2)); 

julia> vshow(a1);
w1 <= w2;
type: Alassign

julia> a2 = oneblock(:(w3 = w4 + ~w2)); vshow(a2);
w3 = (w4 + ~w2);
type: Alassign
```
```jldoctest
a3 = oneblock(:(
    if b1 == b2
        w5 = ~w6
        w7 = w8 
    elseif b2 
        w9 = w9 + w10
    else
        if b3 
            w11 = w12 
        end
    end
))
vshow(a3)

# output

if ((b1 == b2)) begin
    w5 = ~w6;
    w7 = w8;
end else if (b2) begin
    w9 = (w9 + w10);
end else begin
    if (b3) begin
        w11 = w12;
    end
end
type: Ifelseblock
```
"""
function oneblock(expr::Expr)
    return oneblock(expr, Val(expr.head))
end

"""
    oneblock(expr::T) where {T <: Union{Alassign, Ifelseblock}}

For insertion through metaprogramming.
# Example 
```jldoctest
a = @oneblock r = s & t
b = @oneblock (
    if b 
        x = y 
    else
        x = z
    end
)
c = always(:(
    p = q;
    \$(a);
    \$(b)
))
vshow(c)

# output

always_comb begin
    p = q;
    r = (s & t);
    if (b) begin
        x = y;
    end else begin
        x = z;
    end
end
type: Alwayscontent
```
"""
function oneblock(expr::T) where {T <: Union{Alassign, Ifelseblock}}
    expr 
end

function oneblock(expr::Case)
    expr 
end

"""
    oneblock(expr, ::Val{:(=)})

Assignment in Julia, stands for combinational assignment in Verilog.
"""
function oneblock(expr, ::Val{:(=)})
    @assert expr.head == :(=)
    return Alassign(wireexpr.(expr.args)..., comb)
end

"""
    oneblock(expr, ::Val{:call})

Dispatch methods of `oneblock` according to `expr.args[1]`.
"""
function oneblock(expr, ::Val{:call})
    return oneblock(expr, Val(expr.args[1]), Val(:call))
end

"""
    oneblock(expr, ::Val{:<=})

Parse `expr` whose head is `call` and `expr.args[1]` is `<=`.

Parse as a comparison opertor in Julia, interpret as 
sequential assignment in Verilog.
"""
function oneblock(expr, ::Val{:<=}, ::Val{:call})
    return Alassign(wireexpr(expr.args[2]), wireexpr(expr.args[3]), ff)
end

"Types to which AST of `block` can be converted."
const blockconvable = Union{Ifcontent, Ifelseblock, Wireexpr}
# abstract type blockconvable end

"""
    oneblock(expr, ::Val{:elseif}, ::Val{T}) where {T <: blockconvable}

When given `Val{T}` as the third argument, if `expr` is not `block` 
(= if the second argument is not `Val{:block}`), ignore `Val{T}`.

This is needed in `oneblock(expr, ::Val{:elseif})`, 
for `expr`, whose `expr.head == :elseif`, can have either 
`block` or `elseif` as its `expr.args[3]`.
Checks that the return value is of type `T`.
"""
function oneblock(expr, ::Val{:elseif}, ::Val{T}) where {T <: blockconvable}
    return oneblock(expr, Val(:elseif))::T
end

"""
    oneblock(expr, ::Val{:block}, ::Val{T}) where {T <: blockconvable}

Parse `expr` (which is `block`) into `T`. `block` appears at various nodes, thus need
to explicitly indicate which type the return value should be.
Types that is allowed as return value is in [`blockconvable`](@ref).

See also [`blockconv`](@ref).
"""
function oneblock(expr, ::Val{:block}, ::Val{T}) where {T <: blockconvable}
    # intended only for :block inside if/else
    @assert expr.head == :block 

    lineinfo = LineNumberNode(0, "noinfo")

    # only 3 types below may appear inside block
    assignlist = Alassign[]
    ifblocklist = Ifelseblock[]
    wirelist = Wireexpr[]

    try
        for item in expr.args 
            if item isa LineNumberNode
                lineinfo = item 
            else
                parsed = oneblock(item)
                # push!(anslist, parsed)
                
                if parsed isa Alassign
                    push!(assignlist, parsed)
                elseif parsed isa Ifelseblock 
                    push!(ifblocklist, parsed)
                elseif parsed isa Wireexpr 
                    push!(wirelist, parsed)
                else
                    @show parsed, typeof(parsed)
                    throw(error)
                end
            end
        end
    catch e 
        println("failed in parsing, inner block at: $(string(lineinfo))")
        # dump(lineinfo)
        rethrow()
    end

    # return Ifcontent(assignlist, ifblocklist)
    return blockconv(assignlist, ifblocklist, wirelist, Val(T))
end

"""
    oneblock(expr, ::Val{T}) where {T <: blockconvable}

Helper method to make it possible to dispatch `oneblock` without
giving `expr.head` as an argument.
"""
function oneblock(expr, ::Val{T}) where {T <: blockconvable}
    return oneblock(expr, Val(expr.head), Val(T))
end

function oneblock(expr, ::Val{:if})
    # ifelseblock
    @assert expr.head == :if 

    cond = expr.args[1]
    pcond = wireexpr(cond)::Wireexpr

    ifcont = oneblock(expr.args[2], Val(Ifcontent))

    if length(expr.args) == 2
        ans = Ifelseblock(pcond, ifcont)
    else
        celse = oneblock(expr.args[3], Val(Ifelseblock))
        ifadd!(celse, pcond, ifcont)
        ans = celse
    end

    return ans
end

"""
    blockconv(vas, vif, vwire, ::Val{Ifelseblock})

Convert lists of `Alassign`, `Ifelseblock`, and `Wireexpr` 
to a single `Ifelseblock` (whose `conds` is empty). `Wireexpr` is
supposed to be empty.
"""
function blockconv(vas, vif, vwire, ::Val{Ifelseblock})
    @assert length(vwire) == 0
    return Ifelseblock([], [Ifcontent(vas, vif)])
end

"""
    blockconv(vas, vif, vwire, ::Val{Ifcontent})

Convert lists of `Alassign`, `Ifelseblock`, and `Wireexpr` 
to a single `Ifcontent`. `Wireexpr` is supposed to be empty.
"""
function blockconv(vas, vif, vwire, ::Val{Ifcontent})
    @assert length(vwire) == 0
    return Ifcontent(vas, vif)
end

"""
    blockconv(vas, vif, vwire, ::Val{Wireexpr})

Convert input to a single Wireexpr. 

It is expected that both `vas::Vector{Alassign}` and `vif::Vector{Ifelseblock}`
are empty, and vwire is of length 1. Only applied to `block` at `elseif.args[1]` 
(condition of elseif-clause).
"""
function blockconv(vas, vif, vwire, ::Val{Wireexpr})
    @assert length(vas) == 0
    @assert length(vif) == 0
    @assert length(vwire) == 1
    return vwire[1]
end

"""
    oneblock(expr, ::Val{:elseif})

Parse `expr` into `Ifelseblock` where `expr` is elseif-clause.
"""
function oneblock(expr, ::Val{:elseif})
    @assert expr.head == :elseif 

    cond = expr.args[1]
    @assert cond.head == :block 

    # block appears in elseif -> cond
    pcond = wireexpr(cond.args[2])

    # block appears in elseif -> if-clause
    pelseif = oneblock(expr.args[2], Val(Ifcontent))

    if length(expr.args) == 3
        # block may appear in elseif -> else-clause
        # Note that elseif appears instead when more than 
        # two elseif clause occurs.
        fullblock = oneblock(expr.args[3], Val(Ifelseblock))
    else
        fullblock = Ifelseblock()
    end

    ifadd!(fullblock, pcond, pelseif)
    return fullblock
end

"""
    oneblock(arg)

Parse `arg` (which is AST) using macro. Uses reference 
to prevent `arg` being evaluated.
"""
macro oneblock(arg)
    return Expr(:call, oneblock, Ref(arg))
end

"""
    oneblock(expr::Ref{T}) where {T}

Dereference and parse `expr` given by user. Helper function 
for macro `@oneblock`.

See also [`@oneblock`](@ref).
"""
function oneblock(expr::Ref{T}) where {T}
    oneblock(expr[])
end


"""
    wireexpr(expr, ::Val{:ref})

Bit select or slice of wires, e.g. `x[1]` and `x[p:1]`.
"""
function wireexpr(expr, ::Val{:ref})
    body = wireexpr(expr.args[1])
    sl = wireexpr(expr.args[2])
    # length(sl) may be 1 or 2
    Wireexpr(slice, body, sl...)
end
function wireexpr(expr::T) where {T <: Union{Symbol, Int}}
    return Wireexpr(expr)
end
function wireexpr(expr::UInt8)
    return Wireexpr(Int(expr))
end
"""
    wireexpr(expr::Expr)

Parse one wire expression. Be sure to put 'two e's'
in wir'ee'xpr, not 'wirexpr'.

# Syntax 
Part of what can be done in Verilog can be accepted, 
such as `din[7:0]`, `(w1 + w2) << 5`
## `<wirename>`
One wire, without slicing or bit-selecting.

## `<val::Int>`, `<val::hex>`, `<val::bin>`
Literals, e.g. `5`, `0x1f`, `0b10`.

## `<wire> <op> <wire>`, `<op> <wire>`
Unary and binary operators. 
For reduction operators (unary `&, |, ^`), since these are 
not operators in Julia, write it in the form of function 
call explicitly, i.e. `&(wire)`, `|(wire)` instead of doing `^wire`.
Note that we use `^` as xor just as in Verilog, though this is not 
a xor operator in Julia.

## `<wire>[<wire>:<wire>]`, `<wire>[<wire>]`
Bit select and slicing as in Verilog/SystemVerilog.

# Examples 
```jldoctest
julia> w = wireexpr(:(w)); vshow(w);
w
type: Wireexpr

julia> w = wireexpr(:(w1 & &(w2) )); vshow(w);
(w1 & &(w2))
type: Wireexpr

julia> w = wireexpr(:(w[i:0])); vshow(w);
w[i:0]
type: Wireexpr
```
"""
function wireexpr(expr::Expr)
    return wireexpr(expr, Val(expr.head))
end

"""
    wireexpr(expr::Wireexpr)

Insertion through metaprogramming.
# Example 
```jldoctest
julia> w = @wireexpr x + y;

julia> e = :(a + |(\$(w) & z));

julia> ans = wireexpr(e); vshow(ans);
(a + |(((x + y) & z)))
type: Wireexpr
```
"""
function wireexpr(expr::Wireexpr)
    expr 
end

function wireexpr(expr, ::Val{:call})
    return wireexpr(expr, Val(expr.args[1]), Val(:call))
end

"""
    wireexpr(expr, ::Val{:(:)}, ::Val{:call})

Parse wire slice with range object, e.g. `x[a:b]`.
"""
function wireexpr(expr, ::Val{:(:)}, ::Val{:call})
    msb = expr.args[2]
    lsb = expr.args[3]
    (wireexpr(msb), wireexpr(lsb))
end

const wunasym2op = Dict([Val{item} => key for (key, item) in wunaopdict])
const wbinsym2op = Dict([Val{item} => key for (key, item) in wbinopdict])

const unaopvals = Union{[i for i in keys(wunasym2op)]...}
const binopvals = Union{[i for i in keys(wbinsym2op)]...}

"""
    wireexpr(expr, ::T, ::Val{:call}) where {T <: unaopvals}

Parse unary operators.
"""
function wireexpr(expr, ::T, ::Val{:call}) where {T <: unaopvals}
    uno = wireexpr(expr.args[2])
    return Wireexpr(wunasym2op[T], uno)
end

"""
    wireexpr(expr, ::T, ::Val{:call}) where {T <: binopvals}

Parse binary operators.
"""
function wireexpr(expr, ::T, ::Val{:call}) where {T <: binopvals}
    uno = wireexpr(expr.args[2])
    dos = wireexpr(expr.args[3])
    return Wireexpr(wbinsym2op[T], uno, dos)
end

"""
    wireexpr(expr, ::T, ::Val{:call}) where {T <: arityambigVals}

Disambiguate symbols in `arityambigVals` between 
unary and binary operators.
"""
function wireexpr(expr, ::T, ::Val{:call}) where {T <: arityambigVals}
    if length(expr.args) == 2
        return Wireexpr(wunasym2op[T], wireexpr(expr.args[2]))
    else
        @assert length(expr.args) == 3 || (@show length(expr.args); false)
        uno, dos = wireexpr(expr.args[2]), wireexpr(expr.args[3])
        return Wireexpr(wbinsym2op[T], uno, dos)
    end
end

"""
    wireexpr(expr::Expr, ::Val{:&})

Unary `&` parses differently from `|(wire)` and `^(wire)`.
What is `&(wire)` originally used for in Julia?
"""
function wireexpr(expr::Expr, ::Val{:&})
    @assert length(expr.args) == 1
    Wireexpr(redand, wireexpr(expr.args[1]))
end

function wireexpr(expr::Expr, ::Val{:||})
    Wireexpr(
        lor,
        wireexpr(expr.args[1]),
        wireexpr(expr.args[2])
    )
end

function wireexpr(expr::Expr, ::Val{:&&})
    Wireexpr(
        land,
        wireexpr(expr.args[1]),
        wireexpr(expr.args[2])
    )
end

macro wireexpr(arg)
    Expr(:call, wireexpr, Ref(arg))
end

function wireexpr(expr::Ref{T}) where {T}
    wireexpr(expr[])
end


"""
    ralways(expr::Expr)

Convert Julia AST to Verilog always-block. 

Does not infer type of alwaysblock here.
Dispatches methods here according to `expr.head`.
"""
function ralways(expr::Expr) 
    ralways(expr, Val(expr.head))::Alwayscontent
end

function ralways(expr::T...) where {T <: Union{Alassign, Ifelseblock, Case}}
    return Alwayscontent(expr...)
end

function ralways(expr::Alwayscontent)
    expr 
end

"""
    ralways(expr::Expr, ::T) where {T <: Val}

The case where `expr.head` is not `block`, which means
`expr` is one assign (inside always-block) or if-else block.
"""
function ralways(expr::Expr, ::T) where {T <: Val}
    return Alwayscontent(oneblock(expr, T()))
end

"""
    ralwayswithSensitivity(expr)

Parse always block with sensitivity list (e.g. @posedge clk).
"""
function ralwayswithSensitivity(expr)
    alblock = ralways(Expr(expr.head, expr.args[2:end]...))
    sensitivity = expr.args[1]
    @assert sensitivity.head == :macrocall
    # sensitivity.args == [:@posedge, linenumnode, arg]
    edge = eval(Meta.parse(string(sensitivity.args[1])[2:end]))
    sens = oneblock(sensitivity.args[3])

    # alblock.edge = edge 
    # alblock.sensitive = sens 
    ss = Sensitivity(edge, sens)
    alblock.sens = ss

    return alblock 
end

"""
    ralways(expr::Expr, ::Val{:block})

Convert multiple ifelse-blocks and assigns to one always-block.
"""
function ralways(expr::Expr, ::Val{:block})
    if length(expr.args) > 0 && expr.args[1] isa Expr && expr.args[1].head == :macrocall
        return ralwayswithSensitivity(expr)
    end

    assignlist = Alassign[]
    ifblocklist = Ifelseblock[]
    caselist = Case[]

    lineinfo = LineNumberNode(0, "noinfo")

    try 
        for item in expr.args 
            if item isa LineNumberNode 
                lineinfo = item 
            # for metaprogramming
            # ignores sensitivity list
            elseif item isa Case 
                push!(caselist, item)
            elseif item isa Alwayscontent
                push!(assignlist, item.content.assigns...)
                push!(ifblocklist, item.content.ifelseblocks...)
                push!(caselist, item.content.cases...)
            else
                parsed = oneblock(item)

                if parsed isa Alassign
                    push!(assignlist, parsed)
                elseif parsed isa Ifelseblock 
                    push!(ifblocklist, parsed)
                else
                    @show parsed, typeof(parsed)
                    throw(error)
                end 
            end
        end
    catch e
        println("failed in parsing always, inner block at: $(string(lineinfo))")
        rethrow()
    end

    return Alwayscontent(assignlist, ifblocklist, caselist)
end

"""
    ralways(arg)

`ralways` macro version. 
    
Not supposed to be used in most cases, 
`@always` and `always` are often better.
"""
macro ralways(arg)
    return Expr(:call, ralways, Ref(arg))
end

"""
    ralways(expr::Ref{T}) where {T}

For macro call.
"""
function ralways(expr::Ref{T}) where {T}
    ralways(expr[])
end


"""
    ifcontent(x::Expr)

Convert into `Ifcontent` what is convertible to `Alwayscontent`.

# Example
```jldoctest
x = @ifcontent (
    a = b;
    if b 
        x = c
    else
        x = d 
    end
)
vshow(x)

# output

a = b;
if (b) begin
    x = c;
end else begin
    x = d;
end
type: Ifcontent
```
"""
function ifcontent(x::Expr)
    al::Alwayscontent = ralways(x)
    # Ifcontent(al.assigns, al.ifelseblocks)
    al.content
end

"""
    ifcontent(x::Ref{T}) where {T}

For macro call.
"""
function ifcontent(x::Ref{T}) where {T}
    ifcontent(x[])
end

"""
    ifcontent(arg)

Macro call.
"""
macro ifcontent(arg)
    Expr(:call, ifcontent, Ref(arg))
end


"""
    portoneline(expr::Expr)

Parse Julia AST to one line of port declaration as [Oneport](@ref).

# Syntax 
## `@in <wirename>`, `@out <wirename>`
One port declaration of width 1.

## `@in/@out <wirename1, wirename2, ...> `
Multiple port declaration of width 1 in one line.

## `@in/@out <width::Int> <wirename1[, wirename2, ...]>`
Port declarations of width `<width>`.

## `@in/@out <wiretype> [<width::Int>] <wirename1[, wirename2, ...]>`
Port declaration with wiretypes [of width `<width>`].

# Examples
```jldoctest
julia> p1 = portoneline(:(@in din));

julia> vshow(p1);
input din
type: Oneport

julia> p2 = portoneline(:(@out din1, din2, din3)); vshow(p2);
output din1
type: Oneport
output din2
type: Oneport
output din3
type: Oneport

julia> p3 = portoneline(:(@in 8 din)); vshow(p3);
input [7:0] din
type: Oneport

julia> p4 = portoneline(:(@out reg 8 dout)); vshow(p4);
output reg [7:0] dout
type: Oneport
```
"""
function portoneline(expr::Expr)
    @assert expr.head == :macrocall
    args = expr.args

    direc = args[1] 
    if direc == Symbol("@in")
        d = pin 
    else
        @assert direc == Symbol("@out")
        d = pout 
    end
    # ignore LineNumberNode
    try
        portonelinecore(d, args[3:end]...)
    catch e
        println("Port parsing error at $(string(args[2])).")
        rethrow(e)
    end
end

"""
    portoneline(expr::Ref{T}) where {T}

For macro call.
"""
function portoneline(expr::Ref{T}) where {T}
    portoneline(expr[])
end

"""
    portoneline(arg)

Macro version of `portoneline`.
"""
macro portoneline(arg)
    Expr(:call, :portoneline, Ref(arg))
end

"""
    portonelinecore(d::Portdirec, arg1::Symbol, args...)

Helper function to determine behavior according to
`args` types and length.
"""
function portonelinecore(d::Portdirec, arg1::Symbol, args...)

    if length(args) == 0
        portnotype(d, arg1)
    else
        if arg1 in Symbol.(instances(Wiretype))
            if arg1 == :wire 
                wtype = wire 
            elseif arg1 == :reg 
                wtype = reg 
            else
                @assert arg1 == :logic
                wtype = logic 
            end
            porttyped(d, wtype, args...)
        else
            portnotype(d, arg1, args...)
        end
    end
end

"""
    portonelinecore(d::Portdirec, arg1::Int, arg2)

Wrapper for `portnotype`.
"""
function portonelinecore(d::Portdirec, arg1::Int, arg2)
    portnotype(d, arg1, arg2)
end

"""
    portonelinecore(d::Portdirec, arg1::Expr)

Wrapper for `portnotype`.
"""
function portonelinecore(d::Portdirec, arg1::Expr)
    @assert arg1.head == :tuple 
    portnotype(d, arg1)
end

"""
    portnotype(d::Portdirec, arg::Symbol)

Port declaration with no wire type, no wire width.
"""
function portnotype(d::Portdirec, arg::Symbol)
    [Oneport(d, string(arg))]
end

"""
    portnotype(d::Portdirec, arg::Expr)

Multiple port declarations with no wire type, no wire width.
"""
function portnotype(d::Portdirec, arg::Expr)
    @assert arg.head == :tuple 
    [Oneport(d, string(nm)) for nm in arg.args]
end

"""
    portnotype(d::Portdirec, arg1::Int, arg2::Symbol)

Wire width specified, no wire type given.
"""
function portnotype(d::Portdirec, arg1::Int, arg2::Symbol)
    [Oneport(d, arg1, string(arg2))]
end

"""
    portnotype(d::Portdirec, arg1::Int, arg2::Expr)

Wire width specified, no wire type given for multiple declarations.
"""
function portnotype(d::Portdirec, arg1::Int, arg2::Expr)
    @assert arg2.head == :tuple
    [Oneport(d, arg1, string(nm)) for nm in arg2.args]
end

"""
    porttyped(d::Portdirec, arg1::Wiretype, arg2::Symbol)

Wire type given, no wire width given.
"""
function porttyped(d::Portdirec, arg1::Wiretype, arg2::Symbol)
    [Oneport(d, arg1, 1, string(arg2))]
end

"""
    porttyped(d::Portdirec, arg1::Wiretype, arg2::Expr)

Wire type given, no wire width given for multiple declaration.
"""
function porttyped(d::Portdirec, arg1::Wiretype, arg2::Expr)
    @assert arg2.head == :tuple 
    [Oneport(d, arg1, 1, string(nm)) for nm in arg2.args]
end

"""
    porttyped(d::Portdirec, arg1::Wiretype, arg2::Int, arg3::Symbol)

Both wire type and width given.
"""
function porttyped(d::Portdirec, arg1::Wiretype, arg2::Int, arg3::Symbol)
    [Oneport(d, arg1, arg2, arg3)]
end

"""
    porttyped(d::Portdirec, arg1::Wiretype, arg2::Int, arg3::Expr)

Both wire type and width given for multiple declarations in one line.
"""
function porttyped(d::Portdirec, arg1::Wiretype, arg2::Int, arg3::Expr)
    @assert arg3.head == :tuple 
    [Oneport(d, arg1, arg2, string(nm)) for nm in arg3.args]
end

"""
    ports(expr::Expr)

Convert Julia AST into port declarations as [Ports](@ref) object.

# Syntax 
## `<portoneline>[;<portoneline>;...]`
Multiple lines of [`portoneline`](@ref) expressions 
separated by `;` can be accepted. 

# Example 
```jldoctest
pp = ports(:(
    @in p1;
    @in wire 8 p2, p3, p4;
    @out reg 2 p5, p6
))

vshow(pp)

# output

(
    input p1,
    input [7:0] p2,
    input [7:0] p3,
    input [7:0] p4,
    output reg [1:0] p5,
    output reg [1:0] p6
);

type: Ports
```
"""
function ports(expr::Expr)
    return ports(expr, Val(expr.head))
end

"""
    ports(expr::Vector{Oneport})

Insertion through metaprogramming.
# Example 
```jldoctest
a = @portoneline @in 8 d1, d2, d3
b = ports(:(
    @in d0;
    \$(a);
    @out reg 8 dout
))
vshow(b)

# output

(
    input d0,
    input [7:0] d1,
    input [7:0] d2,
    input [7:0] d3,
    output reg [7:0] dout
);

type: Ports
```
"""
function ports(expr::Vector{Oneport})
    Ports(expr)
end

"""
    ports(expr::Ports...)

Interpolation of one Vector{Ports}, nothing else given.
e.g. ports(:(\$([ports(:(@in 6 x)), ports(:(@in y))]...)))
"""
function ports(expr::Ports...)
    Ports(reduce(vcat, [e.val for e in expr]))
end

function ports(expr::Vector{Oneport}...)
    Ports(reduce(vcat, expr))
end

"""
    ports(expr::Expr, ::Val{:macrocall})

Contain only single line declaration.
"""
function ports(expr::Expr, ::Val{:macrocall})
    return Ports(portoneline(expr))
end

"""
    ports(expr::Expr, ::Val{:block})

Contain multiple lines of port declaration.
"""
function ports(expr::Expr, ::Val{:block})
    @assert expr.head == :block 
    anslist = Oneport[]

    lineinfo = LineNumberNode(0, "noinfo")
    for item in expr.args 
        if item isa LineNumberNode 
            lineinfo = item
        # for insertion through metaprogramming
        elseif item isa Vector{Oneport}
            push!(anslist, item...)
        elseif item isa Ports 
            push!(anslist, item.val...)
        else
            push!(anslist, portoneline(item)...)
        end
    end

    return Ports(anslist)
end

"""
    ports(expr::Ref{T}) where {T}

For macro call.
"""
function ports(expr::Ref{T}) where {T}
    return ports(expr[])
end

"""
    ports(arg)

Macro version of `ports`.
"""
macro ports(arg)
    return Expr(:call, :ports, Ref(arg))
end


"""
    decloneline(expr::Expr)

Parse Julia AST into wire declaration as Vector{[Onedecl](@ref)}.

The number of `Onedecl` objects returned may differ 
according to the number of wires declared in one line 
(e.g. `input dout` <=> `input din1, din2, din3`).

# Syntax 
Similar to that of [portoneline](@ref).
## `@wire/@reg/@logic [<width>] <wirename1>[, <wirename2>,...]`

# Examples 
```jldoctest
julia> d = decloneline(:(@reg 10 d1)); vshow(d);
reg [9:0] d1;
type: Onedecl

julia> d = decloneline(:(@logic 8 d1,d2,d3)); vshow(d);
logic [7:0] d1;
type: Onedecl
logic [7:0] d2;
type: Onedecl
logic [7:0] d3;
type: Onedecl

julia> d = decloneline(:(@wire A >> 2 w1, w2)); vshow(d);
wire [(A >> 2)-1:0] w1;
type: Onedecl
wire [(A >> 2)-1:0] w2;
type: Onedecl
```
"""
function decloneline(expr::Expr)
    @assert expr.head == :macrocall
    args = expr.args
    # targs = args[(x -> !(x isa LineNumberNode)).(args)]
    targs = removelinenumbernode(args)
    
    wt = wtypesym(targs[1])

    if length(targs) == 2
        decloneline_inner(wt, Wireexpr(1), targs[2])
    else 
        length(targs) == 3 || error("$(length(targs)) arguments for 'decloneline'.")
        decloneline_inner(wt, wireexpr(targs[2]), targs[3])
    end
end

"""
    wtypesym(wt::Symbol)

Given either of symbols `@wire, @reg, @logic`, return 
`wire, reg, logic (::Wiretype)`, respectively.
"""
function wtypesym(wt::Symbol)
    if wt == Symbol("@wire")
        wire 
    elseif wt == Symbol("@reg")
        reg 
    else
        wt == Symbol("@logic") || error(wt, " is not allowed as a wire type.")
        logic 
    end
end

"""
    decloneline_inner(wt, wid::Wireexpr, var::Symbol)

Declaration of a single wire (e.g. `wire [1:0] d1`, `reg clk`).
"""
function decloneline_inner(wt, wid::Wireexpr, var::Symbol)
    [Onedecl(wt, wid, string(var))]
end

"""
    decloneline_inner(wt, wid::Wireexpr, vars::Expr)

Declaration of multiple wires (e.g. `logic x, y, z`).
"""
function decloneline_inner(wt, wid::Wireexpr, vars::Expr)
    vars.head == :tuple || error("vars.head should be tuple, got $(vars.head).")
    [Onedecl(wt, wid, string(v)) for v in vars.args]
end

"""
    decloneline(arg)

Macro version of `decloneline`.
"""
macro decloneline(arg)
    Expr(:call, :decloneline, Ref(arg))
end

"""
    decloneline(expr::Ref{T}) where {T}

For macro call.
"""
function decloneline(expr::Ref{T}) where {T}
    decloneline(expr[])
end


"""
    decls(expr::Expr)

Parse Julia AST into wire declaration section object [Decls](@ref).

# Syntax 
## `<onedecl>[;<onedecl>;...]`
Multiple [decloneline](@ref) expressions which are concatenated 
by `;` can be accepted.

# Example 
```jldoctest
d = decls(:(
    @wire w1;
    @reg 8 w2,w3,w4;
    @logic 32 w5
))
vshow(d)

# output

wire w1;
reg [7:0] w2;
reg [7:0] w3;
reg [7:0] w4;
logic [31:0] w5;
type: Decls
```
"""
function decls(expr::Expr)
    return decls(expr, Val(expr.head))
end

"""
    decls(expr::Vector{Onedecl}...)

For interpolation of a single vector.
"""
function decls(expr::Vector{Onedecl}...)
    Decls(reduce(vcat, expr))
end

"""
    decls(expr::Decls...)

For interpolation of `Decls` objects.
"""
function decls(expr::Decls...)
    Decls(reduce(vcat, (i.val for i in expr)))
end

"""
    decls(expr::Vector{Onedecl})

For insertion with metaprogramming.
# Example
```jldoctest
a = @decloneline @reg 8 x1, x2
b = decls(:(
    \$(a);
    @wire y1, y2
))
vshow(b)

# output

reg [7:0] x1;
reg [7:0] x2;
wire y1;
wire y2;
type: Decls
```
"""
function decls(expr::Vector{Onedecl})
    Decls(expr)
end

"""
    decls(expr::Expr, ::Val{:macrocall})

Parse single line of declaration.
"""
function decls(expr::Expr, ::Val{:macrocall})
    return Decls(decloneline(expr))
end

"""
    decls(expr::Expr, ::Val{:block})

Multiple lines of wire declarations.
"""
function decls(expr::Expr, ::Val{:block})
    @assert expr.head == :block 
    anslist = Onedecl[]

    lineinfo = LineNumberNode(0, "noinfo")
    for item in expr.args 
        if item isa LineNumberNode 
            lineinfo = item
        # for insertion with metaprogramming
        elseif item isa Vector{Onedecl}
            push!(anslist, item...)
        elseif item isa Decls 
            push!(anslist, item.val...)
        else
            push!(anslist, decloneline(item)...)
        end
    end

    return Decls(anslist)
end

"""
    decls(expr::Ref{T}) where {T}

For macro calls.
"""
function decls(expr::Ref{T}) where {T}
    return decls(expr[])
end

"""
    decls(arg)

Macro version of `decls`.
"""
macro decls(arg)
    return Expr(:call, :decls, Ref(arg))
end