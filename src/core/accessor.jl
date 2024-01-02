function getname(x::T) where {T <: Union{Wireexpr, Oneport, Vmodule}}
    x.name 
end

function getwidth(x::T) where {T <: Union{Oneport}}
    return x.width
end

function getsensitivity(x::Alwayscontent)
    return x.sens
end

function getifcont(x::Alwayscontent)
    return x.content
end

function getdirec(x::Oneport)
    return x.direc
end

function isOutput(x::Oneport)
    return x.direc == pout
end
function isInput(x::Oneport)
    return x.direc == pin
end

function getports(x::Vmodule)
    return x.ports
end

macro vrenamehelp(x, nn)
    fields = fieldnames(Oneport)
    :name in fields || error("field 'name' no longer exists")
    quote 
        Oneport(
            $([fn == :name ? :($(esc(nn))) : :($(esc(x)).$(fn)) for fn in fields]...)
        )
    end
end

function vrename(x::Oneport, nn::String)
    @vrenamehelp(x, nn)
end