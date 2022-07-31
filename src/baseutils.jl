function Base.convert(::Type{String}, x::Symbol)
    string(x)
end

"""
    Base.iterate(x::Wireexpr)

Needed to deal with some return value that may be 
either Wireexpr or Vector{Wireexpr}.
May cause type instability, but it is already inevitable
in parsing AST.
"""
function Base.iterate(x::Wireexpr)
    (x, nothing)
end

function Base.iterate(x::Wireexpr, ::Nothing)
    nothing
end