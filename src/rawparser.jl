"""
    roneblock(expr::T) where {T <: Union{Symbol, Int}}

Convert `expr` to `Wireexpr`.
"""
function roneblock(expr::T) where {T <: Union{Symbol, Int}}
    return Wireexpr(expr)
end

"""
    roneblock(expr::UInt8)

UInt8 may be given when user writes e.g. 0b10, 0x1f.
"""
function roneblock(expr::UInt8)
    return Wireexpr(Int(expr))
end

# """
#     roneblock(expr::Int)

# Convert `expr` to `Wireexpr`.
# """
# function roneblock(expr::Int)
#     return Wireexpr(string(expr))
# end

"""
    roneblock(expr::Expr)

Parse AST in Julia grammar to one if-else statement or 
one assignment inside always blocks in Verilog, 
which are [Ifelseblock](@ref) and [Alassign](@ref), respectively. 

As using Julia expression and Julia parser as if 
it is of Verilog, there can be difference in grammatical matters 
between what can be given as the `expr` and real Verilog 
(e.g. operator precedence of `<=`).

# Syntax 
## `<wirename1> = <wirename2>`, `<wirename1> = <value::Int>`
One blocking assignment. (Note that bit width cannot be 
specified yet, nor can it be printed.)

## `<wirename1> <= <wirename2>/<value::Int>`
One non blocking assignment.

## `<wirename1> <=/= <wireoperation>`
`<wireoperation>` at the rhs is `~<wirename>`, `<wirename> + <wirename>`, and 
so one, which are the operation of wires. (Note that not 
all operators in Verilog are supported, in fact, really few of them are supported now.)

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
julia> a1 = roneblock(:(w1 <= w2)); 

julia> vshow(a1);
w1 <= w2;
type: Alassign

julia> a2 = roneblock(:(w3 = w4 + ~w2)); vshow(a2);
w3 = (w4 + ~w2);
type: Alassign
```
```jldoctest
a3 = roneblock(:(
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
function roneblock(expr::Expr)
    return roneblock(expr, Val(expr.head))
end

"""
    roneblock(expr, ::Val{:(=)})

Assignment in Julia, stands for combinational assignment in Verilog.
"""
function roneblock(expr, ::Val{:(=)})
    @assert expr.head == :(=)
    return Alassign(roneblock.(expr.args)..., comb)
end

"""
    roneblock(expr, ::Val{:call})

Dispatch methods of `roneblock` according to `expr.args[1]`.
"""
function roneblock(expr, ::Val{:call})
    return roneblock(expr, Val(expr.args[1]))
end

"""
    roneblock(expr, ::Val{:<=})

Parse `expr` whose head is `call` and `expr.args[1]` is `<=`.

Parse as a comparison opertor in Julia, interpret as 
sequential assignment in Verilog.
"""
function roneblock(expr, ::Val{:<=})
    return Alassign(roneblock(expr.args[2]), roneblock(expr.args[3]), ff)
end

"Types to which AST of `block` can be converted."
const blockconvable = Union{Ifcontent, Ifelseblock, Wireexpr}
# abstract type blockconvable end

"""
    roneblock(expr, ::Val{:elseif}, ::Val{T}) where {T <: blockconvable}

When given `Val{T}` as the third argument, if `expr` is not `block` 
(= if the second argument is not `Val{:block}`), ignore `Val{T}`.

This is needed in `roneblock(expr, ::Val{:elseif})`, 
for `expr`, whose `expr.head == :elseif`, can have either 
`block` or `elseif` as its `expr.args[3]`.
Checks that the return value is of type `T`.
"""
function roneblock(expr, ::Val{:elseif}, ::Val{T}) where {T <: blockconvable}
    return roneblock(expr, Val(:elseif))::T
end

"""
    roneblock(expr, ::Val{:block}, ::Val{T}) where {T <: blockconvable}

Parse `expr` (which is `block`) into `T`. `block` appears at various nodes, thus need
to explicitly indicate which type the return value should be.
Types that is allowed as return value is in [`blockconvable`](@ref).

See also [`blockconv`](@ref).
"""
function roneblock(expr, ::Val{:block}, ::Val{T}) where {T <: blockconvable}
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
                parsed = roneblock(item)
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
    roneblock(expr, ::Val{T}) where {T <: blockconvable}

Helper method to make it possible to dispatch `roneblock` without
giving `expr.head` as an argument.
"""
function roneblock(expr, ::Val{T}) where {T <: blockconvable}
    return roneblock(expr, Val(expr.head), Val(T))
end

function roneblock(expr, ::Val{:if})
    # ifelseblock
    @assert expr.head == :if 

    cond = expr.args[1]
    pcond = roneblock(cond)::Wireexpr

    ifcont = roneblock(expr.args[2], Val(Ifcontent))

    if length(expr.args) == 2
        ans = Ifelseblock(pcond, ifcont)
    else
        celse = roneblock(expr.args[3], Val(Ifelseblock))
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
    roneblock(expr, ::Val{:elseif})

Parse `expr` into `Ifelseblock` where `expr` is elseif-clause.
"""
function roneblock(expr, ::Val{:elseif})
    @assert expr.head == :elseif 

    cond = expr.args[1]
    @assert cond.head == :block 

    # block appears in elseif -> cond
    pcond = roneblock(cond, Val(Wireexpr))

    # block appears in elseif -> if-clause
    pelseif = roneblock(expr.args[2], Val(Ifcontent))

    if length(expr.args) == 3
        # block may appear in elseif -> else-clause
        # Note that elseif appears instead when more than 
        # two elseif clause occurs.
        fullblock = roneblock(expr.args[3], Val(Ifelseblock))
    else
        fullblock = Ifelseblock()
    end

    ifadd!(fullblock, pcond, pelseif)
    return fullblock
end

const wunasym2op = Dict([Val{item} => key for (key, item) in wunaopdict])
const wbinsym2op = Dict([Val{item} => key for (key, item) in wbinopdict])

const unaopvals = Union{[i for i in keys(wunasym2op)]...}
const binopvals = Union{[i for i in keys(wbinsym2op)]...}

function roneblock(expr, ::T) where {T <: unaopvals}
    uno = roneblock(expr.args[2])
    return Wireexpr(wunasym2op[T], uno)
end

function roneblock(expr, ::T) where {T <: binopvals}
    uno = roneblock(expr.args[2])
    dos = roneblock(expr.args[3])
    return Wireexpr(wbinsym2op[T], uno, dos)
end

"""
    roneblock(expr, ::Val{:-})

Disambiguate `Val{:-}` between unary and binary minuses.
"""
function roneblock(expr, ::Val{:-})
    if length(expr.args) == 2
        return Wireexpr(uminus, roneblock(expr.args[2]))
    else
        @assert length(expr.args) == 3
        uno, dos = roneblock(expr.args[2]), roneblock(expr.args[3])
        return Wireexpr(minus, uno, dos)
    end
end

"""
    @roneblock arg

Parse `arg` (which is AST) using macro. Uses reference 
to prevent `arg` being evaluated.
"""
macro roneblock(arg)
    return Expr(:call, roneblock, Ref(arg))
end

"""
    roneblock(expr::Ref{T}) where {T}

Dereference and parse `expr` given by user. Helper function 
for macro `@roneblock`.

See also [`@roneblock`](@ref).
"""
function roneblock(expr::Ref{T}) where {T}
    roneblock(expr[])
end


"""
    ralways(expr::Expr)

Convert Julia AST to Verilog always-block. 

Does not infer type of alwaysblock here.
Dispatches methods here according to `expr.head`.
"""
function ralways(expr::Expr) 
    return ralways(expr, Val(expr.head))
end

"""
    ralways(expr, ::T) where {T <: Val}

The case where `expr.head` is not `block`, which means
`expr` is one assign (inside always-block) or if-else block.
"""
function ralways(expr, ::T) where {T <: Val}
    return Alwayscontent(roneblock(expr, T()))
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
    sens = roneblock(sensitivity.args[3])

    alblock.edge = edge 
    alblock.sensitive = sens 
    return alblock 
end

"""
    ralways(expr, ::Val{:block})

Convert multiple ifelse-blocks and assigns to one always-block.
"""
function ralways(expr, ::Val{:block})
    if length(expr.args) > 0 && expr.args[1] isa Expr && expr.args[1].head == :macrocall
        return ralwayswithSensitivity(expr)
    end

    assignlist = Alassign[]
    ifblocklist = Ifelseblock[]

    lineinfo = LineNumberNode(0, "noinfo")

    try 
        for item in expr.args 
            if item isa LineNumberNode 
                lineinfo = item 
            else
                parsed = roneblock(item)

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

    return Alwayscontent(assignlist, ifblocklist)
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
```

"""
function decloneline(expr::Expr)
    return decloneline(expr, expr.args[3:end]...)
end

"""
    decloneline(expr::Expr, ::Symbol)

Parse one declaration.
"""
function decloneline(expr::Expr, ::Symbol)
    dtypesym = expr.args[1]
    if dtypesym == Symbol("@wire")
        dtype = wire
    elseif dtypesym == Symbol("@reg")
        dtype = reg
    else
        @assert dtypesym == Symbol("@logic")
        dtype = logic
    end
    name = string(expr.args[3])
    return [Onedecl(dtype, name)]
end

"""
    decloneline(expr::Expr, ::Expr)

Parse multiple wires with the same wiretype (`wire`, `reg`, and `logic`).
"""
function decloneline(expr::Expr, ::Expr)
    dtypesym = expr.args[1]
    if dtypesym == Symbol("@wire")
        dtype = wire
    elseif dtypesym == Symbol("@reg")
        dtype = reg
    else
        @assert dtypesym == Symbol("@logic")
        dtype = logic
    end
    args = expr.args[3].args 

    return [Onedecl(dtype, string(sym)) for sym in args]
end

"""
    decloneline(expr::Expr, ::Int, ::Symbol)

Parse one declaration whose width is more than one.
"""
function decloneline(expr::Expr, ::Int, ::Symbol)
    dtypesym = expr.args[1]
    if dtypesym == Symbol("@wire")
        dtype = wire
    elseif dtypesym == Symbol("@reg")
        dtype = reg
    else
        @assert dtypesym == Symbol("@logic")
        dtype = logic
    end
    width = expr.args[3]
    name = string(expr.args[4])

    return [Onedecl(dtype, width, name)]
end

"""
    decloneline(expr::Expr, ::Int, ::Expr)

Parse multiple declarations whose width is more than one.
"""
function decloneline(expr::Expr, ::Int, ::Expr)
    dtypesym = expr.args[1]
    if dtypesym == Symbol("@wire")
        dtype = wire
    elseif dtypesym == Symbol("@reg")
        dtype = reg
    else
        @assert dtypesym == Symbol("@logic")
        dtype = logic
    end
    width = expr.args[3]
    args = expr.args[4].args

    return [Onedecl(dtype, width, string(sym)) for sym in args]
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