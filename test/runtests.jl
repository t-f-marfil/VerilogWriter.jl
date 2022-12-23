using VerilogWriter, Test, Documenter

include("testutils.jl")

@testonlyexport()

tpairs = [
    "Parsefunc" => "parsefunc.jl",
    "Print" => "print.jl",
    "Hash" => "hash.jl",
    "Autoreset" => "autoreset.jl",
    "Widthinference" => "widthinference.jl",
    "Paramsolve" => "paramsolve.jl"
]

macro testconduct(tpair)
    quote
        tname, tfile = $(esc(tpair))
        @testset "$tname" begin 
            include(tfile)
        end
        println(tname, " done.")
    end
end

@testset "VerilogWriter.jl" begin
    for tpair in tpairs 
        @testconduct tpair
    end
    
    DocMeta.setdocmeta!(
        VerilogWriter, 
        :DocTestSetup, 
        :(using VerilogWriter); 
        recursive=true
    )
    println("start doctest.")
    doctest(VerilogWriter)
    println("doctest done.")
end
