"Parameter in verilog."
struct Oneparam 
    name::String
    val::Int
end

"List of parameters."
struct Parameters
    val::Vector{Oneparam}
end

@enum Portdirec pin pout

struct Oneport
    direc::Portdirec
    width::Int
    name::String

    Oneport(d, w, n) = w > 0 ? new(d, w, n) : error("width should be positive (in Oneport)")
end

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

@enum Atype ff comb aunknown

"Assign statement inside always blocks."
struct Alassign 
    lhs::Wireexpr
    rhs::Wireexpr
    atype::Atype
end

"""
Container of one if-block (, one elseif block, or one else block).

Parametrized by `T` only for mutual recursion with `Ifelseblock`.
"""
struct Ifcontent_inner{T}
    """
    Assign statements.

    Prioritizing assigns over ifelseblock may be good 
    thinking the case of always_comb (default value is often useful).
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

@enum Edge posedge negedge unknownedge
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

struct Vmodule 
    name::String
    params::Parameters
    ports::Ports

    assigns::Vector{Assign}
    always::Vector{Alwayscontent}
end