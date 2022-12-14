Oneparam(n, val::Int) = Oneparam(n, Wireexpr(val))


Parameters(args::Oneparam...) = Parameters([args...])


# Oneport(d::Portdirec, wt::Wiretype, wid::Wireexpr, n) = Oneport(d, Onedecl(wt, wid, n))
Oneport(d::Portdirec, wt::Wiretype, wid::Int, n) = Oneport(d, wt, Wireexpr(wid), n)

# Oneport(d::Portdirec, w::Int, n::String) = Oneport(d, wire, w, n)
Oneport(d::Portdirec, w, n::String) = Oneport(d, wire, w, n)
Oneport(d::Portdirec, n::String) = Oneport(d, 1, n)
Oneport(d::Portdirec, n::Ref{Symbol}) = Oneport(d, string(n[]))
# Oneport(d::Portdirec, w::Int, n::Ref{Symbol}) = Oneport(d, w, string(n[]))
Oneport(d::Portdirec, w, n::Ref{Symbol}) = Oneport(d, w, string(n[]))


Ports(args::Oneport...) = Ports([args...])


Onelocalparam(n, val::Int) = Onelocalparam(n, Wireexpr(val))


Localparams(args::Onelocalparam...) = Localparams([i for i in args])


Onedecl(t::Wiretype, wid::Wireexpr, n) = Onedecl(t, wid, n, false, Wireexpr())

Onedecl(t::Wiretype, wid::Int, n::String) = Onedecl(t, Wireexpr(wid), n)

Onedecl(t::Wiretype, n::String) = Onedecl(t, 1, n)
Onedecl(t::Wiretype, n::Ref{Symbol}) = Onedecl(t, string(n[]))
Onedecl(t::Wiretype, w::Int, n::Ref{Symbol}) = Onedecl(t, w, string(n[]))


Decls(args::Onedecl...) = Decls([args...])


"""
    Wireexpr(n::String, msb::T1, lsb::T2) where {T1 <: Union{Int, Wireexpr}, T2 <: Union{Int, Wireexpr}}

Slice of `n` from `msb` to `lsb`.

Index for wires can be Int or Wireexpr.
"""
Wireexpr(n::String, msb::T1, lsb::T2) where {
    T1 <: Union{Int, Wireexpr}, T2 <: Union{Int, Wireexpr}
} = Wireexpr(slice, n, [Wireexpr(msb), Wireexpr(lsb)], -1, -1)
"""
    Wireexpr(n::String, msb::T) where {T <: Union{Int, Wireexpr}}

Get one bit at `msb` from `n`.
"""
Wireexpr(n::String, msb::T) where {T <: Union{Int, Wireexpr}
} = Wireexpr(slice, n, [Wireexpr(msb)], -1, -1)
"""
    Wireexpr(n::String)

Case where no slice is needed.
"""
Wireexpr(n::String) = Wireexpr(id, n, [], -1, -1)
"""
    Wireexpr(n::Symbol)

Convert Symbol to String and construct Wireexpr.
"""
Wireexpr(n::Symbol) = Wireexpr(string(n))
"""
    Wireexpr(n::Int)

Literal of Integer.
"""
Wireexpr(n::Int) = Wireexpr(-1, n)
# Wireexpr(n::Int) = Wireexpr(literal, "", [], -1, n)
"""
    Wireexpr(w::Integer, n::Integer)

Literal with width specification, printed in the decimal format.
"""
Wireexpr(w::Integer, n::Integer) = Wireexpr(literal, "", [], Int(w), Int(n))
"""
    Wireexpr(expr::Wireexpr)

Return the argument itself, used in slice construction
to make it possible to apply the same method to msb as Int and as Wireexpr.
"""
Wireexpr(expr::Wireexpr) = expr
"""
    Wireexpr()

Create an empty expression.
"""
Wireexpr() = Wireexpr("")
"""
    Wireexpr(op::Wireop, v::Vector{Wireexpr})

Apply an operation on wires in `v`.
"""
Wireexpr(op::Wireop, v::Vector{Wireexpr}) = Wireexpr(op, "", v, -1, -1)
# Wireexpr(op::Wireop, uno::Wireexpr) = Wireexpr(op, [uno])
# Wireexpr(op::Wireop, uno::Wireexpr, dos::Wireexpr) = Wireexpr(op, [uno, dos])
"""
    Wireexpr(op::Wireop, w::Wireexpr...)

Apply an operation of `w` wires.

# Examples 
```jldoctest
julia> a = @wireexpr a; b = @wireexpr b;

julia> c = Wireexpr(add, a, b); # equivalent to wireexpr(:(\$(a) + \$(b)))

julia> vshow(c);
(a + b)
type: Wireexpr

julia> d = Wireexpr(redor, a); vshow(d); # wireexpr(:(|(\$(a))))
|(a)
type: Wireexpr
```
"""
Wireexpr(op::Wireop, w::Wireexpr...) = Wireexpr(op, [w...])


Alassign(lhs, rhs) = Alassign(lhs, rhs, aunknown)


Ifcontent(x::Vector{Alassign}, y::Vector{Ifelseblock}) = Ifcontent(x, y, Case[])
Ifcontent() = Ifcontent([], [])
Ifcontent(x::Vector{Alassign}) = Ifcontent(x, Ifelseblock[])
Ifcontent(x::Alassign...) = Ifcontent([x...])
Ifcontent(x::Ifelseblock...) = Ifcontent(Alassign[], [x...])
Ifcontent(x::Case...) = Ifcontent([], [], [x...])

Ifelseblock() = Ifelseblock([], [])
Ifelseblock(cond::Wireexpr, ifcont::Ifcontent) = Ifelseblock([cond], [ifcont])
Ifelseblock(cond::Wireexpr, ifcont::Ifcontent, elsecont::Ifcontent) = Ifelseblock([cond], [ifcont, elsecont])


Alwayscontent(atype::Atype, edge::Edge, sens::Wireexpr, cont::Ifcontent) = Alwayscontent(atype, Sensitivity(edge, sens), cont)

Alwayscontent(atype::Atype) = Alwayscontent(atype, unknownedge, Wireexpr(), Ifcontent())
Alwayscontent(ifcont::Ifcontent) = Alwayscontent(aunknown, unknownedge, Wireexpr(), ifcont)
Alwayscontent(assigns::Vector{Alassign}, ifblocks::Vector{Ifelseblock}) = Alwayscontent(Ifcontent(assigns, ifblocks))
Alwayscontent(assigns::Vector{Alassign}, ifblocks::Vector{Ifelseblock}, cases::Vector{Case}) = Alwayscontent(Ifcontent(assigns, ifblocks, cases))
Alwayscontent(assign::Alassign...) = Alwayscontent([i for i in assign], Ifelseblock[])
Alwayscontent(ifblock::Ifelseblock...) = Alwayscontent(Alassign[], [i for i in ifblock])
Alwayscontent(case::Case...) = Alwayscontent(Alassign[], Ifelseblock[], [case...])

Alwayscontent() = Alwayscontent(aunknown)


Vmodinst(vname, iname, pts, wild::Bool) = Vmodinst(vname, iname, Pair{String, Wireexpr}[], pts, wild)
Vmodinst(vname, iname, ps, pts) = Vmodinst(vname, iname, ps, pts, false)


Vmodule(n) = Vmodule(n, Vmodenv())
Vmodule(n, env::Vmodenv) = Vmodule(n, env, Alwayscontent[])
Vmodule(n, env::Vmodenv, als) = Vmodule(n, env, Assign[], als)
Vmodule(n, env::Vmodenv, ass::Vector{Assign}, als::Vector{Alwayscontent}) = Vmodule(n, env, Vmodinst[], ass, als)
Vmodule(n, env::Vmodenv, insts::Vector{Vmodinst}, als::Vector{Alwayscontent}) = Vmodule(n, env, insts, Assign[], als)
Vmodule(n, env::Vmodenv, insts, ass, als) = Vmodule(n, env.prms, env.prts, env.lprms, env.dcls, insts, ass, als)

Vmodule(n::String, pas::Parameters, ps::Ports, lpas::Localparams,
decls::Decls, ass::Vector{Assign}, als::Vector{Alwayscontent}
) = Vmodule(n, pas, ps, lpas, decls, Vmodinst[], ass, als)

Vmodule(n::String, pas::Parameters, ps::Ports, decls::Decls, 
ass::Vector{Assign}, als::Vector{Alwayscontent}
) = Vmodule(n, pas, ps, Localparams(), decls, ass, als)

Vmodule(n::String, ps::Ports, decls::Decls, 
ass::Vector{Assign}, als::Vector{Alwayscontent}
) = Vmodule(n, Parameters(), ps, decls, ass, als)

Vmodule(n::String, ps::Ports, decls::Decls, als::Vector{Alwayscontent}
) = Vmodule(n, Parameters(), ps, decls, Assign[], als)