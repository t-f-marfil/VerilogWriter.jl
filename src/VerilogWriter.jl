module VerilogWriter

include("includedeps.jl")

export vshow

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
    Vmodule,
    Readmemh

export pin, pout
export wire, reg, logic
export 
    add, minus, mul, vdiv, lshift, rshift,
    band, bor, bxor,
    neg, uminus, redand, redor, redxor,
    logieq, leq, lt, 
    id, slice, literal, ipselm 
export ff, comb, aunknown
export posedge, negedge, unknownedge

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
    @always, @nralways,
    @cpalways,
    @ralways

export 
    paramsolve, paramcalc

export 
    ifadd!, addatype!,
    invport, invports,
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
    debugAdd!

# vpatch
export 
    PrivateWireNameGen, Vpatch, @vstdpatch,
    posedgePrec, bitbundle, nonegedge, posedgeSync,
    isAtRisingEdge, interceptBuffer, onceHigh, zipSpike

# axi
export
    addAxiLitePort!

export
    wireextract, wireextract!,
    lhsextract, lhsunify, autoreset, autoreset!, isreset,
    defclk, defrst,
    Vmodenv, autodecl, autodeclCore, autodeclVmodlist,
    #  mergedeclenv
    WidthRemainUnresolved, WireWidthConflict, SliceOnTwoDemensionalLogic,
    WidthInfereceStatus, widthInferenceCompleted, widthInferenceMadeProgress, throwIfInferenceIsIncomplete

export 
    FSM, @FSM, fsmconv, transadd!, @tstate, transcond

export
    getname, getwidth, getsensitivity, getifcont,
    getdirec, getports, vrename

export showfield

# export methods needed only for testing
export @testonlyexport
include("testonlyexport.jl")


libs = [
    "core",
    "midlevel"
]
for lib in libs
    include(joinpath(@__DIR__, lib, "main.jl"))
end


include("exportMidlevel.jl")

end
