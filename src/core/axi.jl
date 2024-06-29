function generateAxiLitePort(addrlen, datalen, isManager, suffix)
    datalen % 8 == 0 || error("datalen $datalen is not multiple of eight")
    strblen = Int(datalen / 8)

    # Manager side ports
    arports = @ports (
        @out @logic $addrlen araddr;
        @in arready;
        @out @logic arvalid
    )
    awports = @ports (
        @out @logic $addrlen awaddr;
        @in awready;
        @out @logic awvalid
    )
    bports = @ports (
        @out @logic bready;
        @in 2 bresp;
        @in bvalid
    )
    wports = @ports (
        @out @logic $datalen wdata;
        @out @logic $strblen wstrb;
        @out @logic wvalid;
        @in wready
    )
    rports = @ports (
        @out @logic rready;
        @in rvalid;
        @in $datalen rdata;
        @in 2 rresp
    )

    portsAll = (arports, awports, bports, wports, rports)
    
    if !isManager
        portsAll = (invports(p) for p in portsAll)
    end

    portsAll = (Ports([vrename(p, string(getname(p), suffix)) for p in prts]) for prts in portsAll)

    ans = Ports()
    for p in portsAll
        vpush!(ans, p)
    end

    return ans
end

function addAxiLitePort!(v, addrlen, datalen, isManager)
    addAxiLitePort!(v, addrlen, datalen, isManager, "")
end

function addAxiLitePort!(v::Vmodule, addrlen, datalen, isManager, suffix)
    vpush!(v, generateAxiLitePort(addrlen, datalen, isManager, suffix))
    # datalen % 8 == 0 || error("datalen $datalen is not multiple of eight")
    # strblen = Int(datalen / 8)

    # arports = @ports (
    #     @out @logic $addrlen araddr;
    #     @in arready;
    #     @out @logic arvalid
    # )
    # awports = @ports (
    #     @out @logic $addrlen awaddr;
    #     @in awready;
    #     @out @logic awvalid
    # )
    # bports = @ports (
    #     @out @logic bready;
    #     @in 2 bresp;
    #     @in bvalid
    # )
    # wports = @ports (
    #     @out @logic $datalen wdata;
    #     @out @logic $strblen wstrb;
    #     @out @logic wvalid;
    #     @in wready
    # )
    # rports = @ports (
    #     @out @logic rready;
    #     @in rvalid;
    #     @in $datalen rdata;
    #     @in 2 rresp
    # )
    # vpush!.(v, (arports, awports, bports, wports, rports))
end