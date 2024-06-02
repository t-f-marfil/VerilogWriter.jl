# nibbleToHexAscii
function nibbleToHexAsciiTest()
    v = Vmodule("dut")
    
    vpush!(v, @ports (
        @in CLK, RST;
        @out 0x10 tp
    ))

    for i in 0:0xF
        binaryWire = @wireexpr $(string("binary_$i"))
        w, p = nibbleToHexAscii(binaryWire)
        al = @always (
            $binaryWire = $i;
            tp[$i] = $w == $(string(i, base=16)[begin] |> uppercase |> Int)
        )

        vpush!.(v, (p, al))
    end

    v = vfinalize(v)
    return verilatorSimrun(v, 0x10, 100, option = VerilatorOption(["Unused"]))
end

# binaryToHexAscii
function binaryToAsciiHexTest()
    v = Vmodule("dut")
    vpush!(v, @ports (@in CLK, RST))
    
    function strToAsciiBinary(text)
        result = 0
        for c in text
            result <<= 8
            result |= Int(c)
        end
        return result
    end

    w1, p1 = binaryToHexAscii("din1", 11, false)
    w2, p2 = binaryToHexAscii("din2", 16, false)

    w3, p3 = binaryToHexAscii("din1", 11, true)
    w4, p4 = binaryToHexAscii("din2", 16, true)

    tplen = 4
    vpush!(v, @ports @out @logic $tplen tp)

    vpush!.(v, (p1, p2, p3, p4))

    vpush!(v, @always (
        din1 = 0x3FC;
        tp[0] = $w1 == $(strToAsciiBinary("3FC"));

        din2 = 0xCD23;
        tp[1] = $w2 == $(strToAsciiBinary("CD23"));

        
        tp[2] = $w3 == $(strToAsciiBinary("CF3"));
        tp[3] = $w4 == $(strToAsciiBinary("32DC"))
    ))

    return verilatorSimrun(vfinalize(v), tplen, 100, option=VerilatorOption(["Unused"]))
end

function asciiTest()
    if !Sys.islinux()
        return
    end

    @test nibbleToHexAsciiTest()
    @test binaryToAsciiHexTest()
end