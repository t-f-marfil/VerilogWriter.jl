# add files which should not be included here
# if not specified here then the file is automatically included in VerilogWriter module.
noincludehere = joinpath.(@__DIR__, [
    basename(@__FILE__),
    "midlayerstructs.jl",
])

# @show readdir(abspath(@__DIR__), join=true)
for p in readdir(@__DIR__, join=true)
    if !(p in noincludehere)
        include(p)
    end
end

