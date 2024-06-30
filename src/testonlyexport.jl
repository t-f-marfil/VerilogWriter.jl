# `testonlyvars` is a list of variables/functions/macros
#  to export only for tests

macro listtestonly(args)
    strs = Symbol[]
    for arg in args.args 
        if arg isa Symbol 
            push!(strs, arg)
        else
            arg.head == :macrocall || error("$(arg) is not accepted")
            # macroname
            push!(strs, arg.args[1])
        end
    end
    :($([string(s) for s in strs]))
end

const testonlyvars = @listtestonly (
    # showfield,
    
    oneblock, @oneblock, 
    ralways
)

function macroseparate(sv::Vector{String})
    nomacros = String[]
    macros = String[]
    for s in sv
        if startswith(s, "@")
            push!(macros, s)
        else
            push!(nomacros, s)
        end
    end

    nomacros, macros 
end

function vwmacrostrgen(mname)
    s = "macro $(mname)(args...) :(VerilogWriter.@$(mname)(\$(args...))) end;"
    
    return s
end

macro testonlyexport()
    nomacros, macros = macroseparate(testonlyvars)
    s = """$([
        "const $(s) = VerilogWriter.$(s);" for s in nomacros
        ]...) $([
            vwmacrostrgen(lstrip(s, ['@'])) for s in macros
        ]...)
        """
    q = Meta.parse(s)
    esc(q)
end