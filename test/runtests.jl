using VerilogWriter, Test, Documenter

include("testutils.jl")

@testonlyexport()

tpaths = [
    readdir(joinpath(@__DIR__, "core"), join=true);
    readdir(joinpath(@__DIR__, "core/uartDebug"), join=true);
    readdir(joinpath(@__DIR__, "midlevel"), join=true)
]
tpaths = filter(isfile, tpaths)

macro testconduct(tpath)
    quote
        tfile = $(esc(tpath))
        tname = match(r"[a-zA-Z]+\.jl", tfile).match
        @testset "$tname" begin 
            include(tfile)
        end
    end
end

for tpath in tpaths
    @testconduct tpath
end

DocMeta.setdocmeta!(
    VerilogWriter, 
    :DocTestSetup, 
    :(using VerilogWriter); 
    recursive=true
)


doctest(VerilogWriter)
