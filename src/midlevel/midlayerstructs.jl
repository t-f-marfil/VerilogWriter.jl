@enum Midlayertype lrand lreg lfifo

struct Midlayer 
    type::Midlayertype
    # ports declared by Midlayer-related operations
    lports::Vector{Oneport}
    vmod::Vmodule
end

"struct to contain connection info."
struct Layerconn
    # port names as wireexpr
    wires::Set{Pair{Wireexpr, Wireexpr}}
end

"struct to store and connect Layerconn objects."
struct Layergraph
    edges::Dict{Pair{Midlayer, Midlayer}, Layerconn}
    layers::Set{Midlayer}
end
