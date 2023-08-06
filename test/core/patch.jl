# verilator

function posedgePrecTest()
    v = Vmodule("dut")
    vpush!(v, @always (
        counter <= counter + $(Wireexpr(32, 1))
    ))
    outvals = [
        # predicate false
        (@wireexpr 0b10) => (5, 5),
        (@wireexpr 0b10) => (10, 1),
        (@wireexpr 0b10) => (0, 0),
        (@wireexpr 0b10) => (4, 0),
        # predicate true
        (@wireexpr 0b11) => (3, 8),
        (@wireexpr 0b11) => (0, 3),
        # no trigger detected during the test scope
        (@wireexpr 0b00) => (255, 255)

    ]
    wbuf = Wireexpr[]
    for (expected, (x, y)) in outvals
        w, patch = posedgePrec((@wireexpr counter == $x), (@wireexpr counter == $y), "$(x)_$y")
        vpush!(v, patch)
        push!(wbuf, @wireexpr $w == $expected)
    end

    vpush!(v, @ports @in CLK, RST)
    w, patch = bitbundle(wbuf)
    vpush!(v, patch)
    vpush!(v, @ports @out @logic $(length(wbuf)) tp)
    vpush!(v, @always tp = $w)
    v = v |> vfinalize

    tplen = 7
    cycles = 200
    verilatorSimrun(v, tplen, cycles)
end

function verilatorTest()
    if !Sys.islinux()
        return
    end
    
    cmd = `verilator --version`
    buf = IOBuffer()
    try
        ret = run(pipeline(cmd, stdout=buf))
        @test ret.exitcode == 0
        println(String(take!(buf)) |> rstrip)
    catch e
        println("verilator not found")
        @test false
    end

    @test posedgePrecTest() 

    return
end

verilatorTest()