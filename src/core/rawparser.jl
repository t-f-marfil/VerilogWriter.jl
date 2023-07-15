"""
    removelinenumbernode(args::Vector{T}) where {T}

Remove `LineNumberNode` from `args`.
"""
function removelinenumbernode(args::Vector{T}) where {T}
    args[(x -> !(x isa LineNumberNode)).(args)]
end

"""
    oneparam(expr::Expr)

One parameter. 

# Syntax 
## `<paramname> = <val::Int>`

```jldoctest
julia> vshow(@oneparam x = 10);
parameter x = 10
type: Oneparam
```
"""
function oneparam(expr::Expr)
    args = expr.args
    :(Oneparam($(QuoteNode(args[1])), $(wireexpr(args[2]))))
end

"""
    oneparam(expr::Ref{T}) where {T}

For macro call.
"""
function oneparam(expr::Ref{T}) where {T}
    oneparam(expr[])
end

"""
    @oneparam(arg)

Macro call.
"""
macro oneparam(arg)
    oneparam(arg)
end


"""
    parameters(expr::Expr)

Multiple parameters.

Using `convert` and `localparams` inside.

# Example 
```jldoctest
julia> v = @parameters (
       x = 10;
       y = 20;
       z = 30
       );

julia> vshow(v);
#(
    parameter x = 10,
    parameter y = 20,
    parameter z = 30
)
type: Parameters
```
"""
function parameters(expr::Expr)
    :(convert(Parameters, $(localparams(expr))))
end

"""
    parameters(expr::Ref{T}) where {T}

For macro call.
"""
function parameters(expr::Ref{T}) where {T}
    parameters(expr[])
end

"""
    @parameters(arg)

Macro call.
"""
macro parameters(arg)
    parameters(arg)
end


"""
    onelocalparam(expr::Expr)

One localparam object. The syntax is the same as `oneparam`.
# Example 
```jldoctest
julia> vshow(@onelocalparam x = 100)
localparam x = 100;
type: Onelocalparam
```
"""
function onelocalparam(expr::Expr)
    args = expr.args
    if args[1] isa Expr && args[1].head == :$
        uno = :($(esc(args[1].args[])))
    else
        uno = string(args[1])
    end
    :(Onelocalparam($uno, $(wireexpr(args[2]))))
end

# """
#     onelocalparam(expr::Ref{T}) where {T}

# For macro call.
# """
# function onelocalparam(expr::Ref{T}) where {T}
#     onelocalparam(expr[])
# end

"""
    @onelocalparam(arg)

Macro call.
"""
macro onelocalparam(arg)
    # Expr(:call, onelocalparam, Ref(arg))
    onelocalparam(arg)
end


"""
    localparams(expr::Expr)

Multiple localparams.
# Examples
```jldoctest
julia> p = @localparams x = 10; vshow(p);
localparam x = 10;
type: Localparams
```
```jldoctest
julia> p = @localparams (
       a = 111;
       b = 222;
       c = 333
       );

julia> vshow(p);
localparam a = 111;
localparam b = 222;
localparam c = 333;
type: Localparams
```
"""
function localparams(expr::Expr)
    localparams(expr, Val(expr.head))
end

function localparams(expr::Expr, ::Val{:$})
    return :(Localparams($(esc(expr.args[]))))
end

function localparams(expr::Expr, ::Val{:(=)})
    :(Localparams($(onelocalparam(expr))))
end

function localparams(expr::Expr, ::Val{:block})
    ansv = Expr[]

    for item in expr.args
        if item isa LineNumberNode 
        elseif item isa Oneparam || item isa Onelocalparam 
            push!(ansv, Meta.quot(item))
        elseif item isa Parameters || item isa Localparams 
            push!(ansv, Meta.quot.(item.val)...)
        else
            if item.head == :$
                # Onelocalparam, Localparams, Oneparam, or Parameters
                interpolated = :($(esc(item.args[])))
                bundled = :(Localparams($interpolated))
                push!(ansv, :($bundled...))
            else
                push!(ansv, onelocalparam(item))
            end
        end
    end

    # Localparams(ansv)
    :(Localparams($(Expr(:ref, :Onelocalparam, ansv...))))
    # :(Localparams($(Expr(:ref, :Onelocalparam, [:(Onelocalparam($i)...) for i in ansv]...))))
end

"""
    localparams(expr::Ref{T}) where {T}

For macro call.
"""
function localparams(expr::Ref{T}) where {T}
    localparams(expr[])
end

"""
    @localparams(arg)

Macro version.
"""
macro localparams(arg)
    localparams(arg)
end



"""
    oneblock(expr::Expr)

Parse AST in Julia grammar to one if-else statement or 
one assignment inside always blocks in Verilog, 
which are [Ifelseblock](@ref) and [Alassign](@ref), respectively. 

As using Julia expression and Julia parser as if 
it is of Verilog, there can be difference in grammatical matters 
between what can be given as the `expr` and real Verilog 
(e.g. operator precedence of `<=`).

Returns Expr objects, as this method is supposed to be
called as a helper method for macro call.

# Examples 
```jldoctest oneblock
julia> @testonlyexport(); # `oneblock` is not usually exported

julia> a1 = oneblock(:(w1 <= w2))[2] |> eval; 

julia> vshow(a1);
w1 <= w2;
type: Alassign

julia> a2 = oneblock(:(w3 = w4 + ~w2))[2] |> eval; vshow(a2);
w3 = (w4 + (~w2));
type: Alassign

julia> a3 = oneblock(:(
       if b1 == b2
           w5 = ~w6
           w7 = w8 
       elseif b2 
           w9 = w9 + w10
       else
           if b3 
               w11 = w12 
           end
       end
       ))[2] |> eval;

julia> vshow(a3);
if ((b1 == b2)) begin
    w5 = (~w6);
    w7 = w8;
end else if (b2) begin
    w9 = (w9 + w10);
end else begin
    if (b3) begin
        w11 = w12;
    end
end
type: Ifelseblock
```
"""
function oneblock(expr::Expr)
    head = expr.head

    if head == :if 
        Ifelseblock, ifelseblock(expr)
    elseif head == :(=)
        Alassign, alassign_comb(expr)
    elseif head == :call && expr.args[1] == :<=
        Alassign, alassign_ff(expr)
    elseif head == :block 
        # ifcontent(expr)
        error(":block in oneblock.")
    else
        error("unknown head $(head).")
    end

end

"""
    oneblock(expr::T) where {T <: Union{Alassign, Ifelseblock}}

For interpolation through metaprogramming.
deprecated
"""
function oneblock(expr::T) where {T <: Union{Alassign, Ifelseblock, Case}}
    T, expr 
end

function alassign_comb(expr)
    # Alassign(wireexpr.(expr.args)..., comb)
    :(Alassign($(wireexpr.(expr.args)...), comb))
end
macro alassign_comb(expr)
    alassign_comb(expr)
end

function alassign_ff(expr)
    # Alassign(wireexpr(expr.args[2]), wireexpr(expr.args[3]), ff)
    :(Alassign($(wireexpr(expr.args[2])), $(wireexpr(expr.args[3])), ff))
end
macro alassign_ff(expr)
    alassign_ff(expr)
end


function ifelseblock(expr)

    # cond = expr.args[1]
    cond = (
        if expr.head == :if 
            expr.args[1]
        elseif expr.head == :elseif
            expr.args[1].args[2]
        else
            dump(expr)
            error("unknown expr type.")
        end
    )
    # pcond = wireexpr(cond)::Wireexpr
    pcond = wireexpr(cond)::Expr

    # ifcont = oneblock_expr(expr.args[2], Val(Ifcontent))
    ifcont = ifcontent(expr.args[2])

    if length(expr.args) == 2
        # ans = Ifelseblock(pcond, ifcont)
        ans = :(Ifelseblock($pcond, $ifcont))
    else
        # celse = oneblock_expr(expr.args[3], Val(Ifelseblock))
        tgt = expr.args[3]
        celse = (
            if tgt.head == :elseif 
                ifelseblock(tgt)
            else 
                # Ifelseblock([], [ifcontent(tgt)])
                :(Ifelseblock([], [$(ifcontent(tgt))]))
            end
        )
        # ifadd!(celse, pcond, ifcont)
        # ans = celse
        ans = :(ifadd!($celse, $pcond, $ifcont))
    end

    return ans::Expr
end

function ifcontent(expr)
    # assignlist = Alassign[]
    # ifblocklist = Ifelseblock[]
    assignlist = Expr[]
    ifblocklist = Expr[]
    # wirelist = Wireexpr[]
    lineinfo = nothing

    try
        # top level macro application?
        # e.g.
        # @ifcontent x = y
        if expr.head != :block 
            t, parsed = oneblock(expr)
            if t == Alassign
                push!(assignlist, parsed)
            elseif t == Ifelseblock 
                push!(ifblocklist, parsed)
            # elseif parsed isa Wireexpr 
            #     push!(wirelist, parsed)
            else
                @show parsed, typeof(parsed)
                error("unexpected branch.")
            end

        # parse block.
        else

            # expr.head == :block || (dump(expr); error("unknown expr."))

            lineinfo = LineNumberNode(0, "noinfo")

            for item in expr.args 
                if item isa LineNumberNode
                    lineinfo = item 
                else
                    t, parsed = oneblock(item)
                    # push!(anslist, parsed)
                    
                    if t == Alassign
                        push!(assignlist, parsed)
                    elseif t == Ifelseblock 
                        push!(ifblocklist, parsed)
                    # elseif parsed isa Wireexpr 
                    #     push!(wirelist, parsed)
                    else
                        @show parsed, typeof(parsed)
                        error("unexpected branch.")
                    end
                end
            end
        end
    catch e 
        println("failed in parsing, inner block at: $(string(lineinfo))")
        # dump(lineinfo)
        rethrow()
    end

    # return Ifcontent(assignlist, ifblocklist)
    return :(Ifcontent($(Expr(:ref, :Alassign, assignlist...)), $(Expr(:ref, :Ifelseblock, ifblocklist...))))
    # return blockconv(assignlist, ifblocklist, wirelist, Val(T))
end


"""
    wireexpr(expr::QuoteNode)

For indexed part select.
"""
function wireexpr(expr::QuoteNode)
    wireexpr(expr.value)
end

"""
    wireexpr(expr, ::Val{:quote})

For indexed part select.
"""
function wireexpr(expr, ::Val{:quote})
    wireexpr(expr.args[1])
end

"""
    wireexpr(expr, ::Val{:ref})

Bit select or slice of wires, e.g. `x[1]` and `x[p:1]`.
"""
function wireexpr(expr, ::Val{:ref})
    body = wireexpr(expr.args[1])

    # sl = wireexpr(expr.args[2])
    # # length(sl) may be 1 or 2
    # Wireexpr(slice, body, sl...)

    rngexpr = expr.args[2]
    if (
        rngexpr isa Expr
        && rngexpr.head == :call 
        && rngexpr.args[1] == :(:)
    )
        # Wireexpr(slice, body, wireexpr(rngexpr)...)
        :(Wireexpr(slice, $body, $(wireexpr(rngexpr)...)))
    elseif (
        rngexpr isa Expr 
        && rngexpr.head == :call 
        && (
            rngexpr.args[3] isa QuoteNode
            || (rngexpr.args[3] isa Expr && rngexpr.args[3].head == :quote)
        )
    )
        rngexpr.args[1] == :- || error(
            "$(rngexpr.args[1]) not supported for indexed part select."
        )

        # Wireexpr(
        #     ipselm, 
        #     wirenoname,
        #     [
        #         body,
        #         wireexpr(rngexpr.args[2]), 
        #         wireexpr(rngexpr.args[3])
        #     ],
        #     wirevalinvalid, 
        #     wirevalinvalid
        # )
        quote
            Wireexpr(
                ipselm, 
                wirenoname,
                [
                    $body,
                    $(wireexpr(rngexpr.args[2])), 
                    $(wireexpr(rngexpr.args[3]))
                ],
                wirevalinvalid, 
                wirevalinvalid
            )
        end
    else
        # Wireexpr(slice, body, wireexpr(rngexpr))
        :(Wireexpr(slice, $body, $(wireexpr(rngexpr))))
    end
end

# function wireexpr(expr::T) where {T <: Union{Symbol, Int, String}}
#     # return Wireexpr(expr)
#     :($(Wireexpr(expr)))
# end
function wireexpr(expr::T) where {T <: Union{Int, String}}
    # return Wireexpr(expr)
    :(Wireexpr($expr))
end
function wireexpr(expr::Symbol)
    # return Wireexpr(expr)
    :(Wireexpr($(Meta.quot(expr))))
end

function wireexpr(expr::Unsigned)
    # return Wireexpr(Int(expr))
    :(Wireexpr(Int($expr)))
end
"""
    wireexpr(expr::Expr)

Parse one wire expression. Be sure to put 'two e's'
in wir'ee'xpr, not 'wirexpr'.

# Syntax 
Part of what can be done in Verilog can be accepted, 
such as `din[7:0]`, `(w1 + w2) << 5`
## `<wirename>`
One wire, without slicing or bit-selecting.

## `<val::Int>`, `<val::hex>`, `<val::bin>`
Literals, e.g. `5`, `0x1f`, `0b10`.

## `<wire> <op> <wire>`, `<op> <wire>`
Unary and binary operators. 
For reduction operators (unary `&, |, ^`), since these are 
not operators in Julia, write it in the form of function 
call explicitly, i.e. `&(wire)`, `|(wire)` instead of doing `^wire`.
Note that we use `^` as xor just as in Verilog, though this is not 
a xor operator in Julia.

## `<wire>[<wire>:<wire>]`, `<wire>[<wire>]`
Bit select and slicing as in Verilog/SystemVerilog.
Does not reject even if both wires in `[<wire>:<wire>]` are
not of constant value although it is not a valid verilog syntax.

## `wire[<wire>-:<wire>]`
Indexed part select. Does not reject even if `<wire>`
after `-:` is not of constant value.
As using `-` operator and `:` (quote) in Julia syntax, 
no spaces between `<wire>(here)-:(and here)<wire>` are allowed, 
and `<wire>` after `-:` should in most cases be put inside
parentheses.

Note that because `:` (quote) is used inside quote, 
you (for now) cannot embed objects here through Metaprogramming.

e.g. `w = (@wireexpr w); always(:(x[A-:(\$w)] <= y))` is not 
allowed. 

In such cases use constructors instead as shown below.

```jldoctest
julia> e = Wireexpr(ipselm, @wireexpr(x), @wireexpr(A), @wireexpr(w)); # Indexed Part SELect with Minus operator 

julia> @testonlyexport; vshow(oneblock(:(\$(e) <= y))[2] |> eval);
x[A -: w] <= y;
type: Alassign
```

# Examples 
```jldoctest
julia> (@wireexpr w) |> vshow;
w
type: Wireexpr

julia> (@wireexpr w1 & &(w2)) |> vshow;
(w1 & (&(w2)))
type: Wireexpr

julia> (@wireexpr w[i:0]) |> vshow;
w[i:0]
type: Wireexpr

julia> (@wireexpr w[(P*Q)-:(R+10)]) |> vshow;
w[(P * Q) -: (R + 10)]
type: Wireexpr

```
"""
function wireexpr(expr::Expr)
    return wireexpr(expr, Val(expr.head))
end

"""
    wireexpr(expr::Expr, ::Val{:\$})

Handle interpolation on macro call.
"""
function wireexpr(expr::Expr, ::Val{:$})
    # length of expr.args is supposed to be 1
    return :(Wireexpr($(esc(expr.args[]))))
end

"""
    wireexpr(expr::Wireexpr)

Insertion through metaprogramming.
# Example 
```jldoctest
julia> w = @wireexpr x + y;

julia> e = :(a + |(\$(w) & z));

julia> wireexpr(e) |> eval |> vshow;
(a + (|(((x + y) & z))))
type: Wireexpr
```
"""
function wireexpr(expr::Wireexpr)
    # expr 
    :($expr)
end

function wireexpr(expr, ::Val{:call})
    return wireexpr(expr, Val(expr.args[1]), Val(:call))
end

"""
    wireexpr(expr, ::Val{:(:)}, ::Val{:call})

Parse wire slice with range object, e.g. `x[a:b]`.
"""
function wireexpr(expr, ::Val{:(:)}, ::Val{:call})
    msb = expr.args[2]
    lsb = expr.args[3]
    (wireexpr(msb), wireexpr(lsb))
end

const wunasym2op = Dict([Val{item} => key for (key, item) in wunaopdict])
const wbinsym2op = Dict([Val{item} => key for (key, item) in wbinopdict])

const unaopvals = Union{[i for i in keys(wunasym2op)]...}
const binopvals = Union{[i for i in keys(wbinsym2op)]...}

"""
    wireexpr(expr, ::T, ::Val{:call}) where {T <: unaopvals}

Parse unary operators.
"""
function wireexpr(expr, ::T, ::Val{:call}) where {T <: unaopvals}
    uno = wireexpr(expr.args[2])
    # return Wireexpr(wunasym2op[T], uno)
    :(Wireexpr($(wunasym2op[T]), $uno))
end

"""
    wireexpr(expr, ::T, ::Val{:call}) where {T <: binopvals}

Parse binary operators.
"""
function wireexpr(expr, ::T, ::Val{:call}) where {T <: binopvals}
    # length may be > 3, for (+, *) may parsed in adifferent manner
    args = expr.args
    op = wbinsym2op[T]
    # ansnow = Wireexpr(op, wireexpr(args[2]), wireexpr(args[3]))
    ansnow = :(Wireexpr($op, $(wireexpr(args[2])), $(wireexpr(args[3]))))
    
    if length(args) > 3
        for w in wireexpr.(args[4:end])
            # ansnow = Wireexpr(op, ansnow, w)
            ansnow = :(Wireexpr($op, $ansnow, $w))
        end
    end

    return ansnow
end

"""
    wireexpr(expr, ::T, ::Val{:call}) where {T <: arityambigVals}

Disambiguate symbols in `arityambigVals` between 
unary and binary operators.
"""
function wireexpr(expr, ::T, ::Val{:call}) where {T <: arityambigVals}
    args = expr.args
    if length(args) == 2
        # return Wireexpr(wunasym2op[T], wireexpr(args[2]))
        return :(Wireexpr($(wunasym2op[T]), $(wireexpr(args[2]))))
    elseif length(args) == 3
        uno, dos = wireexpr(args[2]), wireexpr(args[3])
        return :(Wireexpr($(wbinsym2op[T]), $uno, $dos))
    end
end

"""
    wireexpr(expr::Expr, ::Val{:&})

Unary `&` parses differently from `|(wire)` and `^(wire)`.
What is `&(wire)` originally used for in Julia?
"""
function wireexpr(expr::Expr, ::Val{:&})
    @assert length(expr.args) == 1
    # Wireexpr(redand, wireexpr(expr.args[1]))
    :(Wireexpr(redand, $(wireexpr(expr.args[1]))))
end

function wireexpr(expr::Expr, ::Val{:||})
    # Wireexpr(
    #     lor,
    #     wireexpr(expr.args[1]),
    #     wireexpr(expr.args[2])
    # )
    quote
        Wireexpr(
            lor,
            $(wireexpr(expr.args[1])),
            $(wireexpr(expr.args[2]))
        )
    end
end

function wireexpr(expr::Expr, ::Val{:&&})
    # Wireexpr(
    #     land,
    #     wireexpr(expr.args[1]),
    #     wireexpr(expr.args[2])
    # )
    quote
        Wireexpr(
            land,
            $(wireexpr(expr.args[1])),
            $(wireexpr(expr.args[2]))
        )
    end
end

macro wireexpr(arg)
    return wireexpr(arg)
end

function wireexpr(expr::Ref{T}) where {T}
    wireexpr(expr[])
end


"""
    ralways(expr::Expr)

Convert Julia AST to Verilog always-block. 

Does not infer type of alwaysblock here.
Dispatches methods here according to `expr.head`.
"""
function ralways(expr::Expr) 
    ralways_expr(expr, Val(expr.head))::Expr
end

function ralways(expr::T...) where {T <: Union{Alassign, Ifelseblock, Case}}
    return :(Alwayscontent($(expr...)))
end

function ralways(expr::Alwayscontent)
    :($expr)
end

"""
    ralways_expr(expr::Expr, ::T) where {T <: Val}

The case where `expr.head` is not `block`, which means
`expr` is one assignment (inside always-block) or an if-else block.
"""
function ralways_expr(expr::Expr, ::T) where {T <: Val}
    # return Alwayscontent(oneblock(expr))
    _, parsed = oneblock(expr)
    return :(Alwayscontent($parsed))
end

"""
    ralwayswithSensitivity(expr)

Parse always block with sensitivity list (e.g. @posedge clk).
"""
function ralwayswithSensitivity(expr)
    alblock = ralways(Expr(expr.head, expr.args[2:end]...))
    sensitivity = expr.args[1]
    # @assert sensitivity.head == :macrocall
    sensitivity.head == :macrocall || error("$(sensitivity) is not a sensitivity list.")
    # sensitivity.args == [:@posedge, linenumnode, arg]
    edge = eval(Meta.parse(string(sensitivity.args[1])[2:end]))
    sens = wireexpr(sensitivity.args[3])

    # alblock.edge = edge 
    # alblock.sensitive = sens 
    ss = :(Sensitivity($edge, $sens))
    # alblock.sens = ss

    # return alblock 
    return :(alblock = $alblock; alblock.sens = $ss; alblock)
end

"""
    ralways_expr(expr::Expr, ::Val{:block})

Convert multiple ifelse-blocks and assigns to one always-block.
"""
function ralways_expr(expr::Expr, ::Val{:block})
    if length(expr.args) > 0 && expr.args[1] isa Expr && expr.args[1].head == :macrocall
        return ralwayswithSensitivity(expr)
    end

    assignlist = Alassign[]
    ifblocklist = Ifelseblock[]
    exprassignlist, exprifblocklist = Expr[], Expr[]
    caselist = Case[]

    lineinfo = LineNumberNode(0, "noinfo")

    try 
        for item in expr.args 
            if item isa LineNumberNode 
                lineinfo = item 
            # for metaprogramming
            # ignores sensitivity list when interpolating `Alwayscontent`
            elseif item isa Case 
                push!(caselist, item)
            elseif item isa Alwayscontent
                push!(assignlist, item.content.assigns...)
                push!(ifblocklist, item.content.ifelseblocks...)
                push!(caselist, item.content.cases...)
            else
                t, parsed = oneblock(item)

                if t == Alassign
                    push!(exprassignlist, parsed)
                elseif t == Ifelseblock 
                    push!(exprifblocklist, parsed)
                else
                    @show parsed, typeof(parsed)
                    error("undefind behavior detected in ralways.")
                end 
            end
        end
    catch e
        println("failed in parsing always, inner block at: $(string(lineinfo))")
        rethrow()
    end

    return :(Alwayscontent(
        [$assignlist; $(Expr(:ref, :Alassign, exprassignlist...))],
        [$ifblocklist; $(Expr(:ref, :Ifelseblock, exprifblocklist...))],
        $caselist
    ))
end

"""
    @ralways(arg)

`ralways` macro version. 
    
Not supposed to be used in most cases, 
[`@always`](@ref) and [`always`](@ref) are often better.
"""
macro ralways(arg)
    return ralways(arg)
end

"""
    ralways(expr::Ref{T}) where {T}

For macro call.
"""
function ralways(expr::Ref{T}) where {T}
    ralways(expr[])
end

"""
    combffsplit(al::Alwayscontent)

Separate blocking and non-blocking assigments to 
two `Alwayscontent` objects.
"""
function combffsplit(al::Alwayscontent)
    combcont, ffcont = combffsplit(getifcont(al))
    alcomb = Alwayscontent(comb, Sensitivity(), combcont)
    alff = Alwayscontent(ff, getsensitivity(al), ffcont)

    return alcomb, alff
end
function combffsplit(cont::Ifcontent)
    combas, ffas = combffsplit(cont.assigns)
    combbl, ffbl = combffsplit(cont.ifelseblocks)
    combcs, ffcs = combffsplit(cont.cases)

    return Ifcontent(combas, combbl, combcs), Ifcontent(ffas, ffbl, ffcs)
end
function combffsplit(v::Vector{Alassign})
    ccount, fcount = 0, 0
    for i in v
        atype = i.atype
        if atype == comb
            ccount += 1
        elseif atype == ff
            fcount += 1
        end
    end
    cvec = Vector{Alassign}(undef, ccount)
    fvec = Vector{Alassign}(undef, fcount)
    cind, find = 0, 0
    for i in v
        atype = i.atype
        if atype == comb
            cvec[cind+=1] = i
        elseif atype == ff
            fvec[find+=1] = i
        end
    end
    return cvec, fvec
end
function combffsplit(v::Vector{T}) where {T}
    totalvec = [combffsplit(i) for i in v]
    combvec, ffvec = Vector{T}(undef, length(v)), Vector{T}(undef, length(v))

    for (i, (c, f)) in enumerate(totalvec)
        combvec[i] = c
        ffvec[i] = f
    end
    return combvec, ffvec
end
function combffsplit(bl::Ifelseblock)
    ccomb::Vector{Ifcontent}, cff = combffsplit(bl.contents)
    return Ifelseblock(bl.conds, ccomb), Ifelseblock(bl.conds, cff)
end
function combffsplit(cs::Case)
    cconds = Vector{Pair{Wireexpr, Ifcontent}}(undef, length(cs.conds))
    fconds = Vector{Pair{Wireexpr, Ifcontent}}(undef, length(cs.conds))
    for (ind, (w, ifc)) in enumerate(cs.conds)
        cifc, fifc = combffsplit(ifc)
        cconds[ind] = w => cifc
        fconds[ind] = w => fifc
    end
    return cconds, fconds
end

"""
    @cpalways(arg)

Compound always, automatically separate blocking and non-blocking
assignments to two different `Alwayscontent` objects.
"""
macro cpalways(arg)
    quote
        combffsplit(@ralways $arg)
    end
end

"""
    ifcontent(x::Ref{T}) where {T}

For macro call.
"""
function ifcontent(x::Ref{T}) where {T}
    ifcontent(x[])
end

"""
    @ifcontent(arg)

Macro call. deprecated
"""
macro ifcontent(arg)
    ifcontent(arg)
end


"""
    portoneline(expr::Expr)

Parse Julia AST to one line of port declaration as [Oneport](@ref).

# Syntax 
## `@in <wirename>`, `@out <wirename>`
One port declaration of width 1.

## `@in/@out <wirename1, wirename2, ...> `
Multiple port declaration of width 1 in one line.

## `@in/@out <width> <wirename1[, wirename2, ...]>`
Port declarations of width `<width>`.

## `@in/@out @<wiretype> [<width>] <wirename1[, wirename2, ...]>`
Port declaration with wiretypes [of width `<width>`].

# Examples
```jldoctest
julia> p1 = @portoneline @in din;

julia> vshow(p1);
input din
type: Oneport

julia> p2 = (@portoneline @out din1, din2, din3); vshow(p2);
output din1
type: Oneport
output din2
type: Oneport
output din3
type: Oneport

julia> p3 = (@portoneline @in 8 din); vshow(p3);
input [7:0] din
type: Oneport

julia> p4 = (@portoneline @out @reg 8 dout); vshow(p4);
output reg [7:0] dout
type: Oneport

julia> p5 = (@portoneline @out (A+B)<<2 x, y); vshow(p5); # width with parameter
output [((A + B) << 2)-1:0] x
type: Oneport
output [((A + B) << 2)-1:0] y
type: Oneport
```
"""
function portoneline(expr::Expr)
    expr.head == :macrocall || error("invalid input.")
    targs = removelinenumbernode(expr.args)

    pdirec = pdirecsym(targs[1])
    if targs[2] isa Expr && targs[2].head == :macrocall 
        pdecls = decloneline(targs[2])
    else
        pdecls = decloneline(:(@wire $(targs[2:end]...)))
    end

    [:((t = $d;Oneport($pdirec, t.wtype, t.width, t.name))) for d in pdecls]
end

"""
    pdirecsym(sym)

Convert  symbols `@in, @out` to `pin, pout (::Portdirec)`.
"""
function pdirecsym(sym)
    if sym == Symbol("@in")
        pin 
    else
        sym == Symbol("@out") || error("$(sym) is not portdirec.")
        pout 
    end
end

"""
    portoneline(expr::Ref{T}) where {T}

For macro call.
"""
function portoneline(expr::Ref{T}) where {T}
    portoneline(expr[])
end

"""
    @portoneline(arg)

Macro version of `portoneline`.
"""
macro portoneline(arg)
    Expr(:ref, :Oneport, portoneline(arg)...)
end

"""
    oneport(expr::Expr) 

Declaration of one `Oneport` object.
"""
function oneport(expr::Expr) 
    v = portoneline(expr)
    length(v) == 1 || error("$(length(v)) ports are declared in oneport.")
    v[begin]
end

"""
    oneport(expr::Ref{T}) where {T}

For macro call.
"""
function oneport(expr::Ref{T}) where {T}
    oneport(expr[])
end

"""
    @oneport(arg)

Macro version of `oneport`.
"""
macro oneport(arg)
    oneport(arg)
end

"""
    ports(expr::Expr)

Convert Julia AST into port declarations as [Ports](@ref) object.

# Syntax 
## `<portoneline>[;<portoneline>;...]`
Multiple lines of [`portoneline`](@ref) expressions 
separated by `;` can be accepted. 

# Example 
```jldoctest
julia> pp = @ports (
       @in p1;
       @in @wire 8 p2, p3, p4;
       @out @reg 2 p5, p6
       );

julia> vshow(pp);
(
    input p1,
    input [7:0] p2,
    input [7:0] p3,
    input [7:0] p4,
    output reg [1:0] p5,
    output reg [1:0] p6
);
type: Ports
```
"""
function ports(expr::Expr)
    return ports(expr, Val(expr.head))
end

"""
    ports(expr::Vector{Oneport})

Insertion through metaprogramming.
# Example 
```jldoctest
julia> a = @portoneline @in 8 d1, d2, d3;

julia> b = @ports (
       @in d0;
       \$a;
       @out @reg 8 dout
       );

julia> vshow(b);
(
    input d0,
    input [7:0] d1,
    input [7:0] d2,
    input [7:0] d3,
    output reg [7:0] dout
);
type: Ports
```
"""
function ports(expr::Vector{Oneport})
    :(Ports($expr))
end

"""
    ports(expr::Ports...)

Interpolation of one Vector{Ports}, nothing else given.
e.g. ports(:(\$([ports(:(@in 6 x)), ports(:(@in y))]...)))
"""
function ports(expr::Ports...)
    :(Ports(reduce(vcat, [e.val for e in $expr])))
end

function ports(expr::Vector{Oneport}...)
    :(Ports(reduce(vcat, $expr)))
end

"""
    ports(expr::Expr, ::Val{:macrocall})

Contain only single line declaration.
"""
function ports(expr::Expr, ::Val{:macrocall})
    return :(Ports($(Expr(:ref, :Oneport, portoneline(expr)...))))
end

"""
    ports(expr::Expr, ::Val{:block})

Contain multiple lines of port declaration.
"""
function ports(expr::Expr, ::Val{:block})
    @assert expr.head == :block 
    anslist = Expr[]

    lineinfo = LineNumberNode(0, "noinfo")
    for item in expr.args 
        if item isa LineNumberNode 
            lineinfo = item
        # for interpolation through metaprogramming
        # 
        # interpolation no longer occurs here
        # elseif item isa Vector{Oneport}
        #     push!(anslist, Meta.quot.(item)...)
        # elseif item isa Ports 
        #     push!(anslist, Meta.quot.(item.val)...)
        else
            if item.head == :$
                interpolated = :($(esc(item.args[])))
                bundled = :(Ports($interpolated))
                push!(anslist, :($bundled...))
            else
                push!(anslist, portoneline(item)...)
            end
        end
    end

    return :(Ports($(Expr(:ref, :Oneport, anslist...))))
end

"""
    ports(expr::Ref{T}) where {T}

For macro call.
"""
function ports(expr::Ref{T}) where {T}
    return ports(expr[])
end

"""
    @ports(arg)

Macro version of `ports`.
"""
macro ports(arg)
    ports(arg)
end


"""
    decloneline(expr::Expr)::Vector{Expr}

Parse Julia AST into wire declaration as Vector{[Onedecl](@ref)}.

The number of `Onedecl` objects returned may differ 
according to the number of wires declared in one line 
(e.g. `input dout` <=> `input din1, din2, din3`).

# Syntax 
Similar to that of [portoneline](@ref).
## `@wire/@reg/@logic [<width>] <wirename1>[, <wirename2>,...]`

# Examples 
```jldoctest
julia> d = (@decloneline @reg 10 d1); vshow(d);
reg [9:0] d1;
type: Onedecl

julia> d = (@decloneline @logic 8 d1,d2,d3); vshow(d);
logic [7:0] d1;
type: Onedecl
logic [7:0] d2;
type: Onedecl
logic [7:0] d3;
type: Onedecl

julia> d = (@decloneline @wire A >> 2 w1, w2); vshow(d);
wire [(A >> 2)-1:0] w1;
type: Onedecl
wire [(A >> 2)-1:0] w2;
type: Onedecl
```
"""
function decloneline(expr::Expr)::Vector{Expr}
    # @assert expr.head == :macrocall
    expr.head == :macrocall || error("unknown head $(expr.head).")
    args = expr.args
    # targs = args[(x -> !(x isa LineNumberNode)).(args)]
    targs = removelinenumbernode(args)
    
    wt = wtypesym(targs[1])

    if length(targs) == 2
        # implicit wire width 1
        decloneline_inner(wt, Meta.quot(Wireexpr(1)), targs[2])
    elseif length(targs) == 4 
        # 2d reg declaration
        targs[3] isa Symbol || error("only a symbol is allowed for 2d array declaration, given $(targs[3]).")
        [:(Onedecl($wt, $(wireexpr(targs[2])), $(Meta.quot(targs[3])), true, $(wireexpr(targs[4]))))]
    else 
        length(targs) == 3 || error("$(length(targs)) arguments for 'decloneline'.")
        decloneline_inner(wt, wireexpr(targs[2]), targs[3])
    end
end

"""
    wtypesym(wt::Symbol)

Given either of symbols `@wire, @reg, @logic`, return 
`wire, reg, logic (::Wiretype)`, respectively.
"""
function wtypesym(wt::Symbol)
    if wt == Symbol("@wire")
        wire 
    elseif wt == Symbol("@reg")
        reg 
    else
        wt == Symbol("@logic") || error(wt, " is not allowed as a wire type.")
        logic 
    end
end

"""
    decloneline_inner(wt, wid::Expr, var::Symbol)

Declaration of a single wire (e.g. `wire [1:0] d1`, `reg clk`).
"""
function decloneline_inner(wt, wid::Expr, var::Symbol)
    [:(Onedecl($wt, $wid, $(string(var))))]
end
function decloneline_inner(wt, wid::Expr, var::String)
   [:(Onedecl($wt, $wid, $var))]
end

"""
    decloneline_inner(wt, wid::Expr, vars::Expr)

Declaration of multiple wires (e.g. `logic x, y, z`).
"""
function decloneline_inner(wt, wid::Expr, vars::Expr)
    if vars isa Expr && vars.head == :$
        # only one declaration
        # e.g. @logic A x,y is not supported yet
        return [:(Onedecl($wt, $wid, $(esc(vars.args[]))))]
    end
    vars.head == :tuple || error("vars.head should be tuple, got $(vars.head).")
    # [Onedecl(wt, wid, string(v)) for v in vars.args]
    ans = Vector{Expr}(undef, length(vars.args))
    for (i, v) in enumerate(vars.args)
        if v isa Expr
            v.head == :$ || error("unknown expr in decloneline_inner.\n$(dump(v))")
            s = :($(esc(v.args[])))
        else
            !(' ' in string(v)) || error("space included in name $(s)")
            s = Meta.quot(string(v))
        end
        ans[i] = :(Onedecl($wt, $wid, $s))
    end

    ans
end

"""
    @decloneline(arg)

Macro version of `decloneline`.
"""
macro decloneline(arg)
    Expr(:ref, :Onedecl, decloneline(arg)...)
end

"""
    decloneline(expr::Ref{T}) where {T}

For macro call.
"""
function decloneline(expr::Ref{T}) where {T}
    decloneline(expr[])
end


"""
    decls(expr::Expr)

Parse Julia AST into wire declaration section object [Decls](@ref).

# Syntax 
## `<onedecl>[;<onedecl>;...]`
Multiple [decloneline](@ref) expressions which are concatenated 
by `;` can be accepted.

# Example 
```jldoctest
julia> d = @decls (
       @wire w1;
       @reg 8 w2,w3,w4;
       @logic 32 w5
       );

julia> vshow(d)
wire w1;
reg [7:0] w2;
reg [7:0] w3;
reg [7:0] w4;
logic [31:0] w5;
type: Decls
```
"""
function decls(expr::Expr)
    return decls(expr, Val(expr.head))
end

"""
    decls(expr::Vector{Onedecl}...)

For interpolation of a single vector.
"""
function decls(expr::Vector{Onedecl}...)
    :(Decls(reduce(vcat, $expr)))
end

"""
    decls(expr::Decls...)

For interpolation of `Decls` objects.
"""
function decls(expr::Decls...)
    :(Decls(reduce(vcat, (i.val for i in $expr))))
end

"""
    decls(expr::Vector{Onedecl})

For interpolation with metaprogramming.
# Example
```jldoctest
julia> a = @decloneline @reg 8 x1, x2;

julia> b = decls(:(
       \$(a);
       @wire y1, y2
       )) |> eval;

julia> vshow(b);
reg [7:0] x1;
reg [7:0] x2;
wire y1;
wire y2;
type: Decls
```
"""
function decls(expr::Vector{Onedecl})
    Meta.quot(Decls(expr))
end

"""
    decls(expr::Expr, ::Val{:macrocall})

Parse single line of declaration.
"""
function decls(expr::Expr, ::Val{:macrocall})
    return :(Decls($(Expr(:ref, :Onedecl, decloneline(expr)...))))
end

"""
    decls(expr::Expr, ::Val{:block})

Multiple lines of wire declarations.
"""
function decls(expr::Expr, ::Val{:block})
    @assert expr.head == :block 
    anslist = Expr[]

    lineinfo = LineNumberNode(0, "noinfo")
    for item in expr.args 
        if item isa LineNumberNode 
            lineinfo = item
        # for interpolation with metaprogramming
        elseif item isa Vector{Onedecl}
            push!(anslist, Meta.quot.(item)...)
        elseif item isa Decls 
            push!(anslist, Meta.quot.(item.val)...)
        else
            push!(anslist, decloneline(item)...)
        end
    end

    return :(Decls($(Expr(:ref, :Onedecl, anslist...))))
end

"""
    decls(expr::Ref{T}) where {T}

For macro calls.
"""
function decls(expr::Ref{T}) where {T}
    return decls(expr[])
end

"""
    @decls(arg)

Macro version of `decls`.
"""
macro decls(arg)
    decls(arg)
end

"""
    widliteral(arg)

Convert verilog wire literals to `wireexpr`.

Three bases are supported e.g. 3'b101, 10'd25, 8'hff
"""
function widliteral(arg)
    arg.head == :call || error("unknown input head $(arg.head)")
    wid::Int = arg.args[2].args[1]
    body = string(arg.args[3])

    enc, val = body[1], body[2:end]

    numval = parse(Int, val, base=(
        if enc == 'h'
            16 
        elseif enc == 'd'
            10 
        else 
            enc == 'b' || error("unknown encoding \"$(enc)\".")
            2
        end
    ))


    Wireexpr(wid, numval)
end

"""
    @widliteral(arg)

Macro for `widliteral`.
"""
macro widliteral(arg)
    widliteral(arg)
end