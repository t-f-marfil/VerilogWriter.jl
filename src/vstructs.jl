"""
Parameter in verilog.
"""
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

"Wiretype object."
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

"""
Verilog operators.

Unary `&, |` does not exists so explicitly call as function
e.g. `&(wire), |(wire)` (& behaves in a wickedmanner...?),
and are only available inside quoted expressions.
Xor in verilog `^` is in Julia exponential operator, and the difference
in an association exists.
"""
@enum Wireop begin 
    add
    minus
    lshift 
    rshift
    band
    bor
    bxor

    neg 
    uminus
    redand 
    redor
    redxor

    logieq
    leq
    lt

    land 
    lor
    
    id 
    slice
    literal
    hex 
    dec
end

"`&&` and `||` are invalid identifier in julia."
const noJuliaop = (land, lor)
"Must be explicitly called as function e.g. `|(wire1)`, `&(wire2)`."
const explicitCallop = (redand, redor, redxor)

const wunaopdict = Dict([
    neg => :~
    uminus => :-
    redand => :&
    redor => :|
    redxor => :^
])
const wbinopdict = Dict([
    add => :+, 
    minus => :-,
    lshift => :<<,
    rshift => :>>,
    band => :&,
    bor => :|,
    bxor => :^,

    logieq => :(==),
    leq => :<=,
    lt => :<,

    land => :&&,
    lor => :||
])
const arityambigs = [:-, :|, :&, :^]
const arityambigVals = Union{[Val{i} for i in arityambigs]...}

"""
Wire expressions in verilog. 

Contains unnecessary information to handle all the wires
in the same type. 

One motivation to avoid making different types of 
wires (e.g. using parametric types) is that it seemed
beneficial to have multiple wires in a vector, and that 
it is sometime a disadvantage in performance to use 
abstract types when creating vectors.

Some operators on wires in Verilog, which are listed in `Enum Wireop`, 
are overloaded for `Wireexpr`.
Note that reduction operators (unary `&, |, ^`) are not in Julia, 
and logical and, or (`&&, ||`) can be applied only for booleans in Julia, thus 
are not available as an operator for `Wireexpr` objects.

# Examples 
```jldoctest
julia> w1 = @wireexpr x + y;

julia> w2 = @wireexpr z;

julia> vshow(w1 & w2);
((x + y) & z)
type: Wireexpr

julia> w3 = @wireexpr x;

julia> w4 = @wireexpr y && z; # && is available inside `@wireexpr` and `wireexpr` methods.

julia> vshow(w3 | w4)
(x | (y && z))
type: Wireexpr
```
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
Container of an if-else block.
"""
struct Ifelseblock 
    # if cond1 
    #   content1
    # elseif cond2 
    #   content2 
    # ...

    # `length(conds) - length(contents)` may differ according to 
    # the structure, i.e. if-end <=> if-else-end
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

"Assign one statement."
struct Assign 
    lhs::Wireexpr
    rhs::Wireexpr
end

"Represent one wire declaration."
struct Onedecl
    wtype::Wiretype
    width::Int
    name::String 
end

"Multiple wire declarations."
struct Decls 
    val::Vector{Onedecl}
end

"Represents one verilog module."
struct Vmodule 
    name::String
    params::Parameters
    ports::Ports

    decls::Decls

    assigns::Vector{Assign}
    always::Vector{Alwayscontent}
end