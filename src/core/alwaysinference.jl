"""
    atypealways(x::Ifcontent)

Infer type of always-block (into always_ff or always_comb).
"""
function atypealways(x::Ifcontent)
    tassigns = atypealways(x.assigns)
    tifblocks = atypealways(x.ifelseblocks)
    tcases = atypealways(x.cases)

    # unknown occur when both list is empty
    ans = aunknown
    for tnow in (tassigns, tifblocks, tcases)
        if tnow != aunknown
            if ans != aunknown && tnow != ans 
                error("discrepancy in atypes inside ifcontent.")
            end
            ans = tnow 
        end
    end
#     if tassigns == aunknown 
#         ans = tifblocks
#     elseif tifblocks == aunknown
#         ans = tassigns 
#     else
#         if tassigns != tifblocks 
#             throw(error("discrepancy in atypes, \
# assigns:$(tassigns) <=> ifelseblocks:$(tifblocks)."))
#         end 

#         ans = tassigns 
#     end

    return ans 
end

"""
    atypealways(x::Vector{T}) where {T}

Infer type of always-block from a vector of `T`.
"""
function atypealways(x::Vector{T}) where {T}
    if length(x) == 0 
        ans = aunknown 
    else
        # ans = atypealways(x[1])
        ans = aunknown
        for i in x
            ansnow = atypealways(i)
            if ansnow != aunknown
                if ans != aunknown && ans != ansnow 
                    error(
                        "atype discrepancy occured in \n\n$(indent(string(i)))\n\n",
                        "full items:\n\n$(indent(reduce(newlineconcat, string.(x))))"
                    )
                end
                ans = ansnow
            end
        end
    end

    return ans 
end

function atypealways(x::Alassign)
    return x.atype 
end

function atypealways(x::Ifelseblock)
    return atypealways(x.contents)
end

function atypealways(x::Case)
    ifconts = [i[2] for i in x.conds]
    atypealways(ifconts)
end

function atypealways(x::Alwayscontent)
    atypealways(x.content)
end


"""
    addatype!(x::Alwayscontent)

Infer type of always block (combinational or sequential) and
add the information to `x`.
"""
function addatype!(x::Alwayscontent)
    x.atype = atypealways(x)
    return x 
end

"""
    always(expr::Expr)

Parse AST into always block as [Alwayscontent](@ref) using `ralways`.

Also infers type of always using `addatype!`.

# Syntax 
## `<oneblock>;<oneblock>[;<oneblock>;...]`
`<oneblock>` is the expression that follows either below syntax.

### `<wireoperation> = <wireoperation>`
One blocking assignment.
`<wireoperation>` is a expression accepted by [wireexpr](@ref).
Not all syntax accepted here is of valid verilog syntax.

### `<wireoperation> <= <wireoperation>`
One non-blocking assignment.

### If-else statement
```
if <wireoperation>
    <oneblock>
    <oneblock>
    ...
elseif <wireoperation> 
    <oneblock>
    <oneblock>
    ...
else
    <oneblock>
    ...
end
```
If-else statement written in 'Julia syntax', not in Verilog 
syntax, can be accepted. `else` block and `elseif` are not mandatory.
Since `if` `end` are at the top level, no `;` inside if-else statement is needed.
Nested if-else statement can be also accepted as in usual Julia.

The order in which `oneblock` is placed within if, 
elseif, and else block is not strictly preserved. 
If-else statement inside if,elseif,else blocks is placed after
blocking/non-blocking assignment there.

## `@posedge <wirename>; <ifelsestatements>/<assignments>`
Set sensitivity list using macro syntax. `@negedge` is also possible. 
You must put `@posegde/@negedge` statement at the beginning, and only once.

# Examples

```jldoctest
a1 = @always (
    w1 = w2;
    if b2 
        w1 = w3 
    end
)
vshow(a1)

# output

always_comb begin
    w1 = w2;
    if (b2) begin
        w1 = w3;
    end
end
type: Alwayscontent
```

```jldoctest
a1 = @always (
    @posedge clk;
    
    if b1 == b2
        w1 <= w2 + w3 
    else
        w1 <= ~w1 
    end
)
vshow(a1)

# output

always_ff @( posedge clk ) begin
    if ((b1 == b2)) begin
        w1 <= (w2 + w3);
    end else begin
        w1 <= (~w1);
    end
end
type: Alwayscontent
```
"""
function always(expr::Expr)
    alcont = ralways(expr)
    # return addatype!(alcont)
    return :(addatype!($alcont))
end

function always(expr...)
    alcont = ralways(expr...)
    # return addatype!(alcont)
    return :(addatype!($alcont))
end

"""
    @always(arg)

Macro version of `always`
"""
macro always(arg)
    return always(arg)
end

function always(expr::Ref{T}) where {T}
    always(expr[])
end
