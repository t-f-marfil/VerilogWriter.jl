# include("midlayer.jl")
noincludehere = abspath.([
    @__FILE__,
    "midlayerstructs.jl",
])


# @show readdir(abspath(@__DIR__), join=true)
for p in readdir(abspath(@__DIR__), join=true)
    if !(p in noincludehere)
        include(p)
    end
end

