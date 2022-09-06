# overwrite `string` directly, for 
# 1. Base.string(x::Alwayscontent, systemverilog) 
# uses 2nd argument, which is difficult to handle with `show`, `print`.
# 2. Enums behaves differently from other structs when overwriting `Base.show`.

function Base.string(x::Oneparam)
    txt = string("parameter ", string(x.name), 
                " = ", string(x.val))
    return txt
end

function Base.string(x::Parameters)
    if length(x.val) == 0
        return ""
    else
        txt = reduce((x, y)->string(x, ",\n", y), string.(x.val))
        return string("#(\n", indent(txt), "\n)")
    end
end

function Base.string(x::Portdirec)
    return x == pin ? "input" : "output"
end

function Base.string(x::Oneport)
    if x.wtype == wire 
        swtype = ""
    else
        swtype = string(" ", string(x.wtype))
    end

    wid = x.width
    if wid.operation == literal 
        if wid.value == 1
            widtxt = ""
        else
            widtxt = "[$(wid.value-1):0] "
        end
    else
        widtxt = "[$(string(wid))-1:0] "
    end
    txt = string(string(x.direc), swtype, " ", widtxt, x.name)

    # if x.width > 1
    #     txt = string(string(x.direc), swtype, " [$(x.width-1):0] ", x.name)
    # else
    #     txt = string(string(x.direc), swtype, " ", x.name)
    # end
    return txt
end

function Base.string(x::Ports)
    if length(x.val) == 0
        txt = "();\n"
    else
        txt = reduce((x,y)->string(x, ",\n", y), string.(x.val))
        txt = string("(\n", indent(txt), "\n);\n")
    end

    return txt
end

function Base.string(x::Onelocalparam)
    txt = "localparam $(x.name) = $(string(x.val));"
end

function Base.string(x::Localparams)
    if length(x.val) > 0 
        txt = reduce(newlineconcat, string.(x.val))
    else
        txt = ""
    end

    txt 
end

function Base.string(x::Wireexpr)
    if x.operation == id 
        txt = x.name 
    elseif x.operation == literal 
        if x.bitwidth < 0
            txt = string(x.value)
        else
            txt = string(x.bitwidth, "'d", x.value)
        end
    elseif x.operation == slice 
        if length(x.subnodes) == 2
            txt = string(string(x.subnodes[1]), "[", string(x.subnodes[2]), "]")
        else
            @assert length(x.subnodes) == 3
            txt = string(string(x.subnodes[1]), x.name, "[", 
                string(x.subnodes[2]), ":", string(x.subnodes[3]), "]",)
        end
    elseif x.operation in keys(wunaopdict)
        if x.operation in explicitCallop
            txt = string(wunaopdict[x.operation], "(", string(x.subnodes[begin]), ")")
        else
            txt = string(wunaopdict[x.operation], string(x.subnodes[begin]))
        end
    elseif x.operation in keys(wbinopdict)
        txt = string("(", string(x.subnodes[1]), spacewrap(wbinopdict[x.operation]), string(x.subnodes[2]), ")")
    # elseif x.operation == dec 
    #     txt = string(string(x.bitwidth), "'d", string(x.value))
    else
        throw(error("string undef with $(x.operation)."))
    end

    return txt 
end

# assignopdict = Dict(ff => "<=", comb => "=", aunknown => "<=/=")
function Base.string(x::Alassign)
    txt = string(string(x.lhs), spacewrap(assignopdict[x.atype]), string(x.rhs), ";")
    return txt 
end

function Base.string(x::Ifcontent)
    txt1 = length(x.assigns) > 0 ? reduce(newlineconcat, string.(x.assigns)) : ""
    txt2 = length(x.ifelseblocks) > 0 ? reduce(newlineconcat, string.(x.ifelseblocks)) : ""
    txt3 = length(x.cases) > 0 ? reduce(newlineconcat, string.(x.cases)) : ""
    
    txt = ""
    for txtnow in (txt1, txt2, txt3)
        if txt == "" || txtnow == ""
            txt *= txtnow 
        else
            txt *= string("\n", txtnow) 
        end
    end
    
    txt
end

function Base.string(x::Ifelseblock)
    txt = ""
    if length(x.conds) > 0
        for i in 1:(length(x.conds)+1)
            if i == 1 
                txt1 = string("if (", string(x.conds[1]), ") begin\n")
                txt2 = string(x.contents[1])

                txt *= string(txt1, indent(txt2), "\nend")
            elseif i == length(x.conds)+1 
                if length(x.contents) == i
                    txt *= string(" else begin\n", indent(string(x.contents[i])), "\nend")
                else 
                    @assert length(x.contents) == i-1
                end
            else
                txt1 = string(" else if (", string(x.conds[i]), ") begin\n")
                
                txt *= string(txt1, indent(string(x.contents[i])), "\nend")
            end
        end
    elseif length(x.contents) == 1 
        txt = string(x.contents[1])
    end

    return txt 
end

function Base.string(x::Case)
    txt = string("case ($(string(x.condwire)))\n")
    subtxt = ""
    for item in x.conds 
        subtxt *= "$(string(item[1])): begin\n"
        subtxt *= indent(string(item[2]))
        subtxt *= "\nend\n"
    end

    txt *= indent(rstrip(subtxt)) * "\nendcase"
end

# alwaysdict = Dict(ff => "always_ff", comb => "always_comb")
function Base.string(x::Alwayscontent, systemverilog)
    if systemverilog 
        ffhead = "always_ff"
        combhead = "always_comb"
    else
        ffhead = "always" 
        combhead = "always @*"
    end

    if x.atype == ff
        ss = x.sens
        # txt1 = string(ffhead, " @( ", string(x.edge), " ", string(x.sensitive), " ) begin\n")
        txt1 = string(ffhead, " @( ", string(ss.edge), " ", string(ss.sensitive), " ) begin\n")
    elseif x.atype == comb 
        txt1 = string(combhead, " begin\n")
    else
        txt1 = "always_unknown begin\n"
    end

    # txt2 = ""
    # for v in (x.assigns, x.ifelseblocks)
    #     if length(v) > 0
    #         txt2 *= string(reduce(newlineconcat, string.(v)), "\n")
    #     end
    # end
    txt2 = string(x.content)
    txt2 = strip(txt2)
    # txt2 = newlineconcat(reduce(newlineconcat, string.(x.assigns, x.atype)),
    #                      reduce(newlineconcat, string.(x.ifelseblocks, x.atype)))
    return string(txt1, indent(txt2), "\nend")
end

function Base.string(x::Alwayscontent)
    string(x, true)
end

function Base.string(x::Assign) 
    return string("assign ", string(x.lhs), " = ", string(x.rhs), ";")
end

function Base.string(x::Onedecl)
    # if x.width == 1
    #     widtxt = ""
    # else
    #     widtxt = "[$(x.width-1):0] "
    # end
    wid = x.width
    if wid.operation == literal 
        if wid.value == 1
            widtxt = ""
        else
            widtxt = "[$(wid.value-1):0] "
        end
    else
        widtxt = "[$(string(wid))-1:0] "
    end
    return string(string(x.wtype), " ", string(widtxt), x.name, ";")
end

function Base.string(x::Decls)
    if length(x.val) == 0
        txt = ""
    else
        txt = reduce(newlineconcat, string.(x.val))
    end
end

function Base.string(x::Vmodinst; wildconn=false)
    txt = x.vmodname
    if length(x.params) > 0 
        txt *= " #(\n"
        subtxt = ""
        for (uno, dos) in x.params
            subtxt *= ".$(string(uno))($(string(dos))),\n"
        end
        txt *= string(indent(rstrip(subtxt, [' ', ',', '\n'])), "\n", ")")
    end

    txt1 = ""
    for (uno, dos) in x.ports 
        txt1 *= ".$(string(uno))($(string(dos))),\n"
    end
    if wildconn 
        txt1 *= ".*\n"
    end
    ans = string(txt, " ", x.instname, " (\n", 
        indent(rstrip(txt1, [' ', ',', '\n'])), "\n",
        ");" 
    )
    ans
end

function Base.string(x::Vmodule, systemverilog)
    txt1 = string("module ", x.name, " ", string(x.params),
                 string(x.ports))

    txt1 *= string(indent(string(x.locparams)), "\n")

    txt1 *= string(indent(string(x.decls)), "\n\n")

    if length(x.insts) > 0
        txt1 *= string(indent(reduce(newlineconcat, string.(x.insts))), "\n")
    end
    
    if length(x.assigns) > 0
        txt1 *= string(indent(reduce(newlineconcat, string.(x.assigns))), "\n")
    end

    if length(x.always) > 0
        txt1 *= indent(reduce(newlineconcat, string.(x.always, systemverilog)))
    end

    return string(txt1, "\nendmodule")
end

function Base.string(x::Vmodule)
    string(x, true)
end