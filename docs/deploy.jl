function clean()
    for p in readdir(@__DIR__, join=true)
        if isfile(p) && !isnothing(match(r"\.jl", p))
            rm(p)
        end
    end
end

function main()
    clean()
end