function generateRecvBufferSelector()
    depth = 8
    prts = @ports (
        @in CLK,RST;
        # ufp : connection between buffer and axicorecontroller
        @in ufp_wvalid, ufp_wready, ufp_wlast;
        @in 32 ufp_wdata;

        @out @logic bufout_wready;
        @in bufout_wvalid;
        @in 32 bufout_wdata;
        @in bufout_wlast;

        # port to ignore here
        @in $depth bufout_awlen;
        @in bufout_awvalid;
        @out @logic bufout_awready;

        @out @logic debug_valid;
        @out @logic 72 debug_data
    )
    basePorts = @ports (
        @in dfp_wready;
        @out @logic dfp_wvalid;
        @out @logic 32 dfp_wdata;
        @out @logic dfp_wlast;
    )

    arpPorts = renamedPorts(basePorts, x->"$(x)_arp")

    fsm = @FSM state (
        idle, 
        testEther, connectArp,
        testIp,
        explicitFlushBuffer
    )
    transadd!(fsm, @wireexpr(ufp_wvalid & ufp_wready), @tstate idle => testEther)
    transadd!(fsm, @wireexpr((dwordCounter == 3) & (ethertype == $(Wireexpr(16, 0x0806))) & (ufp_wvalid & ufp_wready)), @tstate testEther => connectArp)
    # transadd!(fsm, @wireexpr((dwordCounter == 3)), @tstate testEther => connectArp)
    transadd!(fsm, @wireexpr((dwordCounter == 3) & (ethertype == $(Wireexpr(16, 0x0800))) & (ufp_wvalid & ufp_wready)), @tstate testEther => testIp)
    transadd!(fsm, @wireexpr((dwordCounter == 3) & ethertype_unknown & (ufp_wvalid & ufp_wready)), @tstate testEther => explicitFlushBuffer)

    transadd!(fsm, @wireexpr(bufout_wlast & bufout_wvalid & bufout_wready), @tstate connectArp => idle)
    transadd!(fsm, @wireexpr(bufout_wlast & bufout_wvalid & bufout_wready), @tstate testIp => idle)
    transadd!(fsm, @wireexpr(bufout_wlast & bufout_wvalid & bufout_wready), @tstate explicitFlushBuffer => idle)


    alPortPassThrough = @always (
        debug_data = {$(Wireexpr(8-3, 0)), state, ufp_wdata, $(Wireexpr(32-8-16-1, 0)), ethertype_unknown, ethertype, dwordCounter};
        debug_valid = ufp_wvalid & ufp_wready;

        if state == connectArp
            bufout_wready = dfp_wready_arp
        elseif state == testIp
            bufout_wready = 1
        elseif state == explicitFlushBuffer
            bufout_wready = 1
        else
            bufout_wready = 0
        end;

        if state == connectArp
            dfp_wvalid_arp = bufout_wvalid
            dfp_wdata_arp = bufout_wdata
            dfp_wlast_arp = bufout_wlast
        else
            dfp_wvalid_arp = 0
            dfp_wdata_arp = 0
            dfp_wlast_arp = 0
        end;
    )
    
    almisc = @always (
        if state == idle
            dwordCounter <= $(Wireexpr(8, 1))
        elseif state == testEther
            if ufp_wready & ufp_wvalid
                dwordCounter <= dwordCounter + 1
            end
        end
    )

    alconst = @always (
        bufout_awready = 1;
        ethertype = {ufp_wdata[7:0], ufp_wdata[15:8]};
        ethertype_unknown = ~((ethertype == 0x0806) | (ethertype == 0x0800))
    )

    v = Vmodule("RecvBufferSelector")
    vpush!.(v, (prts, arpPorts))
    vpush!.(v, (fsm, alPortPassThrough, almisc, alconst))

    return v
end

function generateControllerRecvInterface()
    v = Vmodule("ControllerRecvInterface")

    prts = @ports (
        @in ufp_rvalid;
        @in 32 ufp_rdata;
        @in ufp_rlast;
        @out @logic ufp_rready;

        @out @logic dfp_valid;
        @out @logic 32 dfp_data;
        @out @logic dfp_last;
        @in dfp_ready;
    )
    al = @always (
        ufp_rready = dfp_ready;
        
        dfp_valid = ufp_rvalid;
        dfp_data = ufp_rdata;
        dfp_last = ufp_rlast;
    )

    vpush!.(v, (prts, al))
    return v
end

function generateBufferWithReadRandomAccess()
    # read as fifo, randomly accessible from dfp
    vname = "randomReadAccessBuffer"
    v = Vmodule(vname)
    prts = @ports (
        @in CLK, RST;

        @in ufp_wvalid;
        @in ufp_wlast;
        @in 32 ufp_wdata;
        @out @logic ufp_wready;

        @in 13 dfp_araddr; # word addressing
        @in dfp_arvalid;
        @out @logic dfp_arready;

        @out @logic dfp_rvalid, dfp_rinvalid;
        @out @logic 32 dfp_rdata;

        # force flush, also flush arready&arvalid transaction
        @in dfp_flush;
        @out @logic dfp_full;

        @out @logic debug_valid;
        @out @logic 72 debug_data;
    )

    width = 32
    depth = 13
    @sym2wire enread, enwrite, addrin, addrout, din
    dout, raminst = generateRamSdpRfInst(width, depth, enread, enwrite, addrin, addrout, din, vname)

    alctrl = @cpalways (
        dfp_full = full;
        ufp_wready = ~full;

        debug_data = 0;
        debug_valid = 0;

        if dfp_full & dfp_flush
            full <= 0
            wptr <= 0
        else
            if ufp_wvalid & ufp_wready
                debug_valid = 1
                debug_data = {$(Wireexpr(32-13-1, 0)), ufp_wlast, wptr, $(Wireexpr(8, 0)), ufp_wdata}

                wptr <= wptr + $(Wireexpr(depth, 1))
                if ufp_wlast
                    full <= $(Wireexpr(1, 1))
                end
            end
        end
    )

    alreadstallusage = @cpalways (
        if prev_read_stalling
            addrout = dfp_araddr_buf
        else
            addrout = dfp_araddr
        end;
        if read_stalling & ~prev_read_stalling
            dfp_araddr_buf <= dfp_araddr
        end;

        if dfp_full & dfp_flush
            prev_read_stalling <= 0
        else
            prev_read_stalling <= read_stalling
        end;
        dfp_arready = ~prev_read_stalling;
    )
    alread = @cpalways (
        dfp_rdata = $dout;
        enread = $(Wireexpr(1, 1));

        if (dfp_arvalid & dfp_arready) | prev_read_stalling
            if addrout < wptr
                dfp_rvalid <= 1
                dfp_rinvalid <= 0

                read_stalling = 0
            else
                if full
                    dfp_rvalid <= 0
                    dfp_rinvalid <= 1

                    read_stalling = 0
                else
                    dfp_rvalid <= 0
                    dfp_rinvalid <= 0

                    read_stalling = 1
                end
            end
        else
            read_stalling = 0
            dfp_rvalid <= 0
            dfp_rinvalid <= 0
        end
    )
    alwrite = @always (
        din = ufp_wdata;
        addrin = wptr;
        enwrite = (~full) & ufp_wvalid & ufp_wready;
    )

    vpush!.(v, (prts, raminst, alctrl..., alreadstallusage..., alread..., alwrite))
    return v
end
