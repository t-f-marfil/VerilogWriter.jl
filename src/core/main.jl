const pathbasic = [
    "baseutils.jl",
    "textutils.jl",
    "vstructhandlers.jl",
    "vconstructors.jl",
    "rawparser.jl",
    "alwaysinference.jl",
    "paramsolve.jl", 
    "vopoverloads.jl", 
    "fsm.jl", 
    "autoreset.jl",
    "widthinference.jl", 
    "vstring.jl",
    "vpush.jl", 
    "accessor.jl",
]

for p in pathbasic
    include(joinpath(@__DIR__, p))
end