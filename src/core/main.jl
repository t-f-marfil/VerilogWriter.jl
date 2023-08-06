# order in which files below are included matters,
# vconstructors should be included before contructors are used
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
    "verilator.jl",
    "stdpatch.jl",
]

for p in pathbasic
    include(joinpath(@__DIR__, p))
end