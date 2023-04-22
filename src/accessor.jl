function getname(x::Wireexpr)
    x.name 
end


function getname(x::Midlayer)
    x.vmod.name 
end
