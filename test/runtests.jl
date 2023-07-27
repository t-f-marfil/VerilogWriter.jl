using VerilogWriter, Test, Documenter

include("testutils.jl")

@testonlyexport()

tpaths = readdir(joinpath(@__DIR__, "core"), join=true)
# tpaths = vcat([], readdir(joinpath(@__DIR__, "midlevel"), join=true))

macro testconduct(tpath)
    quote
        # tname, tfile = $(esc(tpair))
        tfile = $(esc(tpath))
        tname = match(r"[a-zA-Z]+\.jl", tfile).match
        @testset "$tname" begin 
            include(tfile)
        end
        # println(tname, " done.")
    end
end

DocMeta.setdocmeta!(
    VerilogWriter, 
    :DocTestSetup, 
    :(using VerilogWriter); 
    recursive=true
)

doctest(VerilogWriter)

# @testset "VerilogWriter.jl" begin
# for tpair in tpairs 
for tpath in tpaths
    @testconduct tpath
end


# println("start doctest.")
# doctest(VerilogWriter)
# println("doctest done.")
# # end
