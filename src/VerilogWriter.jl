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
    Vmodule

export
    oneparam, parameters, @oneparam, @parameters,
    portoneline, ports, @portoneline, @ports,
    onelocalparam, localparams, @onelocalparam, @localparams,
    wireexpr, @wireexpr,
    decloneline, decls, @decloneline, @decls,
    oneblock, ifcontent, ralways, always, @oneblock, @ifcontent, @always, @ralways

export 
    ifadd!, 
    invport, invports,
    lhsextract, lhsunify, autoreset,
    Vmodenv, autodecl

export 
    FSM, fsmconv, transadd!

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
include("vstring.jl")
include("rawparser.jl")
include("alwaysinference.jl")

include("vopoverloads.jl")

include("fsm.jl")

include("autoreset.jl")
include("widthinference.jl")

end
