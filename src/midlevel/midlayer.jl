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


function layermacro(arg, n::String)
    :($(esc(arg)) = $(Symbol(string(n, "layer")))($(string(arg))))
end


macro FIFOlayer(arg)
    layermacro(arg, "FIFO")
end
macro Randlayer(arg)
    layermacro(arg, "Rand")
end

function lowerportsgen(lowername::String)
    ports(:(
        @out $(Symbol("valid_to_lower_$(lowername)"));
        @in $(Symbol("update_from_lower_$(lowername)"))
    ))
end
function upperportsgen(uppername::String)
    ports(:(
        @in $(Symbol("valid_from_upper_$(uppername)"));
        @out $(Symbol("update_to_upper_$(uppername)"))
    ))
end

function connectall(x::Layergraph)
    # should insert clk,rst before width inference
    for ml in x.layers 
        for p in ml.lports
            vpush!(ml.vmod, p)
        end
    end

    for ((pre::Midlayer, post::Midlayer), conninfo) in x.edges
        vpre, vpost = pre.vmod, post.vmod
        
        vpush!(vpre, lowerportsgen(getname(vpost)))
        vpush!(vpost, upperportsgen(getname(vpre)))
        # how do you connect valid/update interface?
    end

end

function name_wireconnectedattop(connname::String, v::Vmodule)
    Wireexpr(wirenamemodgen(v)(connname))
end

"""

Given the name if a port and the vmodule object the port belongs to,
return the name of a wire which is connected to the port at the top module.
"""
function outerportnamegen(portname::String, vmod::Vmodule)
    wirenamemodgen(vmod)(portname)
end


"""
    unconnectedports_mlay(x::Layergraph)

Using data in `x::Layergraph` detect unconnected ports
in submodules.
"""
function unconnectedports_mlay(x::Layergraph)

    # try detecting unconnected ports 
    pconnected = Dict{Midlayer, Dict{Oneport, Bool}}([
        lay => Dict([p => false for p in lay.vmod.ports]) 
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

function layer2vmod(x::Layergraph; name = "Layers")
    v = Vmodule(name)

    # # generate always_comb that connects ports 
    # # as described in Layerconn
    for ((uno::Midlayer, dos::Midlayer), conn) in x.edges 
        # what is needed below: 
        #  function: <connection_name>, <modulename> -> <wirename_in_mother_module>
        for (ppre, ppost) in conn.ports
            al = always(:(
                $(
                    name_wireconnectedattop(getname(ppost), dos.vmod)
                ) = $(
                    name_wireconnectedattop(getname(ppre), uno.vmod)
                )
            ))

            vpush!(v, al)

        end

    end

    # unconnectedvec = [midl => filter(k -> !d[k], keys(d)) for (midl, d) in pconnected]
    unconnectedvec = unconnectedports_mlay(x)

    npvec = Vector{Oneport}(undef, sum([length(s) for (_, s) in unconnectedvec]))
    ci = 1
    for (midl, d) in unconnectedvec
        for p in d 
            nname = outerportnamegen(getname(p), midl.vmod)
            newport = vrename(p, nname)

            npvec[ci] = newport
            ci += 1
        end
    end

    vpush!(v, alloutwire(Ports(npvec)))

    commonports = (x -> Oneport(pin, getname(x))).(
        [defclk, defrst]
    )
    vpush!(v, commonports...)

    for lay in x.layers 
        qvec = Vector{Expr}(undef, length(commonports))
        for (ind, prt::Oneport) in enumerate(commonports)
            f = wirenamemodgen(lay.vmod)
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

    connectall(x)

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
    Layerconn(Set(v))
end

