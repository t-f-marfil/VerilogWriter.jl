const defaultlports = [
    (@ports (
        @in CLK, RST
    ))...
]
Midlayer(t::Midlayertype, v::Vmodule) = Midlayer(t, defaultlports, v)
Midlayer(t::Midlayertype, s) = Midlayer(t, Vmodule(s))

Layerconn(x::Pair{Oneport, Oneport}) = Layerconn(Set([x]))
Layerconn() = Layerconn(Set{Pair{Oneport, Oneport}}())


Layergraph() = Layergraph(Dict{Pair{Midlayer, Midlayer}, Layerconn}(), Set{Midlayer}())