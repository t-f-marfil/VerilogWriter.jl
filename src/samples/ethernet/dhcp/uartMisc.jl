
@vstdpatch function joinWithAsciiSpace(wires, wireWidths, name::AbstractString)
    length(wires) == length(wireWidths) || error("Vector length discrepancy, $(length(wires)) <=> $(length(wireWidths)).")

    totalWidth = sum(wireWidths) + 8*(length(wireWidths) - 1)
    resultWire = @wireexpr($(string("_joinwith_asciiSpace_", name)))

    indexBase = 0
    alassigns = Vector{Alassign}(undef, 2length(wires) - 1)
    for i in eachindex(wires)
        wirenow = wires[i]
        widthnow = wireWidths[i]
        al = @alassign_comb $resultWire[$(indexBase + widthnow - 1):$(indexBase)] = $wirenow
        alassigns[i] = al
        indexBase += 8 + widthnow
    end
    
    indexBase = 0
    for i in 1:(length(wireWidths) - 1)
        indexBase += wireWidths[i]
        al = @alassign_comb $resultWire[$(indexBase + 8 - 1):$indexBase] = $(Int(' '))
        alassigns[length(wireWidths) + i] = al
        indexBase += 8
    end

    return resultWire, Vpatch(Alwayscontent(comb, alassigns), @decls @logic $totalWidth $resultWire)
end

@vstdpatch function outputAsciiEncoded(wires, widths, name::AbstractString)
    encodeds = [binaryToHexAscii(wire, width, true) for (wire, width) in zip(wires, widths)]

    asciiSerialized, pAsciiSerialized = joinWithAsciiSpace(
        [w for (w, _) in encodeds],
        [widthToAsciiEncodedWidth(w) for w in widths],
        name
    )

    # encoded wires and space (= one ascii char == 8 bit) between wires
    # returnWidth = sum([widthToAsciiEncodedWidth(w) for w in widths]) + 8 * (length(wires) - 1)
    returnPatch = Vpatch(
        [p for (_, p) in encodeds]...,
        pAsciiSerialized
    )
    return asciiSerialized, returnPatch
end

@vstdpatch function wireConcat(wires, widths, name::AbstractString)
    @assert all(x -> x > 0, widths)
    result = @wireexpr($(string("_result_wireConcat_", name)))
    dcl = @decls (
        @logic $(sum(widths)) $result
    )

    alvec = Vector{Alassign}(undef, length(wires))
    totalWidth = 0
    for (ind, (wire, width)) in enumerate(zip(wires, widths))
        alvec[ind] = (
            if width == 1
                @alassign_comb $result[$totalWidth] = $wire
            else
                @alassign_comb $result[$(totalWidth+width-1):$totalWidth] = $wire
            end
        )
        totalWidth += width
    end

    return result, Vpatch(dcl, Alwayscontent(comb, alvec))
end

@vstdpatch function wireUnpack(wire, widths, name::AbstractString)
    assignvec = Vector{Alassign}(undef, length(widths))
    wirevec = Vector{Wireexpr}(undef, length(widths))
    pvg = PrivateWireNameGen(string("_wireUnpack_", name))

    index = 0
    for (i, wid) in enumerate(widths)
        wireNow = pvg("_wire$i")
        wirevec[i] = Wireexpr(wireNow)
        al = @alassign_comb $wireNow = $wire[$(index+wid-1):$index]
        assignvec[i] = al
        index += wid
    end

    return wirevec, Vpatch(Alwayscontent(comb, assignvec))
end
