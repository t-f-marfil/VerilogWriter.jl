# order in which files below are included matters,
# vconstructors should be included before contructors are used
const pathbasic = [
    "vstructs.jl",

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
    "unionfind.jl",
    "widthinference.jl", 
    "vstring.jl",
    "vpush.jl", 
    "accessor.jl",
    "verilator.jl",

    "axi.jl",
    "memfile.jl",

    "patch/stdpatch.jl",
    "patch/ram.jl",
    "uartDebug/ascii.jl",
]

for p in pathbasic
    include(joinpath(@__DIR__, p))
end