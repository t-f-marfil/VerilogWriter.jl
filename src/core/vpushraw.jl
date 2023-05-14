function vpush!(coll::Decls, x::Onedecl...)
    push!(coll.val, x...)
end

function vpush!(coll::Ports, x::Oneport...)
    push!(coll.val, x...)
end

function vpush!(coll::Parameters, x::Oneparam...)
    push!(coll.val, x...)
end

function vpush!(coll::Localparams, x::Onelocalparam...)
    push!(coll.val, x...)
end

function vpush!(coll::T, x::T...) where {T <: Union{Decls, Ports, Parameters, Localparams}}
    for v in x 
        vpush!(coll, v.val...)
    end
end


function vpush!(coll::Vmodule, x::Vmodinst...)
    push!(coll.insts, x...)
end

function vpush!(coll::Vmodule, x::Assign...)
    push!(coll.assigns, x...)
end

function vpush!(coll::Vmodule, x::Alwayscontent...)
    push!(coll.always, x...)
end

function vpush!(coll::Vmodule, x::Oneparam...)
    vpush!(coll.params, x...)
end

function vpush!(coll::Vmodule, x::Oneport...)
    vpush!(coll.ports, x...)
end

function vpush!(coll::Vmodule, x::Onelocalparam...)
    vpush!(coll.lparams, x...)
end

function vpush!(coll::Vmodule, x::Onedecl...)
    vpush!(coll.decls, x...)
end

function vpush!(coll::Vmodule, x::T...) where {T <: Union{Decls, Ports, Parameters, Localparams}}
    for v in x 
        vpush!(coll, v.val...)
    end
end

function vpush!(coll::Vmodule, x::FSM...)
    for m in x
        vpush!(coll, fsmconv(Onedecl, m))
        vpush!(coll, fsmconv(Localparams, m))
        vpush!(coll, fsmconv(Alwayscontent, m))
    end
end

function vpush!(coll::Vmodule, x::Vector{T}...) where {T}
    for v in x 
        vpush!(coll, v...)
    end
end
