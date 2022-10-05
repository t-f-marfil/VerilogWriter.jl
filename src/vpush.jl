# Generated from "vpushgen.jl", do not edit manually,
# edit "vpushraw.jl." instead

"""
    vpush!(coll::Decls, x::Onedecl...)

vpush! method, add Onedecl to Decls.
"""
function vpush!(coll::Decls, x::Onedecl...)
    #= none:1 =#
    #= none:2 =#
    push!(coll.val, x...)
end

"""
    vpush!(coll::Ports, x::Oneport...)

vpush! method, add Oneport to Ports.
"""
function vpush!(coll::Ports, x::Oneport...)
    #= none:1 =#
    #= none:2 =#
    push!(coll.val, x...)
end

"""
    vpush!(coll::Parameters, x::Oneparam...)

vpush! method, add Oneparam to Parameters.
"""
function vpush!(coll::Parameters, x::Oneparam...)
    #= none:1 =#
    #= none:2 =#
    push!(coll.val, x...)
end

"""
    vpush!(coll::Localparams, x::Onelocalparam...)

vpush! method, add Onelocalparam to Localparams.
"""
function vpush!(coll::Localparams, x::Onelocalparam...)
    #= none:1 =#
    #= none:2 =#
    push!(coll.val, x...)
end

"""
    vpush!(coll::T, x::T...) where T <: Union{Decls, Ports, Parameters, Localparams}

vpush! method, add T to T.
"""
function vpush!(coll::T, x::T...) where T <: Union{Decls, Ports, Parameters, Localparams}
    #= none:1 =#
    #= none:2 =#
    for v = x
        #= none:3 =#
        vpush!(coll, v.val...)
    end
end

"""
    vpush!(coll::Vmodule, x::Vmodinst...)

vpush! method, add Vmodinst to Vmodule.
"""
function vpush!(coll::Vmodule, x::Vmodinst...)
    #= none:1 =#
    #= none:2 =#
    push!(coll.insts, x...)
end

"""
    vpush!(coll::Vmodule, x::Assign...)

vpush! method, add Assign to Vmodule.
"""
function vpush!(coll::Vmodule, x::Assign...)
    #= none:1 =#
    #= none:2 =#
    push!(coll.assigns, x...)
end

"""
    vpush!(coll::Vmodule, x::Alwayscontent...)

vpush! method, add Alwayscontent to Vmodule.
"""
function vpush!(coll::Vmodule, x::Alwayscontent...)
    #= none:1 =#
    #= none:2 =#
    push!(coll.always, x...)
end

"""
    vpush!(coll::Vmodule, x::Oneparam...)

vpush! method, add Oneparam to Vmodule.
"""
function vpush!(coll::Vmodule, x::Oneparam...)
    #= none:1 =#
    #= none:2 =#
    vpush!(coll.params, x...)
end

"""
    vpush!(coll::Vmodule, x::Oneport...)

vpush! method, add Oneport to Vmodule.
"""
function vpush!(coll::Vmodule, x::Oneport...)
    #= none:1 =#
    #= none:2 =#
    vpush!(coll.ports, x...)
end

"""
    vpush!(coll::Vmodule, x::Onelocalparam...)

vpush! method, add Onelocalparam to Vmodule.
"""
function vpush!(coll::Vmodule, x::Onelocalparam...)
    #= none:1 =#
    #= none:2 =#
    vpush!(coll.lparams, x...)
end

"""
    vpush!(coll::Vmodule, x::Onedecl...)

vpush! method, add Onedecl to Vmodule.
"""
function vpush!(coll::Vmodule, x::Onedecl...)
    #= none:1 =#
    #= none:2 =#
    vpush!(coll.decls, x...)
end

"""
    vpush!(coll::Vmodule, x::T...) where T <: Union{Decls, Ports, Parameters, Localparams}

vpush! method, add T to Vmodule.
"""
function vpush!(coll::Vmodule, x::T...) where T <: Union{Decls, Ports, Parameters, Localparams}
    #= none:1 =#
    #= none:2 =#
    for v = x
        #= none:3 =#
        vpush!(coll, v.val...)
    end
end

"""
    vpush!(coll::Vmodule, x::FSM...)

vpush! method, add FSM to Vmodule.
"""
function vpush!(coll::Vmodule, x::FSM...)
    #= none:1 =#
    #= none:2 =#
    for m = x
        #= none:3 =#
        vpush!(coll, fsmconv(Onedecl, m))
        #= none:4 =#
        vpush!(coll, fsmconv(Localparams, m))
        #= none:5 =#
        vpush!(coll, fsmconv(Alwayscontent, m))
    end
end

