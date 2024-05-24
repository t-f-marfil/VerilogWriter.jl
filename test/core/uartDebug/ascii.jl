
let 
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
    @test verilatorSimrun(v, 0x10, 100, option = VerilatorOption(["Unused"]))
end