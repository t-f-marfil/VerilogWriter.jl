module Core

macro exportCore()
    quote
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

        export
            dumpMemfile

        # Vmodgraph
        export
            Vmodgraph, Layerconn, @pconnect, dotgen, layer2vmod!

        export
            uartRecv, uartSend

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
            WidthInferenceStatus, widthInferenceCompleted, widthInferenceMadeProgress, throwIfInferenceIsIncomplete

        export 
            FSM, @FSM, fsmconv, transadd!, @tstate, transcond

        export
            getname, getwidth, getsensitivity, getifcont,
            getdirec, getports, vrename, renamedPorts

        export addAxiLitePort!, generateAxiLitePort

        export VerilatorOption, verilatorSimrun, acceptableInVerilatorTest

        export showfield

        # export methods needed only for testing
        export @testonlyexport
    end
end

@exportCore

# order in which files below are included matters,
# vconstructors should be included before contructors are used
const pathbasic = [
    "testonlyexport.jl",

    "vstructs.jl",

    "baseutils.jl",
    "textutils.jl",
    "vstructhandlers.jl",
    "vconstructors.jl",
    "rawparser.jl",
    "alwaysinference.jl",
    "paramsolve.jl", 
    "vopoverloads.jl", 
    "fsm.jl", 
    "autoreset.jl",
    "unionfind.jl",
    "widthinference.jl", 
    "vstring.jl",
    "vpush.jl", 
    "accessor.jl",
    "verilator.jl",

    "vmodgraph.jl",

    "uart.jl",

    "axi.jl",
    "memfile.jl",

    "patch/exportPatch.jl",
    "patch/stdpatch.jl",
    "patch/ram.jl",
    "uartDebug/ascii.jl",
]

for p in pathbasic
    include(joinpath(@__DIR__, p))
end

@exportPatch
@exportUartDebug

end