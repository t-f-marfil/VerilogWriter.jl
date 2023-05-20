"""
    ilconnectSUML(parent::Midlayer, children::Midlayer...)::Vmoudle

Properly connect valid and update signals from a single parent (upper stream) module 
to multiple child (lower stream) modules.
"""
function ilconnectSUML(parent::Midlayer, children::Midlayer...)::Vmodule
    vmodname = "ilSUML_$(getname(parent))_to_$(reduce((x, y)->string(x,"_and_",y), [getname(c) for c in children]))"
    m = Vmodule(vmodname)

    alvec = Alwayscontent[]
    # accepted stands for the case in which 
    # valid & update occured once
    acceptedAll = Wireexpr("acceptedall")
    acceptedAllrhs = Wireexpr(1, 1)
    phaseGlobal = Wireexpr("transphase_global")

    validParent = nametolower(ilvalid)
    updateParent = nametolower(ilupdate)

    prts = ports(:(
        @in $(validParent);
        @out @logic $(updateParent)
    ))
    vpush!(m, prts)

    outvalidvec = Vector{Wireexpr}(undef, length(children))
    inupdatevec = Vector{Wireexpr}(undef, length(children))

    for (ind, child) in enumerate(children)
        acceptedwire = Wireexpr("accepted_child$(ind)_comb")
        acceptedreg = Wireexpr("accepted_child$(ind)_reg")
        accepted = acceptedwire | acceptedreg
        acceptedAllrhs &= accepted

        validChildNow = string(nametoupper(ilvalid), "_", ind)
        updateChildNow = string(nametoupper(ilupdate), "_", ind)

        # vpush!(m, ports(:(
        #     @out @logic $(validChildNow);
        #     @in $(updateChildNow)
        # )))
        outvalidvec[ind] = Wireexpr(validChildNow)
        inupdatevec[ind] = Wireexpr(updateChildNow)

        acceptedComb = always(:(
            $(acceptedwire) = $(
                validChildNow
            ) & $(
                updateChildNow
            )
        ))
        acceptedFf = always(:(
            if $acceptedAll
                $acceptedreg <= 0
            else 
                $acceptedreg <= $acceptedwire | $acceptedreg;
            end
        ))

        phaseLocal = Wireexpr("transphase_local_child$(ind)")
        phaseFf = always(:(
            if $(accepted)
                $phaseLocal <= ~$phaseGlobal
            end
        ))

        acceptedThisPhase = ~(phaseLocal == phaseGlobal)
        validChiComb = always(:(
            $(
                validChildNow
            ) = $(
                validParent
            ) & ~$acceptedThisPhase
        ))

        push!(alvec, acceptedComb, acceptedFf, phaseFf, validChiComb)
    end

    
    bundlevalid = nametoupper(ilvalid)
    bundleupdate = nametoupper(ilupdate)

    childprts = ports(:(
        @out @logic $(length(children)) $(bundlevalid);
        @in $(length(children)) $(bundleupdate)
    ))

    vpush!(m, childprts)
    # assign valid_to_lower[i] = valid_to_lower_i
    vpush!(m, always(Expr(:block, [Alassign(w, wireexpr(:($(bundleupdate)[$(i-1)])), comb) for (i, w) in enumerate(inupdatevec)]...)))
    vpush!(m, always(Expr(:block, [Alassign(wireexpr(:($(bundlevalid)[$(i-1)])), w, comb) for (i, w) in enumerate(outvalidvec)]...)))


    phaseAllFf = always(:(
        if $acceptedAll
            $phaseGlobal <= ~$phaseGlobal
        end
    ))
    acceptedAllComb = always(:(
        $acceptedAll = $acceptedAllrhs
    ))
    
    parentUpdateComb = always(:(
        $(updateParent) = $acceptedAll
    ))

    push!(alvec, phaseAllFf, acceptedAllComb, parentUpdateComb)

    vpush!(m, alvec)
    # for wire width inference
    vpush!(m, Onedecl(logic, phaseGlobal))
    
    return m
end
