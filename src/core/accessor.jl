function getname(x::T) where {T <: Union{Wireexpr, Oneport, Vmodule}}
    x.name 
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