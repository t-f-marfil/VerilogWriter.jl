iter(f, n) = n <= 1 ? f : x -> f(iter(f, n-1)(x))

function main()

    lines = readlines("intro.md")
    ci = "[![CI](https://github.com/t-f-marfil/VerilogWriter.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/t-f-marfil/VerilogWriter.jl/actions/workflows/CI.yml)"
    doclink = "Examples and full documents are available [here](https://t-f-marfil.github.io/VerilogWriter.jl/)."
    
    outtxt = string(lines[begin], "\n", ci, "\n")

    # body starts from line 10
    for ind in 10:length(lines)
        if startswith(lines[ind], "## Brief Introduction")
            outtxt = string(outtxt, "\n", doclink)
        end

        line = replace(lines[ind], r"jldoctest[.]*" => "Julia")

        outtxt = string(outtxt, "\n", line)
    end


    write(joinpath(iter(dirname, 3)(@__FILE__), "README.md"), outtxt)
end

main()