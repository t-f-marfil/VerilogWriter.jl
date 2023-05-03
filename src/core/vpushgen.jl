function arg12types(fexpr::Expr)
    fexpr.head == :function || error("$(fexpr.head) is not acceptable.")

    farg = fexpr.args[1].head == :where ? fexpr.args[1].args[1].args : fexpr.args[1].args
    uno, dos = argtype_inner.(view(farg, 2:3))
end

function argdefstr(fexpr::Expr)
    string(fexpr.args[1])
end

function argtype_inner(e::Expr)::Symbol
    if e.head == Symbol("::")
        e.args[2]
    else
        e.head == Symbol("...") || error("$(e.head) when argument parsing")
        e.args[1].args[2]
    end
end

# get code from vpushraw.jl
methstr = ""
open(joinpath(@__DIR__, "vpushraw.jl")) do io 
    # scope problem
    global methstr = read(io, String)
end
methvec = split(methstr, "function")
f(x) = "function"*x
methvec = rstrip.(f.(methvec)[begin+1:end])

# parse all methods
ex = Meta.parse.(methvec)

# add doc & method
open(joinpath(@__DIR__, "vpush.jl"), "w") do io 
    pre = "# Generated from \"vpushgen.jl\", do not edit manually,\n# edit \"vpushraw.jl\" instead.\n\n"
    write(io, pre)

    for meth in ex
        uno, dos = arg12types(meth)
        d = "vpush! method, add $(dos) to $(uno)."
        s = """
        \"\"\"
            $(argdefstr(meth))
        
        $(d)
        \"\"\"
        $(string(meth))
        
        """

        # open("vpush.jl", "a") do io 
        write(io, s)
        # end
    end

    # suf = """
    # "Add new objects into existing Verilog-like objects."
    # vpush!
    # """
    suf = ""
    write(io, suf)
end