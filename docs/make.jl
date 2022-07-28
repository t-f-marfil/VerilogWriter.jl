push!(LOAD_PATH,"../src/")
using Documenter, VerilogWriter

makedocs(
    sitename = "VerilogWriter Document",
    format = Documenter.HTML(prettyurls = false),
    pages = [
        "Introduction" => "index.md"
    ]
)