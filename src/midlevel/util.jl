function wirenamemodgen(lay::Midlayer)
    x -> string(x, "_", getname(lay))
end