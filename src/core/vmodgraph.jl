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
    outerportnamegen(portname::String, mlay)

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

struct TopPortNameCollision{T} <: Exception where {T <: AbstractString}
    names::Vector{T}
    mangledNames::Vector{T}
end
function Base.showerror(io::IO, e::TopPortNameCollision)
    println(io, e.names)
    println(io, e.mangledNames)
end

"""
    bypassUnconnected_mlay!(v::Vmodule, x::Vmodgraph)

Add to the top-level module ports that are connected to counterparts of 
submodules, which are not connected to ports of other `Vmodule` objects.
"""
function bypassUnconnected_mlay!(v::Vmodule, x::Vmodgraph, mangle::Bool)
    unconnectedvec::Vector{Pair{Vmodule, Set{Oneport}}} = unconnectedports_mlay(x)

    npvec = Vector{Oneport}(undef, sum([length(s) for (_, s) in unconnectedvec]))
    mangledName = Vector{String}(undef, sum([length(s) for (_, s) in unconnectedvec]))
    ci = 1
    for (vmod, d) in unconnectedvec
        for p in d
            nname = mangle ? outerportnamegen(getname(p), vmod) : getname(p)
            newport = vrename(p, nname)

            npvec[ci] = newport
            mangledName[ci] = outerportnamegen(getname(p), vmod)
            ci += 1
        end
    end

    if !mangle
        if length(Set([getname(p) for p in npvec])) != length(mangledName)
            throw(TopPortNameCollision([getname(p) for p in npvec], mangledName))
        end
        alassignvec = Vector{Alassign}(undef, sum([length(s) for (_, s) in unconnectedvec]))
        for (i, (p,n)) in enumerate(zip(npvec, mangledName))
            if getdirec(p) == pout
                alassignvec[i] = @alassign_comb ($(getname(p)) = $n)
            else
                alassignvec[i] = @alassign_comb ($n = $(getname(p)))
            end
        end

        vpush!(v, @always ($(Ifcontent(alassignvec))))
    end

    vpush!(v, mangle ? alloutwire(Ports(npvec)) : Ports(npvec))

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
function layer2vmod!(x::Vmodgraph ; name = "Layer")
    layer2vmod!(x, true ; name=name)
end

"""
    layer2vmod!(x::Mmodgraph; name = "Layers")::Vector{Vmodule}

Generate a list of `Vmodule` objects from `Mmodgraph`.

`x` may change its content through the evaluation.
"""
function layer2vmod!(x::Vmodgraph, mangle::Bool; name = "Layer")::Vector{Vmodule}
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
    bypassUnconnected_mlay!(v, x, mangle)

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


"""
    umlgen!(buf::IO, g::Vmodgraph)

Generate PlantUML diagram to show connections between modules.
"""
function umlgen!(buf::IO, g::Vmodgraph)
    # aggregate ports into one port group
    port_group_index = 0
    port_group_connection = Vector{Tuple{Tuple{String,Int},Tuple{String,Int}}}()
    # false for input, true for output
    port_groups = Dict{Int, Tuple{Bool, Vector{String}}}()
    vmodule_name_to_groups = Dict{String, Vector{Int}}()

    vmodule_name_to_port_name_to_connection_count = Dict{String, Dict{String, Int}}()

    for v in g.vmods
        vmodule_name_to_groups[getname(v)] = Int[]
        vmodule_name_to_port_name_to_connection_count[getname(v)] = Dict([getname(p) => 0 for p in v.ports])
    end

    for ((src,dest), conn) in g.edges
        pg_src = [p[begin] for p in conn.ports]
        pg_dest = [p[end] for p in conn.ports]

        for (ind,pn) in enumerate(pg_src)
            count_value = vmodule_name_to_port_name_to_connection_count[getname(src)][pn]
            if count_value > 0
                pg_src[ind] = pn * "_$count_value"
            end
            vmodule_name_to_port_name_to_connection_count[getname(src)][pn] += 1
        end
        # no connection duplicate in input ports
        for pn in pg_dest
            vmodule_name_to_port_name_to_connection_count[getname(dest)][pn] += 1
        end

        push!(vmodule_name_to_groups[getname(src)], port_group_index)
        push!(vmodule_name_to_groups[getname(dest)], port_group_index+1)

        port_groups[port_group_index] = (true, pg_src)
        port_groups[port_group_index+1] = (false, pg_dest)

        push!(port_group_connection, ((getname(src), port_group_index), (getname(dest), port_group_index+1)))
        port_group_index += 2
    end

    for v in g.vmods
        port_name_to_connection_count = vmodule_name_to_port_name_to_connection_count[getname(v)]
        
        out_remainder = String[]
        in_remainder = String[]

        for p in v.ports
            connection_count = port_name_to_connection_count[getname(p)]
            if connection_count == 0
                if getdirec(p) == pin
                    push!(in_remainder, getname(p))
                else
                    push!(out_remainder, getname(p))
                end
            end
        end

        if length(out_remainder) > 0
            port_groups[port_group_index] = (true, out_remainder)
            push!(vmodule_name_to_groups[getname(v)], port_group_index)
            port_group_index += 1
        end

        if length(in_remainder) > 0
            port_groups[port_group_index] = (false, in_remainder)
            push!(vmodule_name_to_groups[getname(v)], port_group_index)
            port_group_index += 1
        end
    end

    write(buf, "@startuml\n\n")
    for (vn, gr) in vmodule_name_to_groups
        write(buf, "class $vn {\n")
        for (i, gind) in enumerate(gr)
            direc, pg = port_groups[gind]

            # true for output
            if direc
                for p in pg
                    write(buf, "+ $p\n")
                end
            else
                for p in pg
                    write(buf, "- $p\n")
                end
            end

            if i != length(gr)
                write(buf, "..\n")
            end
        end
        write(buf, "}\n\n")
    end

    for ((n_src, pg_src), (n_dest, pg_dest)) in port_group_connection
        src_port_repr = port_groups[pg_src][end][begin]
        dest_port_repr = port_groups[pg_dest][end][begin]

        write(buf, "$n_src::$src_port_repr ---> $n_dest::$dest_port_repr\n")
    end

    write(buf, "@enduml\n")

    return nothing
end
