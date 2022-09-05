"""
    wireextract(x::Ifcontent)

Extract `Wireexpr`s from `x::Ifcontent`, along with
equality constraints of wire width.

Return `declonly::Vector{Wireexpr}`, which contains wires appear in 
`x::Ifcontent`, and `equality::Vector{Tuple{Wireexpr, Wireexpr}}`, 
which contains tuples of two `Wireexpr`s which are supposed to be of the same width.
"""
function wireextract(x::Ifcontent)
    declonly = Wireexpr[]
    equality = Tuple{Wireexpr, Wireexpr}[]

    wireextract!(x, declonly, equality)
    declonly, equality
end

"""
    wireextract!(x::Ifcontent, declonly, equality)

Helper function for [`wireextract`](@ref). 
Add constraints to `declonly` and `equality`.
"""
function wireextract!(x::Ifcontent, declonly, equality)
    for i in x.assigns 
        push!(equality, (i.lhs, i.rhs))
    end

    for i in x.ifelseblocks
        push!(declonly, i.conds...)
        map(y -> wireextract!(y, declonly, equality), i.contents)
    end

    for i in x.cases 
        push!(declonly, i.condwire)
        for (uno, dos) in i.conds 
            push!(declonly, uno)
            wireextract!(dos, declonly, equality)
        end
    end
end


"update julia to v1.8 and replace with `wirewidid::Int = 0`."
wirewidid = 0

"Value which indicates that the `Wirewid` object does not have a valid value."
const wwinvalid = -1

struct Wirewid 
    id::Int 
    "`wwinvalid` for undef val"
    val::Int
end

function Wirewid(v)
    global wirewidid += 1
    Wirewid(wirewidid, v)
end

Wirewid() = Wirewid(wwinvalid)


"Environment in which wire width inference is done."
struct Vmodenv
    prms::Parameters
    prts::Ports
    lprms::Localparams
    dcls::Decls
end

"""
    Vmodenv()

Create an empty `Vmodenv` object.
"""
Vmodenv() = Vmodenv(Parameters(), Ports(), Localparams(), Decls())


"""
    findandpush_widunify!(newval::String, envdicts, ansset, widvars)

Looking inside envdicts, add `newval` to `ansset` and `widvars`
if `newval` is not in `envdicts`.
"""
function findandpush_widunify!(newval::String, envdicts, ansset, widvars)
    dictans = map(d -> get(d, newval, nothing), envdicts)
    
    if all(x -> x == nothing, dictans)
        v = get(ansset, newval, nothing)
        if v == nothing
            widvar = Wirewid()
            ansset[newval] = widvar
            widvars[widvar] = [newval]
        end
    end

    return nothing
end

"""
    wirepush_widunify!(w::Wireexpr, envdicts, ansset, widvars)

Push every wire that appears inside `w` to `ansset` and `widvars`.
"""
function wirepush_widunify!(w::Wireexpr, envdicts, ansset, widvars)
    f!(x) = findandpush_widunify!(x, envdicts, ansset, widvars)
    g!(x) = wirepush_widunify!(x, envdicts, ansset, widvars)

    op = w.operation
    if op == id 
        f!(w.name)
    elseif op == slice 
        map((x -> g!(x)), w.subnodes)

    elseif op in wunaop || op in wbinop 
        map((x -> g!(x)), w.subnodes)
    end

    return nothing
end

"""
    eqwidflatten!(x::Wireexpr, envdicts, ansset, eqwids::Vector{Wirewid})

Extract wires that appear inside `x` which are of the same width as `x` itself, 
find `Wirewid` objects which correspond to the wire and push them into `eqwids`.
When slice appears inside `x`, new Wirewid object is created and then added to `eqwids`.
"""
function eqwidflatten!(x::Wireexpr, envdicts, ansset, eqwids::Vector{Wirewid})
    f!(xx) = eqwidflatten!(xx, envdicts, ansset, eqwids)

    op = x.operation 
    if op == neg
        # unary bitwise operator
        f!(x.subnodes[1])
    elseif op in wunaop 
        # reduction
        push!(eqwids, Wirewid(1))
    elseif op == lshift || op == rshift 
        f!(x.subnodes[1])
    elseif op in wbinop
        f!.(x.subnodes[1:2])
    elseif op == id 
        widnow = nothing
        for d in (envdicts..., ansset)
            widnow = get(d, x.name, nothing)
            if widnow != nothing 
                break
            end
        end
        @assert widnow != nothing

        push!(eqwids, widnow)

    elseif op == slice 
        if length(x.subnodes) == 2
            # e.g. x[1] --> bit select
            push!(eqwids, Wirewid(1))
        elseif length(x.subnodes) == 3
            # x[m:2], y[3:0]
            indexes = view(x.subnodes, 2:3)
            if all(w -> w.operation == literal, indexes)
                widval = abs(indexes[1].value - indexes[2].value) + 1
                push!(eqwids, Wirewid(widval))
            end
        end

    elseif op == literal
        bw = x.bitwidth
        if bw > 0
            push!(eqwids, Wirewid(bw))
        end
    end

    return nothing
end


"""
    declonly_widunify!(declonly, envdicts, ansset, widvars)

Called in [`widunify`](@ref), push wires that appear in `declonly`.
"""
function declonly_widunify!(declonly, envdicts, ansset, widvars)
    for w in declonly
        wirepush_widunify!(w, envdicts, ansset, widvars)
    end
    return nothing 
end

"""
    equality_widunify!(equality, envdicts, ansset, widvars)

Called in [`widunify`](@ref), infer wire width from `equality` constraints.
Supposed be called after [`declonly_widunify!`](@ref).
"""
function equality_widunify!(equality, envdicts, ansset, widvars)
    for (lhs, rhs) in equality
        # push every wires in lhs/rhs first
        # if wire isn't declared, add new Wirewid to `ansset` and `widvars`
        wirepush_widunify!(lhs, envdicts, ansset, widvars)
        wirepush_widunify!(rhs, envdicts, ansset, widvars)
        
        # no consideration on wire concats?
        # from lhs/rhs pick all `Wirewid`s whose value should be the same
        eqwids = Wirewid[]
        eqwidflatten!(lhs, envdicts, ansset, eqwids)
        eqwidflatten!(rhs, envdicts, ansset, eqwids)
        unique!(eqwids)

        # unify, determine width value
        widhere = wwinvalid
        for ww in eqwids 
            if ww.val != wwinvalid
                if widhere == wwinvalid 
                    widhere = ww.val 
                else
                    if widhere != ww.val 
                        throw(error("width inference failure in $(string(lhs)) <=> $(string(rhs))."))
                    end
                end
            end
        end

        # finally,
        if widhere != wwinvalid
            # register concrete width value
            newwid = Wirewid(widhere)
            for ww in eqwids
                if ww.val == wwinvalid
                    # otherwise ww is not contained in `widvars`

                    # ww may be of `parameters`, `localparams`
                    updatee = pop!(widvars, ww, String[])
                    for item in updatee 
                        ansset[item] = newwid
                    end 
                end
            end
        else 
            # concrete width value is not determined, do unify only
            newwid = argmax(
                (
                    x -> length(
                        get(widvars, x, String[])
                    )
                ),
                eqwids
            )


            lst = get(widvars, newwid, nothing)
            if lst != nothing
                for ww in eqwids
                    if ww != newwid 
                        removing = pop!(widvars, ww, String[])
                        push!(lst, removing...)

                        for item in removing 
                            ansset[item] = newwid
                        end
                    end
                end
            end 

        end

    end

    return nothing
end

"""
    widunify(declonly::Vector{Wireexpr}, equality::Vector{Tuple{Wireexpr, Wireexpr}}, env::Vmodenv)

Given `declonly` and `equality` from [`wireextract`](@ref), 
infer width of wires which appear in the conditions.
"""
function widunify(declonly::Vector{Wireexpr}, 
    equality::Vector{Tuple{Wireexpr, Wireexpr}}, env::Vmodenv)
    # prms, prts, lprms, dcls = map(x -> getfield(env, x), fieldnames(Vmodenv))
    prms = env.prms 
    prts = env.prts 
    lprms = env.lprms 
    dcls = env.dcls

    prmdict = Dict([p.name => Wirewid() for p in prms.val])
    lprmdict = Dict([p.name => Wirewid() for p in lprms.val])

    prtdict = Dict([p.name => Wirewid(p.width) for p in prts.val])
    dcldict = Dict([d.name => Wirewid(d.width) for d in dcls.val])

    envdicts = (prmdict, prtdict, lprmdict, dcldict)

    # may contain Wirewid with both wwinvalid and a valid value
    ansset = Dict{String, Wirewid}()
    # only contain Wireval whose val field == wwinvalid
    widvars = Dict{Wirewid, Vector{String}}()

    # helper functions
    declonly_widunify!(declonly, envdicts, ansset, widvars)
    equality_widunify!(equality, envdicts, ansset, widvars)

    ansset, widvars 
end


"""
    widunify(declonly::Vector{Wireexpr}, equality::Vector{Tuple{Wireexpr, Wireexpr}})

Call `widunify` under an empty `env` (, where no ports, parameters,... are declared).
"""
function widunify(declonly::Vector{Wireexpr}, 
    equality::Vector{Tuple{Wireexpr, Wireexpr}})

    widunify(declonly, equality, Vmodenv())
end


"Error thrown when wire width inferenece is not possible."
struct WirewidthUnresolved <: Exception 
    mes::String
end

Base.showerror(io::IO, e::WirewidthUnresolved) = print(
    io, "Wire width cannot be inferred for the following wires.\n", e.mes
)

"""
    strwidunknown(widvars)

Format `widvars`, returned from [`widunify`](@ref), to a string.
"""
function strwidunknown(widvars)
    # sort by the first element of wire names
    debuglst = sort([i for i in widvars], by=(x -> x[2][1]))
    txt = ""
    for (ind, (var, lst)) in enumerate(debuglst)
        txt *= "$(ind). "
        subtxt = reduce((x, y) -> x * " = " * y, lst)
        txt *= subtxt
        txt *= "\n"
    end

    rstrip(txt)
end


"""
    autodecl(x::Ifcontent, env::Vmodenv)

Declare wires in `x::Ifcontent` which are not yet declared in `env`.
Raise error when not enough information to determine width of all wires is given.

# Examples 

## Inference Success 

```jldoctest
pts = @ports (
        @in 16 din;
        @in b1
)
env = Vmodenv(Parameters(), pts, Localparams(), Decls())

c = @ifcontent (
    reg1 = 0;
    reg2 = din;
    if b1 
        reg1 = din[10:7]
    end
) 

newds = autodecl(c, env)
vshow(newds)

# output

reg [3:0] reg1;
reg [15:0] reg2;
type: Decls
```

## Fail in Inference

```jldoctest
c = @ifcontent (
    reg1 = 0;
    reg2 = din;
    if b1 
        reg1 = din[10:7]
    end
) 

autodecl(c)

# output

ERROR: Wire width cannot be inferred for the following wires.
1. b1
2. reg2 = din
```

"""
function autodecl(x::Ifcontent, env::Vmodenv)
    don, equ = wireextract(x)
    ansset, widvars = widunify(don, equ, env)

    length(widvars) == 0 || throw(
        WirewidthUnresolved(
            strwidunknown(widvars)
        )
    )

    newdecls = [Onedecl(reg, ww.val, n) for (n, ww) in ansset]
    sort!(newdecls, by=(x -> x.name))
    Decls(newdecls)
end

"""
    autodecl(x::Ifcontent)

Call `autodecl` under an empty environment.
"""
function autodecl(x::Ifcontent)
    autodecl(x, Vmodenv())
end