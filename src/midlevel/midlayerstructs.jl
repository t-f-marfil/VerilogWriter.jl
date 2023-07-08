@enum Midlayertype lrand lreg lfifo

struct Midlayer
    name::String
    type::Midlayertype
    # ports declared by Midlayer-related operations
    lports::Vector{Oneport}
    vmod::Vmodule
end

"struct to contain connection info."
struct Layerconn
    pid::Int
    # port names as wireexpr
    ports::OrderedSet{Pair{Oneport, Oneport}}
end

struct Midport
    pid::Int
    mmod::Midlayer
end
const defaultMidPid = 0

"struct to store and connect Layerconn objects."
struct Layergraph
    edges::OrderedDict{Pair{Midport, Midport}, Layerconn}
    layers::OrderedSet{Midlayer}
end

@enum Interlaysigtype ilvalid ilupdate
