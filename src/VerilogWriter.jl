module VerilogWriter

export 
    showfield, vshow,
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
    roneblock, always, @roneblock, @always

export 
    ifadd!

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
