# include("midlevel/midlayer.jl")
# include("core/rawparser.jl")
let 
    addrlen = 13
    datalen = 32
    ipint(a, b, c, d) = (((((a << 8) | b) << 8) | c) << 8) | d

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

    # v = Vmodule("mymaster")
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
        $(nametoupper(ilupdate, 1)) = awready;
        awvalid = $(nametoupper(ilvalid, 1))
    )
    wdataal = @always (
        wdata = wdata_in;
        wstrb = wstrb_in;
        $(nametoupper(ilupdate, 1)) = wready;
        wvalid = $(nametoupper(ilvalid, 1))
    )
    raddral = @always (
        araddr = araddr_in;
        $(nametoupper(ilupdate, 2)) = arready;
        arvalid = $(nametoupper(ilvalid, 2))
    )
    rdataal = @always (
        rdata_out = rdata;
        $(nametolower(ilvalid, 2)) = rvalid;
        rready = $(nametolower(ilupdate, 2))
    )
    vpush!.(Wdata, (wdataal, @ports (@in $datalen wdata_in; @in $strblen wstrb_in)))
    vpush!.(Waddr, (waddral, @ports @in $addrlen awaddr_in))
    vpush!.(Rdata, (rdataal, @ports @out @logic $datalen rdata_out))
    vpush!.(Raddr, (raddral, @ports @in $addrlen araddr_in))

    # m = @FSM etherrecv idle, idler, waiting, readtype, readdata, clear, abort, addr1, addr2, addr3, typeRegister, lenRegister, dataRegister, setStatus, readStatus, waitStatus
    # m = @FSM etherrecv idle, addr1, addr2, addr3, typeRegister, lenRegister, dataRegister, setStatus, readStatus, waitStatus, readall
    # @sym2wire ack, nack, isarp, notarp, abortdone, readdatadone, cleardone
    # transadd!(m, [
    #     (ilacceptedLower(2), @tstate idler => waiting),
    #     (ack, @tstate waiting => readdata),
    #     (nack, @tstate waiting => idler),
    #     (ilacceptedUpper(2), @tstate readtype => clear),
    #     # (notarp, @tstate readtype => clear),
    #     # (abortdone, @tstate abort => idle),
    #     (readdatadone, @tstate readdata => readtype),
    #     (cleardone, @tstate clear => idle),
    # ])

    # alcomb = @always (
    #     ack = $(ilacceptedUpper(2)) & rdata[0];
    #     nack = $(ilacceptedUpper(2)) & ~rdata[0];
    #     isarp = $(ilacceptedUpper(2)) & (rdata[15:0] == $(Wireexpr(16, 0x0608)));
    #     notarp = $(ilacceptedUpper(2)) & ~isarp;
    #     readdatadone = $(ilacceptedUpper(2)) & (_count == 2 + 7) & (_subcount == 1);
    #     cleardone = $(ilacceptedLower(1));
    #     abortdone = $(ilacceptedLower(1));
    # )

    # decldata = @decls (
    #     @logic 48 srcmac, destmac
    # )

    # alfsm = @cpalways (
    #     araddr = 0;
    #     awaddr = 0;
    #     wstrb = 0;
    #     wdata = 0;
    #     bready = 1;
    #     $(nametolower(ilvalid, 2)) = 0;
    #     $(nametoupper(ilupdate, 2)) = 0;
    #     $(nametolower(ilvalid, 1)) = 0;
    #     fire <= fire | transinit;

    #     if etherrecv == idle
    #         $(nametolower(ilvalid, 2)) = fire
    #         araddr = 0x17fc
    #     elseif etherrecv == waiting
    #         $(nametoupper(ilupdate, 2)) = 1
    #         _count <= $(Wireexpr(32, 0))
    #         _subcount <= 0
    #     elseif etherrecv == readtype
    #         if _count == 0
    #             $(nametolower(ilvalid, 2)) = 1
    #             araddr = 0x100c
    #             if $(ilacceptedLower(2))
    #                 _count <= _count + 1
    #             end
    #         elseif _count == 1
    #             $(nametoupper(ilupdate, 2)) = 1
    #             if $(ilacceptedUpper(2))
    #                 _count <= 0
    #             end
    #         end
    #     elseif etherrecv == readdata
    #         if _count == 0
    #             if _subcount == 0
    #                 $(nametolower(ilvalid, 2)) = 1
    #                 araddr = 0x1000
    #                 if $(ilacceptedLower(2))
    #                     _subcount <= _subcount + $(Wireexpr(32, 1))
    #                 end
    #             else
    #                 $(nametoupper(ilupdate, 2)) = 1
    #                 if $(ilacceptedUpper(2))
    #                     _subcount <= 0
    #                     srcmac[31:0] <= rdata
    #                     _count <= _count + 1
    #                 end
    #             end
    #         end
    #         if _count == 1
    #             if _subcount == 0
    #                 $(nametolower(ilvalid, 2)) = 1
    #                 araddr = 0x1004
    #                 if $(ilacceptedLower(2))
    #                     _subcount <= _subcount + $(Wireexpr(32, 1))
    #                 end
    #             else
    #                 $(nametoupper(ilupdate, 2)) = 1
    #                 if $(ilacceptedUpper(2))
    #                     _subcount <= 0
    #                     srcmac[47:32] <= rdata[15:0]
    #                     destmac[15:0] <= rdata[31:16]
    #                     _count <= _count + 1
    #                 end
    #             end
    #         end
    #         if _count == 2
    #             if _subcount == 0
    #                 $(nametolower(ilvalid, 2)) = 1
    #                 araddr = 0x1008
    #                 if $(ilacceptedLower(2))
    #                     _subcount <= _subcount + $(Wireexpr(32, 1))
    #                 end
    #             else
    #                 $(nametoupper(ilupdate, 2)) = 1
    #                 if $(ilacceptedUpper(2))
    #                     _subcount <= 0
    #                     destmac[47:16] <= rdata
    #                     _count <= _count + 1
    #                 end
    #             end
    #         end
    #         if (2 < _count) & (_count < 3 + 7)
    #             if _subcount == 0
    #                 $(nametolower(ilvalid, 2)) = 1
    #                 araddr = 0x100c + ((_count[12:0] - 3) << 2)
    #                 if $(ilacceptedLower(2))
    #                     _subcount <= _subcount + $(Wireexpr(32, 1))
    #                 end
    #             else
    #                 $(nametoupper(ilupdate, 2)) = 1
    #                 if $(ilacceptedUpper(2))
    #                     _subcount <= 0
    #                     if _count == 3 + 6
    #                         _count <= 0
    #                     else
    #                         _count <= _count + 1
    #                     end
    #                 end
    #             end
    #         end
    #     elseif etherrecv == clear || etherrecv == abort
    #         $(nametolower(ilvalid, 1)) = 1
    #         awaddr = 0x17fc
    #         wdata = 0
    #         wstrb = 0b1
    #     end
    # )
    # vpush!.(v, (alcomb, decldata, alfsm..., m, @ports @in transinit))
    # vpush!.(v, (alcomb, decldata))
    m = @FSM etherrecv idle, addr1, addr2, addr3, typeRegister, lenRegister, dataRegister, setStatus, readStatus, waitStatus, readall
    
    # m = @FSM ether idle, addr1, addr2, addr3, typeRegister, lenRegister, dataRegister, setStatus, readStatus, waitStatus
    counter(x) = @wireexpr _counter == $x
    subcount(x) = @wireexpr _subcount == $x
    readdone2() = ilacceptedUpper(2) & counter(2)

    wdone = @wireexpr $(nametolower(ilvalid, 1)) & $(nametolower(ilupdate, 1))
    transadd!(m, (@wireexpr transinit), @tstate idle => addr1)
    # transadd!(m, (@wireexpr fire), @tstate idle => addr1)
    transadd!(m, ilacceptedUpper(2) & subcount(2), @tstate addr1 => addr2)
    transadd!(m, ilacceptedUpper(2) & counter(2), @tstate addr2 => addr3)
    transadd!(m, readdone2(), @tstate addr3 => typeRegister)
    transadd!(m, readdone2(), @tstate typeRegister => lenRegister)
    transadd!(m, readdone2(), @tstate lenRegister => dataRegister)
    # transadd!(m, wdone, @tstate dataRegister1 => dataRegister2)

    # data other than htype
    datawords = 7
    transadd!(m, ilacceptedUpper(2) & (@wireexpr (_count == $datawords-1) & (_subcount == 2)), @tstate dataRegister => readall)
    transadd!(m, (@wireexpr _waitcount == 200) & (@wireexpr _count == 11) , @tstate readall => setStatus)
    transadd!(m, ilacceptedLower(1) & (@wireexpr _count == 2), @tstate setStatus => readStatus)
    transadd!(m, (@wireexpr rissued), @tstate readStatus => waitStatus)
    transadd!(m, (@wireexpr phybusy), @tstate waitStatus => readStatus)
    # transadd!(m, (@wireexpr waitStatusDone), @tstate waitStatus => idler)
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
        rissued = $(nametolower(ilvalid, 2)) & $(nametolower(ilupdate, 2));
        phybusy = $(nametoupper(ilvalid, 2)) & $(nametoupper(ilupdate, 2)) & rdata[0];
        waitStatusDone = $(nametoupper(ilvalid, 2)) & $(nametoupper(ilupdate, 2)) & ~rdata[0];

        bready = 1;
    )
    destip = ipint(169, 254, 140, 269)
    alff = @cpalways (
        fire <= fire | transinit;
        

        awaddr = 0;
        wstrb = 0;
        wdata = 0;

        araddr = 0;



        $(nametolower(ilvalid, 1)) = 0;
        $(nametolower(ilvalid, 2)) = 0;
        $(nametoupper(ilupdate, 2)) = 0;

        if ether == addr1
            if _subcount == 0
                awaddr = 0x0000
                wstrb = 0b1111
                wdata = ~0
                $(nametolower(ilvalid, 1)) = fire
                if $(ilacceptedLower(1))
                    _subcount <= 1
                end
            elseif _subcount == 1
                araddr = 0x0000
                $(nametolower(ilvalid, 2)) = 1
                if $(ilacceptedLower(2))
                    _subcount <= 2
                end
            elseif _subcount == 2
                $(nametoupper(ilupdate, 2)) = 1
                if $(ilacceptedUpper(2))
                    _subcount <= 0
                end
            end
        elseif ether == addr2
            if _counter == $(Wireexpr(32, 0))
                awaddr = 0x0004
                wstrb = 0b1111
                wdata = 0x0000_ffff
                $(nametolower(ilvalid, 1)) = 1;
                if $(ilacceptedLower(1))
                    _counter <= 1
                end
            elseif _counter == 1
                araddr = 0x0004
                $(nametolower(ilvalid, 2)) = 1
                if $(ilacceptedLower(2))
                    _counter <= 2
                end
            elseif _counter == 2
                $(nametoupper(ilupdate, 2)) = 1
                if $(ilacceptedUpper(2))
                    _counter <= 0
                end
            end
        elseif ether == addr3
            if _counter == 0
                awaddr = 0x0008
                wstrb = 0b1111
                wdata = 0xcefa_005e
                $(nametolower(ilvalid, 1)) = 1;
                if $(ilacceptedLower(1))
                    _counter <= 1
                end
            elseif _counter == 1
                araddr = 0x0008
                $(nametolower(ilvalid, 2)) = 1
                if $(ilacceptedLower(2))
                    _counter <= 2
                end
            elseif _counter == 2
                $(nametoupper(ilupdate, 2)) = 1
                if $(ilacceptedUpper(2))
                    _counter <= 0
                end
            end
        elseif ether == typeRegister
            if _counter == 0
                awaddr = 0x000c
                wstrb = 0b1111
                wdata = $(@wireexpr 0x0100 << 16) | 0x0608
                $(nametolower(ilvalid, 1)) = 1;
                if $(ilacceptedLower(1))
                    _counter <= 1
                end
            elseif _counter == 1
                araddr = 0x000c
                $(nametolower(ilvalid, 2)) = 1
                if $(ilacceptedLower(2))
                    _counter <= 2
                end
            elseif _counter == 2
                $(nametoupper(ilupdate, 2)) = 1
                if $(ilacceptedUpper(2))
                    _counter <= 0
                end
            end
        elseif ether == lenRegister
            if _counter == 0
                awaddr = 0x07f4
                wstrb = 0b0011
                wdata = 28 + 14
                $(nametolower(ilvalid, 1)) = 1;
                if $(ilacceptedLower(1))
                    _counter <= 1
                end
            elseif _counter == 1
                araddr = 0x07f4
                $(nametolower(ilvalid, 2)) = 1
                if $(ilacceptedLower(2))
                    _counter <= 2
                end
            elseif _counter == 2
                $(nametoupper(ilupdate, 2)) = 1
                if $(ilacceptedUpper(2))
                    _counter <= 0
                end
            end
        elseif ether == dataRegister
            if _subcount == 0
                awaddr = 0x0010 + (_count[12:0] << 2)
                wstrb = 0b1111
                $(nametolower(ilvalid, 1)) = 1;
                wdata = dvec[((_count << 5) + 31)-:32]
                if $(nametolower(ilvalid, 1)) & $(nametolower(ilupdate, 1))
                    _subcount <= 1
                    # if _count < 7 - 1
                    #     _count <= _count + 1
                    # else
                    #     _count <= $(Wireexpr(32, 0))
                    # end
                end
            elseif _subcount == 1
                araddr =  0x0010 + (_count[12:0] << 2)
                $(nametolower(ilvalid, 2)) = 1
                if $(ilacceptedLower(2))
                    _subcount <= 2
                end
            elseif _subcount == 2
                $(nametoupper(ilupdate, 2)) = 1
                if $(ilacceptedUpper(2))
                    _subcount <= 0
                    if _count < 7 - 1
                        _count <= _count + 1
                    else
                        _count <= $(Wireexpr(32, 0))
                    end
                end
            end

        # elseif ether == dataRegister2
        #     awaddr = 0x0014
        #     wstrb = 0b1111
        #     wdata = dvec[63:32]
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
                    $(nametolower(ilvalid, 2)) = 1
                    if $(ilacceptedLower(2))
                        _subcount <= 1
                    end
                else
                    $(nametoupper(ilupdate, 2)) = 1
                    if $(ilacceptedUpper(2))
                        _subcount <= $(Wireexpr(32, 0))
                        # if _count == 10
                        #     _count <= 0
                        # else
                        #     _count <= _count + 1
                        # end
                        _count <= _count + 1
                    end
                end
            end
        elseif ether == setStatus
            $(nametolower(ilvalid, 1)) = 0
            if _count == 0
                araddr = 0x07fc
                $(nametolower(ilvalid, 2)) = 1
                if $(ilacceptedLower(2))
                    _count <= _count + 1
                end
            elseif _count == 1
                $(nametoupper(ilupdate, 2)) = 1
                if $(ilacceptedUpper(2))
                    _count <= _count + 1
                end
                rtemp <= rdata
            else
                $(nametolower(ilvalid, 1)) = 1
                awaddr = 0x07fc
                wstrb = 0b1111
                wdata[0] = 1
                wdata[31:1] = rtemp[31:1]
                if $(ilacceptedLower(1))
                    _count <= 0
                end
            end
        else
            $(nametolower(ilvalid, 1)) = 0
        end;

        if ether == readStatus
            araddr = 0x07fc
            $(nametolower(ilvalid, 2)) = 1
        end;

        if ether == waitStatus
            $(nametoupper(ilupdate, 2)) = 1
        end
    )

    # vpush!.(v, (arports, awports, bports, wports, rports))
    vpush!.(v, (m, alcomb, alff...))
    vpush!.(v, (@ports @in transinit))


    v1 = vfinalize.(layer2vmod!(g, name="vaxi_1"))
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
    # vshow(wrapper)
    vexport(v1)
    vexport(wrapper, "mymaster_1_wrapper.v")

    # logic to add multiple ports per vmodule is broken?
end