push!(LOAD_PATH,"../src/")
using Documenter, VerilogWriter

function docgen(prettyurls)
    DocMeta.setdocmeta!(VerilogWriter, :DocTestSetup, :(using VerilogWriter); recursive=true)

    makedocs(
        sitename = "VerilogWriter Document",
        # format = Documenter.HTML(prettyurls=false),
        format = Documenter.HTML(prettyurls=prettyurls),
        pages = [
            "User Guide" => [
                "Introduction" => "index.md",
                "Quick Start" => "qstart.md",
                "Basic Types" => "types.md",
                "Basic Automation" => "inference.md",
                "Finite State Machines" => "fsm.md", 
                "Mid-Level Synthesis" => "midlevel.md",
                "Reference" => "reference.md",
            ],
            "Release Note" => "release.md",
        ],
        warnonly = [:missing_docs],
        modules = [VerilogWriter],
        doctest = false
    )

    include(joinpath(@__DIR__, "src", "intro2readme.jl"))
end

function main()
    prettyurls = false
    if "DEPLOY" in ARGS
        prettyurls = true
    end

    docgen(prettyurls)

    if "DEPLOY" in ARGS
        deploydocs(
            repo="github.com/t-f-marfil/VerilogWriter.jl.git",
            push_preview=true,
            devbranch="develop",
        )
    end
end

main()