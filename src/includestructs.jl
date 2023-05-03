const pathstructs = [
    "core/vstructs.jl",
    "midlevel/midlayerstructs.jl"
]

for p in pathstructs
    include(joinpath(@__DIR__, p))
end