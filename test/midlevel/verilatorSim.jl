function intermmodSimpleTest()
    @Randmmod A
    @Randmmod B
    @Randmmod C 
    @Randmmod D
    @Randmmod E

    lay = Mmodgraph()
    lay(A=>C)
    p1 = @oneport @in @logic 4 d1
    p2 = @oneport @out @logic 4 d2
    lay(B=>C, Layerconn([p2 => p1]))
    vpush!(C, p1)
    vpush!(B, p2)
    al = @always (
        if $(nametolower(imupdate)) & $(nametolower(imvalid))
            d2 <= d2 + 1
        end
    )
    vpush!(B, al)
    lay(B=>D)
    lay(E=>D)

    @Randmmod debugcore
    imvalids = Dict{Midmodule, Oneport}()
    imupdates = Dict{Midmodule, Oneport}()

    for m in (A,B,E)
        imvalids[m] = debugAdd!(m, nametolower(imvalid), 1) |> invport
        imupdates[m] = debugAdd!(m, nametolower(imupdate), 1) |> invport
    end
    for m in (C, D)
        imvalids[m] = debugAdd!(m, nametoupper(imvalid), 1) |> invport
        imupdates[m] = debugAdd!(m, nametoupper(imupdate), 1) |> invport
    end

    for ((_, vp), (_, up)) in zip(imvalids, imupdates)
        vpush!(debugcore, vp, up)
    end
    # prerequisit
    w0, pkg0 = posedgePrec(imupdates[D] |> Wireexpr, imvalids[B] |> Wireexpr, "DB")
    w2, pkg2 = posedgePrec(imvalids[B] |> Wireexpr, imvalids[A] |> Wireexpr, "BA")
    w1, pkg1 = posedgePrec(imvalids[A] |> Wireexpr, imupdates[C] |> Wireexpr, "AC")
    w3, pkg3 = posedgePrec(imupdates[C] |> Wireexpr, imvalids[E] |> Wireexpr, "CE")
    vpush!.(debugcore, (pkg0, pkg1, pkg2, pkg3))

    # test body
    w4, pkg4 = posedgeSync(imupdates[A] |> Wireexpr, imupdates[C] |> Wireexpr, "ACsync")
    # B,E,D sync
    w5, pkg5 = posedgeSync(~Wireexpr(imvalids[B]), ~Wireexpr(imvalids[E]), "BEnegvalidsync")
    w6, pkg6 = posedgeSync(Wireexpr(imvalids[E]), Wireexpr(imvalids[D]), "DvalidWaitsE")
    w7, pkg7 = posedgeSync(Wireexpr(imupdates[B]), Wireexpr(imupdates[E]), "BEupdatesync")
    w8, pkg8 = posedgeSync(~Wireexpr(imupdates[D]), ~Wireexpr(imupdates[B]), "BDnegupdatesync")
    vpush!.(debugcore, (pkg4, pkg5, pkg6, pkg7, pkg8))

    pretp, pkgtp = bitbundle([(@wireexpr $w == 0b11) for w in [w0, w1, w2, w3, w4, w5, w6, w7, w8]], "tpbundle")
    vpush!(debugcore, pkgtp)
    vpush!(debugcore, @ports @out @logic 9 tp)
    vpush!(debugcore, @always tp = $pretp)

    ms = layer2vmod!(lay)
    m = ms[begin]

    function f(m, waitcount)
        al1 = @always (
            if acc
                counter <= $(Wireexpr(32, 0))
                score <= score + $(Wireexpr(32, 1))
            elseif counter < $waitcount
                counter <= counter + 1
            end
        )
        al2 = @always (
            $(nametolower(imvalid)) = counter == $waitcount;
            acc = $(nametolower(imvalid)) & $(nametolower(imupdate))
        )
        vpush!(m, al1, al2)

        return nothing
    end
    function g(m, waitcount)
        al1 = @always (
            if acc
                counter <= $(Wireexpr(32, 0))
                score <= score + $(Wireexpr(32, 1))
            elseif counter < $waitcount
                counter <= counter + 1
            end
        )
        al2 = @always (
            $(nametoupper(imupdate)) = $waitcount == counter;
            acc = $(nametoupper(imvalid)) & $(nametoupper(imupdate))
        )
        vpush!(m, al1, al2)
    end

    wcupper = [10, 8, 15]
    for (m, c) in zip((A, B, E), wcupper)
        f(m, c)
    end
    wclower = [12, 6]
    for (m, c) in zip((C, D), wclower)
        g(m, c)
    end

    for m in ms
        try
            vfinalize(m)
        catch
            vshow(m)
            rethrow()
        end
    end

    duts = vfinalize.(ms)

    debuggraph = Mmodgraph()
    mdut = Midmodule(duts[begin])
    
    debuggraph(
        mdut => debugcore, 
        [
            [invport(p) => p for p in values(imvalids)];
            [invport(p) => p for p in values(imupdates)]
        ]
    )

    debugs = layer2vmod!(debuggraph, name="dut")
    debugs = vfinalize.(debugs)
    dbgpvec = getports(debugs[begin]).val
    for i in eachindex(dbgpvec)
        pnow = dbgpvec[i]
        if getname(pnow) == "tp_debugcore"
            dbgpvec[i] = @oneport @out @logic $(getwidth(pnow)) tp
            vpush!(debugs[begin], @always tp = tp_debugcore)
            vpush!(debugs[begin], @decls @logic $(getwidth(pnow)) tp_debugcore)
        end
    end

    return verilatorSimrun([debugs; duts[begin+1:end]], 9, 200, option=VerilatorOption(["unoptflat", "unused", "undriven", "declfilename"]))
end

function midlevelVerilatorTest()
    if !Sys.islinux()
        return
    end

    @test intermmodSimpleTest()
    return
end

midlevelVerilatorTest()