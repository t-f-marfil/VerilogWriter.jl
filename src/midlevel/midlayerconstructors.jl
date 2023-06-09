const defaultlports = [
    (@ports (
        @in CLK, RST
    ))...
]
Midlayer(t::Midlayertype, lp::Vector{Oneport}, v::Vmodule) = Midlayer(getname(v), t, lp, v)
Midlayer(n::String, t::Midlayertype, v::Vmodule) = Midlayer(n, t, defaultlports, v)
Midlayer(t::Midlayertype, v::Vmodule) = Midlayer(t, defaultlports, v)
Midlayer(t::Midlayertype, s) = Midlayer(t, Vmodule(s))

Layerconn(x::Pair{Oneport, Oneport}) = Layerconn(Set([x]))
Layerconn() = Layerconn(Set{Pair{Oneport, Oneport}}())
Layerconn(x::T) where {T <: AbstractArray} = Layerconn(Set(x))

Layergraph() = Layergraph(Dict{Pair{Midlayer, Midlayer}, Layerconn}(), Set{Midlayer}())