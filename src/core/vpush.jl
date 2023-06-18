"""
    vpush!(coll::Decls, x::Onedecl...)

vpush! method, add Onedecl to Decls.
"""
function vpush!(coll::Decls, x::Onedecl...)
    push!(coll.val, x...)
end

"""
    vpush!(coll::Ports, x::Oneport...)

vpush! method, add Oneport to Ports.
"""
function vpush!(coll::Ports, x::Oneport...)
    push!(coll.val, x...)
end

"""
    vpush!(coll::Parameters, x::Oneparam...)

vpush! method, add Oneparam to Parameters.
"""
function vpush!(coll::Parameters, x::Oneparam...)
    push!(coll.val, x...)
end

"""
    vpush!(coll::Localparams, x::Onelocalparam...)

vpush! method, add Onelocalparam to Localparams.
"""
function vpush!(coll::Localparams, x::Onelocalparam...)
    push!(coll.val, x...)
end

"""
    vpush!(coll::T, x::T...) where {T <: Union{Decls, Ports, Parameters, Localparams}}

vpush! method, add T to T.
"""
function vpush!(coll::T, x::T...) where {T <: Union{Decls, Ports, Parameters, Localparams}}
    for v in x 
        vpush!(coll, v.val...)
    end
end


"""
    vpush!(coll::Vmodule, x::Vmodinst...)

vpush! method, add Vmodinst to Vmodule.
"""
function vpush!(coll::Vmodule, x::Vmodinst...)
    push!(coll.insts, x...)
end

"""
    vpush!(coll::Vmodule, x::Assign...)

vpush! method, add Assign to Vmodule.
"""
function vpush!(coll::Vmodule, x::Assign...)
    push!(coll.assigns, x...)
end

"""
    vpush!(coll::Vmodule, x::Alwayscontent...)

vpush! method, add Alwayscontent to Vmodule.
"""
function vpush!(coll::Vmodule, x::Alwayscontent...)
    push!(coll.always, x...)
end

"""
    vpush!(coll::Vmodule, x::Oneparam...)

vpush! method, add Oneparam to Vmodule.
"""
function vpush!(coll::Vmodule, x::Oneparam...)
    vpush!(coll.params, x...)
end

"""
    vpush!(coll::Vmodule, x::Oneport...)

vpush! method, add Oneport to Vmodule.
"""
function vpush!(coll::Vmodule, x::Oneport...)
    vpush!(coll.ports, x...)
end

"""
    vpush!(coll::Vmodule, x::Onelocalparam...)

vpush! method, add Onelocalparam to Vmodule.
"""
function vpush!(coll::Vmodule, x::Onelocalparam...)
    vpush!(coll.lparams, x...)
end

"""
    vpush!(coll::Vmodule, x::Onedecl...)

vpush! method, add Onedecl to Vmodule.
"""
function vpush!(coll::Vmodule, x::Onedecl...)
    vpush!(coll.decls, x...)
end

"""
    vpush!(coll::Vmodule, x::T...) where {T <: Union{Decls, Ports, Parameters, Localparams}}

vpush! method, add T to Vmodule.
"""
function vpush!(coll::Vmodule, x::T...) where {T <: Union{Decls, Ports, Parameters, Localparams}}
    for v in x 
        vpush!(coll, v.val...)
    end
end

"""
    vpush!(coll::Vmodule, x::FSM...)

vpush! method, add FSM to Vmodule.
"""
function vpush!(coll::Vmodule, x::FSM...)
    for m in x
        vpush!(coll, fsmconv(Onedecl, m))
        vpush!(coll, fsmconv(Localparams, m))
        vpush!(coll, fsmconv(Alwayscontent, m))
    end
end

"""
    vpush!(coll::Vmodule, x::Vector{T}...) where {T}

vpush! method, add Vector to Vmodule.
"""
function vpush!(coll::Vmodule, x::Vector{T}...) where {T}
    for v in x 
        vpush!(coll, v...)
    end
end

function vpush!(coll::Vmodule)
    return nothing
end

function vpush!(coll::Vmodule, x::Vmodule...)
    fields = filter(x -> x != :name, fieldnames(Vmodule))
    for m in x
        vpush!.(coll, getfield.(m, fields))
    end
    return nothing
end