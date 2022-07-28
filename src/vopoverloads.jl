# only used when constructing structs from 
# each constructors.

# function Base.convert(::Type{Lhs}, x::Wireexpr)
#     return Lhs(x.name, x.msb, x.lsb)
# end

function unaopoverload()
    for op in keys(wunaopdict)
        fovload = """
        function Base.:$(wunaopdict[op])(uno::Wireexpr)
            return Wireexpr($(string(op)), uno)
        end
        """
        eval(Meta.parse(fovload))
    end
end

unaopoverload()

# function Base.:~(uno::Wireexpr)
#     return Wireexpr(neg, uno)
# end

function binopoverload()
    for op in keys(wbinopdict)
        fovload = """
        function Base.:$(wbinopdict[op])(uno::Wireexpr, dos::Wireexpr)
            return Wireexpr($(string(op)), uno, dos)
        end
        """
        eval(Meta.parse(fovload))
    end
end

binopoverload()

# function Base.:+(uno::Wireexpr, dos::Wireexpr)
#     return Wireexpr(add, uno, dos)
# end

# function Base.:<<(uno::Wireexpr, dos::Wireexpr)
#     return Wireexpr(lshift, uno, dos)
# end

# function Base.:>>(uno::Wireexpr, dos::Wireexpr)
#     return Wireexpr(rshift, uno, dos)
# end