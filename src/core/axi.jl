function addAxiLitePort!(v::Vmodule, addrlen, datalen)
    datalen % 8 == 0 || error("datalen $datalen is not multiple of eight")
    strblen = Int(datalen / 8)

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
    vpush!.(v, (arports, awports, bports, wports, rports))
end