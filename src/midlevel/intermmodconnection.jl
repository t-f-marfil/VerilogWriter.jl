"""
    imconnectSUML(parent::Midport, children::Midport...)::Vmoudle

Properly connect valid and update signals from a single parent (upper stream) module 
to multiple child (lower stream) modules.
"""
function imconnectSUML(parent::Midport, children::Midport...)::Vmodule
    vmodname = "imSUML_$(getname(parent))_to_$(reduce((x, y)->string(x,"_and_",y), [getname(c) for c in children]))"
    m = Vmodule(vmodname)

    alvec = Alwayscontent[]
    # accepted stands for the case in which 
    # valid & update occured once
    acceptedAll = Wireexpr("acceptedall")
    acceptedAllrhs = Wireexpr(1, 1)
    phaseGlobal = Wireexpr("transphase_global")

    validParent = nametolower(imvalid, defaultMidPid)
    updateParent = nametolower(imupdate, defaultMidPid)
    updateParentRhs = Wireexpr(1, 1)

    prts = @ports (
        @in $validParent;
        @out @logic $updateParent
    )
    vpush!(m, prts)

    outvalidvec = Vector{Wireexpr}(undef, length(children))
    inupdatevec = Vector{Wireexpr}(undef, length(children))

    for (ind, child) in enumerate(children)
        acceptedwire = Wireexpr("accepted_child$(ind)_comb")
        acceptedreg = Wireexpr("accepted_child$(ind)_reg")
        accepted = acceptedwire | acceptedreg
        acceptedAllrhs &= accepted

        validChildNow = Wireexpr(string(nametoupper(imvalid, defaultMidPid), "_", ind))
        updateChildNow = Wireexpr(string(nametoupper(imupdate, defaultMidPid), "_", ind))
        
        updateParentRhs &= accepted | updateChildNow
        
        outvalidvec[ind] = validChildNow
        inupdatevec[ind] = updateChildNow

        acceptedComb = @always (
            $acceptedwire = $validChildNow & $updateChildNow
        )
        acceptedFf = @always (
            if $acceptedAll
                $acceptedreg <= 0
            else 
                $acceptedreg <= $acceptedwire | $acceptedreg;
            end
        )

        phaseLocal = Wireexpr("transphase_local_child$(ind)")
        phaseFf = @always (
            if $accepted
                $phaseLocal <= ~$phaseGlobal
            end
        )

        acceptedThisPhase = ~(phaseLocal == phaseGlobal)
        validChiComb = @always (
            $validChildNow = $validParent & ~$acceptedThisPhase
        )

        push!(alvec, acceptedComb, acceptedFf, phaseFf, validChiComb)
    end

    
    bundlevalid = nametoupper(imvalid, defaultMidPid)
    bundleupdate = nametoupper(imupdate, defaultMidPid)

    childprts = @ports (
        @out @logic $(length(children)) $bundlevalid;
        @in $(length(children)) $bundleupdate
    )

    vpush!(m, childprts)
    # assign valid_to_lower[i] = valid_to_lower_i

    if length(children) > 1
        # vpush!(m, always(Expr(:block, [Alassign(w, (@wireexpr ($(bundleupdate)[$(i-1)])), comb) for (i, w) in enumerate(inupdatevec)]...)))
        vpush!(m, Alwayscontent(comb, [Alassign(w, (@wireexpr ($(bundleupdate)[$(i-1)])), comb) for (i, w) in enumerate(inupdatevec)]))
        # vpush!(m, always(Expr(:block, [Alassign((@wireexpr ($(bundlevalid)[$(i-1)])), w, comb) for (i, w) in enumerate(outvalidvec)]...)))
        vpush!(m, Alwayscontent(comb, [Alassign((@wireexpr ($(bundlevalid)[$(i-1)])), w, comb) for (i, w) in enumerate(outvalidvec)]))
    else
        # vpush!(m, always(Expr(:block, Alassign(inupdatevec[], wireexpr(:($(bundleupdate))), comb))))
        # vpush!(m, always(Expr(:block, Alassign(wireexpr(:($(bundlevalid))), outvalidvec[], comb))))
        vpush!(m, Alwayscontent(comb, [Alassign(inupdatevec[], (@wireexpr $bundleupdate), comb)]))
        vpush!(m, Alwayscontent(comb, [Alassign((@wireexpr $bundlevalid), outvalidvec[], comb)]))
    end

    phaseAllFf = @always (
        if $acceptedAll
            $phaseGlobal <= ~$phaseGlobal
        end
    )
    acceptedAllComb = @always (
        $acceptedAll = $acceptedAllrhs
    )
    
    parentUpdateComb = @always (
        $updateParent = $updateParentRhs
    )

    push!(alvec, phaseAllFf, acceptedAllComb, parentUpdateComb)

    vpush!(m, alvec)
    # for wire width inference
    vpush!(m, Onedecl(logic, phaseGlobal))
    
    return m
end

function imconnectMUSL(child::Midport, parents::Midport...)
    length(parents) > 0 || error("number of upper Midports should be more than zero.")
    vmodname = "imMUSL_$(getname(child))_from_$(reduce((x, y)->string(x,"_and_",y), [getname(p) for p in parents]))"
    m = Vmodule(vmodname)

    chiports = @ports (
        @in $(nametoupper(imupdate, defaultMidPid));
        @out @logic $(nametoupper(imvalid, defaultMidPid))
    )
    parports = @ports (
        @in $(length(parents)) $(nametolower(imvalid, defaultMidPid));
        @out @logic $(length(parents)) $(nametolower(imupdate, defaultMidPid))
    )
    vpush!(m, chiports, parports)

    pupdateassigns = Vector{Alassign}(undef, length(parents))
    upperallvalid = Wireexpr(redand, Wireexpr(nametolower(imvalid, defaultMidPid)))
    for (ind, lay) in enumerate(parents)
        wlhs = length(parents) > 1 ? (@wireexpr ($(nametolower(imupdate, defaultMidPid))[$(ind-1)])) : @wireexpr ($(nametolower(imupdate, defaultMidPid)))
        pupdateassigns[ind] = Alassign(
            wlhs,
            Wireexpr(nametoupper(imupdate, defaultMidPid)) & upperallvalid,
            comb
        )
    end
    vpush!(m, Alwayscontent(comb, Ifcontent(pupdateassigns)))
    vpush!(m, @always ($(nametoupper(imvalid, defaultMidPid)) = $upperallvalid))

    return m
end

"""
    graph2adlist(lay::Mmodgraph)

Generate adjacency list from Mmodgraph.
"""
function graph2adlist(lay::Mmodgraph)
    # precond: no duplicate egdes in lay.edges
    suml = OrderedDict{Midport, Vector{Midport}}()
    musl = OrderedDict{Midport, Vector{Midport}}()

    for ((uno, dos), _) in lay.edges
        if !(uno in keys(suml))
            suml[uno] = Midmodule[]
        end
        if !(dos in keys(musl))
            musl[dos] = Midmodule[]
        end

        push!(suml[uno], dos)
        push!(musl[dos], uno)
    end

    return suml, musl
end

function wirenameMlayToSuml(il::IntermmodSigtype, upper::Midport)
    "$(string(il)[3:end])_mlay2suml_from_$(getname(upper))"
end
function wirenameMuslToMlay(il::IntermmodSigtype, lower::Midport)
    "$(string(il)[3:end])_musl2mlay_to_$(getname(lower))"
end
function wirenameSumlToMusl(il::IntermmodSigtype, upper::Midport, lower::Midport)
    "$(string(il)[3:end])_suml2musl_$(getname(upper))_to_$(getname(lower))"
end

const InfotypeSuml = Tuple{Decls, Vmodinst, Alwayscontent}

"""
    generateSUML(suml::D) where {D <: AbstractDict{Midport, Vector{Midport}}}

instantiate all `imconnectSUML` verilog modules from
an adjacency list.
"""
function generateSUML(suml::D) where {D <: AbstractDict{Midport, Vector{Midport}}}
    hublist = Vector{Vmodule}(undef, length(suml))
    addinfolist = Vector{InfotypeSuml}(undef, length(suml))
    for (i, (upper, lowers)) in enumerate(suml)
        hub = imconnectSUML(upper, lowers...)

        bundlevalid = Wireexpr("bundle_valid_SUML_from_$(getname(upper))")
        bundleupdate = Wireexpr("bundle_update_SUML_from_$(getname(upper))")
        dcls = @decls (@logic $(length(lowers)) $(getname(bundlevalid)), $(getname(bundleupdate)))

        hubinst = Vmodinst(
            getname(hub),
            "uSUML_from_$(getname(upper))",
            [
                "CLK" => Wireexpr("CLK"),
                "RST" => Wireexpr("RST"),
                nametolower(imvalid, defaultMidPid) => Wireexpr(wirenameMlayToSuml(imvalid, upper)),
                nametolower(imupdate, defaultMidPid) => Wireexpr(wirenameMlayToSuml(imupdate, upper)),
                nametoupper(imvalid, defaultMidPid) => bundlevalid,
                nametoupper(imupdate, defaultMidPid) => bundleupdate
            ]
        )

        valids = Vector{Alassign}(undef, length(lowers))
        updates = Vector{Alassign}(undef, length(lowers))
        # valids = Vector{Expr}(undef, length(lowers))
        # updates = Vector{Expr}(undef, length(lowers))

        for (ind, low) in enumerate(lowers)
            valnow = Wireexpr(wirenameSumlToMusl(imvalid, upper, low))
            updnow = Wireexpr(wirenameSumlToMusl(imupdate, upper, low))

            if length(lowers) > 1
                # valids[ind] = :($valnow = $(bundlevalid)[$(ind-1)])
                # updates[ind] = :($(bundleupdate)[$(ind-1)] = $updnow)
                valids[ind] = @alassign_comb $valnow = $bundlevalid[$(ind-1)]
                updates[ind] = @alassign_comb ($(bundleupdate)[$(ind-1)] = $updnow)
            else
                valids[ind] = @alassign_comb ($valnow = $(bundlevalid))
                updates[ind] = @alassign_comb ($(bundleupdate) = $updnow)
            end
        end

        # alcomb = always(Expr(:block, valids..., updates...))
        alcomb = Alwayscontent(comb, [valids; updates])
    
        hublist[i] = hub
        addinfolist[i] = tuple(dcls, hubinst, alcomb)
    end

    return hublist, addinfolist
end


function generateMUSL(musl::D) where {D <: AbstractDict{Midport, Vector{Midport}}}
    hublist = Vector{Vmodule}(undef, length(musl))
    addinfolist = Vector{InfotypeSuml}(undef, length(musl))
    for (i, (lower, uppers)) in enumerate(musl)
        hub = imconnectMUSL(lower, uppers...)

        bundlevalid = Wireexpr("bundle_valid_MUSL_from_$(getname(lower))")
        bundleupdate = Wireexpr("bundle_update_MUSL_from_$(getname(lower))")
        dcls = @decls (@logic $(length(uppers)) $(getname(bundlevalid)), $(getname(bundleupdate)))

        hubinst = Vmodinst(
            getname(hub),
            "uMUSL_from_$(getname(lower))",
            [
                "CLK" => Wireexpr("CLK"),
                "RST" => Wireexpr("RST"),
                nametolower(imvalid, defaultMidPid) => bundlevalid,
                nametolower(imupdate, defaultMidPid) => bundleupdate,
                nametoupper(imvalid, defaultMidPid) => Wireexpr(wirenameMuslToMlay(imvalid, lower)),
                nametoupper(imupdate, defaultMidPid) => Wireexpr(wirenameMuslToMlay(imupdate, lower))
            ]
        )

        # valids = Vector{Expr}(undef, length(uppers))
        # updates = Vector{Expr}(undef, length(uppers))
        valids = Vector{Alassign}(undef, length(uppers))
        updates = Vector{Alassign}(undef, length(uppers))

        for (ind, upp) in enumerate(uppers)
            valnow = Wireexpr(wirenameSumlToMusl(imvalid, upp, lower))
            updnow = Wireexpr(wirenameSumlToMusl(imupdate, upp, lower))

            if length(uppers) > 1
                # valids[ind] = :($(bundlevalid)[$(ind-1)] = $valnow)
                # updates[ind] = :($updnow = $(bundleupdate)[$(ind-1)])
                valids[ind] = @alassign_comb ($(bundlevalid)[$(ind-1)] = $valnow)
                updates[ind] = @alassign_comb ($updnow = $(bundleupdate)[$(ind-1)])
            else
                # valids[ind] = :($(bundlevalid) = $valnow)
                # updates[ind] = :($updnow = $(bundleupdate))
                valids[ind] = @alassign_comb ($(bundlevalid) = $valnow)
                updates[ind] = @alassign_comb ($updnow = $(bundleupdate))
            end
        end

        # alcomb = always(Expr(:block, valids..., updates...))
        alcomb = Alwayscontent(comb, [valids; updates])
    
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

"""
    ildatabuffer(lay::Midmodule, conn::Layerconn)

Intended to hold data from upstream midlayer object,
even if other upstream object is not yet valid in the same MUSL.

However, it is not needed now since MUSL waits all upstreams for until their
valid signals are all asserted.
May be needed when MUSL behavior is modified.
"""
function ildatabuffer(lay::Midmodule, conn::Layerconn)
    m = Vmodule("ildatabuf_$(getname(lay))")
    prts = Ports([p for (p, _) in conn.ports])
    ilprts = @ports (
        @in $(nametolower(imvalid, defaultMidPid)), $(nametolower(imupdate, defaultMidPid))
    )
    trans = Wireexpr(nametolower(imvalid, defaultMidPid)) & Wireexpr(nametolower(imupdate, defaultMidPid))

    for prt in prts
        nm = getname(prt)
        din = string("din_", nm)
        dout = string("dout_", nm)
        dbuf = string("dbuf_", nm)
        alff = @always (
            if $trans
                $dbuf <= $din
            end
        )
        alcomb = @always (
            if $trans
                $dout = $din
            else
                $dout = $dbuf
            end
        )

        vpush!.(m, (alff, alcomb))
    end

    vpush!(m, portsNameMod(alloutlogic(prts), x -> string("dout_", x)))
    vpush!(m, portsNameMod(invports(prts), x -> string("din_", x)))
    vpush!(m, ilprts)

    return m
end