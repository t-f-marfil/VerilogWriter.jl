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
    updateParentRhs = Wireexpr(1, 1)

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

        validChildNow = Wireexpr(string(nametoupper(ilvalid), "_", ind))
        updateChildNow = Wireexpr(string(nametoupper(ilupdate), "_", ind))
        # updatereg = Wireexpr("update_child$(ind)_reg")
        # updateLocal = updatereg | updateChildNow

        updateParentRhs &= accepted | updateChildNow
        # vpush!(m, ports(:(
        #     @out @logic $(validChildNow);
        #     @in $(updateChildNow)
        # )))
        outvalidvec[ind] = validChildNow
        inupdatevec[ind] = updateChildNow

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
        $updateParent = $updateParentRhs
    ))

    push!(alvec, phaseAllFf, acceptedAllComb, parentUpdateComb)

    vpush!(m, alvec)
    # for wire width inference
    vpush!(m, Onedecl(logic, phaseGlobal))
    
    return m
end

function ilconnectMUSL(child::Midlayer, parents::Midlayer...)
    length(parents) > 0 || error("number of upper Midlayers should be more than zero.")
    vmodname = "ilMUSL_$(getname(child))_from_$(reduce((x, y)->string(x,"_and_",y), [getname(p) for p in parents]))"
    m = Vmodule(vmodname)

    chiports = ports(:(
        @in $(nametoupper(ilupdate));
        @out @logic $(nametoupper(ilvalid))
    ))
    parports = ports(:(
        @in $(length(parents)) $(nametolower(ilvalid));
        @out @logic $(length(parents)) $(nametolower(ilupdate))
    ))
    vpush!(m, chiports, parports)

    pupdateassigns = Vector{Alassign}(undef, length(parents))
    for (ind, lay) in enumerate(parents)
        pupdateassigns[ind] = Alassign(
            wireexpr(:($(nametolower(ilupdate))[$(ind-1)])),
            Wireexpr(nametoupper(ilupdate)),
            comb
        )
    end
    vpush!(m, Alwayscontent(comb, Ifcontent(pupdateassigns)))
    vpush!(m, always(:($(nametoupper(ilvalid)) = &($(nametolower(ilvalid))))))

    return m
end

"""
    graph2adlist(lay::Layergraph)

Generate adjacency list from Layergraph.
"""
function graph2adlist(lay::Layergraph)
    # precond: no duplicate egdes in lay.edges
    suml = OrderedDict{Midlayer, Vector{Midlayer}}()
    musl = OrderedDict{Midlayer, Vector{Midlayer}}()

    for ((uno, dos), _) in lay.edges
        if !(uno in keys(suml))
            suml[uno] = Midlayer[]
        end
        if !(dos in keys(musl))
            musl[dos] = Midlayer[]
        end

        push!(suml[uno], dos)
        push!(musl[dos], uno)
    end

    return suml, musl
end

function wirenameMlayToSuml(il::Interlaysigtype, upper::Midlayer)
    "$(string(il)[3:end])_mlay2suml_from_$(getname(upper))"
end
function wirenameMuslToMlay(il::Interlaysigtype, lower::Midlayer)
    "$(string(il)[3:end])_musl2mlay_to_$(getname(lower))"
end
function wirenameSumlToMusl(il::Interlaysigtype, upper::Midlayer, lower::Midlayer)
    "$(string(il)[3:end])_suml2musl_$(getname(upper))_to_$(getname(lower))"
end

const InfotypeSuml = Tuple{Decls, Vmodinst, Alwayscontent}

function generateSUML(suml::D) where {D <: AbstractDict{Midlayer, Vector{Midlayer}}}
    hublist = Vector{Vmodule}(undef, length(suml))
    addinfolist = Vector{InfotypeSuml}(undef, length(suml))
    for (i, (upper, lowers)) in enumerate(suml)
        hub = ilconnectSUML(upper, lowers...)

        bundlevalid = Wireexpr("bundle_valid_SUML_from_$(getname(upper))")
        bundleupdate = Wireexpr("bundle_update_SUML_from_$(getname(upper))")
        dcls = decls(:(@logic $(length(lowers)) $bundlevalid, $bundleupdate))

        hubinst = Vmodinst(
            getname(hub),
            "uSUML_from_$(getname(upper))",
            [
                "CLK" => Wireexpr("CLK"),
                "RST" => Wireexpr("RST"),
                "valid_to_lower" => Wireexpr(wirenameMlayToSuml(ilvalid, upper)),
                "update_from_lower" => Wireexpr(wirenameMlayToSuml(ilupdate, upper)),
                "valid_from_upper" => bundlevalid,
                "update_to_upper" => bundleupdate
            ]
        )

        valids = Vector{Expr}(undef, length(lowers))
        updates = Vector{Expr}(undef, length(lowers))

        for (ind, low) in enumerate(lowers)
            valnow = Wireexpr(wirenameSumlToMusl(ilvalid, upper, low))
            updnow = Wireexpr(wirenameSumlToMusl(ilupdate, upper, low))
            valids[ind] = :($valnow = $(bundlevalid)[$(ind-1)])
            updates[ind] = :($(bundleupdate)[$(ind-1)] = $updnow)
        end

        alcomb = always(Expr(:block, valids..., updates...))
    
        hublist[i] = hub
        addinfolist[i] = tuple(dcls, hubinst, alcomb)
    end

    return hublist, addinfolist
end


function generateMUSL(musl::D) where {D <: AbstractDict{Midlayer, Vector{Midlayer}}}
    hublist = Vector{Vmodule}(undef, length(musl))
    addinfolist = Vector{InfotypeSuml}(undef, length(musl))
    for (i, (lower, uppers)) in enumerate(musl)
        hub = ilconnectMUSL(lower, uppers...)

        bundlevalid = Wireexpr("bundle_valid_MUSL_from_$(getname(lower))")
        bundleupdate = Wireexpr("bundle_update_MUSL_from_$(getname(lower))")
        dcls = decls(:(@logic $(length(uppers)) $bundlevalid, $bundleupdate))

        hubinst = Vmodinst(
            getname(hub),
            "uMUSL_from_$(getname(lower))",
            [
                "CLK" => Wireexpr("CLK"),
                "RST" => Wireexpr("RST"),
                "valid_to_lower" => bundlevalid,
                "update_from_lower" => bundleupdate,
                "valid_from_upper" => Wireexpr(wirenameMuslToMlay(ilvalid, lower)),
                "update_to_upper" => Wireexpr(wirenameMuslToMlay(ilupdate, lower))
            ]
        )

        valids = Vector{Expr}(undef, length(uppers))
        updates = Vector{Expr}(undef, length(uppers))

        for (ind, upp) in enumerate(uppers)
            valnow = Wireexpr(wirenameSumlToMusl(ilvalid, upp, lower))
            updnow = Wireexpr(wirenameSumlToMusl(ilupdate, upp, lower))
            valids[ind] = :($(bundlevalid)[$(ind-1)] = $valnow)
            updates[ind] = :($updnow = $(bundleupdate)[$(ind-1)])
        end

        alcomb = always(Expr(:block, valids..., updates...))
    
        hublist[i] = hub
        addinfolist[i] = tuple(dcls, hubinst, alcomb)
    end

    return hublist, addinfolist
end

function addsumlinfo!(m::Vmodule, lst::Vector{InfotypeSuml})
    for item in lst
        vpush!.(Ref(m), item)
    end
    return nothing
end