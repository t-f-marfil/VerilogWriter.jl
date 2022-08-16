module VerilogWriter

export 
    showfield, vshow

export
    Oneparam, Parameters,
    Portdirec, Wiretype,
    Oneport, Ports,
    Wireop,
    Wireexpr,
    Atype,
    Alassign, Ifcontent, Case, Ifelseblock, Edge, Alwayscontent,
    Assign,
    Onedecl, Decls, 
    Vmodule

export
    portoneline, ports, @portoneline, @ports,
    wireexpr, @wireexpr,
    decloneline, decls, @decloneline, @decls,
    oneblock, ifcontent, ralways, always, @oneblock, @ifcontent, @always, @ralways

export 
    ifadd!, 
    invport, invports

include("vstructs.jl")
include("baseutils.jl")
include("textutils.jl")
include("vstructhandlers.jl")
include("vconstructors.jl")
include("vstring.jl")
include("rawparser.jl")
include("alwaysinference.jl")

include("vopoverloads.jl")

include("fsm.jl")

end
