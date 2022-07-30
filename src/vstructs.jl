"Parameter in verilog."
struct Oneparam 
    name::String
    val::Int
end

"List of parameters."
struct Parameters
    val::Vector{Oneparam}
end

"Port direction object."
@enum Portdirec pin pout

@enum Wiretype wire reg logic 

"Represent a single port declaration."
struct Oneport
    direc::Portdirec
    wtype::Wiretype
    width::Int
    name::String
    # Oneport(d, t, w, n) = w > 0 ? new(d, t, w, n) : error("width should be positive (in Oneport)")
end

"Gather multiple ports."
struct Ports
    val::Vector{Oneport}
end

"Verilog operators."
@enum Wireop begin 
    add
    minus
    lshift 
    rshift

    neg 
    uminus
    
    id 
    slice
    literal
    hex 
    dec
end

const wunaopdict = Dict([
    neg => :~
    uminus => :-
])
const wbinopdict = Dict([
    add => :+, 
    minus => :-,
    lshift => :<<,
    rshift => :>>
])

"""
Wire expressions in verilog. 

Contains unnecessary information to handle all the wires
in the same type. 

One motivation that I avoid making different types of 
wires (e.g. using parametric types) is that it seemed
beneficial to have multiple wires in a vector, and that 
it is sometime a disadvantage in performance to use 
abstract type when creating vectors.
"""
struct Wireexpr
    # name == "" for no name (intermediate node)
    # -1 for Int field that should not contain any data
    operation::Wireop 
    name::String
    subnodes::Vector{Wireexpr}
    bitwidth::Int
    value::Int 
end

"Type of always blocks."
@enum Atype ff comb aunknown

"Assign statement inside always blocks."
struct Alassign 
    lhs::Wireexpr
    rhs::Wireexpr
    atype::Atype
end

"""
Container of one if-block (, one elseif block, or one else block).

Parametrized by `T` only for mutual recursion with `Ifelseblock`, 
thus used as `Ifcontent_inner{Ifelseblock}`, which is aliased as `Ifcontent`.
"""
struct Ifcontent_inner{T}
    """
    Assign statements.

    Prioritizing assigns over ifelseblock may be good 
    thinking the case of always_comb (default value is often useful).

    May better obtain the order in which assigns and ifelseblocks
    are added?
    """
    assigns::Vector{Alassign}
    """
    Ifelse statements.
    """
    ifelseblocks::Vector{T}
end

"""
Container of if-else block.

`length(conds) - length(contents)` may differ according to 
the structure, i.e. if-end <=> if-else-end
"""
struct Ifelseblock 
    # if cond1 
    #   content1
    # elseif cond2 
    #   content2 
    # ...
    conds::Vector{Wireexpr}
    contents::Vector{Ifcontent_inner{Ifelseblock}}
end

const Ifcontent = Ifcontent_inner{Ifelseblock}

"Edge in sensitivity lists."
@enum Edge posedge negedge unknownedge

"Represent always blocks."
mutable struct Alwayscontent
    atype::Atype 
    edge::Edge
    sensitive::Wireexpr
    assigns::Vector{Alassign}
    ifelseblocks::Vector{Ifelseblock}
end

struct Assign 
    lhs::Wireexpr
    rhs::Wireexpr
end


struct Onedecl
    wtype::Wiretype
    width::Int
    name::String 
end

struct Decls 
    val::Vector{Onedecl}
end

struct Vmodule 
    name::String
    params::Parameters
    ports::Ports

    assigns::Vector{Assign}
    always::Vector{Alwayscontent}
end