const defaultlports = [
    (@ports (
        @in CLK, RST
    ))...
]
Midmodule(t::Midmoduletype, lp::Vector{Oneport}, v::Vmodule) = Midmodule(getname(v), t, lp, v)
Midmodule(n::String, t::Midmoduletype, v::Vmodule) = Midmodule(n, t, defaultlports, v)
Midmodule(t::Midmoduletype, v::Vmodule) = Midmodule(t, defaultlports, v)
Midmodule(v::Vmodule) = Midmodule(lrand, v)
Midmodule(t::Midmoduletype, s) = Midmodule(t, Vmodule(s))

# Layerconn(x) = Layerconn(0, x)
Layerconn(x::Layerconn) = x
Layerconn() = Layerconn(OrderedSet{Pair{Oneport, Oneport}}())
# Layerconn(pid::Int, x::Pair{Oneport, Oneport}) = Layerconn(pid, Set([x]))
# Layerconn(pid::Int, x::T) where {T <: AbstractArray} = Layerconn(pid, Set(x))
Layerconn(x::Pair{Oneport, Oneport}) = Layerconn(OrderedSet([x]))
Layerconn(x::T) where {T <: AbstractArray} = Layerconn(OrderedSet(x))

Mmodgraph() = Mmodgraph(OrderedDict{Pair{Midmodule, Midmodule}, Layerconn}(), Set{Midmodule}())