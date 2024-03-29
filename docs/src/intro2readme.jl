iter(f, n) = n <= 1 ? f : x -> f(iter(f, n-1)(x))

function main()

    lines = readlines(joinpath(@__DIR__, "index.md"))
    ci = "[![CI](https://github.com/t-f-marfil/VerilogWriter.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/t-f-marfil/VerilogWriter.jl/actions/workflows/CI.yml)"
    codecov = "[![codecov](https://codecov.io/gh/t-f-marfil/VerilogWriter.jl/branch/master/graph/badge.svg?token=2JM0REZRDK)](https://codecov.io/gh/t-f-marfil/VerilogWriter.jl)"
    badges = [ci, codecov]
    doclink = "Examples and full documents are available [here](https://t-f-marfil.github.io/VerilogWriter.jl/)."
    
    outtxt = string(lines[begin], "\n", badges..., "\n")

    # body starts from line 10
    for ind in 10:length(lines)
        if startswith(lines[ind], "## Brief Introduction")
            outtxt = string(outtxt, "\n\n", doclink)
        end

        line = replace(lines[ind], r"jldoctest[.]*" => "Julia")

        outtxt = string(outtxt, "\n", line)
    end


    write(joinpath(iter(dirname, 3)(@__FILE__), "README.md"), outtxt)
end

main()