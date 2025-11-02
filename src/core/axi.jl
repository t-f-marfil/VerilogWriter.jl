function generateAxiLitePort(addrlen, datalen, isManager::Bool, suffix)
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

function generateAxi4Port(addrlen, datalen, idlen, userlen, isManager, suffix)
    # Manager side port
    axi4ports = @ports (
        @out @logic $idlen awid;
        @out @logic 8 awlen;
        @out @logic 3 awsize;
        @out @logic 2 awburst;
        @out @logic 2 awlock;
        @out @logic 4 awcache;
        @out @logic 3 awprot;
        @out @logic 4 awqos;
        @out @logic 4 awregion;
        @out @logic $userlen awuser;
        
        @out @logic wlast;
        @out @logic $userlen wuser;
        
        @in $idlen bid;
        @in $userlen buser;

        @out @logic $idlen arid;
        @out @logic 8 arlen;
        @out @logic 3 arsize;
        @out @logic 2 arburst;
        @out @logic 2 arlock;
        @out @logic 4 arcache;
        @out @logic 3 arprot;
        @out @logic 4 arqos;
        @out @logic 4 arregion;
        @out @logic $userlen aruser;

        @in $idlen rid;
        @in rlast;
        @in $userlen ruser;
    )

    result = generateAxiLitePort(addrlen, datalen, true, "")

    vpush!(result, axi4ports)

    if !isManager
        result = invports(result)
    end

    result = Ports([vrename(p, string(getname(p), suffix)) for p in result])

    return result
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