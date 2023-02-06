# `testonlyvars` is a list of variables/functions/macros
#  to export only for tests

export @testonlyexport

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