"""
    atypealways(x::T) where {T <: Union{Alwayscontent, Ifcontent}}

Infer type of always-block (into always_ff or always_comb).

Duck typing with `Alwayscontent` and `Ifcontent` is done because
both have in common `assigns` and `ifelseblocks` as its fields.
"""
function atypealways(x::T) where {T <: Union{Alwayscontent, Ifcontent}}
    tassigns = atypealways(x.assigns)
    tifblocks = atypealways(x.ifelseblocks)

    # unknown occur when either list is empty
    ans = aunknown
    if tassigns == aunknown 
        ans = tifblocks
    elseif tifblocks == aunknown
        ans = tassigns 
    else
        if tassigns != tifblocks 
            throw(error("discrepancy in atypes, \
assigns:$(tassigns) <=> ifelseblocks:$(tifblocks)."))
        end 

        ans = tassigns 
    end

    return ans 
end

"""
    atypealways(x::Vector{T}) where {T}

Infer type of always-block from a vector of `T`.
"""
function atypealways(x::Vector{T}) where {T}
    if length(x) == 0 
        ans = aunknown 
    else
        ans = atypealways(x[1])
        for i in 2:length(x)
            ansnow = atypealways(x[i])
            if ans != ansnow 
                e = error("atype discrepancy occured in \n$(string(x[i])).")
                throw(e)
            end
        end
    end

    return ans 
end

function atypealways(x::Alassign)
    return x.atype 
end

function atypealways(x::Ifelseblock)
    return atypealways(x.contents)
end

