module VerilogWriter

include("includedeps.jl")

export 
    # showfield, 
    vshow

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
    @oneport,
    wireexpr, @wireexpr,
    decloneline, decls, @decloneline, @decls,
    # oneblock, 
    ifcontent, 
    # ralways, 
    always, combffsplit,
    # @oneblock, 
    @ifcontent, 
    @alassign_comb, @alassign_ff,
    @always,
    @cpalways,
    @ralways

export 
    paramsolve, paramcalc

export 
    ifadd!, addatype!,
    invport, invports, 
    # declmerge,
    @sym2wire,
    alloutreg, alloutwire, alloutlogic,
    naiveinst,
    wrappergen,
    @preport,
    vfinalize,
    vexport

export 
    vpush!

# verilog debug
export
    debugAdd!, VerilatorOption,
    verilatorSimrun

# vpatch
export 
    PrivateWireNameGen, Vpatch,
    posedgePrec, bitbundle, nonegedge, posedgeSync

export
    wireextract, wireextract!,
    lhsextract, lhsunify, autoreset, autoreset!, isreset,
    defclk, defrst,
    Vmodenv, autodecl, autodecl_core
    #  mergedeclenv

export 
    FSM, @FSM, fsmconv, transadd!, @tstate, transcond

export
    getname, getwidth, getsensitivity, getifcont,
    getdirec, getports, vrename

export showfield

macro listtestonly(args)
    strs = Symbol[]
    for arg in args.args 
        if arg isa Symbol 
            push!(strs, arg)
        else
            arg.head == :macrocall || error("$(arg) is not accepted")
            # macroname
            push!(strs, arg.args[1])
        end
    end
    :($([string(s) for s in strs]))
end

const testonlyvars = @listtestonly (
    # showfield,
    
    oneblock, @oneblock, 
    ralways
)
include("testonlyexport.jl")


# priority for files declaring `struct`s

include("codegenfunc.jl")
include("includestructs.jl")

for myenum in [Portdirec, Wiretype, Wireop, Atype, Edge]
    for i in instances(myenum)
        eval(:(export $(Symbol(i))))
    end
end

# include("includecore.jl")
# include(joinpath(@__DIR__, "midlevel", "main.jl"))
libs = [
    "core",
    "midlevel"
]
for lib in libs
    include(joinpath(@__DIR__, lib, "main.jl"))
end


include("exportMidlevel.jl")

end
