"""
    Lhs(n::String, msb::Int)

Slice one bit of wire `n`.
"""
Lhs(n::String, msb::Int) = Lhs(n, msb, msb)
"""
    Lhs(n::String)

Case where no slice is needed (use all bits in `n`).
"""
Lhs(n::String) = Lhs(n, -1)

"""
    Wireexpr(n::String, msb::Int, lsb::Int)

Slice of `n` from `msb` to `lsb`.
"""
Wireexpr(n::String, msb::Int, lsb::Int) = Wireexpr(id, n, msb, lsb, [], -1, -1)
"""
    Wireexpr(n:String, msb::Int)

Get one bit at `msb` from `n`.
"""
Wireexpr(n::String, msb::Int) = Wireexpr(n, msb, msb)
"""
    Wireexpr(n::String)

Case where no slice is needed.
"""
Wireexpr(n::String) = Wireexpr(n, -1)
"""
    Wireexpr()

Create empty expression.
"""
Wireexpr() = Wireexpr("")

Wireexpr(op::Wireop, v::Vector{Wireexpr}) = Wireexpr(op, "", -1, -1, v, -1, -1)
Wireexpr(op::Wireop, uno::Wireexpr) = Wireexpr(op, [uno])
Wireexpr(op::Wireop, uno::Wireexpr, dos::Wireexpr) = Wireexpr(op, [uno, dos])

Alassign(lhs, rhs) = Alassign(lhs, rhs, aunknown)

Ifcontent() = Ifcontent([], [])

Ifelseblock() = Ifelseblock([], [])
Ifelseblock(cond::Wireexpr, ifcont::Ifcontent) = Ifelseblock([cond], [ifcont])
Ifelseblock(cond::Wireexpr, ifcont::Ifcontent, elsecont::Ifcontent) = Ifelseblock([cond], [ifcont, elsecont])

Alwayscontent(atype::Atype) = Alwayscontent(atype, posedge, Wireexpr(), [], [])
Alwayscontent(assigns::Vector{Alassign}, ifblocks::Vector{Ifelseblock}) = Alwayscontent(aunknown, unknownedge, Wireexpr(), assigns, ifblocks)
Alwayscontent(assign::Alassign) = Alwayscontent([assign], Ifelseblock[])
Alwayscontent(ifblock::Ifelseblock) = Alwayscontent(Alassign[], [ifblock])
