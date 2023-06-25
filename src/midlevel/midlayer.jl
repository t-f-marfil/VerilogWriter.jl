"""
    function (cls::Layergraph)(p::Pair{Midlayer, Midlayer}, conn::Layerconn)

Add new connection between Midlayers.
"""
function (cls::Layergraph)(p::Pair{Midlayer, Midlayer}, conn::Layerconn)
    push!(cls.edges, p => conn)

    push!(cls.layers, p[1])
    push!(cls.layers, p[2])
end
function (cls::Layergraph)(p::Pair{Midlayer, Midlayer})
    cls(p, Layerconn())
end

@basehashgen(
    Midlayer,
    Layerconn
)

"""
    function pushhelp_dotgen!(lay::Midlayer, randset::Set{Midlayer}, regset::Set{Midlayer}, fifoset::Set{Midlayer})

Helper function for `dotgen`.
"""
function pushhelp_dotgen!(lay::Midlayer, randset::Set{Midlayer}, regset::Set{Midlayer}, fifoset::Set{Midlayer})
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
    edgepush_dotgen!(iobuf::IOBuffer, edges::D) where {D <: AbstractDict{Pair{Midlayer, Midlayer}, Layerconn}}

Helper function for `dotgen`.
"""
function edgepush_dotgen!(iobuf::IOBuffer, edges::D) where {D <: AbstractDict{Pair{Midlayer, Midlayer}, Layerconn}}
    for ((n1, n2), ninfo) in edges 
        write(iobuf, "$(getname(n1)) -> $(getname(n2));\n")
    end
    return 
end

"""
    dotgen(lay::Layergraph; dpi=96)

Convert `Layergraph` object to a graph written in DOT language.
"""
function dotgen(lay::Layergraph; dpi=96)
    regset = Set{Midlayer}()
    randset = Set{Midlayer}()
    fifoset = Set{Midlayer}()

    for (uno, dos) in keys(lay.edges)
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


Reglayer(arg) = Midlayer(lreg, arg)
Randlayer(arg) = Midlayer(lrand, arg)
FIFOlayer(arg) = Midlayer(lfifo, arg)
FIFOlayer(arg, dep, wid) = Midlayer(lfifo, fifogen(dep, wid, name=arg))


function layermacro(arg, n::String, others...)
    :($(esc(arg)) = $(Symbol(string(n, "layer")))($(tuple(string(arg), (esc(t) for t in others)...)...)))
end


macro FIFOlayer(arg, others...)
    layermacro(arg, "FIFO", others...)
end
macro Randlayer(arg)
    layermacro(arg, "Rand")
end

"Chose proper preposition."
const prep4ilst_lower = Dict([
    ilvalid => "to"
    ilupdate => "from"
])
const prep4ilst_upper = Dict([
    (k => (v == "to" ? "from" : "to")) for (k, v) in prep4ilst_lower
])


const portdir4ilst_lower = Dict([
    ilvalid => pout
    ilupdate => pin
])
const portdir4ilst_upper = Dict([
    (k => (v == pin ? pout : pin)) for (k, v) in portdir4ilst_lower
])

function nametolower(st::Interlaysigtype)
    "$(string(st)[3:end])_$(prep4ilst_lower[st])_lower"
end
function nametoupper(st::Interlaysigtype)
    "$(string(st)[3:end])_$(prep4ilst_upper[st])_upper"
end

function nametolower(st::Interlaysigtype, suffix::Midlayer)
    string(nametolower(st), "_", getname(suffix))
end
function nametoupper(st::Interlaysigtype, suffix::Midlayer)
    string(nametoupper(st), "_", getname(suffix))
end

# function lowerportsgen(lowername::String)
#     ports(:(
#         @out @logic $(Symbol(nametolower(lowername, ilvalid)));
#         @in $(Symbol(nametolower(lowername, ilupdate)))
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

function addCommonPortEachLayer(x::Layergraph)
    for ml in x.layers 
        for p in ml.lports
            vpush!(ml.vmod, p)
        end
    end

    return nothing
end

function addIlPortEachLayer(x::Layergraph)
    preadded = Dict([lay => false for lay in x.layers])
    postadded = Dict([lay => false for lay in x.layers])

    for ((pre::Midlayer, post::Midlayer), conninfo) in x.edges
        vpre, vpost = pre.vmod, post.vmod

        for ilattr in instances(Interlaysigtype)
            preadded[pre] || vpush!(vpre, Oneport(portdir4ilst_lower[ilattr], logic, nametolower(ilattr)))
            postadded[post] || vpush!(vpost, Oneport(portdir4ilst_upper[ilattr], logic, nametoupper(ilattr)))
        end

        preadded[pre] = postadded[post] = true
    end

    return nothing
end

function addPortEachLayer(x::Layergraph)
    addCommonPortEachLayer(x)
    addIlPortEachLayer(x)
end

function wireAddSuffix(wirename::String, lsuffix::Midlayer)
    # Wireexpr(wirenamemodgen(lsuffix)(wirename))
    Wireexpr(string(wirename, "_", getname(lsuffix)))
end

"""
    outerportnamegen(portname::String, mlay::Midlayer)

Given the name of a port and the vmodule object the port belongs to,
return the name of a wire which is connected to the port at the top module.
"""
function outerportnamegen(portname::String, mlay::Midlayer)
    wirenamemodgen(mlay)(portname)
end

"""
    unconnectedports_mlay(x::Layergraph)

Using data in `x::Layergraph`, detect unconnected ports
in submodules.
"""
function unconnectedports_mlay(x::Layergraph)

    # try detecting unconnected ports 
    pconnected = OrderedDict{Midlayer, OrderedDict{Oneport, Bool}}([
        lay => OrderedDict([p => false for p in lay.vmod.ports]) 
        for lay in x.layers
    ])

    for ((uno::Midlayer, dos::Midlayer), conn) in x.edges 
        for (ppre, ppost) in conn.ports
            # update pconnected
            ppre in keys(pconnected[uno]) || error("$(string(ppre)) not in module $(getname(uno))")
            pconnected[uno][ppre] = true
            ppost in keys(pconnected[dos]) || error("$(string(ppost)) not in module $(getname(dos))")
            pconnected[dos][ppost] = true

        end
    end

    [midl => filter(k -> !d[k], keys(d)) for (midl, d) in pconnected]
end

"""
    layerconnInstantiate_mlay!(v::Vmodule, x::Layergraph)

Push data in Layerconn objects into Vmodule in a form of Verilog codes.
"""
function layerconnInstantiate_mlay!(v::Vmodule, x::Layergraph)
    mvec = Vmodule[]
    layVisited = Dict{Midlayer, Layerconn}()
    # # generate always_comb that connects ports 
    # # as described in Layerconn
    # qvec = Expr[]
    qvec = Alassign[]
    for ((uno::Midlayer, dos::Midlayer), conn) in x.edges 
        # what is needed below: 
        #  function: <connection_name>, <modulename> -> <wirename_in_mother_module>
        layVisited[uno] = vmerge(conn, get(layVisited, uno, Layerconn()))
        db = ildatabuffer(uno, conn)

        smod = wirenamemodgen(db)
        
        for (ppre, ppost) in conn.ports
            # getname(ppre) is not typo
            # this is needed to match the name with 
            # the one generated for Vmodinst ports
            q1 = @alassign_comb (
                $(
                    wireAddSuffix(getname(ppost), dos)
                ) = $(
                    smod(string("dout_", getname(ppre)))
                )
            )
            q2 = @alassign_comb (
                $(
                    smod(string("din_", getname(ppre)))
                ) = $(
                    wireAddSuffix(getname(ppre), uno)
                )
            )
            push!(qvec, q1, q2)
        end

    end

    for (uno, conn) in layVisited
        db = ildatabuffer(uno, conn)
        vpush!(db, commonports)
        push!(mvec, db)

        smod = wirenamemodgen(db)
        dports = filter(x -> getname(x) != "CLK" && getname(x) != "RST", [i for i in getports(db)])
        vpush!(v, Vmodinst(
            getname(db),
            "uildatabuf_$(getname(uno))",
            [
                "CLK" => Wireexpr("CLK"),
                "RST" => Wireexpr("RST"),
                [(n = getname(p); n => Wireexpr(smod(n))) for p in dports]...
            ]
        ))
        alil = @always (
            $(smod(nametolower(ilupdate))) = $(nametolower(ilupdate, uno));
            $(smod(nametolower(ilvalid))) = $(nametolower(ilvalid, uno))
        )
        vpush!(v, alil)
    end

    # alans = Alwayscontent(comb, ifcontent(Expr(:block, qvec...)))
    alans = Alwayscontent(comb, qvec)
    vpush!(v, alans)
    
    return mvec
end

"""
    ilconndecl_mlay!(v::Vmodule, x::Layergraph)

Originally, Connect valid/update wires, which are generated automatically
when converting `Midlayer` objects into Verilog HDL, between `Midlayer` objects.

Now is needed only for wire declaration.
"""
function ilconndecl_mlay!(v::Vmodule, x::Layergraph)
    # rvec = Expr[]
    # dvec = Expr[]
    dvec = Onedecl[]
    rregistered = Dict([lay => false for lay in x.layers])
    lregistered = Dict([lay => false for lay in x.layers])

    for ((uno::Midlayer, dos::Midlayer), _) in x.edges 
        for ilattr in instances(Interlaysigtype)
            rlhs = nametoupper(ilattr, dos)
            rrhs = nametolower(ilattr, uno)
            # # set appropiate lhs <=> rhs
            if portdir4ilst_upper[ilattr] == pout
                rlhs, rrhs = rrhs, rlhs
                uno, dos = dos, uno
            end
            # r = :(
            #     $(
            #         rlhs
            #     ) = $(
            #         rrhs
            #     )
            # )
            # push!(rvec, r)
            # # push!(dvec, :(@logic $(rrhs), $(rlhs)))


            rregistered[uno] || push!(dvec, (@decloneline (@logic $rrhs))...)
            lregistered[dos] || push!(dvec, (@decloneline (@logic $(rlhs)))...)

            rregistered[uno] = lregistered[dos] = true
        end

    end

    # vpush!(v, always(Expr(:block, rvec...)))
    # vpush!(v, decls(Expr(:block, dvec...)))
    vpush!(v, Decls(dvec))

    return nothing
end

"""
    ilconnect_mlay(v::Vmodule, lay::Layergraph)

Connect valid and update signals of `Midlayer` objects with each other.

## Overview
+ Upper_Layer -> ilSUML -> ilMUSL -> Lower_Layer

Currently all this connections are placed at the top module.
May better create one verilog module other than top module and push these
wires there.
"""
function ilconnect_mlay!(v::Vmodule, lay::Layergraph)
    suml, musl = graph2adlist(lay)

    # hublist: list of ilconnect_something Vmodules
    # addinfolist: other additional information (e.g. Decls objects)
    hublist1, addinfolist1 = generateSUML(suml)
    hublist2, addinfolist2 = generateMUSL(musl)

    addsumlinfo!(v, addinfolist1)
    addsumlinfo!(v, addinfolist2)

    # Connection between upstream layer and SUML hub
    # qs = Vector{Expr}(undef, length(suml)*2)
    qs = Vector{Alassign}(undef, length(suml)*2)
    for (ind, (upper, _)) in enumerate(suml)
        qupdate = @alassign_comb ($(nametolower(ilupdate, upper)) = $(wirenameMlayToSuml(ilupdate, upper)))
        qvalid = @alassign_comb ($(wirenameMlayToSuml(ilvalid, upper)) = $(nametolower(ilvalid, upper)))
        qs[2ind-1] = qupdate
        qs[2ind] = qvalid
    end
    # vpush!(v, always(Expr(:block, qs...)))
    vpush!(v, Alwayscontent(comb, qs))

    # Connection between downstream layer and MUSL hub
    # qs = Vector{Expr}(undef, length(musl)*2)
    qs = Vector{Alassign}(undef, length(musl)*2)
    for (ind, (lower, _)) in enumerate(musl)
        qupdate = @alassign_comb ($(wirenameMuslToMlay(ilupdate, lower)) = $(nametoupper(ilupdate, lower)))
        qvalid = @alassign_comb ($(nametoupper(ilvalid, lower)) = $(wirenameMuslToMlay(ilvalid, lower)))
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
    bypassUnconnected_mlay!(v::Vmodule, x::Layergraph)

Add to the top-level module ports that are connected to counterparts of 
submodules, which are not connected to ports of other `Midlayer` objects.
"""
function bypassUnconnected_mlay!(v::Vmodule, x::Layergraph)
    # connect unconnected ports to outer ports
    unconnectedvec::Vector{Pair{Midlayer, OrderedSet{Oneport}}} = unconnectedports_mlay(x)

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
    connectCommonPorts_mlay!(v::Vmodule, x::Layergraph)

Connect ports which all submodules have in common to the 
proper ports in the top module.
"""
function connectCommonPorts_mlay!(v::Vmodule, x::Layergraph)

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
    layer2vmod!(x::Layergraph; name = "Layers")::Vector{Vmodule}

Generate a list of `Vmodule` objects from `Layergraph`.

`x` may change its content through the evaluation.
"""
function layer2vmod!(x::Layergraph; name = "Layers")::Vector{Vmodule}
    # toplevel module 
    v = Vmodule(name)

    # generate always_comb that connects ports 
    # as described in Layerconn
    # note that 2 function calls below do not modify 
    # Vmodules in each midlayer objects
    dbufs = layerconnInstantiate_mlay!(v, x)
    ilconndecl_mlay!(v, x)

    hubs = ilconnect_mlay!(v, x)
    
    # connect unconnected ports to outer ports
    bypassUnconnected_mlay!(v, x)

    connectCommonPorts_mlay!(v, x)

    # reflect data in layerconn to Vmodule objects
    addPortEachLayer(x)

    # execute below after connecting modules
    # instantiate every layer
    for lay in x.layers 
        vpush!(v, vinstnamemod(lay.vmod))
    end

    return [v; [lay.vmod for lay in x.layers]; dbufs; hubs]
end

function vpush!(x::Midlayer, items...)
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

