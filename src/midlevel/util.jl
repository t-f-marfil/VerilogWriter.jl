function wirenamemodgen(lay::Midlayer)
    x -> string(x, "_", getname(lay))
end

function vmerge(x::Layerconn...)
    return Layerconn(vcat([[j for j in i.ports] for i in x]...))
end