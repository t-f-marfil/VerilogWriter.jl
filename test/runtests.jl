using VerilogWriter, Test, Documenter

tpairs = [
    "Parsefunc" => "parsefunc.jl",
    "Print" => "print.jl",
    "Hash" => "hash.jl",
    "Autoreset" => "autoreset.jl",
    "Widthinference" => "widthinference.jl"
]

@testset "VerilogWriter.jl" begin
    for (tname, tfile) in tpairs 
        expr = quote
            @testset $tname begin 
                include($tfile)
            end
            println($tname, " done.")
        end
        eval(expr)
    end
    
    # DocMeta.setdocmeta!(VerilogWriter, :DocTestSetup, :(using VerilogWriter); recursive=true)
    # doctest(VerilogWriter)
    # println("doctest done.")
end
