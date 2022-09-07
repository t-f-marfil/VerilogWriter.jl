# """
#     atypealways(x::T) where {T <: Union{Alwayscontent, Ifcontent}}

# Infer type of always-block (into always_ff or always_comb).

# This is out of date, Alwayscontent now contains Ifcontent.
# # Duck typing with `Alwayscontent` and `Ifcontent` is done because
# # both have in common `assigns` and `ifelseblocks` as its fields.
# """
# function atypealways(x::T) where {T <: Union{Alwayscontent, Ifcontent}}
#     tassigns = atypealways(x.assigns)
#     tifblocks = atypealways(x.ifelseblocks)

#     # unknown occur when either list is empty
#     ans = aunknown
#     if tassigns == aunknown 
#         ans = tifblocks
#     elseif tifblocks == aunknown
#         ans = tassigns 
#     else
#         if tassigns != tifblocks 
#             throw(error("discrepancy in atypes, \
# assigns:$(tassigns) <=> ifelseblocks:$(tifblocks)."))
#         end 

#         ans = tassigns 
#     end

#     return ans 
# end

"""
    atypealways(x::Ifcontent)

Infer type of always-block (into always_ff or always_comb).
"""
function atypealways(x::Ifcontent)
    tassigns = atypealways(x.assigns)
    tifblocks = atypealways(x.ifelseblocks)
    tcases = atypealways(x.cases)

    # unknown occur when both list is empty
    ans = aunknown
    for tnow in (tassigns, tifblocks, tcases)
        if tnow != aunknown
            if ans != aunknown && tnow != ans 
                error("discrepancy in atypes inside ifcontent.")
            end
            ans = tnow 
        end
    end
#     if tassigns == aunknown 
#         ans = tifblocks
#     elseif tifblocks == aunknown
#         ans = tassigns 
#     else
#         if tassigns != tifblocks 
#             throw(error("discrepancy in atypes, \
# assigns:$(tassigns) <=> ifelseblocks:$(tifblocks)."))
#         end 

#         ans = tassigns 
#     end

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
        # ans = atypealways(x[1])
        ans = aunknown
        for i in x
            ansnow = atypealways(i)
            if ansnow != aunknown
                if ans != aunknown && ans != ansnow 
                    error(
                        "atype discrepancy occured in \n\n$(indent(string(i)))\n\n",
                        "full items:\n\n$(indent(reduce(newlineconcat, string.(x))))"
                    )
                end
                ans = ansnow
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

function atypealways(x::Case)
    ifconts = [i[2] for i in x.conds]
    atypealways(ifconts)
end

function atypealways(x::Alwayscontent)
    atypealways(x.content)
end