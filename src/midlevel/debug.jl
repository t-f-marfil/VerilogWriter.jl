function debugNamegen(s::AbstractString)
    return string("_debug_", s)
end
"""
    debugAdd!(m::Midmodule, n::AbstractString, wid=-1)

Add to `m::Midmodule` a port for debugging.
"""
function debugAdd!(m::Midmodule, n::AbstractString, wid=-1)
    dname = debugNamegen(n)
    dbgpdecl = @oneport @out @logic $wid $dname
    dbgal = @always $dname = $n

    vpush!.(m, (dbgpdecl, dbgal))
    return @oneport @out @logic $wid $(wirenamemodgen(getvmod(m))(dname))
end