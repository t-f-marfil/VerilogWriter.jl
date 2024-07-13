"struct to contain connection info."
struct Layerconn
    ports::Vector{Pair{String, String}}
end

"struct to store and connect Layerconn objects."
struct Vmodgraph
    edges::Dict{Pair{Vmodule, Vmodule}, Layerconn}
    vmods::Set{Vmodule}
end

Vmodgraph() = Vmodgraph(Dict{Pair{Vmodule, Vmodule}, Layerconn}(), Set{Vmodule}())

const defaultlports = [
    (@ports (
        @in CLK, RST
    ))...
]

function symPairToStrPair(ast)
    ast.args[1] == :(=>) || error("$(ast.args[1]) is not acceptable in tuple expression")
    return :($(string(ast.args[2])) => $(string(ast.args[3])))
end
macro pconnect(arg)
    if arg.head == :call
        return :([$(symPairToStrPair(arg))])
    else
        arg.head == :tuple || error("arg.head should be tuple, but actually $(arg.head)")
        return :([$([symPairToStrPair(e) for e in arg.args]...)])
    end
end

Layerconn(x::Layerconn) = x
Layerconn() = Layerconn(Vector{Pair{String, String}}())


function (cls::Vmodgraph)(p::Pair{Vmodule, Vmodule}, args...)
    dfp, ufp = p
    isnothing(get(cls.edges, (dfp => ufp), nothing)) || error("pair dfp => ufp is already registered")
    push!(cls.edges, (dfp => ufp) => Layerconn(args...))

    push!(cls.vmods, dfp)
    push!(cls.vmods, ufp)
    return nothing
end


"""
    edgepush_dotgen!(iobuf::IOBuffer, edges::D) where {D <: AbstractDict{Pair{Midport, Midport}, Layerconn}}

Helper function for `dotgen`.
"""
function edgepush_dotgen!(iobuf::IOBuffer, edges)
    for ((n1, n2), ninfo) in edges 
        write(iobuf, "$(getname(n1)) -> $(getname(n2));\n")
    end
    return 
end

"""
    dotgen(lay::Mmodgraph; dpi=96)

Convert `Mmodgraph` object to a graph written in DOT language.
"""
function dotgen(lay::Vmodgraph; dpi=96)
    sbuf = IOBuffer()
    
    for v in sort([v for v in lay.vmods], by=x->getname(x))
        write(sbuf, "$(getname(v)) [shape=oval];\n")
    end

    nodeattr = String(take!(sbuf))

    edgepush_dotgen!(sbuf, lay.edges)

    edgeattr = String(take!(sbuf))

    txt = """digraph{
    rankdir = LR;
    dpi = $(dpi);

    $(rstrip(nodeattr))
    $(rstrip(edgeattr))
    }"""

    txt
end


function addCommonPortEachLayer(x::Vmodgraph)
    for vm in x.vmods 
        for p in commonports
            if !(p in getports(vm))
                vpush!(vm, p)
            end
        end
    end

    return nothing
end


function addPortEachLayer(x::Vmodgraph)
    addCommonPortEachLayer(x)
    # addIlPortEachLayer(x)
end

function wireAddSuffix(wirename::String, vsuffix::Vmodule)
    Wireexpr(string(wirename, "_", getname(vsuffix)))
end

# using ..Core: wirenamemodgen

"""
    outerportnamegen(portname::String, mlay::Midmodule)

Given the name of a port and the vmodule object the port belongs to,
return the name of a wire which is connected to the port at the top module.
"""
function outerportnamegen(portname::String, vmod)
    wirenamemodgen(vmod)(portname)
end

function portmatch_uc(a::Oneport, b::Oneport)
    directest = getdirec(a) == getdirec(b)
    # width may not have been inferred at this point
    # widthtest = isequal(getwidth(a), getwidth(b)) # comparing wireexpr
    nametest = getname(a) == getname(b)

    # return directest & widthtest & nametest
    return directest & nametest
end

"""
    unconnectedports_mlay(x::Mmodgraph)

Using data in `x::Mmodgraph`, detect unconnected ports
in submodules.
"""
function unconnectedports_mlay(x::Vmodgraph)

    # try detecting unconnected ports 
    pconnected = Dict{Vmodule, Dict{Oneport, Bool}}([
        vmod => Dict([p => false for p in vmod.ports]) 
        for vmod in x.vmods
    ])

    for ((dfp::Vmodule, ufp::Vmodule), conn) in x.edges 
        for (_ppre, _ppost) in conn.ports
            ppre = @oneport @out -1 $_ppre
            ppost = @oneport @in -1 $_ppost
            # update pconnected
            # ppre in keys(pconnected[uno])
            prefil = [filter(p -> portmatch_uc(ppre, p[1]), pconnected[dfp])...]
            (length(prefil) > 0 && getdirec(ppre) == pout) || error("$(string(ppre)) not in port $(getname(dfp)) and should be output with the same width")
            # should be length 1
            pconnected[dfp][prefil[][1]] = true

            # ppost in keys(pconnected[dos])
            postfil = [filter(p -> portmatch_uc(ppost, p[1]), pconnected[ufp])...]
            (length(postfil) > 0 && getdirec(ppost) == pin) || error("$(string(ppost)) not in port $(getname(ufp)) and should be input with the same width")
            pconnected[ufp][postfil[][1]] = true

        end
    end

    [vmod => filter(k -> (!d[k] & !(k in commonports)), keys(d)) for (vmod, d) in pconnected]
end

"""
    layerconnInstantiate_mlay!(v::Vmodule, x::Mmodgraph)

Push data in Layerconn objects into Vmodule in a form of Verilog codes.

Currently only adding to the top level Vmodule (v) always_comb statements that connects upstream ports to 
downstream ports.
"""
function layerconnInstantiate_mlay!(v::Vmodule, x::Vmodgraph)
    mvec = Vmodule[]
    qvec = Alassign[]
    
    for ((uno::Vmodule, dos::Vmodule), conn) in x.edges 
        for (ppre, ppost) in conn.ports
            # below means
            # always_comb begin
            #   <ppost_name>_<dos_name> = <ppre_name>_<uno_name>
            # end
            # at the top level module
            postwire = wireAddSuffix(ppost, dos)
            prewire = wireAddSuffix(ppre, uno)
            q = @alassign_comb $postwire = $prewire
            push!(qvec, q)
        end
    end

    alans = Alwayscontent(comb, qvec)
    vpush!(v, alans)
    
    return nothing
end


"""
    bypassUnconnected_mlay!(v::Vmodule, x::Mmodgraph)

Add to the top-level module ports that are connected to counterparts of 
submodules, which are not connected to ports of other `Midmodule` objects.
"""
function bypassUnconnected_mlay!(v::Vmodule, x::Vmodgraph)
    unconnectedvec::Vector{Pair{Vmodule, Set{Oneport}}} = unconnectedports_mlay(x)

    npvec = Vector{Oneport}(undef, sum([length(s) for (_, s) in unconnectedvec]))
    ci = 1
    for (vmod, d) in unconnectedvec
        for p in d
            nname = outerportnamegen(getname(p), vmod)
            newport = vrename(p, nname)

            npvec[ci] = newport
            ci += 1
        end
    end

    vpush!(v, alloutwire(Ports(npvec)))

    return nothing
end

"CLK and RST"
const commonports = (x -> Oneport(pin, getname(x))).(
    [defclk, defrst]
)

"""
    connectCommonPorts_mlay!(v::Vmodule, x::Mmodgraph)

Connect ports which all submodules have in common to the 
proper ports in the top module.
"""
function connectCommonPorts_mlay!(v::Vmodule, x::Vmodgraph)

    vpush!(v, commonports...)

    for vmod in x.vmods 
        qvec = Vector{Alassign}(undef, length(commonports))
        for (ind, prt::Oneport) in enumerate(commonports)
            f = wirenamemodgen(vmod)
            q = @alassign_comb (
                $(
                    Symbol(f(getname(prt)))
                ) = $(
                    Symbol(getname(prt))
                )
            )
            qvec[ind] = q
        end
        vpush!(v, Alwayscontent(comb, qvec))
    end

    return nothing
end

# using ..Core: vinstnamemod

"""
    layer2vmod!(x::Mmodgraph; name = "Layers")::Vector{Vmodule}

Generate a list of `Vmodule` objects from `Mmodgraph`.

`x` may change its content through the evaluation.
"""
function layer2vmod!(x::Vmodgraph; name = "Layers")::Vector{Vmodule}
    # toplevel module 
    v = Vmodule(name)

    # generate always_comb that connects ports 
    # as described in Layerconn
    # note that 2 function calls below do not modify 
    # Vmodules in each midlayer objects
    # dbufs = layerconnInstantiate_mlay!(v, x)
    layerconnInstantiate_mlay!(v, x)
     
    # connect unconnected ports to outer ports
    # currently doing this before `vfinalize`,
    # port of unknown width should not exist at this time
    bypassUnconnected_mlay!(v, x)

    connectCommonPorts_mlay!(v, x)

    # reflect data in layerconn to Vmodule objects
    addPortEachLayer(x)

    # execute below after connecting modules.
    # instantiate every layer
    for vmod in x.vmods 
        vpush!(v, vinstnamemod(vmod))
    end

    # return [v; [lay.vmod for lay in x.layers]; hubs]
    return [v; [v for v in x.vmods]]
end


macro layerconn(arg)
    v = Vector{Pair{Oneport, Oneport}}()
    if arg.head == :call 
        v = [((_, x, y) = arg.args; Oneport(pout, string(x)) => Oneport(pin, string(y)))]
    else
        arg.head == :tuple || error("unknown arg $(dump(arg)).")
        v = [((_, x, y) = expr.args; Oneport(pout, string(x)) => Oneport(pin, string(y))) for expr in arg.args]
    end
    Layerconn(OrderedSet(v))
end
