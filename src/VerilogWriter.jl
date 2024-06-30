module VerilogWriter

include("includedeps.jl")

libs = [
    "core",
    "midlevel"
]
for lib in libs
    include(joinpath(@__DIR__, lib, "main.jl"))
end

using .Core
Core.@exportCore
Core.@exportPatch
Core.@exportUartDebug

using .Midlevel
Midlevel.@exportMidlevel

end
