function arpreq()
    addrlen = 13
    datalen = 32

    datalen % 8 == 0 || error("datalen should be multiple of eight")
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

    @Randlayer v
    vpush!(v, bports)
    vpush!(v, @ports (
        @out @logic $addrlen awaddr, araddr;
        @out @logic $strblen wstrb;
        @out @logic $datalen wdata;
        @in $datalen rdata;
    ))

    g = Layergraph()
    @Randlayer Raddr
    @Randlayer Rdata
    @Randlayer Waddr
    @Randlayer Wdata
    vpush!(Raddr, arports)
    vpush!(Rdata, rports)
    vpush!(Waddr, awports)
    vpush!(Wdata, wports)

    g(v => Waddr, 1, (@oneport @out $addrlen awaddr) => @oneport @in $addrlen awaddr_in)
    g(v => Wdata, 1, [
        (@oneport @out $datalen wdata) => (@oneport @in $datalen wdata_in),
        (@oneport @out $strblen wstrb) => @oneport @in $strblen wstrb_in
    ])
    g(v => Raddr, 2, (@oneport @out $addrlen araddr) => (@oneport @in $addrlen araddr_in))
    g(Rdata => v, 2, [
        (@oneport @out $datalen rdata_out) => (@oneport @in $datalen rdata)
    ])
    waddral = @always (
        awaddr = awaddr_in;
        $(nametoupper(imupdate, 1)) = awready;
        awvalid = $(nametoupper(imvalid, 1))
    )
    wdataal = @always (
        wdata = wdata_in;
        wstrb = wstrb_in;
        $(nametoupper(imupdate, 1)) = wready;
        wvalid = $(nametoupper(imvalid, 1))
    )
    raddral = @always (
        araddr = araddr_in;
        $(nametoupper(imupdate, 2)) = arready;
        arvalid = $(nametoupper(imvalid, 2))
    )
    rdataal = @always (
        rdata_out = rdata;
        $(nametolower(imvalid, 2)) = rvalid;
        rready = $(nametolower(imupdate, 2))
    )
    vpush!.(Wdata, (wdataal, @ports (@in $datalen wdata_in; @in $strblen wstrb_in)))
    vpush!.(Waddr, (waddral, @ports @in $addrlen awaddr_in))
    vpush!.(Rdata, (rdataal, @ports @out @logic $datalen rdata_out))
    vpush!.(Raddr, (raddral, @ports @in $addrlen araddr_in))

    m = @FSM etherrecv idle, addr1, addr2, addr3, typeRegister, lenRegister, dataRegister, setStatus, readStatus, waitStatus, readall
    
    counter(x) = @wireexpr _counter == $x
    subcount(x) = @wireexpr _subcount == $x
    readdone2() = imacceptedUpper(2) & counter(2)

    wdone = @wireexpr $(nametolower(imvalid, 1)) & $(nametolower(imupdate, 1))
    transadd!(m, (@wireexpr transinit), @tstate idle => addr1)
    transadd!(m, imacceptedUpper(2) & subcount(2), @tstate addr1 => addr2)
    transadd!(m, imacceptedUpper(2) & counter(2), @tstate addr2 => addr3)
    transadd!(m, readdone2(), @tstate addr3 => typeRegister)
    transadd!(m, readdone2(), @tstate typeRegister => lenRegister)
    transadd!(m, readdone2(), @tstate lenRegister => dataRegister)
    
    # data other than htype
    datawords = 7
    transadd!(m, imacceptedUpper(2) & (@wireexpr (_count == $datawords-1) & (_subcount == 2)), @tstate dataRegister => readall)
    transadd!(m, (@wireexpr _waitcount == 200) & (@wireexpr _count == 11) , @tstate readall => setStatus)
    transadd!(m, imacceptedLower(1) & (@wireexpr _count == 2), @tstate setStatus => readStatus)
    transadd!(m, (@wireexpr rissued), @tstate readStatus => waitStatus)
    transadd!(m, (@wireexpr phybusy), @tstate waitStatus => readStatus)
    transadd!(m, (@wireexpr waitStatusDone), @tstate waitStatus => idle)

    vpush!(v, @decls @logic 32*$datawords dvec, dbuf, dtarget);

    alcomb = @always (
        ether = etherrecv;
        # dvec = 0;
        # ethertype, hlen, plen
        dvec[31:0] = 0x0406_0008;
        # operation, sender mac1 
        dvec[63:32] = 0x0000_0100;
        # sender mac2
        dvec[95:64] = 0xcefa_005e;
        # sender ip, 172.16.0.2
        dvec[127:96] = 0x0200_10ac;
        # recv mac1, ignore in req
        dvec[159:128] = 0;
        # recvmac, recv ip1
        dvec[191:160] = 0x10ac_0000;
        # recv ip2, empty
        dvec[223:192] = 0x0000_0100;
        rissued = $(nametolower(imvalid, 2)) & $(nametolower(imupdate, 2));
        phybusy = $(nametoupper(imvalid, 2)) & $(nametoupper(imupdate, 2)) & rdata[0];
        waitStatusDone = $(nametoupper(imvalid, 2)) & $(nametoupper(imupdate, 2)) & ~rdata[0];

        bready = 1;
    )
    alff = @cpalways (
        fire <= fire | transinit;
        

        awaddr = 0;
        wstrb = 0;
        wdata = 0;

        araddr = 0;



        $(nametolower(imvalid, 1)) = 0;
        $(nametolower(imvalid, 2)) = 0;
        $(nametoupper(imupdate, 2)) = 0;

        if ether == addr1
            if _subcount == 0
                awaddr = 0x0000
                wstrb = 0b1111
                wdata = ~0
                $(nametolower(imvalid, 1)) = fire
                if $(imacceptedLower(1))
                    _subcount <= 1
                end
            elseif _subcount == 1
                araddr = 0x0000
                $(nametolower(imvalid, 2)) = 1
                if $(imacceptedLower(2))
                    _subcount <= 2
                end
            elseif _subcount == 2
                $(nametoupper(imupdate, 2)) = 1
                if $(imacceptedUpper(2))
                    _subcount <= 0
                end
            end
        elseif ether == addr2
            if _counter == $(Wireexpr(32, 0))
                awaddr = 0x0004
                wstrb = 0b1111
                wdata = 0x0000_ffff
                $(nametolower(imvalid, 1)) = 1;
                if $(imacceptedLower(1))
                    _counter <= 1
                end
            elseif _counter == 1
                araddr = 0x0004
                $(nametolower(imvalid, 2)) = 1
                if $(imacceptedLower(2))
                    _counter <= 2
                end
            elseif _counter == 2
                $(nametoupper(imupdate, 2)) = 1
                if $(imacceptedUpper(2))
                    _counter <= 0
                end
            end
        elseif ether == addr3
            if _counter == 0
                awaddr = 0x0008
                wstrb = 0b1111
                wdata = 0xcefa_005e
                $(nametolower(imvalid, 1)) = 1;
                if $(imacceptedLower(1))
                    _counter <= 1
                end
            elseif _counter == 1
                araddr = 0x0008
                $(nametolower(imvalid, 2)) = 1
                if $(imacceptedLower(2))
                    _counter <= 2
                end
            elseif _counter == 2
                $(nametoupper(imupdate, 2)) = 1
                if $(imacceptedUpper(2))
                    _counter <= 0
                end
            end
        elseif ether == typeRegister
            if _counter == 0
                awaddr = 0x000c
                wstrb = 0b1111
                wdata = $(@wireexpr 0x0100 << 16) | 0x0608
                $(nametolower(imvalid, 1)) = 1;
                if $(imacceptedLower(1))
                    _counter <= 1
                end
            elseif _counter == 1
                araddr = 0x000c
                $(nametolower(imvalid, 2)) = 1
                if $(imacceptedLower(2))
                    _counter <= 2
                end
            elseif _counter == 2
                $(nametoupper(imupdate, 2)) = 1
                if $(imacceptedUpper(2))
                    _counter <= 0
                end
            end
        elseif ether == lenRegister
            if _counter == 0
                awaddr = 0x07f4
                wstrb = 0b0011
                wdata = 28 + 14
                $(nametolower(imvalid, 1)) = 1;
                if $(imacceptedLower(1))
                    _counter <= 1
                end
            elseif _counter == 1
                araddr = 0x07f4
                $(nametolower(imvalid, 2)) = 1
                if $(imacceptedLower(2))
                    _counter <= 2
                end
            elseif _counter == 2
                $(nametoupper(imupdate, 2)) = 1
                if $(imacceptedUpper(2))
                    _counter <= 0
                end
            end
        elseif ether == dataRegister
            if _subcount == 0
                awaddr = 0x0010 + (_count[12:0] << 2)
                wstrb = 0b1111
                $(nametolower(imvalid, 1)) = 1;
                wdata = dvec[((_count << 5) + 31)-:32]
                if $(nametolower(imvalid, 1)) & $(nametolower(imupdate, 1))
                    _subcount <= 1
                end
            elseif _subcount == 1
                araddr =  0x0010 + (_count[12:0] << 2)
                $(nametolower(imvalid, 2)) = 1
                if $(imacceptedLower(2))
                    _subcount <= 2
                end
            elseif _subcount == 2
                $(nametoupper(imupdate, 2)) = 1
                if $(imacceptedUpper(2))
                    _subcount <= 0
                    if _count < 7 - 1
                        _count <= _count + 1
                    else
                        _count <= $(Wireexpr(32, 0))
                    end
                end
            end
        elseif ether == readall
            if _count == 11
                if _waitcount == 200
                    _waitcount <= 0
                    _count <= 0
                else
                    _waitcount <= _waitcount + $(Wireexpr(32, 1))
                end
            else
                if _subcount == 0
                    araddr = 0x00 + (_count[12:0] << 2)
                    $(nametolower(imvalid, 2)) = 1
                    if $(imacceptedLower(2))
                        _subcount <= 1
                    end
                else
                    $(nametoupper(imupdate, 2)) = 1
                    if $(imacceptedUpper(2))
                        _subcount <= $(Wireexpr(32, 0))
                        _count <= _count + 1
                    end
                end
            end
        elseif ether == setStatus
            $(nametolower(imvalid, 1)) = 0
            if _count == 0
                araddr = 0x07fc
                $(nametolower(imvalid, 2)) = 1
                if $(imacceptedLower(2))
                    _count <= _count + 1
                end
            elseif _count == 1
                $(nametoupper(imupdate, 2)) = 1
                if $(imacceptedUpper(2))
                    _count <= _count + 1
                end
                rtemp <= rdata
            else
                $(nametolower(imvalid, 1)) = 1
                awaddr = 0x07fc
                wstrb = 0b1111
                wdata[0] = 1
                wdata[31:1] = rtemp[31:1]
                if $(imacceptedLower(1))
                    _count <= 0
                end
            end
        else
            $(nametolower(imvalid, 1)) = 0
        end;

        if ether == readStatus
            araddr = 0x07fc
            $(nametolower(imvalid, 2)) = 1
        end;

        if ether == waitStatus
            $(nametoupper(imupdate, 2)) = 1
        end
    )

    vpush!.(v, (m, alcomb, alff...))
    vpush!.(v, (@ports @in transinit))


    v1 = vfinalize.(layer2vmod!(g, name="arpreq"))
    wrapper = wrappergen(v1[begin])
    axiformat(s) = replace(s, r"((aw|w|b|ar|r)[a-zA-Z0-9_]+)_[a-zA-Z0-9_]+" => s"\1")
    newports = [Oneport(getdirec(i), wire, getwidth(i), axiformat(getname(i))) for i in getports(wrapper)] |> Ports
    core = wrapper.insts[]
    newcore = Vmodinst(
        core.vmodname,
        core.instname,
        core.params,
        [s => Wireexpr(axiformat(getname(w))) for (s, w) in core.ports],
        core.wildconn
    )
    wrapper = Vmodule(getname(wrapper))
    vpush!.(wrapper, (newports, newcore))
    # # vshow(wrapper)
    # vexport(v1)
    # # vexport(wrapper, "mymaster_1_wrapper.v")
    # vexport("mymaster_1_wrapper.v", wrapper)

    return v1, wrapper
    # logic to add multiple ports per vmodule is broken?
end

v, wrapper = arpreq()