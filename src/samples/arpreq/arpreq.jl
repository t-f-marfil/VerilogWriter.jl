let 
    reqAddrAndData = [
        # ARP Probe for 169.254.10.10 (one of Link Local Addresses)
        # with AXI Ethernet Lite MAC IP Core.
        # 
        # dest. addr. = FF:FF:FF:FF:FF:FF (broadcast)
        # src. addr. = 00:00:5E:00:FA:CE (default in userguide pg135-axi-ethernetlite)
        (1, 0x0000, 0xFFFF_FFFF),
        (1, 0x0004, 0x0000_FFFF),
        (1, 0x0008, 0xCEFA_005E),
        # EtherType = 0x0806 (ARP)
        # ethernet frame (ARP packet) payload starts here
        # HTYPE = 1
        (1, 0x000C, 0x0100_0608),
        # PTYPE = 0x0800,
        # HLEN (MAC addr. length) = 6,
        # PLEN (IP addr. length) = 4
        (1, 0x0010, 0x0406_0008),
        # OPERATION = 1 (Request)
        # Sender MAC = 00:00:5E:00:FA:CE
        (1, 0x0014, 0x0000_0100),
        (1, 0x0018, 0xCEFA_005E),
        # Sender IP = 0.0.0.0 (RFC 3927)
        (1, 0x001C, 0x0000_0000),
        # Target MAC = 00:00:00:00:00:00 (RFC 3927)
        (1, 0x0020, 0x0000_0000),
        # Target IP = 169.254.10.10
        (1, 0x0024, 0xFEA9_0000),
        (1, 0x0028, 0x0000_0A0A),
        
        # Length of packet at 0x07F4 (AXI Ethernet Lite MAC)
        # sender/target MAC addr. (6 + 6), ethertype (2), and payload (28)
        (1, 0x07F4, 14 + 28),

        # Set Transmit Status at 0x07FC
        (1, 0x07FC, 0b1),
    ]
    
    addrList = [addr for (_, addr, _) in reqAddrAndData]
    dataList = [data for (_, _, data) in reqAddrAndData]
    opcodeList = [code for (code, _, _) in reqAddrAndData]

    addrlen, datalen = 13, 32

    @sym2wire updateReqData, updateReqAddr, restart
    addrmemfile = "arpProbeAddr.mem"
    datamemfile = "arpProbeData.mem"
    opcodememfile = "arpProbeOpcode.mem"
    open(addrmemfile, "w") do io
        dumpMemfile(io, addrList, addrlen)
    end
    open(datamemfile, "w") do io
        dumpMemfile(io, dataList, datalen)
    end
    open(opcodememfile, "w") do io
        dumpMemfile(io, opcodeList, 1)
    end
    addrWires, addrPatch = readOnlyQueue(addrlen, length(addrList), updateReqAddr, restart, addrmemfile)
    dataWires, dataPatch = readOnlyQueue(datalen, length(dataList), updateReqData, restart, datamemfile)
    opcodeAddrWires, opcodeAddrPatch = readOnlyQueue(1, length(opcodeList), updateReqAddr, restart, opcodememfile)
    opcodeDataWires, opcodeDataPatch = readOnlyQueue(1, length(opcodeList), updateReqData, restart, opcodememfile)

    v = Vmodule("ArpProbe")
    vpush!.(v, (addrPatch, dataPatch))
    vpush!.(v, (opcodeAddrPatch, opcodeDataPatch))
    vpush!(v, @ports @in CLK, rstn)

    addAxiLitePort!(v, addrlen, datalen, true)
    vpush!(v, @ports @in btn)

    controlAl = @always (
        # when reset, value is set to zero (default) by autoreset
        
        if btn
            rstCleared <= 1;
        end
    )

    queueAl = @always (
        addrIsWrite = $(opcodeAddrWires[1]) & ($(opcodeAddrWires[2]) == 1);
        addrIsRead = $(opcodeAddrWires[1]) & ($(opcodeAddrWires[2]) == 0);

        dataIsWrite = $(opcodeDataWires[1]) & ($(opcodeDataWires[2]) == 1);
        dataIsRead = $(opcodeDataWires[1]) & ($(opcodeDataWires[2]) == 0);

        updateReqAddr = updateReqAddrWrite | updateReqRead;
        updateReqData = updateReqDataWrite | updateReqRead;
    )
    prespike, pspike = zipSpike([@wireexpr(wvalid & wready), @wireexpr(awvalid & awready), @wireexpr(bready & bvalid)])
    vpush!(v, pspike)

    # Workaround in order not to surpass 100Mbps when sending more than one ethenet frame
    waitCount = 50
    alSpike = @cpalways (
        spike = 0;
        if $prespike
            startCount <= $(Wireexpr(1, 1))
        elseif spikeCount == $waitCount
            startCount <= 0
            spike = 1
        end;

        if spikeCount == $waitCount
            spikeCount <= 0
        elseif startCount
            spikeCount <= spikeCount + $(Wireexpr(32, 1))
        end
    )
    vpush!(v, alSpike...)

    awAl = @cpalways (
        awvalid = $(addrWires[1]) & addrIsWrite & rstCleared & ~awaccepted;
        if spike
            awaccepted <= 0
        else
            awaccepted <= (awaccepted | (awvalid & awready))
        end;
        updateReqAddrWrite = spike;
        awaddr = $(addrWires[2]);
        restart = $(Wireexpr(1, 0))
    )


    wAl = @cpalways (
        wvalid = $(dataWires[1]) & dataIsWrite & rstCleared & ~waccepted;
        if spike
            waccepted <= 0
        else
            waccepted <= (waccepted | (wvalid & wready))
        end;
        updateReqDataWrite = spike;
        wdata = $(dataWires[2]);
        wstrb = ~0
    )

    rAl = @always (
        arvalid = $(addrWires[1]) & addrIsRead & rstCleared;
        araddr = $(addrWires[2]);
        updateReqRead = arvalid & arready
    )

    constAl = @always (
        # araddr = 0;
        # arvalid = 0;

        bready = 1;
        rready = 1;
    )

    vpush!.(v, (
        queueAl,
        controlAl,
        awAl...,
        wAl...,
        rAl,
        constAl
    ))

    v = vfinalize(v; rst=@wireexpr ~rstn)
    w = wrappergen(v)
    
    vexport(v), vexport("$(getname(w)).v", w)
end