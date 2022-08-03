using VerilogWriter
using Test

@testset "VerilogWriter.jl" begin
    @testset "Parsefunc" begin
        include("parsefunc.jl")
    end
    @testset "Print" begin
        include("print.jl")
    end
end
