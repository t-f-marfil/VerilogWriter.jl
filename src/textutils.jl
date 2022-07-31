"generate spaces of length `x`."
space(x::Int) = " "^x

"TAB as 4 spaces."
const TAB = space(4)

"Indent `txt` with spaces of length \$eachspalen*depth\$."
function indent(txt; eachspalen=4, depth=1)
    spalen = eachspalen*depth 
    return reduce((x,y)->string(x, "\n", y), map((s -> space(spalen)*s), split(txt, "\n")))
end

"Wrap `txt` with space of length `width`."
function spacewrap(txt; width=1)
    return string(" "^width, txt, " "^width)
end

"Concatenate `uno` and `dos` with '\\n' inserted inbetween."
function newlineconcat(uno, dos)
    return string(uno, "\n", dos)
end

"""
    vshow(x; systemverilog=true)

Print the structs in `VerilogWriter.jl` in a readable 
format (except for enums).
When `systemverilog=false`, output `always`, `always @*` 
instead of `always_ff`, `always_comb`, respectively.
"""
function vshow(x; systemverilog=true)
    println(string(x))
    println(string("type: ", typeof(x)))
end

function vshow(x::T; systemverilog=true) where {T <: Union{Vmodule, Alwayscontent}}
    println(string(x, systemverilog))
    println(string("type: ", typeof(x)))
end

function vshow(x::Vector{T}; systemverilog=true) where {T}
    vshow.(x, systemverilog=systemverilog)
end

"for documentation of structs."
function showfield(t)
    txt = string(t, "(")
    for (uno, dos) in zip(fieldnames(t), t.types)
        txt *= string(uno, "::", dos, ", ")
    end

    txt = string(rstrip(txt, [' ', ',']), ")")
    txt
end