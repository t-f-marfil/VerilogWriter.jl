function Base.broadcastable(x::Midlayer)
    return Ref(x)
end