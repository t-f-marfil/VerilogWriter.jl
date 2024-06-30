module Midlevel

include(joinpath(@__DIR__, "../includedeps.jl"))

using ..Core
using ..Core: @nonIternonBcast, @basehashgen

include(joinpath(@__DIR__, "exportMidlevel.jl"))
@exportMidlevel

# add files which should be included with special care.
# if not specified here then the file is automatically included in VerilogWriter module.
manualInclude = joinpath.(@__DIR__, [
    basename(@__FILE__),
    "midlayerstructs.jl",
    "exportMidlevel.jl",
])

include(joinpath(@__DIR__, "midlayerstructs.jl"))

# @show readdir(abspath(@__DIR__), join=true)
for p in readdir(@__DIR__, join=true)
    if !(p in manualInclude)
        include(p)
    end
end

end