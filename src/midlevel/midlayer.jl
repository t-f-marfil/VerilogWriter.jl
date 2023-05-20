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
    edgepush_dotgen!(iobuf::IOBuffer, edges::Dict{Pair{Midlayer, Midlayer}, Layerconn})

Helper function for `dotgen`.
"""
function edgepush_dotgen!(iobuf::IOBuffer, edges::Dict{Pair{Midlayer, Midlayer}, Layerconn})
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

@enum Interlaysigtype ilvalid ilupdate

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

function lowerportsgen(lowername::String)
    ports(:(
        @out @logic $(Symbol(nametolower(lowername, ilvalid)));
        @in $(Symbol(nametolower(lowername, ilupdate)))
    ))
end
function upperportsgen(uppername::String)
    ports(:(
        @in $(Symbol("valid_from_upper_$(uppername)"));
        @out @logic $(Symbol("update_to_upper_$(uppername)"))
    ))
end

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
        # vpush!(vpre, lowerportsgen(getname(vpost)))
        # vpush!(vpost, upperportsgen(getname(vpre)))
        # how do you connect valid/update interface?
    end

    return nothing
end

function addPortEachLayer(x::Layergraph)
    addCommonPortEachLayer(x)
    addIlPortEachLayer(x)
    # # should insert clk,rst before width inference
    # for ml in x.layers 
    #     for p in ml.lports
    #         vpush!(ml.vmod, p)
    #     end
    # end

    # for ((pre::Midlayer, post::Midlayer), conninfo) in x.edges
    #     vpre, vpost = pre.vmod, post.vmod

    #     for ilattr in instances(Interlaysigtype)
    #         vpush!(vpre, Oneport(portdir4ilst_lower[ilattr], nametolower(ilattr)))
    #         vpush!(vpost, Oneport(portdir4ilst_upper[ilattr], nametoupper(ilattr)))
    #     end
    #     # vpush!(vpre, lowerportsgen(getname(vpost)))
    #     # vpush!(vpost, upperportsgen(getname(vpre)))
    #     # how do you connect valid/update interface?
    # end

end

function wireAddSuffix(wirename::String, lsuffix::Midlayer)
    Wireexpr(wirenamemodgen(lsuffix)(wirename))
end

"""

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

    # # generate always_comb that connects ports 
    # # as described in Layerconn
    qvec = Expr[]
    for ((uno::Midlayer, dos::Midlayer), conn) in x.edges 
        # what is needed below: 
        #  function: <connection_name>, <modulename> -> <wirename_in_mother_module>
        for (ppre, ppost) in conn.ports
            q = :(
                $(
                    wireAddSuffix(getname(ppost), dos)
                ) = $(
                    wireAddSuffix(getname(ppre), uno)
                )
            )
            push!(qvec, q)
        end

    end

    alans = Alwayscontent(comb, ifcontent(Expr(:block, qvec...)))
    vpush!(v, alans)
    
end

"""
    lconnect_mlay!(v::Vmodule, x::Layergraph)

Connect valid/update wires, which are generated automatically
when converting `Midlayer` objects into Verilog HDL, between `Midlayer` objects.
"""
function lconnect_mlay!(v::Vmodule, x::Layergraph)
    rvec = Expr[]
    dvec = Expr[]
    rregistered = Dict([lay => false for lay in x.layers])
    lregistered = Dict([lay => false for lay in x.layers])

    for ((uno::Midlayer, dos::Midlayer), _) in x.edges 
        for ilattr in instances(Interlaysigtype)
            rlhs = nametoupper(ilattr, dos)
            rrhs = nametolower(ilattr, uno)
            # set appropiate lhs <=> rhs
            if portdir4ilst_upper[ilattr] == pout
                rlhs, rrhs = rrhs, rlhs
                uno, dos = dos, uno
            end
            r = :(
                $(
                    rlhs
                ) = $(
                    rrhs
                )
            )
            push!(rvec, r)
            # push!(dvec, :(@logic $(rrhs), $(rlhs)))


            rregistered[uno] || push!(dvec, :(@logic $(rrhs)))
            lregistered[dos] || push!(dvec, :(@logic $(rlhs)))

            rregistered[uno] = lregistered[dos] = true
        end

    end

    vpush!(v, always(Expr(:block, rvec...)))
    vpush!(v, decls(Expr(:block, dvec...)))

    return nothing
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
        qvec = Vector{Expr}(undef, length(commonports))
        for (ind, prt::Oneport) in enumerate(commonports)
            f = wirenamemodgen(lay)
            q = :(
                $(
                    Symbol(f(getname(prt)))
                ) = $(
                    Symbol(getname(prt))
                )
            )

            qvec[ind] = q
            # vpush!(v, al)
        end

        vpush!(v, always(Expr(:block, qvec...)))
    end

    return nothing
end

function layer2vmod!(x::Layergraph; name = "Layers")::Vector{Vmodule}
    # toplevel module 
    v = Vmodule(name)

    # generate always_comb that connects ports 
    # as described in Layerconn
    # note that 2 function calls below do not modify 
    # Vmodules in each midlayer objects
    layerconnInstantiate_mlay!(v, x)
    lconnect_mlay!(v, x)
    
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

    ans = [v, [lay.vmod for lay in x.layers]...]
    # vfinalize.(ans)
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

