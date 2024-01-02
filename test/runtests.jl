using VerilogWriter, Test, Documenter

include("testutils.jl")

@testonlyexport()

tpaths = readdir(joinpath(@__DIR__, "core"), join=true)
tpaths = [tpaths; readdir(joinpath(@__DIR__, "midlevel"), join=true)]

macro testconduct(tpath)
    quote
        tfile = $(esc(tpath))
        tname = match(r"[a-zA-Z]+\.jl", tfile).match
        @testset "$tname" begin 
            include(tfile)
        end
    end
end

DocMeta.setdocmeta!(
    VerilogWriter, 
    :DocTestSetup, 
    :(using VerilogWriter); 
    recursive=true
)


# @testset "VerilogWriter.jl" begin
# for tpair in tpairs 
for tpath in tpaths
    @testconduct tpath
end

doctest(VerilogWriter)

# println("start doctest.")
# doctest(VerilogWriter)
# println("doctest done.")
# # end
