function Base.convert(::Type{Lhs}, x::Wireexpr)
    return Lhs(x.name, x.msb, x.lsb)
end

"""
ifadd!(ifblock::Ifelseblock, cond, ifcont)

Add `cond` and `ifcont` at the head of `ifblock`.

Intended to add if-clause to `Ifelseblock` constructed
from elseif-clause (because elseif-clause often parses first).
"""
function ifadd!(ifblock::Ifelseblock, cond, ifcont)
pushfirst!(ifblock.conds, cond)
pushfirst!(ifblock.contents, ifcont)
end

function addatype!(x::Alwayscontent)
    x.atype = atypealways(x)
    return x 
end