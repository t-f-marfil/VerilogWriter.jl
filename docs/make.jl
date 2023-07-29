push!(LOAD_PATH,"../src/")
using Documenter, VerilogWriter

function docgen()
    DocMeta.setdocmeta!(VerilogWriter, :DocTestSetup, :(using VerilogWriter); recursive=true)

    makedocs(
        sitename = "VerilogWriter Document",
        format = Documenter.HTML(prettyurls=false),
        pages = [
            # "Examples" => "index.md",
            "Introduction" => "index.md",
            "Quick Start" => "qstart.md",
            "Basic Types" => "types.md",
            "Basic Automation" => "inference.md",
            "Finite State Machines" => "fsm.md", 
            "Mid-Level Synthesis" => "midlevel.md",
            "Reference" => "reference.md"
        ],
        modules = [VerilogWriter],
        strict = :doctest,
        doctest = false
    )

    include(joinpath(@__DIR__, "src", "intro2readme.jl"))
end

function main()
    # include(joinpath(@__DIR__, "deploy.jl"))
    # if any(x->x in ARGS, ("clean", "deploy"))
    #     return
    # end

    docgen()
    include(joinpath(@__DIR__, "deploy.jl"))
end

main()