function getname(x::T) where {T <: Union{Wireexpr, Oneport, Onedecl, Vmodule}}
    x.name 
end

function getwidth(x::T) where {T <: Union{Oneport, Onedecl}}
    return x.width
end

function getsensitivity(x::Alwayscontent)
    return x.sens
end

function getwiretype(x::Oneport)
    return x.wtype
end

function getifcont(x::Alwayscontent)
    return x.content
end

function getdirec(x::Oneport)
    return x.direc
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