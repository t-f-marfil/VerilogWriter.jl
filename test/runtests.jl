using VerilogWriter
using Test

@testset "VerilogWriter.jl" begin
    @testset "Print" begin
        include("print.jl")
    end
end
