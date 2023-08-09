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

function nonegedgeTest()
    v = Vmodule("dut")
    
    countmax = 100
    al = @always (
        if $countmax < counter
            counter <= 0
        else
            counter <= counter + $(Wireexpr(33, 1))
        end
    )
    vpush!(v, al)

    sigs = [Wireexpr("sig$i") for i in 1:5]
    
    als = @cpalways (
        $(sigs[1]) = 1;
        $(sigs[2]) = 0;

        if counter < 20
            $(sigs[3]) = 0
            $(sigs[4]) = 1
        else
            $(sigs[3]) = 1
            $(sigs[4]) = 0
            $(sigs[5]) <= 1
        end
    )
    vpush!(v, als...)
    ws = Vector{String}(undef, length(sigs))
    for (ind, sig) in enumerate(sigs)
        w, pkg = nonegedge(sig, getname(sig))
        vpush!(v, pkg)
        ws[ind] = w
    end

    vpush!(v, @oneport @out @logic $(length(sigs)) tp)
    vpush!(v, @always (
        tp[0] = $(ws[1]);
        tp[1] = $(ws[2]);
        tp[2] = ~$(ws[3]);
        tp[3] = ~$(ws[4]);
        tp[4] = $(ws[5]);
    ))
    vpush!(v, @ports @in CLK, RST)
    v = vfinalize(v)

    return verilatorSimrun(v, length(sigs), 4countmax)
end

function posedgeSyncTest() 
    v = Vmodule("dut")
    
    countmax = 80
    al = @always (
        if $countmax < counter
            counter <= 0
            supcount <= $(Wireexpr(1, 1))
        else
            counter <= counter + $(Wireexpr(32, 1))
        end
    )
    vpush!(v, al)

    counts = [0, 20, 33, 100]
    al = @always $([(@alassign_comb $("count$c") = $c < counter) for c in counts]...)
    vpush!(v, al)

    al = @always (
        if supcount == 0
            sig1 = count0
            sig2 = count20
            sig3 = count33
            sig4 = count100
        else
            sig1 = count100
            sig2 = count33
            sig3 = count20
            sig4 = count100
        end
    )
    vpush!(v, al)

    @sym2wire sig1, sig2, sig3, sig4
    sigpairs =  [
        ((sig1, sig2), 0b10), 
        ((sig1, sig1), 0b11), 
        ((sig3, sig1), 0b10), 
        ((sig2, sig2), 0b11), 
        ((sig3, sig2), 0b10),
        ((sig2, sig3), 0b10),
        ((sig4, sig4), 0b00),
    ]
    wsync = Vector{Wireexpr}(undef, length(sigpairs))
    for (ind, ((uno, dos), b)) in enumerate(sigpairs)
        w, pkg = posedgeSync(uno, dos, "$(getname(uno))_$(getname(dos))")
        wsync[ind] = @wireexpr $w == $b
        vpush!(v, pkg)
        vpush!(v, @always tp[$(ind-1)] = $(wsync[ind]))
    end

    for (ind, w) in enumerate(wsync)
        wn, pkg = nonegedge(w, getname(w))
        vpush!(v, pkg)
        vpush!(v, @always tp[$(ind-1+length(wsync))] = $wn)
    end
    
    tplen = 2*length(wsync)
    vpush!(v, @oneport @out @logic $tplen tp)
    vpush!(v, @ports @in CLK,RST)
    v = vfinalize(v)
    
    
    verilatorSimrun(v, tplen, 200)
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
    catch
        println("verilator not found")
        rethrow()
    end

    @test posedgePrecTest()
    @test nonegedgeTest()
    @test posedgeSyncTest()

    return
end

verilatorTest()