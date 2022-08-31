using VerilogWriter, Test, Documenter

@testset "VerilogWriter.jl" begin
    DocMeta.setdocmeta!(VerilogWriter, :DocTestSetup, :(using VerilogWriter); recursive=true)
    doctest(VerilogWriter)

    @testset "Parsefunc" begin
        include("parsefunc.jl")
    end
    @testset "Print" begin
        include("print.jl")
    end
    @testset "Hash" begin
        include("hash.jl")
    end
    @testset "Autoreset" begin
        include("autoreset.jl")
    end
    @testset "Wireextract" begin
        include("wireextract.jl")
    end
end
