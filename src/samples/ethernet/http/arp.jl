function generateArpMessageBlock(name)
    
    vbuf = generateEtherFrameTxBuffer("arp_$name")
    vethergen = generateEtherFrameGenerator("arp_$name")
    # varpreqgen = generateArpRequestGenerator()
    varpreqgen = generateArpMessageGenerator("arp_$name")

    g = Vmodgraph()

    g(
        varpreqgen => vethergen,
        @pconnect (
            wdata => wdata_in,
            wvalid => wvalid_in,
            wlast => wlast_in
        )
    )
    g(
        vethergen => varpreqgen,
        @pconnect (
            wready_out => wready
        )
    )

    g(
        vethergen => vbuf,
        @pconnect (
            wvalid => ufp_valid,
            wdata => ufp_data,
            wlast => ufp_last
        )
    )
    g(
        vbuf => vethergen,
        @pconnect (
            ufp_ready => wready
        )
    )
    
    vs = layer2vmod!(g, false, name="ArpMessageBlock_$name")
    return vs
end
