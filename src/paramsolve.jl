"""
    (cls::Wireop)(uno::Int)

`uminus`, whose type is `Wireop` is now callable.

Used in calculating parameters, for `Wireexpr` is used inside parameter objects.
"""
function (cls::Wireop)(uno::Int)
    if cls == uminus 
        -uno 
    else
        error("no support for other operators.")
        # missing 
    end
end

"""
    (cls::Wireop)(uno::Int, dos::Int)

Operators in `wbinop` are now callable.

Used in calculating parameters, for `Wireexpr` is used inside parameter objects.
"""
function (cls::Wireop)(uno::Int, dos::Int)
    if cls == add 
        uno + dos 
    elseif cls == minus 
        uno - dos 
    elseif cls == mul 
        uno * dos 
    elseif cls == vdiv 
        div(uno, dos)
    elseif cls == lshift 
        uno << dos 
    elseif cls == rshift 
        uno >> dos 
    else
        error("no support for other operators.") 
        # missing
    end
end

"value to be returned when parameter value cannot be solved."
const punsolved = -2

"""
    paramsolvecore_inner!(w, ans::Dict{String, Int}, alldict::Dict{String, Wireexpr}, visited::Dict{String, Bool})

Return the constant value of `w::Wireexpr`.

If the value for `w` has not been calculated, recursively (with depth-first-search) 
evaluate the parameters which appear at rhs of `w`, and update `ans`.
"""
function paramsolvecore_inner!(w, ans::Dict{String, Int}, 
    alldict::Dict{String, Wireexpr}, visited::Dict{String, Bool})

    op = w.operation
    if op == id 
        n = w.name
        anshere = ans[n]

        if anshere == punsolved

            if visited[n]
                error(
                    "Looking at '$(n)',\n",
                    "Mutual recursion detected in solving parameters."
                )
            end

            visited[n] = true
            return ans[n] = paramsolvecore_inner!(alldict[n], ans, alldict, visited)

        else
            return anshere
        end

    elseif op == literal 
        return w.value
    elseif op in wbinop 
        if op == div 
            return div(
                paramsolvecore_inner!.(w.subnodes, Ref(ans), Ref(alldict), Ref(visited))...
            )
        else
            s1, s2 = w.subnodes
            return op(
                paramsolvecore_inner!(s1, ans, alldict, visited),
                paramsolvecore_inner!(s2, ans, alldict, visited)
            )
        end
    else
        error(
            "operator '$(op)' is not supported for parameters/localparams."
        )
    end

    vshow(w)
    @show op, s1, s2
    error("not supposed to reach here.")
end

"""
    paramsolvecore!(n::String, ans, alldict)

Prepare for the computation of the parameter named `n`.
"""
function paramsolvecore!(n::String, ans, alldict)
    visited = Dict([i => false for i in keys(alldict)])
    visited[n] = true 
    ans[n] = paramsolvecore_inner!(alldict[n], ans, alldict, visited)
end
        

"""
    paramsolve(prm::Parameters, lprm::Localparams)

Using `prm` and `lprm`, calculate all parameters' rhs, which is a 
`Wireexpr`, and determine the constant value corresponds to each parameter.
"""
function paramsolve(prm::Parameters, lprm::Localparams)
    prmdict = Dict([p.name => p.val for p in prm.val])
    lprmdict = Dict([lp.name => lp.val for lp in lprm.val])
    
    alldict = merge(prmdict, lprmdict)

    ans = Dict([i => punsolved for i in keys(alldict)])
    
    for n in keys(alldict)
        if ans[n] == punsolved
            paramsolvecore!(n, ans, alldict)
        end
    end

    ans
end

"""
    paramcalc(w::Wireexpr, ans)

Evaluate paramter whose rhs is `w` under `ans` returned from `paramsolve`.
"""
function paramcalc(w::Wireexpr, ans)
    paramsolvecore_inner!(w, ans, Dict{String, Wireexpr}(), Dict{String, Bool}())
end