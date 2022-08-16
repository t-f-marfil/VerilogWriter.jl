# only used when constructing structs from 
# each constructors.

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

function binopoverload()
    for op in keys(wbinopdict)
        if !(op in noJuliaop)
            fovload = """
            function Base.:($(wbinopdict[op]))(uno::Wireexpr, dos::Wireexpr)
                return Wireexpr($(string(op)), uno, dos)
            end
            """
            eval(Meta.parse(fovload))
        end
    end
end

binopoverload()
