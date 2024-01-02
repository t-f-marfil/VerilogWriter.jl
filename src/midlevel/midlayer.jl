"""
    (cls::Mmodgraph)(p::Pair{Midport, Midport}, conn::Layerconn)

Add new connection between Midmodules.
"""
function (cls::Mmodgraph)(p::Pair{Midport, Midport}, args...)
    dfp, ufp = p
    isnothing(get(cls.edges, (dfp => ufp), nothing)) || error("pair dfp => ufp is already registered")
    push!(cls.edges, (dfp => ufp) => Layerconn(args...))

    push!(cls.layers, getmmod(dfp))
    push!(cls.layers, getmmod(ufp))
    return nothing
end
"""
    (cls::Mmodgraph)(p::Pair{Midmodule, Midmodule}, pid::Int, conn::Layerconn)

Case where port id is the same between both dfp and ufp.
"""
function (cls::Mmodgraph)(p::Pair{Midmodule, Midmodule}, pid::Int, args...)
    dfp, ufp = Midport(pid, p[1]), Midport(pid, p[2])
    cls(dfp => ufp, args...)
end
function (cls::Mmodgraph)(p::Pair{Midmodule, Midmodule}, args...)
    # include the case where nothing given as arg
    cls(p, defaultMidPid, Layerconn(args...))
end

@basehashgen(
    Midmodule,
    Layerconn
)

"""
    pushhelp_dotgen!(lay::Midmodule, randset::S{Midmodule}, regset::S{Midmodule}, fifoset::S{Midmodule}) where {S <: AbstractSet}

Helper function for `dotgen`.
"""
function pushhelp_dotgen!(lay::Midmodule, randset::S, regset::S, fifoset::S) where {S <: AbstractSet{Midmodule}}
    t = lay.type
    if t == lrand
        push!(randset, lay)
    elseif t == lreg 
        push!(regset, lay)
    elseif t == lfifo 
        push!(fifoset, lay)
    else
        error("unknown type $(t).")
    end

    return
end

"""
    edgepush_dotgen!(iobuf::IOBuffer, edges::D) where {D <: AbstractDict{Pair{Midport, Midport}, Layerconn}}

Helper function for `dotgen`.
"""
function edgepush_dotgen!(iobuf::IOBuffer, edges::D) where {D <: AbstractDict{Pair{Midport, Midport}, Layerconn}}
    for ((_n1, _n2), ninfo) in edges 
        n1, n2 = getmmod.((_n1, _n2))
        write(iobuf, "$(getname(n1)) -> $(getname(n2));\n")
    end
    return 
end

"""
    dotgen(lay::Mmodgraph; dpi=96)

Convert `Mmodgraph` object to a graph written in DOT language.
"""
function dotgen(lay::Mmodgraph; dpi=96)
    regset = OrderedSet{Midmodule}()
    randset = OrderedSet{Midmodule}()
    fifoset = OrderedSet{Midmodule}()

    for (dfp, ufp) in keys(lay.edges)
        uno, dos = getmmod.((dfp, ufp))
        pushhelp_dotgen!(uno, randset, regset, fifoset)
        pushhelp_dotgen!(dos, randset, regset, fifoset)
    end

    sbuf = IOBuffer()
    for b in regset
        write(sbuf, "$(getname(b)) [shape=box];\n")
    end
    for c in randset 
        write(sbuf, "$(getname(c)) [shape=oval];\n")
    end
    for f in fifoset 
        write(sbuf, "$(getname(f)) [shape=box, peripheries=2];\n")
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


Regmmod(arg) = Midmodule(lreg, arg)
Randmmod(arg) = Midmodule(lrand, arg)
FIFOmmod(arg) = Midmodule(lfifo, arg)
FIFOmmod(arg, dep, wid) = Midmodule(lfifo, fifogen(dep, wid, name=arg))


function layermacro(arg, n::String, others...)
    :($(esc(arg)) = $(Symbol(string(n, "mmod")))($(tuple(string(arg), (esc(t) for t in others)...)...)))
end


macro FIFOmmod(arg, others...)
    layermacro(arg, "FIFO", others...)
end
macro Randmmod(arg)
    layermacro(arg, "Rand")
end

"Chose proper preposition."
const prep4ilst_lower = Dict([
    imvalid => "to"
    imupdate => "from"
])
const prep4ilst_upper = Dict([
    (k => (v == "to" ? "from" : "to")) for (k, v) in prep4ilst_lower
])


const portdir4ilst_lower = Dict([
    imvalid => pout
    imupdate => pin
])
const portdir4ilst_upper = Dict([
    (k => (v == pin ? pout : pin)) for (k, v) in portdir4ilst_lower
])

"""
    nametolower(st::IntermmodSigtype)

Return the name of a wire connected to downstream verilog modules.
"""
function nametolower(st::IntermmodSigtype)
    nametolower(st, defaultMidPid)
end
"""
    nametoupper(st::IntermmodSigtype)

Return the name of a wire connected to upstream verilog modules.
"""
function nametoupper(st::IntermmodSigtype)
    nametoupper(st, defaultMidPid)
end
function nametolower(st::IntermmodSigtype, pid::Int)
    "$(string(st)[3:end])_$(prep4ilst_lower[st])_lower_port$pid"
end
function nametoupper(st::IntermmodSigtype, pid::Int)
    "$(string(st)[3:end])_$(prep4ilst_upper[st])_upper_port$pid"
end

# function nametolower(st::IntermmodSigtype, suffix::Midmodule)
#     string(nametolower(st), "_", getname(suffix))
# end
# function nametoupper(st::IntermmodSigtype, suffix::Midmodule)
#     string(nametoupper(st), "_", getname(suffix))
# end

function nametolower(st::IntermmodSigtype, suffix::Midport)
    string(nametolower(st, getpid(suffix)), "_", getname(getmmod(suffix)))
end
function nametoupper(st::IntermmodSigtype, suffix::Midport)
    string(nametoupper(st, getpid(suffix)), "_", getname(getmmod(suffix)))
end

# function lowerportsgen(lowername::String)
#     ports(:(
#         @out @logic $(Symbol(nametolower(lowername, imvalid)));
#         @in $(Symbol(nametolower(lowername, imupdate)))
#     ))
# end
# function upperportsgen(uppername::String)
#     ports(:(
#         @in $(Symbol("valid_from_upper_$(uppername)"));
#         @out @logic $(Symbol("update_to_upper_$(uppername)"))
#     ))
# end

function lowerportsgen(lowerobj)
    lowerportsgen(getname(lowerobj))
end
function upperportsgen(upperobj)
    upperportsgen(getname(upperobj))
end

function addCommonPortEachLayer(x::Mmodgraph)
    for ml in x.layers 
        for p in ml.lports
            if !(p in getports(getvmod(ml)))
                vpush!(ml, p)
            end
        end
    end

    return nothing
end

function addIlPortEachLayer(x::Mmodgraph)
    preadded = Dict([lay => Dict{Int, Bool}() for lay in x.layers])
    postadded = Dict([lay => Dict{Int, Bool}() for lay in x.layers])

    for ((pre::Midport, post::Midport), _) in x.edges
        vpre, vpost = getmmod(pre).vmod, getmmod(post).vmod

        for ilattr in instances(IntermmodSigtype)
            get(preadded[getmmod(pre)], getpid(pre), false) || vpush!(vpre, Oneport(portdir4ilst_lower[ilattr], logic, nametolower(ilattr, getpid(pre))))
            get(postadded[getmmod(post)], getpid(post), false) || vpush!(vpost, Oneport(portdir4ilst_upper[ilattr], logic, nametoupper(ilattr, getpid(post))))
        end

        preadded[getmmod(pre)][getpid(pre)] = postadded[getmmod(post)][getpid(post)] = true
    end

    return nothing
end

function addPortEachLayer(x::Mmodgraph)
    addCommonPortEachLayer(x)
    addIlPortEachLayer(x)
end

function wireAddSuffix(wirename::String, lsuffix::Midmodule)
    # Wireexpr(wirenamemodgen(lsuffix)(wirename))
    Wireexpr(string(wirename, "_", getname(lsuffix)))
end

"""
    outerportnamegen(portname::String, mlay::Midmodule)

Given the name of a port and the vmodule object the port belongs to,
return the name of a wire which is connected to the port at the top module.
"""
function outerportnamegen(portname::String, mlay::Midmodule)
    wirenamemodgen(mlay)(portname)
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
function unconnectedports_mlay(x::Mmodgraph)

    # try detecting unconnected ports 
    pconnected = OrderedDict{Midmodule, OrderedDict{Oneport, Bool}}([
        lay => OrderedDict([p => false for p in lay.vmod.ports]) 
        for lay in x.layers
    ])

    for ((dfp::Midport, ufp::Midport), conn) in x.edges 
        for (ppre, ppost) in conn.ports
            # update pconnected
            # ppre in keys(pconnected[uno])
            prefil = [filter(p -> portmatch_uc(ppre, p[1]), pconnected[getmmod(dfp)])...]
            (length(prefil) > 0 && getdirec(ppre) == pout) || error("$(string(ppre)) not in port $(getname(dfp)) and should be output with the same width")
            # should be length 1
            pconnected[getmmod(dfp)][prefil[][1]] = true

            # ppost in keys(pconnected[dos])
            postfil = [filter(p -> portmatch_uc(ppost, p[1]), pconnected[getmmod(ufp)])...]
            (length(postfil) > 0 && getdirec(ppost) == pin) || error("$(string(ppost)) not in port $(getname(ufp)) and should be input with the same width")
            pconnected[getmmod(ufp)][postfil[][1]] = true

        end
    end

    [midl => filter(k -> (!d[k] & !(k in commonports)), keys(d)) for (midl, d) in pconnected]
end

"""
    layerconnInstantiate_mlay!(v::Vmodule, x::Mmodgraph)

Push data in Layerconn objects into Vmodule in a form of Verilog codes.
"""
function layerconnInstantiate_mlay!(v::Vmodule, x::Mmodgraph)
    mvec = Vmodule[]
    layVisited = Dict{Midmodule, Layerconn}()
    # # generate always_comb that connects ports 
    # # as described in Layerconn
    # qvec = Expr[]
    qvec = Alassign[]
    dclsvec = Onedecl[]
    for ((_uno::Midport, _dos::Midport), conn) in x.edges 
        uno, dos = getmmod.((_uno, _dos))
        # what is needed below: 
        #  function: <connection_name>, <modulename> -> <wirename_in_mother_module>
        layVisited[uno] = vmerge(conn, get(layVisited, uno, Layerconn()))
        db = ildatabuffer(uno, conn)

        smod = wirenamemodgen(db)
        
        for (ppre, ppost) in conn.ports
            # getname(ppre) is not typo
            # this is needed to match the name with 
            # the one generated for Vmodinst ports

            # q1 = @alassign_comb (
            #     $(
            #         wireAddSuffix(getname(ppost), dos)
            #     ) = $(
            #         smod(string("dout_", getname(ppre)))
            #     )
            # )
            # q2 = @alassign_comb (
            #     $(
            #         smod(string("din_", getname(ppre)))
            #     ) = $(
            #         wireAddSuffix(getname(ppre), uno)
            #     )
            # )
            # push!(qvec, q1, q2)

            # below means
            # always_comb begin
            #   <ppost_name>_<dos_name> = <ppre_name>_<uno_name>
            # end
            # at the top level module
            postwire = wireAddSuffix(getname(ppost), dos)
            prewire = wireAddSuffix(getname(ppre), uno)
            q = @alassign_comb $postwire = $prewire
            push!(qvec, q)

            # same pre may be connected to multiple ports, thus to avoid 
            # duplicate, not added here
            dcl = @decls @logic $(getwidth(ppost)) $(postwire)
            vpush!(v, dcl) 
        end

    end

    # ilbuf not needed now
    # for (uno, conn) in layVisited
    #     db = ildatabuffer(uno, conn)
    #     vpush!(db, commonports)
    #     push!(mvec, db)

    #     smod = wirenamemodgen(db)
    #     dports = filter(x -> getname(x) != "CLK" && getname(x) != "RST", [i for i in getports(db)])
    #     vpush!(v, Vmodinst(
    #         getname(db),
    #         "uildatabuf_$(getname(uno))",
    #         [
    #             "CLK" => Wireexpr("CLK"),
    #             "RST" => Wireexpr("RST"),
    #             [(n = getname(p); n => Wireexpr(smod(n))) for p in dports]...
    #         ]
    #     ))
    #     alil = @always (
    #         $(smod(nametolower(imupdate))) = $(nametolower(imupdate, uno));
    #         $(smod(nametolower(imvalid))) = $(nametolower(imvalid, uno))
    #     )
    #     vpush!(v, alil)
    # end

    # alans = Alwayscontent(comb, ifcontent(Expr(:block, qvec...)))
    alans = Alwayscontent(comb, qvec)
    vpush!(v, alans)
    
    return mvec
end

"""
    ilconndecl_mlay!(v::Vmodule, x::Mmodgraph)

Originally, Connect valid/update wires, which are generated automatically
when converting `Midmodule` objects into Verilog HDL, between `Midmodule` objects.

Now is needed only for wire declaration.
"""
function ilconndecl_mlay!(v::Vmodule, x::Mmodgraph)
    # rvec = Expr[]
    # dvec = Expr[]
    dvec = Onedecl[]
    # rregistered = Dict([lay::Midmodule => [false, false] for lay in x.layers])
    # lregistered = Dict([lay::Midmodule => [false, false] for lay in x.layers])
    ufpregistered = Dict([lay::Midmodule => Dict{Int, Vector{Bool}}() for lay in x.layers])
    dfpregistered = Dict([lay::Midmodule => Dict{Int, Vector{Bool}}() for lay in x.layers])

    for ((dfp::Midport, ufp::Midport), _) in x.edges 
        for ilattr in instances(IntermmodSigtype)
            # rlhs = nametoupper(ilattr, dos)
            # rrhs = nametolower(ilattr, uno)
            rufp = nametoupper(ilattr, ufp)
            rdfp = nametolower(ilattr, dfp)
            # rlhs, rrhs = rufp, rdfp
            # # set appropiate lhs <=> rhs
            # if portdir4ilst_upper[ilattr] == pout
            #     rlhs, rrhs = rrhs, rlhs
            #     uno, dos = dos, uno
            # end
            ddfp = dfpregistered[getmmod(dfp)]
            if getpid(dfp) in keys(ddfp)
                # port id specified
                if !ddfp[getpid(dfp)][Int(ilattr) + 1]
                    push!(dvec, (@decloneline (@logic $rdfp))...)
                    ddfp[getpid(dfp)][Int(ilattr) + 1] = true
                end
            else
                ddfp[getpid(dfp)] = [false, false]
                push!(dvec, (@decloneline (@logic $rdfp))...)
                ddfp[getpid(dfp)][Int(ilattr) + 1] = true
            end
            
            dufp = ufpregistered[getmmod(ufp)]
            if getpid(ufp) in keys(dufp)
                # port id specified
                if !dufp[getpid(ufp)][Int(ilattr) + 1]
                    push!(dvec, (@decloneline (@logic $rufp))...)
                    dufp[getpid(ufp)][Int(ilattr) + 1] = true
                end
            else
                dufp[getpid(ufp)] = [false, false]
                push!(dvec, (@decloneline (@logic $rufp))...)
                dufp[getpid(ufp)][Int(ilattr) + 1] = true
            end
            # rregistered[uno][Int(ilattr) + 1] || push!(dvec, (@decloneline (@logic $rrhs))...)
            # lregistered[dos][Int(ilattr) + 1] || push!(dvec, (@decloneline (@logic $(rlhs)))...)

            # rregistered[uno][Int(ilattr) + 1] = lregistered[dos][Int(ilattr) + 1] = true
        end

    end

    # vpush!(v, always(Expr(:block, rvec...)))
    # vpush!(v, decls(Expr(:block, dvec...)))
    vpush!(v, Decls(dvec))

    return nothing
end

"""
    imconnect_mlay(v::Vmodule, lay::Mmodgraph)

Connect valid and update signals of `Midmodule` objects with each other.

## Overview
+ Upper_Layer -> imSUML -> imMUSL -> Lower_Layer

Currently all this connections are placed at the top module.
May better create one verilog module other than top module and push these
wires there.
"""
function imconnect_mlay!(v::Vmodule, lay::Mmodgraph)
    suml, musl = graph2adlist(lay)

    # hublist: list of imconnect_something Vmodules
    # addinfolist: other additional information (e.g. Decls objects)
    hublist1, addinfolist1 = generateSUML(suml)
    hublist2, addinfolist2 = generateMUSL(musl)

    addsumlinfo!(v, addinfolist1)
    addsumlinfo!(v, addinfolist2)

    # Connection between upstream layer and SUML hub
    # qs = Vector{Expr}(undef, length(suml)*2)
    qs = Vector{Alassign}(undef, length(suml)*2)
    for (ind, (upper, _)) in enumerate(suml)
        qupdate = @alassign_comb ($(nametolower(imupdate, upper)) = $(wirenameMlayToSuml(imupdate, upper)))
        qvalid = @alassign_comb ($(wirenameMlayToSuml(imvalid, upper)) = $(nametolower(imvalid, upper)))
        qs[2ind-1] = qupdate
        qs[2ind] = qvalid
    end
    # vpush!(v, always(Expr(:block, qs...)))
    vpush!(v, Alwayscontent(comb, qs))

    # Connection between downstream layer and MUSL hub
    # qs = Vector{Expr}(undef, length(musl)*2)
    qs = Vector{Alassign}(undef, length(musl)*2)
    for (ind, (lower, _)) in enumerate(musl)
        qupdate = @alassign_comb ($(wirenameMuslToMlay(imupdate, lower)) = $(nametoupper(imupdate, lower)))
        qvalid = @alassign_comb ($(nametoupper(imvalid, lower)) = $(wirenameMuslToMlay(imvalid, lower)))
        qs[2ind-1] = qupdate
        qs[2ind] = qvalid
    end
    # vpush!(v, always(Expr(:block, qs...)))
    vpush!(v, Alwayscontent(comb, qs))

    vpush!.(hublist1, Ref(@ports @in CLK, RST))
    vpush!.(hublist2, Ref(@ports @in CLK, RST))

    return [hublist1; hublist2]
end

"""
    bypassUnconnected_mlay!(v::Vmodule, x::Mmodgraph)

Add to the top-level module ports that are connected to counterparts of 
submodules, which are not connected to ports of other `Midmodule` objects.
"""
function bypassUnconnected_mlay!(v::Vmodule, x::Mmodgraph)
    # connect unconnected ports to outer ports
    unconnectedvec::Vector{Pair{Midmodule, OrderedSet{Oneport}}} = unconnectedports_mlay(x)

    npvec = Vector{Oneport}(undef, sum([length(s) for (_, s) in unconnectedvec]))
    ci = 1
    for (midl, d) in unconnectedvec
        for p in d
            nname = outerportnamegen(getname(p), midl)
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
function connectCommonPorts_mlay!(v::Vmodule, x::Mmodgraph)

    vpush!(v, commonports...)

    for lay in x.layers 
        # qvec = Vector{Expr}(undef, length(commonports))
        qvec = Vector{Alassign}(undef, length(commonports))
        for (ind, prt::Oneport) in enumerate(commonports)
            f = wirenamemodgen(lay)
            q = @alassign_comb (
                $(
                    Symbol(f(getname(prt)))
                ) = $(
                    Symbol(getname(prt))
                )
            )

            qvec[ind] = q
            # vpush!(v, al)
        end

        # vpush!(v, always(Expr(:block, qvec...)))
        vpush!(v, Alwayscontent(comb, qvec))
    end

    return nothing
end

"""
    layer2vmod!(x::Mmodgraph; name = "Layers")::Vector{Vmodule}

Generate a list of `Vmodule` objects from `Mmodgraph`.

`x` may change its content through the evaluation.
"""
function layer2vmod!(x::Mmodgraph; name = "Layers")::Vector{Vmodule}
    # toplevel module 
    v = Vmodule(name)

    # generate always_comb that connects ports 
    # as described in Layerconn
    # note that 2 function calls below do not modify 
    # Vmodules in each midlayer objects
    dbufs = layerconnInstantiate_mlay!(v, x)
    ilconndecl_mlay!(v, x)

    hubs = imconnect_mlay!(v, x)
    
    # connect unconnected ports to outer ports
    # currently doing this before `vfinalize`,
    # port of unknown width should not exist at this time
    bypassUnconnected_mlay!(v, x)

    connectCommonPorts_mlay!(v, x)

    # reflect data in layerconn to Vmodule objects
    addPortEachLayer(x)

    # execute below after connecting modules.
    # instantiate every layer
    for lay in x.layers 
        vpush!(v, vinstnamemod(lay.vmod))
    end

    return [v; [lay.vmod for lay in x.layers]; dbufs; hubs]
end

function vpush!(x::Midmodule, items...)
    vpush!(x.vmod, items...)
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

function imacceptedLower(pid=defaultMidPid)
    @wireexpr $(nametolower(imvalid, pid)) & $(nametolower(imupdate, pid))
end

function imacceptedUpper(pid=defaultMidPid)
    @wireexpr $(nametoupper(imvalid, pid)) & $(nametoupper(imupdate, pid))
end