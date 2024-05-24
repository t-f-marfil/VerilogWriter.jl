export nibbleToHexAscii

@vstdpatch function nibbleToHexAscii(nibbleWire, name::AbstractString)
    pvg = PrivateWireNameGen(name)
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
