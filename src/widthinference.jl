"""
    wireextract(x)

Extract `Wireexpr`s from `x::Ifcontent`, along with
equality constraints of wire width.

Return `declonly::Vector{Wireexpr}`, which contains wires appear in 
`x::Ifcontent`, and `equality::Vector{Tuple{Wireexpr, Wireexpr}}`, 
which contains tuples of two `Wireexpr`s which are supposed to be of the same width.

Type of `x` is restricted by `wireextract!`.
"""
function wireextract(x)
    declonly = Wireexpr[]
    equality = Tuple{Wireexpr, Wireexpr}[]

    wireextract!(x, declonly, equality)
    declonly, equality
end

"""
    wireextract!(x::Ifcontent, declonly, equality)
 
For `Ifcontent`.
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
        for (cnd, dos) in i.conds 
            # push!(declonly, uno)
            push!(equality, (i.condwire, cnd))
            wireextract!(dos, declonly, equality)
        end
    end
end

"""
    wireextract!(x::Vector{T}, declonly, equality) where {T <: Union{Ifcontent, Alwayscontent}}

For `Vector{Ifcontent/Alwayscontent}`.
"""
function wireextract!(x::Vector{T}, declonly, equality) where {T <: Union{Ifcontent, Alwayscontent}}
    for c in x 
        wireextract!(c, declonly, equality)
    end
end

"""
    wireextract!(x::Alwayscontent, declonly, equality)

For `Alwayscontent`. 
"""
function wireextract!(x::Alwayscontent, declonly, equality)
    if x.atype == ff
        wireextract!(x.sens, declonly, equality)
    end
    wireextract!(x.content, declonly, equality)
end

"""
    wireextract!(x::Sensitivity, declonly, equality)

For `Sensitivity`.
"""
function wireextract!(x::Sensitivity, declonly, equality)
    if x.edge != unknownedge
        push!(declonly, x.sensitive)
    end
end

"Helper function for [`wireextract`](@ref)."
wireextract!


"update julia to v1.8 and replace with `wirewidid::Int = 0`."
wirewidid = 0

"Value which indicates that the `Wirewid` object does not have a valid value."
const wwinvalid = Wireexpr(-1)
# const wwinvalid = -1

struct Wirewid 
    id::Int 
    "`wwinvalid` for undef val"
    val::Wireexpr
    # val::Int
end

function Wirewid(v::Wireexpr)
    global wirewidid += 1
    Wirewid(wirewidid, v)
end

Wirewid(v::Int) = Wirewid(Wireexpr(v))

Wirewid() = Wirewid(wwinvalid)


eachfieldconstruct(Vmodenv)

"""
    Vmodenv()

Create an empty `Vmodenv` object.
"""
Vmodenv() = Vmodenv(Parameters(), Ports(), Localparams(), Decls())
Vmodenv(m::Vmodule) = Vmodenv(m.params, m.ports, m.lparams, m.decls)

"""
    separate_widunknown(v::Vector{Onedecl})

Separate `Onedecls` into the group of wires whose width
is already determined and the group of wires with unknown width.
"""
function separate_widunknown(v::Vector{Onedecl})
    wknown = v[(d->!isequal(d.width, wwinvalid)).(v)]
    wunknown = v[(d->isequal(d.width, wwinvalid)).(v)]
    wknown, wunknown
end

function separate_widunknown(x::Decls)
    Decls.(separate_widunknown(x.val))
end

function separate_widunknown(v::Vector{Oneport})
    pknown = v[(p->!isequal(p.width, wwinvalid)).(v)]
    punknown = v[(p->isequal(p.width, wwinvalid)).(v)]
    pknown, punknown
end

function separate_widunknown(x::Ports)
    Ports.(separate_widunknown(x.val))
end

"""
    unknowndeclpush!(ansset::Dict{String, Wirewid}, widvars::Dict{Wirewid, Vector{String}}, ukports::Ports, ukdecls::Decls)

Register ports/wire declarations of unknown width 
to `ansset` and `widvars`.
"""
function unknowndeclpush!(ansset::Dict{String, Wirewid}, widvars::Dict{Wirewid, Vector{String}},
    ukports::Ports, ukdecls::Decls)

    for p in ukports.val
        n = p.name 
        widvar = Wirewid()
        ansset[n] = widvar
        widvars[widvar] = [n]
    end
    for d in ukdecls.val
        n = d.name
        widvar = Wirewid()
        ansset[n] = widvar
        widvars[widvar] = [n]
    end
end


"""
    extract2dreg(x::Vector{Onedecl})

Extract 2d regs as dict object from `x`.
"""
function extract2dreg(x::Vector{Onedecl})
    ans = Dict{String, Onedecl}()
    for d in x
        if d.is2d 
            # ans[d.name] = d.width
            ans[d.name] = d
        end
    end

    ans 
end

"""
    extract2dreg(x::Decls)

Extract 2d regs as dict object from `x`.
"""
function extract2dreg(x::Decls)
    extract2dreg(x.val)
end

function extract2dreg(x::Vmodule)
    extract2dreg(x.decls)
end


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
    elseif op == slice || op == ipselm
        map((x -> g!(x)), w.subnodes)

    elseif op in wunaop || op in wbinop 
        map((x -> g!(x)), w.subnodes)
    end

    return nothing
end

function wirepush_widunify!(t::Tuple{Wireexpr, Wireexpr}, envdicts, ansset, widvars)
    for w in t 
        wirepush_widunify!(w, envdicts, ansset, widvars)
    end
end

"""
    eqwidflatten!(x::Wireexpr, envdicts, reg2d, ansset, eqwids::Vector{Wirewid}, declonly, equality)

Extract wires that appear inside `x` which are of the same width as `x` itself, 
find `Wirewid` objects which correspond to the wire and push them into `eqwids`.
When slice appears inside `x`, new Wirewid object is created and then added to `eqwids`.
"""
function eqwidflatten!(x::Wireexpr, envdicts, reg2d, ansset, eqwids::Vector{Wirewid}, declonly, equality)
    f!(xx) = eqwidflatten!(xx, envdicts, reg2d, ansset, eqwids, declonly, equality)

    op = x.operation 
    if op == neg
        # unary bitwise operator
        f!(x.subnodes[1])
    elseif op in wunaop 
        # reduction
        push!(eqwids, Wirewid(1))
        push!(declonly, x.subnodes[])
    elseif op == lshift || op == rshift 
        f!(x.subnodes[1])
    elseif op in (logieq, lt, leq)
        push!(eqwids, Wirewid(1))
        push!(equality, tuple(x.subnodes...))
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
        subname = x.subnodes[1].name

        if length(x.subnodes) == 2
            # e.g. x[1] --> bit select or 2d reg
            # subname = x.subnodes[1].name
            push!(eqwids, Wirewid(
                    get(reg2d, subname, Wireexpr(1))
                )
            )
        elseif length(x.subnodes) == 3
            # x[m:2], y[3:0]
            # error if 2d reg
            !(subname in keys(reg2d)) || error(
                "2d reg $(subname) is sliced at [$(string(x.subnodes[2])):$(string(x.subnodes[3]))]."
            )

            indexes = view(x.subnodes, 2:3)
            if all(w -> w.operation == literal, indexes)
                # y[3:0] -> width(y) == 4
                widval = abs(indexes[1].value - indexes[2].value) + 1
                push!(eqwids, Wirewid(widval))
            else 
                # x[m:2] -> width(x) == (m-2) + 1
                # suppose indexes[1] > indexes[2] ? is this always true?
                widnow = Wirewid(
                    Wireexpr(
                        add, 
                        Wireexpr(
                            minus,
                            indexes[1],
                            indexes[2]
                        ),
                        Wireexpr(1)
                    )
                )
                push!(eqwids, widnow)
            end

        end

    elseif op == ipselm
        push!(eqwids, Wirewid(x.subnodes[3]))

    elseif op == literal
        bw = x.bitwidth
        if bw > 0
            push!(eqwids, Wirewid(bw))
        end
    end

    return nothing
end

function eqwidflatten!(t::Tuple{Wireexpr, Wireexpr}, envdicts, reg2d, ansset, eqwids::Vector{Wirewid}, declonly, equality)
    for w in t 
        eqwidflatten!(w, envdicts, reg2d, ansset, eqwids, declonly, equality)
    end
end

# """
#     declonly_widunify!(declonly, envdicts, ansset, widvars)

# Called in [`widunify`](@ref), push wires that appear in `declonly`.
# """
# function declonly_widunify!(declonly, envdicts, ansset, widvars)
#     for w in declonly
#         wirepush_widunify!(w, envdicts, ansset, widvars)
#     end
#     return nothing 
# end

function unifycore_errorstr(t::Tuple{Wireexpr, Wireexpr})
    lhs, rhs = t
    string(string(lhs), " <=> ", string(rhs))
end

function unifycore_errorstr(w::Wireexpr)
    string(w)
end

"""
    unifycore_widunify!(items::Vector{T}, envdicts, reg2d, ansset, widvars, declonly, equality) where {T <: Union{Wireexpr, Tuple{Wireexpr, Wireexpr}}}

Called in [`widunify`](@ref), infer wire width from `equality` constraints.

To recursively look into `Wireexpr`s in `items`, push new equality 
and declaration into `declonly` and `equality` given as arguments.
"""
function unifycore_widunify!(items::Vector{T}, envdicts, reg2d, ansset, widvars, declonly, equality) where {T <: Union{Wireexpr, Tuple{Wireexpr, Wireexpr}}}
    for item in items
        # lhs, rhs = item

        # push every wires in lhs/rhs first
        # if wire isn't declared, add new Wirewid to `ansset` and `widvars`
        wirepush_widunify!(item, envdicts, ansset, widvars)
        
        # no consideration on wire concats?
        # from lhs/rhs pick all `Wirewid`s whose value should be the same
        eqwids = Wirewid[]
        eqwidflatten!(item, envdicts, reg2d, ansset, eqwids, declonly, equality)
        unique!(eqwids)

        # unify, determine width value
        widhere = wwinvalid
        for ww in eqwids 
            # if ww.val != wwinvalid
            if !isequal(ww.val, wwinvalid)
                # if widhere == wwinvalid 
                if isequal(widhere, wwinvalid)
                    widhere = ww.val 
                else
                    # if widhere != ww.val 
                    if !isequal(widhere, ww.val)
                        error(
                            "width inference failure in evaluating $(unifycore_errorstr(item)).\n",
                            "width discrepancy between $(string(widhere)) and $(string(ww.val))."
                        )
                    end
                end
            end
        end

        # finally,
        # if widhere != wwinvalid
        if !isequal(widhere, wwinvalid)
            # register concrete width value
            newwid = Wirewid(widhere)
            for ww in eqwids
                # if ww.val == wwinvalid
                if isequal(ww.val, wwinvalid)
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
    envdictsgen_widunify(env::Vmodenv)::Tuple{Dict{String, Wirewid}, Dict{Wirewid, Vector{String}}, NTuple{4, Dict{String, Wirewid}}}

Separate variables with known and unknown width.

Appropriately insert them into the return value `ansset`, `widvars` and `envdicts`.
"""
function envdictsgen_widunify(env::Vmodenv)::Tuple{
    Dict{String, Wirewid},
    Dict{Wirewid, Vector{String}},
    NTuple{4, Dict{String, Wirewid}}
}
    prms = env.prms 
    prts = env.prts 
    lprms = env.lprms 
    dcls = env.dcls

    # separate ports/decls of unknown width
    kprts, ukprts = separate_widunknown(prts)
    kdcls, ukdcls = separate_widunknown(dcls)

    prmdict = Dict([p.name => Wirewid() for p in prms.val])
    lprmdict = Dict([p.name => Wirewid() for p in lprms.val])

    # only data of delc/ports of known width
    prtdict = Dict([(p.name => Wirewid(p.width)) for p in kprts.val])
    dcldict = Dict([d.name => Wirewid(d.width) for d in kdcls.val])

    envdicts = (prmdict, prtdict, lprmdict, dcldict)


    # may contain Wirewid with both wwinvalid and a valid value
    ansset = Dict{String, Wirewid}()
    # only contain Wireval whose val field == wwinvalid
    widvars = Dict{Wirewid, Vector{String}}()

    unknowndeclpush!(ansset, widvars, ukprts, ukdcls)


    ansset, widvars, envdicts
end

"""
    widunify(declonly::Vector{Wireexpr}, equality::Vector{Tuple{Wireexpr, Wireexpr}}, env::Vmodenv)::Tuple{Dict{String, Wirewid}, Dict{Wirewid, Vector{String}}}

Given `declonly` and `equality` from [`wireextract`](@ref), 
infer width of wires which appear in the conditions.
"""
function widunify(declonly::Vector{Wireexpr}, 
    equality::Vector{Tuple{Wireexpr, Wireexpr}}, env::Vmodenv)::Tuple{
        Dict{String, Wirewid},
        Dict{Wirewid, Vector{String}}
    }

    # generate a dict object from env
    ansset, widvars, envdicts = envdictsgen_widunify(env)

    # set of 2d regs
    prereg2d = extract2dreg(env.dcls)
    reg2d = Dict([k=>i.width for (k, i) in prereg2d])

    # helper functions
    while length(declonly) > 0 || length(equality) > 0
        newdonly = Wireexpr[]
        newequal = Tuple{Wireexpr, Wireexpr}[]

        unifycore_widunify!(declonly, envdicts, reg2d, ansset, widvars, newdonly, newequal)
        unifycore_widunify!(equality, envdicts, reg2d, ansset, widvars, newdonly, newequal)
        
        declonly, equality = newdonly, newequal
    end 

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
    portdeclupdated!(env::Vmodenv, ansset::Dict{String, Wirewid})

When env contains ports/wire declarations of unknown width, 
return new `Vmodenv` object whose bitwidth are all filled in.

`ansset` is supposed to contain enough information. 
Data in `ansset` which is used in this method is removed from `ansset`, 
this behavior is essential for `autodecl_core`.
"""
function portdeclupdated!(env::Vmodenv, ansset::Dict{String, Wirewid})

    prenewprts = Vector{Oneport}(undef, length(env.prts.val))
    prenewdcls = Vector{Onedecl}(undef, length(env.dcls.val))

    for (ind, p) in enumerate(env.prts.val)
        if isequal(p.width, wwinvalid)
            # oldd = p.decl
            widhere = pop!(ansset, p.name)
            prenewprts[ind] = Oneport(p.direc, p.wtype, widhere.val, p.name)
        else
            prenewprts[ind] = p 
        end
    end

    for (ind, d) in enumerate(env.dcls.val)
        if isequal(d.width, wwinvalid)
            prenewdcls[ind] = Onedecl(d.wtype, pop!(ansset, d.name).val, d.name)
        else
            prenewdcls[ind] = d 
        end
    end

    Vmodenv(
        env.prms, 
        Ports(prenewprts),
        env.lprms,
        Decls(prenewdcls)
    )
end


"""
    autodecl_core(x, env::Vmodenv)

Core of `autodecl`, return `Decls` object of automatically declared wires, 
and `env::Vmodenv` all of whose unknown width value is filled in through width inference.

Type of `x` is restricted to the type `wireextract!` accepts.
"""
function autodecl_core(x, env::Vmodenv)
    don, equ = wireextract(x)
    ansset, widvars = widunify(don, equ, env)

    length(widvars) == 0 || throw(
        WirewidthUnresolved(
            strwidunknown(widvars)
        )
    )
    # length(widvars) == 0 || error("Wirewidth unresolved, ", strwidunknown(widvars))

    # extract from ansset ports/declarations specified in `env`
    newenv = portdeclupdated!(env, ansset)

    newdecls = [Onedecl(logic, ww.val, n) for (n, ww) in ansset]
    sort!(newdecls, by=(d -> d.name))
    Decls(newdecls), newenv
end

"""
    autodecl_core(x)

Call `autodecl_core` under an empty environment.
For debug (test) use.
"""
function autodecl_core(x)
    autodecl_core(x, Vmodenv())
end

"""
    mergedeclenv(d::Decls, env::Vmodenv)

Merge return value from autodecl_core into a new `Vmodenv` object.
"""
function mergedeclenv(d::Decls, env::Vmodenv)
    Vmodenv(
        env.prms, 
        env.prts,
        env.lprms,
        declmerge(env.dcls, d)
    )
end


"""
    autodecl(x, env::Vmodenv)::Vmodenv

Declare wires in `x` which are not yet declared in `env`.
Raise error when not enough information to determine width of all wires is given.

Type of `x` is restricted to the type `wireextract!` accepts.

# Examples 

## Inference Success 

```jldoctest
pts = @ports (
        @in 16 din;
        @in b1
)
env = Vmodenv(pts)

c = @ifcontent (
    reg1 = 0;
    reg2 = din;
    if b1 
        reg1 = din[10:7]
    end
) 

venv = autodecl(c, env)
vshow(venv)

# output

input [15:0] din
input b1

logic [3:0] reg1;
logic [15:0] reg2;
type: Vmodenv
```

You may also declare ports/wires beforehand
whose width is unknown.

When declaring ports/wires without specifying
its bit width, assign `-1` as its width.

```jldoctest
ps = @ports (
    @in 2 x;
    @in -1 y;
    @out @reg A z
) 
ds = @decls (
    @wire -1 w1;
    @wire B w2
)

ab = @always (
    z <= r1 + r2 + r3;
    r4 <= (y & w1) << r1[1:0];
    r5 <= y + w2
)
env = Vmodenv(Parameters(), ps, Localparams(), ds)
nenv = autodecl(ab.content, env)

vshow(nenv)

# output

input [1:0] x
input [B-1:0] y
output reg [A-1:0] z

wire [B-1:0] w1;
wire [B-1:0] w2;
logic [A-1:0] r1;
logic [A-1:0] r2;
logic [A-1:0] r3;
logic [B-1:0] r4;
logic [B-1:0] r5;
type: Vmodenv
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
function autodecl(x, env::Vmodenv)::Vmodenv
    d, nenv = autodecl_core(x, env)
    mergedeclenv(d, nenv)
end

"""
    autodecl(x)::Vmodenv

Conduct wire width inference under an empty environment.
"""
function autodecl(x)::Vmodenv
    autodecl(x, Vmodenv())
end

"""
    autodecl(x::Vmodule)::Vmodule

Using ports, parameters, localparams, decls in `x::Vmodule` 
as an environment, conduct wire width inference and 
return a new `Vmodule` object with inferred wires.
"""
function autodecl(x::Vmodule)::Vmodule
    env = Vmodenv(x)
    
    nenv = autodecl(x.always, env)
    Vmodule(
        x.name, 
        nenv, 
        x.insts,
        x.assigns, 
        x.always
    )
end
