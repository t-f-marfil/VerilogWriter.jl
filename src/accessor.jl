function getname(x::T) where {T <: Union{Wireexpr, Oneport, Vmodule}}
    x.name 
end

function getname(x::Midlayer)
    getname(x.vmod)
end
