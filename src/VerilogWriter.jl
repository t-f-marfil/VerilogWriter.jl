module VerilogWriter

export 
    showfield, vshow

export
    Oneparam, Parameters,
    Portdirec, Wiretype,
    Oneport, Ports,
    Onelocalparam, Localparams,
    Wireop,
    Wireexpr,
    Atype, Sensitivity,
    Alassign, Ifcontent, Case, Ifelseblock, Edge, Alwayscontent,
    Assign,
    Onedecl, Decls,
    Vmodinst, 
    Vmodule

export
    oneparam, parameters, @oneparam, @parameters,
    portoneline, ports, @portoneline, @ports,
    onelocalparam, localparams, @onelocalparam, @localparams,
    wireexpr, @wireexpr,
    decloneline, decls, @decloneline, @decls,
    oneblock, ifcontent, ralways, always, @oneblock, @ifcontent, @always, @ralways

export 
    paramsolve, paramcalc

export 
    ifadd!, 
    invport, invports, declmerge

export
    lhsextract, lhsunify, autoreset,
    Vmodenv, autodecl

export 
    FSM, @FSM, fsmconv, transadd!, @tstate, transcond

# priority for files declaring `struct`s

include("codegenfunc.jl")
include("vstructs.jl")

for myenum in [Portdirec, Wiretype, Wireop, Atype, Edge]
    for i in instances(myenum)
        eval(:(export $(Symbol(i))))
    end
end

include("baseutils.jl")
include("textutils.jl")
include("vstructhandlers.jl")
include("vconstructors.jl")
include("rawparser.jl")
include("alwaysinference.jl")
include("paramsolve.jl")

include("vopoverloads.jl")

include("fsm.jl")

include("autoreset.jl")
include("widthinference.jl")

include("vstring.jl")


end
