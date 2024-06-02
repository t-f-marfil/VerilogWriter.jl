export nibbleToHexAscii, binaryToHexAscii
export widthToAsciiEncodedWidth

@vstdpatch function nibbleToHexAscii(nibbleWire, name::AbstractString)
    pvg = PrivateWireNameGen(string("_nibbleToHex_", name))
    extended = pvg("_extended")
    ans = pvg("_ans")

    al = @always (
        $extended = $(Wireexpr(8, 0));
        $extended[3:0] = $nibbleWire;
        if $nibbleWire < 10
            $ans = $extended + 48
        else
            # 'A' == 65, 0xA == 10
            $ans = $extended + $(65 - 10)
        end
    )
    return @wireexpr($ans), Vpatch(al)
end

"""
    widthToAsciiEncodedWidth(width)

Convert width of wire to width of its ascii hex representation
"""
widthToAsciiEncodedWidth(width) = (width >> 2) * 8 + ((width % 4 > 0) ? 8 : 0)

@vstdpatch function binaryToHexAscii(wire, width, invertByteOrder::Bool, name::AbstractString)
    pvg = PrivateWireNameGen(string("_binaryToHex_", name))
    width > 0 || error("width should be larger than 0, $width given.")

    extended = pvg("_extended")
    extendedWidth = width + ((4 - (width % 4)) % 4)
    alextend = @always (
        $extended = $(Wireexpr(extendedWidth, 0));
        $extended[$(width-1):0] = $wire
    )

    plist = Vector{Vpatch{Tuple{Alwayscontent}}}(undef, extendedWidth >> 2)
    allist = Vector{Alassign}(undef, extendedWidth >> 2)
    result = pvg("_result")
    for i in 1:(extendedWidth >> 2)
        nibble, p = nibbleToHexAscii(@wireexpr($extended[$(4i-1):$(4*(i-1))]))
        # invert endian, msb may have to appear at the beginning of string
        index = invertByteOrder ? (extendedWidth >> 2) - i + 1 : i
        alnibble = @alassign_comb (
            $result[$(8index-1):$(8*(index-1))] = $nibble
        )
        plist[i] = p
        allist[i] = alnibble
    end

    return @wireexpr($result), Vpatch(alextend, plist..., Alwayscontent(comb, allist), @decls @logic $(8*(extendedWidth >> 2)) $result)
end