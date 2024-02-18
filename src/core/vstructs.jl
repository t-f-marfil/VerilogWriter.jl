"""
Verilog operators.

Unary `&, |` does not exist so explicitly call as function
e.g. `&(wire), |(wire)` (& behaves in a wickedmanner...?),
and are only available inside quoted expressions.
Xor in verilog `^` is in Julia exponential operator, and the difference
in an association exists.
"""
@enum Wireop begin 
    add
    minus
    mul
    vdiv
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
    ipselm
    # hex 
    # dec
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
const wunaop = Set(keys(wunaopdict))

const wbinopdict = Dict([
    add => :+, 
    minus => :-,
    mul => :*,
    vdiv => :/,
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
const wbinop = Set(keys(wbinopdict))

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

julia> w4 = @wireexpr y && z; # && is available inside `@wireexpr`.

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
    # use only for `literal`
    bitwidth::Int
    value::Int 
end

"name == \"\" for no name (intermediate node)"
const wirenoname = ""
"-1 for Int field of Wireexpr which should not contain any data."
const wirevalinvalid = -1

"""
Parameter in verilog.
"""
struct Oneparam 
    name::String
    val::Wireexpr
end

"List of parameters."
struct Parameters
    val::Vector{Oneparam}
end

"Port direction object."
@enum Portdirec pin pout

"Wiretype object."
@enum Wiretype wire reg logic

"One localparam."
struct Onelocalparam 
    name::String 
    val::Wireexpr
end

"Multiple localparams."
struct Localparams
    val::Vector{Onelocalparam} 
end

"Represent one wire declaration."
struct Onedecl
    wtype::Wiretype
    width::Wireexpr
    name::String 
    # for 2d
    is2d::Bool 
    wid2d::Wireexpr
end

"Multiple wire declarations."
struct Decls 
    val::Vector{Onedecl}
end

"Represent a single port declaration."
struct Oneport
    direc::Portdirec
    wtype::Wiretype
    width::Wireexpr
    name::String
end

"Gather multiple ports."
struct Ports
    val::Vector{Oneport}
end

"Type of always blocks."
@enum Atype ff comb aunknown

const assignopdict = Dict(ff => "<=", comb => "=", aunknown => "<=/=")

"Assign statement inside always blocks."
struct Alassign 
    lhs::Wireexpr
    rhs::Wireexpr
    atype::Atype
end

"""
Container of one if-block (, one elseif block, or one else block).

Parametrized by `T, U` only for mutual recursion with `Ifelseblock` and `Case`,
thus used as `Ifcontent_inner{Ifelseblock, Case}`, which is aliased as `Ifcontent`.
"""
struct Ifcontent_inner{T, U}
    """
    Assign statements.

    Prioritizing assigns over ifelseblock may be good 
    thinking the case of always_comb (in which default value is often useful).

    May better obtain the order in which assigns and ifelseblocks
    are added?
    """
    assigns::Vector{Alassign}
    """
    Ifelse statements.
    """
    ifelseblocks::Vector{T}
    cases::Vector{U}
end

"""
Container of an if-else block. Parametrized by `T` for mutual recursion.
Used as `Ifelseblock = Ifelseblock_inner{Case}`.
"""
struct Ifelseblock_inner{T}
    # if cond1 
    #   content1
    # elseif cond2 
    #   content2 
    # ...

    # `length(conds) - length(contents)` may differ according to 
    # the structure, i.e. if-end <=> if-else-end
    conds::Vector{Wireexpr}
    contents::Vector{Ifcontent_inner{Ifelseblock_inner{T}, T}}
end

"""
```
case (cnd)
    cnd1: begin
        foo1
    end
    cnd2: begin
        foo2
    end
    ...
endcase
```

converts to

```
Case(cnd, [
    (cnd1 => foo1),
    (cnd2 => foo2),
    ...
])
```
"""
struct Case 
    condwire::Wireexpr
    conds::Vector{Pair{
        Wireexpr,
        Ifcontent_inner{
            Ifelseblock_inner{Case}, 
            Case
        }}}
end

const Ifelseblock = Ifelseblock_inner{Case}
const Ifcontent = Ifcontent_inner{Ifelseblock, Case}

"Edge in sensitivity lists."
@enum Edge posedge negedge unknownedge

"Sensitivity list for always blocks."
struct Sensitivity
    edge::Edge 
    sensitive::Wireexpr
end

"Represent always blocks."
mutable struct Alwayscontent
    atype::Atype 
    # edge::Edge
    # sensitive::Wireexpr
    sens::Sensitivity
    content::Ifcontent
end

"Assign one statement."
struct Assign 
    lhs::Wireexpr
    rhs::Wireexpr
end

"""
Represents module instantiation.

```jldoctest
i = Vmodinst(
    "mod1",
    "u1",
    [
        "A" => Wireexpr(15)
    ],
    [
        "p1" => (@wireexpr x << 1),
        "p2" => (@wireexpr y)
    ]
)
vshow(i)

# output

mod1 #(
    .A(15)
) u1 (
    .p1((x << 1)),
    .p2(y)
);
type: Vmodinst
```

For convenient instantiation 
see also [`@preport`](@ref) and [`naiveinst`](@ref).
"""
struct Vmodinst
    vmodname::String 
    instname::String
    params::Vector{
        Pair{String, Wireexpr}
    }
    ports::Vector{
        Pair{String, Wireexpr}
    }
    wildconn::Bool
end

"Represents one verilog module."
struct Vmodule 
    name::String
    params::Parameters
    ports::Ports

    lparams::Localparams
    decls::Decls
    
    insts::Vector{Vmodinst}

    assigns::Vector{Assign}
    always::Vector{Alwayscontent}
end


"Environment in which wire width inference is done."
struct Vmodenv
    prms::Parameters
    prts::Ports
    lprms::Localparams
    dcls::Decls
end