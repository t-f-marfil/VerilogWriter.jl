# samplepaths = joinpath(@__DIR__, "../../src/samples")

# for dir in readdir(samplepaths)
#     apath = joinpath(samplepaths, dir)
#     if isdir(apath)
#         include(joinpath(apath, string(dir, ".jl")))
#         vpaths = joinpath.(apath, string.(dir, [".sv", "_wrapper.v"]))
#         buf = IOBuffer()

#         # v, wrapper is defined inside included file
#         vexport(buf, v)
#         @show read(vpaths[1], String) == String(take!(buf))
#         vexport(buf, wrapper)
#         @show read(vpaths[2], String) == String(take!(buf))
#     end
# end
