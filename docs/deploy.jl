function clean()
    dirneeded = r"(src|build)$"

    for p in readdir(@__DIR__, join=true)
        if isdir(p) && isnothing(match(dirneeded, p))
            rm(p, recursive=true)
        elseif isfile(p) && isnothing(match(r"\.jl", p))
            rm(p)
        end
    end
end

function recgetfile_inner(parentpath)
    ans = String[]
    for p in joinpath.(Ref(parentpath), readdir(parentpath))
        if isfile(p)
            push!(ans, p)
        elseif isdir(p)
            ans = [ans; recgetfile_inner(p)]
        end
    end

    return ans
end

function recgetfile(parentpath)
    ans = String[]
    pinit = pwd()
    cd(parentpath)

    for p in readdir()
        if isfile(p)
            push!(ans, p)
        elseif isdir(p)
            ans = [ans; recgetfile_inner(p)]
        end
    end

    cd(pinit)

    return ans
end

function recdircreate(p)
    if !ispath(p)
        recdircreate(dirname(p))
        mkdir(p)
    end
    return nothing
end

function movehere()
    items = recgetfile("build")

    for p in items
        if isnothing(match(r"\.jl$", basename(p)))
            destpath = joinpath(@__DIR__, p)
            recdircreate(destpath |> dirname)

            cp(joinpath(@__DIR__, "build", p), destpath)
        end
    end
end

function deploy()
    clean()
    if "clean" in ARGS
        return
    end

    movehere()
end

deploy()