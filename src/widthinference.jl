"""
    wireextract(x::Ifcontent)

Extract wireexprs from `x::Ifcontent` preserving 
equality constraints of wires.
"""
function wireextract(x::Ifcontent)
    declonly = Wireexpr[]
    equality = Tuple{Wireexpr, Wireexpr}[]

    wireextract!(x, declonly, equality)
    declonly, equality
end

"""
    wireextract!(x::Ifcontent, declonly, equality)

Helper function for [`wireextract`](@ref). 
Add constraints to `declonly` and `equality`.
"""
function wireextract!(x::Ifcontent, declonly, equality)
    for i in x.assigns 
        push!(equality, (i.lhs, i.rhs))
    end

    for i in x.ifelseblocks
        push!(declonly, i.conds...)
        map(y -> wireextract!(y, declonly, equality), i.contents)
    end

    for i in x.cases 
        push!(declonly, i.condwire)
        for (uno, dos) in i.conds 
            push!(declonly, uno)
            wireextract!(dos, declonly, equality)
        end
    end
end