
# # deprecated, use ArpMessageGenerator with opcode input
# function generateArpRequestGenerator()
#     v = Vmodule("ArpRequestGenerator")
#     prts = @ports (
#         @in CLK, RST;
#         # static source MAC address
#         # 00:00:5E:00:FA:CE
#         @in 32 senderProtAddr;
#         @in 32 targetProtAddr;
#         @in commandValid;
#         @out @logic commandReady;

#         @out @logic 32 wdata;
#         @out @logic wlast;
#         @out @logic wvalid;
#         @in wready;
#     )

#     fsm = @FSM state idle, busy
#     transadd!(fsm, @wireexpr(commandReady & commandValid), @tstate idle => busy)
#     transadd!(fsm, @wireexpr(wlast & wvalid & wready), @tstate busy => idle)

#     almain = @always (
#         {wvalid, wdata, wlast} = 0;
#         if state == busy
#             wvalid = 1
#             if wcounter == 0
#                 # ethernet -> ar$hrd = 1
#                 # ip -> ar$pro = 0x0800
#                 wdata = 0x0008_0100
#             elseif wcounter == 1
#                 # ar$hln = 6
#                 # ar$pln = 4
#                 # REQUEST -> ar$op = 1
#                 wdata = 0x0100_0406
#             elseif wcounter == 2
#                 # sender hardware address
#                 # 00:00:5E:00:FA:CE
#                 wdata = 0x005E_0000
#             elseif wcounter == 3
#                 # sender protocol address
#                 wdata = {senderProtAddrBuf[23:16], senderProtAddrBuf[31:24], $(Wireexpr(16, 0xCEFA))}
#             elseif wcounter == 4
#                 # target hardware address -> whatever (should be ignored)
#                 # for now fill 0
#                 wdata = {$(Wireexpr(16,0)), senderProtAddrBuf[7:0], senderProtAddrBuf[15:8]}
#             elseif wcounter == 5
#                 wdata = 0
#             elseif wcounter == 6
#                 wdata = {targetProtAddrBuf[7:0], targetProtAddrBuf[15:8], targetProtAddrBuf[23:16], targetProtAddrBuf[31:24]}
#                 wlast = 1
#             end
#         end
#     )
#     almisc = @cpalways (
#         commandReady = state == idle;
#         if state == idle
#             wcounter <= $(Wireexpr(4, 0))
#             senderProtAddrBuf <= senderProtAddr
#             targetProtAddrBuf <= targetProtAddr
#         elseif state == busy
#             if wvalid & wready
#                 wcounter <= wcounter + 1
#             end
#         end
#     )

#     vpush!.(v, (prts, fsm, almain, almisc...))
#     return v
# end

function generateArpMessageGenerator(name)
    v = Vmodule("ArpMessageGenerator_$name")
    prts = @ports (
        @in CLK, RST;
        # static source MAC address
        # 00:00:5E:00:FA:CE
        @in 32 senderProtAddr;
        @in 32 targetProtAddr;
        @in 16 opcode;
        @in arp_command_valid;
        @out @logic arp_command_ready;

        @out @logic 32 wdata;
        @out @logic wlast;
        @out @logic wvalid;
        @in wready;
    )

    fsm = @FSM state idle, busy
    transadd!(fsm, @wireexpr(arp_command_ready & arp_command_valid), @tstate idle => busy)
    transadd!(fsm, @wireexpr(wlast & wvalid & wready), @tstate busy => idle)

    almain = @always (
        {wvalid, wdata, wlast} = 0;
        if state == busy
            wvalid = 1
            if wcounter == 0
                # ethernet -> ar$hrd = 1
                # ip -> ar$pro = 0x0800
                wdata = 0x0008_0100
            elseif wcounter == 1
                # ar$hln = 6
                # ar$pln = 4
                wdata = {opcodeBuf[7:0], opcodeBuf[15:8], $(Wireexpr(16, 0x0406))}
            elseif wcounter == 2
                # sender hardware address
                # 00:00:5E:00:FA:CE
                wdata = 0x005E_0000
            elseif wcounter == 3
                # sender protocol address
                wdata = {senderProtAddrBuf[23:16], senderProtAddrBuf[31:24], $(Wireexpr(16, 0xCEFA))}
            elseif wcounter == 4
                # target hardware address -> whatever (should be ignored)
                # for now fill 0
                wdata = {$(Wireexpr(16,0)), senderProtAddrBuf[7:0], senderProtAddrBuf[15:8]}
            elseif wcounter == 5
                wdata = 0
            elseif wcounter == 6
                wdata = {targetProtAddrBuf[7:0], targetProtAddrBuf[15:8], targetProtAddrBuf[23:16], targetProtAddrBuf[31:24]}
                wlast = 1
            end
        end
    )
    almisc = @cpalways (
        arp_command_ready = state == idle;
        if state == idle
            wcounter <= $(Wireexpr(4, 0))
            senderProtAddrBuf <= senderProtAddr
            targetProtAddrBuf <= targetProtAddr
            opcodeBuf <= opcode
        elseif state == busy
            if wvalid & wready
                wcounter <= wcounter + 1
            end
        end
    )

    vpush!.(v, (prts, fsm, almain, almisc...))
    return v
end

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
    return vs, g
end
