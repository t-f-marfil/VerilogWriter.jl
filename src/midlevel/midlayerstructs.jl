@enum Midmoduletype lrand lreg lfifo

struct Midmodule
    name::String
    type::Midmoduletype
    # ports declared by Midmodule-related operations
    lports::Vector{Oneport}
    vmod::Vmodule
end

"struct to contain connection info."
struct Layerconn
    # pid::Int
    # port names as wireexpr
    ports::OrderedSet{Pair{Oneport, Oneport}}
end

struct Midport
    pid::Int
    mmod::Midmodule
end
const defaultMidPid = 0

"struct to store and connect Layerconn objects."
struct Layergraph
    edges::OrderedDict{Pair{Midport, Midport}, Layerconn}
    layers::OrderedSet{Midmodule}
end

@enum IntermmodSigtype imvalid imupdate
