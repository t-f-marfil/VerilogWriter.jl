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
    Alassign, Ifcontent, Ifelseblock, Edge, Alwayscontent,
    Assign,
    Onedecl, Decls, 
    Vmodule

export
    portoneline, ports, @portoneline, @ports,
    wireexpr, @wireexpr,
    decloneline, decls, @decloneline, @decls,
    oneblock, ralways, always, @oneblock, @always, @ralways

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

end
