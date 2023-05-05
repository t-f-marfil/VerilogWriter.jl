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
    ports::OrderedSet{Pair{Oneport, Oneport}}
end

"struct to store and connect Layerconn objects."
struct Layergraph
    edges::OrderedDict{Pair{Midlayer, Midlayer}, Layerconn}
    layers::OrderedSet{Midlayer}
end
