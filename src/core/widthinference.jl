"Value which indicates that the `Wirewid` object does not have a valid value."
const WWINVALID::Wireexpr = Wireexpr(-1)

eachfieldconstruct(Vmodenv)

"""
    Vmodenv()

Create an empty `Vmodenv` object.
"""
Vmodenv() = Vmodenv(Parameters(), Ports(), Localparams(), Decls())
Vmodenv(m::Vmodule) = Vmodenv(m.params, m.ports, m.lparams, m.decls)

"""
    extract2dreg(x::Vector{Onedecl})

Extract 2d regs as dict object from `x`.
"""
function extract2dreg(x::Vector{Onedecl})::Dict{String, Onedecl}
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

"""Store values needed to infer wire widths."""
struct WidthConstraint
    equality::Vector{NTuple{2, Int}}
    name2id::Dict{String, Int}
    id2wid::Dict{Int, Wireexpr}
    
    "id whose width can be inferred from wire, preprocess and convert into id2wid"
    id2wire::Dict{Int, Wireexpr}

    "store all wires associated with id for debugging purpose"
    id2wireAll::Vector{Wireexpr}
end

function Base.broadcastable(x::WidthConstraint)
    Ref(x)
end

WidthConstraint() = WidthConstraint(Vector{Tuple{Int, Int}}(), Dict{String, Int}(), Dict{Int, Wireexpr}(), Dict{Int, Wireexpr}(), Vector{Wireexpr}())

function dumpConstraint(x::WidthConstraint)
    dumpDictInConstraint(x.equality, "wid1" => "wid2", "equality")
    dumpDictInConstraint(x.name2id, "name" => "id", "name2id")
    dumpDictInConstraint(x.id2wid, "id" => "wid", "id2wid")
    dumpDictInConstraint(x.id2wire, "id" => "wire", "id2wire (unresolved)")

    # dumpDictInConstraint(x.id2wireAll, "idAll" => "wireAll", "id2wireAll")
    println("$(length(x.id2wireAll)) items in id2wireAll (current total widvar: $(getTotalWidvar()))")
    
    buf = IOBuffer()
    for item in x.id2wireAll
        write(buf, string(item))
        write(buf, ", ")
    end
    println(String(take!(buf)))
end
function dumpDictInConstraint(d, names, title)
    keyName, valueName = names
    println("Dumping $title")
    for (k, v) in d
        println("  ", "($keyName) $(string(k)) => ($valueName) $(string(v))")
    end
end

"""Identifier to represent wire width variable."""
WidvarId::Int = 0

function generateWidvarId()
    global WidvarId
    WidvarId += 1
    return WidvarId
end

function initializeWidvarId()
    global WidvarId
    WidvarId = 0
    return nothing
end

function getTotalWidvar()
    return WidvarId
end

function extractConstraintsCore!(x::Wireexpr, constraint::WidthConstraint)::Int
    op = x.operation

    if op == neg
        # neg is the only bitwise opearator in unary ones
        return extractConstraintsCore!(x.subnodes[], constraint)
    elseif op in wunaop
        # reduction
        extractConstraintsCore!(x.subnodes[], constraint)

        widvarId = generateWidvarId()
        constraint.id2wid[widvarId] = Wireexpr(1)
        push!(constraint.id2wireAll, x)
        return widvarId
    elseif op == lshift || op == rshift
        # e.g. In case of `a << b`, width of `b` can be of any value, 
        # width(a << b) == width(a)
        extractConstraintsCore!(x.subnodes[2], constraint)
        return extractConstraintsCore!(x.subnodes[1], constraint)
    elseif op in (logieq, lt, leq)
        wid1 = extractConstraintsCore!(x.subnodes[1], constraint)
        wid2 = extractConstraintsCore!(x.subnodes[2], constraint)
        
        thisWid = generateWidvarId()
        constraint.id2wid[thisWid] = Wireexpr(1)
        push!(constraint.equality, (wid1, wid2))
        push!(constraint.id2wireAll, x)
        return thisWid
    elseif op in wbinop
        # binary operator other than shifting and logical comparison
        wids = extractConstraintsCore!.(x.subnodes, constraint)
        push!(constraint.equality, (wids[1], wids[2]))
        return wids[begin]
    elseif op == id
        if x.name in keys(constraint.name2id)
            return constraint.name2id[x.name]
        else
            widvarId = generateWidvarId()
            constraint.name2id[x.name] = widvarId
            push!(constraint.id2wireAll, x)
            return widvarId
        end
    elseif op == slice
        @assert length(x.subnodes) == 2 || length(x.subnodes) == 3
        extractConstraintsCore!.(x.subnodes, constraint)

        # width of x cannot be fully inferred without additional information
        # e.g. `r[2]` may be one bit wide and also may be n-bit wide if `r` is a 2d reg
        # pass
        widvarId = generateWidvarId()
        # leave further processing to preprocess phase
        # e.g. detecting whether slicing is applied to 1d or 2d wire
        constraint.id2wire[widvarId] = x
        push!(constraint.id2wireAll, x)
        return widvarId
    elseif op == ipselm
        extractConstraintsCore!.(x.subnodes[2:3], constraint)
        
        widvarId = generateWidvarId()
        # leave consequent processing to preprocess phase
        constraint.id2wire[widvarId] = x
        push!(constraint.id2wireAll, x)
        return widvarId
    elseif op == literal
        widvarId = generateWidvarId()
        bw = x.bitwidth
        if bw > 0
            constraint.id2wid[widvarId] = Wireexpr(bw)
        end
        push!(constraint.id2wireAll, x)
        return widvarId
    end
end

function extractConstraints!(x::Alassign, constraint)
    widLhs = extractConstraintsCore!(x.lhs, constraint)
    widRhs = extractConstraintsCore!(x.rhs, constraint)
    push!(constraint.equality, (widLhs, widRhs))

    return nothing
end

function extractConstraints!(x::Wireexpr, constraint)
    extractConstraintsCore!(x, constraint)
    return nothing
end

function extractConstraints!(x::Vector{T}, constraint) where {T}
    for item in x
        extractConstraints!(item, constraint)
    end
    return nothing
end


function extractConstraints!(x::Ifelseblock, constraint)
    # TODO: what is the width of condition? 1bit-long only?
    extractConstraints!.((x.conds, x.contents), constraint)
    return nothing
end

function extractConstraints!(x::Ifcontent, constraint)
    extractConstraints!.((x.assigns, x.ifelseblocks, x.cases), constraint)
    return nothing
end

function extractConstraints!(x::Case, constraint)
    extractConstraints!(x.condwire, constraint)
    for (w::Wireexpr, cont::Ifcontent) in x.conds
        extractConstraints!(w, constraint)
        extractConstraints!(cont, constraint)
    end
    return nothing
end

function extractConstraints!(x::Alwayscontent, constraint)
    extractConstraints!(x.content, constraint)
    return nothing
end

function extractConstraints!(x::Onelocalparam, constraint)
    extractConstraints!(x.val, constraint)
    return nothing
end

function extractConstraints(x)
    constraint = WidthConstraint()
    initializeWidvarId()

    extractConstraints!(x, constraint)
    return constraint
end

function uniqueNameToWidvar!(equality, ansset)::Dict{String, Wirewid}
    newAnsSet = Dict{String, Wirewid}()
    for (name::String, wid::Wirewid) in ansset
        if !(name in keys(newAnsSet))
            newAnsSet[name] = wid
        else
            push!(equality, (wid, newAnsSet[name]))
        end
    end

    return newAnsSet
end

struct Reg2dInfo
    # pairs of 2d reg names and its width (not depth)
    nameToWidth::Dict{String, Wireexpr}
end
"""Error raised when slicing on 2d-array is attempted."""
struct SliceOnTwoDemensionalLogic <: Exception
    cause::Wireexpr
end
function Base.showerror(io::IO, e::SliceOnTwoDemensionalLogic)
    print(io, "Slicing $(string(e.cause.subnodes[begin])) which is a 2D logic (at $(string(e.cause)))")
end

"""
    resolveSliceWidth!(constraint::WidthConstraint, info::Reg2dInfo)

Determine the width of slices (e.g. `wire1[A], reg2[4:1]`) in `constraint.id2wire` 
"""
function resolveSliceWidth!(constraint::WidthConstraint, info::Reg2dInfo)
    id2wid = constraint.id2wid
    for (widvarId::Int, wire::Wireexpr) in constraint.id2wire
        op = wire.operation
        if op == slice
            # sanity, true for all wires
            @assert wire.subnodes[1].operation == id
            if length(wire.subnodes) == 2
                slicedName = getname(wire.subnodes[1])
                id2wid[widvarId] = (
                    if slicedName in keys(info.nameToWidth)
                        info.nameToWidth[slicedName]
                    else
                        Wireexpr(1)
                    end
                )
            else
                # sanity, true for all wires
                @assert length(wire.subnodes) == 3
                !(getname(wire.subnodes[1]) in keys(info.nameToWidth)) || throw(SliceOnTwoDemensionalLogic(wire))

                indexes = view(wire.subnodes, 2:3)
                if all(w -> w.operation == literal, indexes)
                    width = abs(indexes[1].value - indexes[2].value) + 1
                    id2wid[widvarId] = Wireexpr(width)
                else
                    # what if w0[1+3:0] ... ???
                    width = @wireexpr $(indexes[1]) - $(indexes[2]) + 1
                    id2wid[widvarId] = width
                end
            end
        else
            vshow(wire)
            error("While preprocessing id2wire, encountered unacceptable value")
        end
    end
    return nothing
end

"""
    addDeclarationInfo!(constraint::WidthConstraint, declarations::T) where {T<:Union{Ports,Decls}}

Add width information obtained from `declarations` into `constraint`.
"""
function addDeclarationInfo!(constraint::WidthConstraint, declarations::T) where {T<:Union{Ports,Decls}}
    for item in declarations
        name = getname(item)
        width = getwidth(item)

        widId = get(constraint.name2id, name, nothing)

        # TODO: generate warning when declaring wires which is not used at all

        @assert isnothing(widId) || !(widId in keys(constraint.id2wid))
        if !isnothing(widId)
            constraint.id2wid[widId] = width
        else
            # unused wire declaration
            # add entry to dict only for supressing key error in updateUnknownWidth
            widId = generateWidvarId()
            constraint.name2id[name] = widId
            constraint.id2wid[widId] = width
            push!(constraint.id2wireAll, Wireexpr(name))
        end
    end
    return nothing
end

"""
    addParameterInfo!(constraint::WidthConstraint, info::T) where {T <: Union{Localparams}}

Exclude items in `info` from target of wire width inference.

Localparam with explicit width declaration is not yet implemented.
As a workaround we treat localparam as wire of unknown width.
"""
function addParameterInfo!(constraint::WidthConstraint, info::T) where {T <: Union{Localparams}}
    for item in info
        # localparam is not the target of width inference
        pop!(constraint.name2id, item.name, nothing)
    end
    return nothing
end

"""Error to be raised when wire width conflict is detected."""
struct WireWidthConflict <: Exception 
    wires::Vector{Wireexpr}
    widths::Vector{Wireexpr}
end

function Base.showerror(io::IO, e::WireWidthConflict)
    println(io, "Wire Width Conflict Detected")
    println(io, "WIRE -> WIDTH")
    bodyStarted = false
    for (wire, width) in zip(e.wires, e.widths)
        if bodyStarted
            print(io, "\n")
        else
            bodyStarted = true
        end
        print(io, "  ", string(wire), " : ", isequal(width, WWINVALID) ? "Unspecified" : string(width))
    end
end

function widUpdated_uuw(x::Oneport, w::Wireexpr)
    return Oneport(getdirec(x), getwiretype(x), w, getname(x))
end
function widUpdated_uuw(x::Onedecl, w::Wireexpr)
    return Onedecl(x.wtype, w, getname(x), x.is2d, x.wid2d)
end

"""
    updateUnknownWidth(tree::UnionFindTree, container::T, name2id, groupToWid) where {T <: Union{Ports, Decls}}

Return new `T` object which is constructed updating wires with unknown width in `container`
by actual width value.
"""
@generated function updateUnknownWidth(tree::UnionFindTree, container::T, name2id, groupToWid) where {T <: Union{Ports, Decls}}
    itemType = container == Ports ? Oneport : Onedecl
    quote
        newItems = Vector{$itemType}(undef, length(container))
        for (ind, item) in enumerate(container)
            # can even infer width for 2d reg
            if isequal(getwidth(item), WWINVALID)
                widId = name2id[getname(item)]
                widIdGroup = getRoot(widId, tree)
                wid = groupToWid[widIdGroup]
                item = widUpdated_uuw(item, wid)
            end
            # if getname(item) in keys(isNameVisited)
            #     isNameVisited[getname(item)] = true
            # end
            newItems[ind] = item
        end
        widthAssigned = $T(newItems)
        return widthAssigned
    end
end

"""
    unifyEquality(equality)

Body of width inference.

Given list of pairs of wire-width-id (identifier which represents width),
group ids that are inferred to be representing the same width.

Adopt union-find-tree as an internal implementation of grouping.
"""
function unifyEquality(equality)
    tree = UnionFindTree(getTotalWidvar())
    for (wid1, wid2) in equality
        uniteTree(wid1, wid2, tree)
    end
    return tree
end

"""
    treeToWidthGroup(tree::UnionFindTree)

Take a return value from [unifyEquality](@ref) as an argument and
generate a list of sets, each of which contains ids that represent the same width.
"""
function treeToWidthGroup(tree::UnionFindTree)
    widthGroup = Dict{Int, Set{Int}}()
    for i in 1:getTotalWidvar()
        parent = getRoot(i, tree)
        if parent in keys(widthGroup)
            push!(widthGroup[parent], i)
        else
            widthGroup[parent] = Set(i)
        end
    end
    return widthGroup
end

"""
    mapGroupToWidth(widthGroup::Dict{Int, Set{Int}}, constraint::WidthConstraint)

Take an output from [treeToWidthGroup](@ref) and map each group to actual width(`::Wireexpr`).

As a representative of each group we adopt the root width-id in the tree passed to [treeToWidthGroup](@ref).
"""
function mapGroupToWidth(widthGroup::Dict{Int, Set{Int}}, constraint::WidthConstraint)
    groupToWid = Dict{Int, Wireexpr}()
    for (parent, group) in widthGroup
        width = WWINVALID
        for widId in group
            currentWidth = get(constraint.id2wid, widId, WWINVALID)
            if isequal(width, WWINVALID)
                width = currentWidth
            elseif !isequal(currentWidth, WWINVALID)
                if !isequal(width, currentWidth)
                    e = WireWidthConflict(
                        [constraint.id2wireAll[i] for i in group],
                        [get(constraint.id2wid, i, WWINVALID) for i in group]
                    )
                    throw(e)
                end
            end
        end
        groupToWid[parent] = width
    end
    return groupToWid
end

"""
    generateUndeclaredLogic(env::Vmodenv, tree, name2id, groupToWid)

Generate `Decls` object that contains all wire declarations
which turned out to be required through wire width inference.
"""
function generateUndeclaredLogic(env::Vmodenv, tree, name2id, groupToWid)
    names = keys(name2id)
    alreadyDeclared = union(Set(getname.(env.prts)), Set(getname.(env.dcls)))
    generating = filter(x -> !(x in alreadyDeclared), names)
    generatedLogics = Vector{Onedecl}(undef, length(generating))
    for (ind, name) in enumerate(generating)
        widId = name2id[name]
        widIdGroup = getRoot(widId, tree)
        wid = groupToWid[widIdGroup]
        generatedLogics[ind] = Onedecl(logic, wid, name)
    end

    return Decls(generatedLogics)
end

"""
    isWidthUnresolved(widId::Int, tree::UnionFindTree, groupToWid)

Check if wire width value for `widId` has successfully been determined.
"""
function isWidthUnresolved(widId::Int, tree::UnionFindTree, groupToWid)
    root = getRoot(widId, tree)
    wid = groupToWid[root]
    return isequal(wid, WWINVALID)
end

"""Error to be thrown when width of any wires remain unknown."""
struct WidthRemainUnresolved <: Exception
    unresolvedId::Vector{Int}
    unifyTree::UnionFindTree
    widthGroup::Dict{Int, Set{Int}}
    constraint::WidthConstraint
end

function Base.showerror(io::IO, e::WidthRemainUnresolved)
    println(io, "Wire width cannot be inferred for the following wires.")
    visitedRoot = Set{Int}()
    ind = 1
    for (count, widId) in enumerate(e.unresolvedId)
        root = getRoot(widId, e.unifyTree)
        if !(root in visitedRoot)
            push!(visitedRoot, root)
            isFirstItem = true
            for w in sort(collect(e.widthGroup[root]))
                wireNow = e.constraint.id2wireAll[w]
                if wireNow.operation != literal
                    if isFirstItem
                        print(io, "$ind. $(string(wireNow))")
                        isFirstItem = false
                    else
                        print(io, " = $(string(wireNow))")
                    end
                end
            end
            # if all items are of literal then no newline
            if !isFirstItem
                if (count != length(e.unresolvedId))
                    println(io, "")
                end
                ind += 1
            end
        end
    end
end

"""
    errorUnlessWidthResolved(unresolved::Vector{Int}, tree, widthGroup, constraint)

Throw error when `unresolves` in not empty, which indicates that width of some wires remain unknown.
"""
function errorUnlessWidthResolved(unresolved::Vector{Int}, tree, widthGroup, constraint)
    if length(unresolved) > 0
        throw(WidthRemainUnresolved(unresolved, tree, widthGroup, constraint))
    end
    return nothing
end

"""
    autodeclCore(x, env::Vmodenv)

Core of `autodecl`, return `Decls` object of automatically declared wires, 
and `env::Vmodenv` all of whose unknown width value is filled in through width inference.
"""
function autodeclCore(x, env::Vmodenv)
    constraint = extractConstraints(x)
    reg2d = extract2dreg(env.dcls)
    info = Reg2dInfo(Dict([k => v.width for (k, v) in reg2d]))
    
    resolveSliceWidth!(constraint, info)
    addDeclarationInfo!.(constraint, (env.prts, env.dcls))
    addParameterInfo!(constraint, env.lprms)

    tree = unifyEquality(constraint.equality)
    widthGroup = treeToWidthGroup(tree)

    groupToWid = mapGroupToWidth(widthGroup, constraint)
    unresolved = filter(x -> isWidthUnresolved(x, tree, groupToWid), [x[2] for x in constraint.name2id])
    errorUnlessWidthResolved(unresolved, tree, widthGroup, constraint)

    nprts = (updateUnknownWidth(tree, env.prts, constraint.name2id, groupToWid))
    ndcls = (updateUnknownWidth(tree, env.dcls, constraint.name2id, groupToWid))

    autoGenerated = generateUndeclaredLogic(env, tree, constraint.name2id, groupToWid)
    return autoGenerated, Vmodenv(env.prms, nprts, env.lprms, ndcls)
end

"""
    autodeclCore(x)

Call `autodeclCore` under an empty environment.
For debug (test) use.
"""
function autodeclCore(x)
    autodeclCore(x, Vmodenv())
end


"""
    autodecl(x, env::Vmodenv)::Vmodenv

Declare wires in `x` which are not yet declared in `env`.
Raise error when not enough information to determine width of all wires is given.

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
julia> ps = @ports (
       @in 2 x;
       @in -1 y;
       @out @reg A z
       );

julia> ds = @decls (
       @wire -1 w1;
       @wire B w2
       );

julia> ab = @always (
       z <= r1 + r2 + r3;
       r4 <= (y & w1) << r1[1:0];
       r5 <= y + w2
       );

julia> env = Vmodenv(Parameters(), ps, Localparams(), ds);

julia> nenv = autodecl(ab.content, env);

julia> vshow(nenv);
input [1:0] x
input [B-1:0] y
output reg [A-1:0] z

wire [B-1:0] w1;
wire [B-1:0] w2;
logic [A-1:0] r1;
logic [A-1:0] r2;
logic [B-1:0] r5;
logic [A-1:0] r3;
logic [B-1:0] r4;
type: Vmodenv
```


## Fail in Inference

```jldoctest
julia> c = @always (
       reg1 = 0;
       reg2 = din;
       if b1 
           reg1 = din[10:7]
       end
       );

julia> autodecl(c);
ERROR: Wire width cannot be inferred for the following wires.
1. b1
2. reg2 = din
```
"""
function autodecl(x, env::Vmodenv)::Vmodenv
    d, nenv = autodeclCore(x, env)
    vpush!(nenv.dcls, d)
    return nenv
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
