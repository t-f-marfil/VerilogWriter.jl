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

Parse AST in Julia grammar to one if-block in Verilog. 

As using Julia expression and Julia parser as if 
it is of Verilog, there can be difference in grammatical matters 
between what can be given as the `expr` and real Verilog 
(e.g. operator precedence of `<=`).

In order to enable multiple dispatch according to the head of `expr`,
dispatches `roneblock` with an additional argument `Val(expr.head)`.
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
Dispatch methods here according to `expr.head`.
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

macro ralways(arg)
    return Expr(:call, ralways, Ref(arg))
end

function ralways(expr::Ref{T}) where {T}
    ralways(expr[])
end


function pportoneline(expr::Expr, ::Symbol)
    direc = expr.args[1] == Symbol("@in") ? pin : (
        @assert expr.args[1] == Symbol("@out"); pout)
    name = string(expr.args[3])
    return [Oneport(direc, name)]
end

function pportoneline(expr::Expr, ::Expr)
    direc = expr.args[1] == Symbol("@in") ? pin : (
        @assert expr.args[1] == Symbol("@out"); pout)
    args = expr.args[3].args 

    return [Oneport(direc, string(sym)) for sym in args]
end

function ports(expr::Expr)
    @assert expr.head == :block 
    anslist = Oneport[]

    lineinfo = LineNumberNode(0, "noinfo")
    for item in expr.args 
        if item isa LineNumberNode 
            lineinfo = item
        else
            push!(anslist, pportoneline(item, item.args[3])...)
        end
    end

    return Ports(anslist)
end
