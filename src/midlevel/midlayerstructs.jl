# @enum Midmoduletype lrand lreg lfifo

# struct Midmodule
#     name::String
#     type::Midmoduletype
#     # ports declared by Midmodule-related operations
#     lports::Vector{Oneport}
#     vmod::Vmodule
# end

"struct to contain connection info."
struct Layerconn
    # pid::Int
    # port names as wireexpr
    # ports::OrderedSet{Pair{Oneport, Oneport}}
    ports::Vector{Pair{String, String}}
end

# struct Midport
#     pid::Int
#     mmod::Midmodule
# end
# const defaultMidPid = 0

"struct to store and connect Layerconn objects."
# struct Mmodgraph
#     edges::OrderedDict{Pair{Midport, Midport}, Layerconn}
#     layers::OrderedSet{Midmodule}
# end

struct Vmodgraph
    edges::Dict{Pair{Vmodule, Vmodule}, Layerconn}
    vmods::Set{Vmodule}
end

Vmodgraph() = Vmodgraph(Dict{Pair{Vmodule, Vmodule}, Layerconn}(), Set{Vmodule}())

# @enum IntermmodSigtype imvalid imupdate
