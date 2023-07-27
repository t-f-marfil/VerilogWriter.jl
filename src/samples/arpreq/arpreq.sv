module arpreq (
    input transinit_v,
    input [1:0] bresp_v,
    input bvalid_v,
    output bready_v,
    output [12:0] awaddr_Waddr,
    output awvalid_Waddr,
    input awready_Waddr,
    input wready_Wdata,
    output wvalid_Wdata,
    output [3:0] wstrb_Wdata,
    output [31:0] wdata_Wdata,
    input arready_Raddr,
    output arvalid_Raddr,
    output [12:0] araddr_Raddr,
    input [31:0] rdata_Rdata,
    input [1:0] rresp_Rdata,
    output rready_Rdata,
    input rvalid_Rdata,
    input CLK,
    input RST
);
    logic [12:0] awaddr_in_Waddr;
    logic [3:0] wstrb_in_Wdata;
    logic [31:0] wdata_in_Wdata;
    logic [12:0] araddr_in_Raddr;
    logic [31:0] rdata_v;
    logic valid_to_lower_port1_v;
    logic valid_from_upper_port1_Waddr;
    logic update_from_lower_port1_v;
    logic update_to_upper_port1_Waddr;
    logic valid_from_upper_port1_Wdata;
    logic update_to_upper_port1_Wdata;
    logic valid_to_lower_port2_v;
    logic valid_from_upper_port2_Raddr;
    logic update_from_lower_port2_v;
    logic update_to_upper_port2_Raddr;
    logic valid_to_lower_port2_Rdata;
    logic valid_from_upper_port2_v;
    logic update_from_lower_port2_Rdata;
    logic update_to_upper_port2_v;
    logic [1:0] bundle_valid_SUML_from_v_port1;
    logic [1:0] bundle_update_SUML_from_v_port1;
    logic bundle_valid_SUML_from_v_port2;
    logic bundle_update_SUML_from_v_port2;
    logic bundle_valid_SUML_from_Rdata_port2;
    logic bundle_update_SUML_from_Rdata_port2;
    logic bundle_valid_MUSL_from_Waddr_port1;
    logic bundle_update_MUSL_from_Waddr_port1;
    logic bundle_valid_MUSL_from_Wdata_port1;
    logic bundle_update_MUSL_from_Wdata_port1;
    logic bundle_valid_MUSL_from_Raddr_port2;
    logic bundle_update_MUSL_from_Raddr_port2;
    logic bundle_valid_MUSL_from_v_port2;
    logic bundle_update_MUSL_from_v_port2;
    logic CLK_Raddr;
    logic CLK_Rdata;
    logic CLK_Waddr;
    logic CLK_Wdata;
    logic CLK_v;
    logic RST_Raddr;
    logic RST_Rdata;
    logic RST_Waddr;
    logic RST_Wdata;
    logic RST_v;
    logic [12:0] araddr_v;
    logic [12:0] awaddr_v;
    logic [31:0] rdata_out_Rdata;
    logic update_mlay2suml_from_Rdata_port2;
    logic update_mlay2suml_from_v_port1;
    logic update_mlay2suml_from_v_port2;
    logic update_musl2mlay_to_Raddr_port2;
    logic update_musl2mlay_to_Waddr_port1;
    logic update_musl2mlay_to_Wdata_port1;
    logic update_musl2mlay_to_v_port2;
    logic update_suml2musl_Rdata_port2_to_v_port2;
    logic update_suml2musl_v_port1_to_Waddr_port1;
    logic update_suml2musl_v_port1_to_Wdata_port1;
    logic update_suml2musl_v_port2_to_Raddr_port2;
    logic valid_mlay2suml_from_Rdata_port2;
    logic valid_mlay2suml_from_v_port1;
    logic valid_mlay2suml_from_v_port2;
    logic valid_musl2mlay_to_Raddr_port2;
    logic valid_musl2mlay_to_Waddr_port1;
    logic valid_musl2mlay_to_Wdata_port1;
    logic valid_musl2mlay_to_v_port2;
    logic valid_suml2musl_Rdata_port2_to_v_port2;
    logic valid_suml2musl_v_port1_to_Waddr_port1;
    logic valid_suml2musl_v_port1_to_Wdata_port1;
    logic valid_suml2musl_v_port2_to_Raddr_port2;
    logic [31:0] wdata_v;
    logic [3:0] wstrb_v;

    imSUML_v_port1_to_Waddr_port1_and_Wdata_port1 uSUML_from_v_port1 (
        .CLK(CLK),
        .RST(RST),
        .valid_to_lower_port0(valid_mlay2suml_from_v_port1),
        .update_from_lower_port0(update_mlay2suml_from_v_port1),
        .valid_from_upper_port0(bundle_valid_SUML_from_v_port1),
        .update_to_upper_port0(bundle_update_SUML_from_v_port1)
    );
    imSUML_v_port2_to_Raddr_port2 uSUML_from_v_port2 (
        .CLK(CLK),
        .RST(RST),
        .valid_to_lower_port0(valid_mlay2suml_from_v_port2),
        .update_from_lower_port0(update_mlay2suml_from_v_port2),
        .valid_from_upper_port0(bundle_valid_SUML_from_v_port2),
        .update_to_upper_port0(bundle_update_SUML_from_v_port2)
    );
    imSUML_Rdata_port2_to_v_port2 uSUML_from_Rdata_port2 (
        .CLK(CLK),
        .RST(RST),
        .valid_to_lower_port0(valid_mlay2suml_from_Rdata_port2),
        .update_from_lower_port0(update_mlay2suml_from_Rdata_port2),
        .valid_from_upper_port0(bundle_valid_SUML_from_Rdata_port2),
        .update_to_upper_port0(bundle_update_SUML_from_Rdata_port2)
    );
    imMUSL_Waddr_port1_from_v_port1 uMUSL_from_Waddr_port1 (
        .CLK(CLK),
        .RST(RST),
        .valid_to_lower_port0(bundle_valid_MUSL_from_Waddr_port1),
        .update_from_lower_port0(bundle_update_MUSL_from_Waddr_port1),
        .valid_from_upper_port0(valid_musl2mlay_to_Waddr_port1),
        .update_to_upper_port0(update_musl2mlay_to_Waddr_port1)
    );
    imMUSL_Wdata_port1_from_v_port1 uMUSL_from_Wdata_port1 (
        .CLK(CLK),
        .RST(RST),
        .valid_to_lower_port0(bundle_valid_MUSL_from_Wdata_port1),
        .update_from_lower_port0(bundle_update_MUSL_from_Wdata_port1),
        .valid_from_upper_port0(valid_musl2mlay_to_Wdata_port1),
        .update_to_upper_port0(update_musl2mlay_to_Wdata_port1)
    );
    imMUSL_Raddr_port2_from_v_port2 uMUSL_from_Raddr_port2 (
        .CLK(CLK),
        .RST(RST),
        .valid_to_lower_port0(bundle_valid_MUSL_from_Raddr_port2),
        .update_from_lower_port0(bundle_update_MUSL_from_Raddr_port2),
        .valid_from_upper_port0(valid_musl2mlay_to_Raddr_port2),
        .update_to_upper_port0(update_musl2mlay_to_Raddr_port2)
    );
    imMUSL_v_port2_from_Rdata_port2 uMUSL_from_v_port2 (
        .CLK(CLK),
        .RST(RST),
        .valid_to_lower_port0(bundle_valid_MUSL_from_v_port2),
        .update_from_lower_port0(bundle_update_MUSL_from_v_port2),
        .valid_from_upper_port0(valid_musl2mlay_to_v_port2),
        .update_to_upper_port0(update_musl2mlay_to_v_port2)
    );
    v v_inst (
        .bready(bready_v),
        .bresp(bresp_v),
        .bvalid(bvalid_v),
        .awaddr(awaddr_v),
        .araddr(araddr_v),
        .wstrb(wstrb_v),
        .wdata(wdata_v),
        .rdata(rdata_v),
        .transinit(transinit_v),
        .CLK(CLK_v),
        .RST(RST_v),
        .valid_to_lower_port1(valid_to_lower_port1_v),
        .update_from_lower_port1(update_from_lower_port1_v),
        .valid_to_lower_port2(valid_to_lower_port2_v),
        .update_from_lower_port2(update_from_lower_port2_v),
        .valid_from_upper_port2(valid_from_upper_port2_v),
        .update_to_upper_port2(update_to_upper_port2_v)
    );
    Waddr Waddr_inst (
        .awaddr(awaddr_Waddr),
        .awready(awready_Waddr),
        .awvalid(awvalid_Waddr),
        .awaddr_in(awaddr_in_Waddr),
        .CLK(CLK_Waddr),
        .RST(RST_Waddr),
        .valid_from_upper_port1(valid_from_upper_port1_Waddr),
        .update_to_upper_port1(update_to_upper_port1_Waddr)
    );
    Wdata Wdata_inst (
        .wdata(wdata_Wdata),
        .wstrb(wstrb_Wdata),
        .wvalid(wvalid_Wdata),
        .wready(wready_Wdata),
        .wdata_in(wdata_in_Wdata),
        .wstrb_in(wstrb_in_Wdata),
        .CLK(CLK_Wdata),
        .RST(RST_Wdata),
        .valid_from_upper_port1(valid_from_upper_port1_Wdata),
        .update_to_upper_port1(update_to_upper_port1_Wdata)
    );
    Raddr Raddr_inst (
        .araddr(araddr_Raddr),
        .arready(arready_Raddr),
        .arvalid(arvalid_Raddr),
        .araddr_in(araddr_in_Raddr),
        .CLK(CLK_Raddr),
        .RST(RST_Raddr),
        .valid_from_upper_port2(valid_from_upper_port2_Raddr),
        .update_to_upper_port2(update_to_upper_port2_Raddr)
    );
    Rdata Rdata_inst (
        .rready(rready_Rdata),
        .rvalid(rvalid_Rdata),
        .rdata(rdata_Rdata),
        .rresp(rresp_Rdata),
        .rdata_out(rdata_out_Rdata),
        .CLK(CLK_Rdata),
        .RST(RST_Rdata),
        .valid_to_lower_port2(valid_to_lower_port2_Rdata),
        .update_from_lower_port2(update_from_lower_port2_Rdata)
    );
    always_comb begin
        awaddr_in_Waddr = awaddr_v;
        wstrb_in_Wdata = wstrb_v;
        wdata_in_Wdata = wdata_v;
        araddr_in_Raddr = araddr_v;
        rdata_v = rdata_out_Rdata;
    end
    always_comb begin
        valid_suml2musl_v_port1_to_Waddr_port1 = bundle_valid_SUML_from_v_port1[0];
        valid_suml2musl_v_port1_to_Wdata_port1 = bundle_valid_SUML_from_v_port1[1];
        bundle_update_SUML_from_v_port1[0] = update_suml2musl_v_port1_to_Waddr_port1;
        bundle_update_SUML_from_v_port1[1] = update_suml2musl_v_port1_to_Wdata_port1;
    end
    always_comb begin
        valid_suml2musl_v_port2_to_Raddr_port2 = bundle_valid_SUML_from_v_port2;
        bundle_update_SUML_from_v_port2 = update_suml2musl_v_port2_to_Raddr_port2;
    end
    always_comb begin
        valid_suml2musl_Rdata_port2_to_v_port2 = bundle_valid_SUML_from_Rdata_port2;
        bundle_update_SUML_from_Rdata_port2 = update_suml2musl_Rdata_port2_to_v_port2;
    end
    always_comb begin
        bundle_valid_MUSL_from_Waddr_port1 = valid_suml2musl_v_port1_to_Waddr_port1;
        update_suml2musl_v_port1_to_Waddr_port1 = bundle_update_MUSL_from_Waddr_port1;
    end
    always_comb begin
        bundle_valid_MUSL_from_Wdata_port1 = valid_suml2musl_v_port1_to_Wdata_port1;
        update_suml2musl_v_port1_to_Wdata_port1 = bundle_update_MUSL_from_Wdata_port1;
    end
    always_comb begin
        bundle_valid_MUSL_from_Raddr_port2 = valid_suml2musl_v_port2_to_Raddr_port2;
        update_suml2musl_v_port2_to_Raddr_port2 = bundle_update_MUSL_from_Raddr_port2;
    end
    always_comb begin
        bundle_valid_MUSL_from_v_port2 = valid_suml2musl_Rdata_port2_to_v_port2;
        update_suml2musl_Rdata_port2_to_v_port2 = bundle_update_MUSL_from_v_port2;
    end
    always_comb begin
        update_from_lower_port1_v = update_mlay2suml_from_v_port1;
        valid_mlay2suml_from_v_port1 = valid_to_lower_port1_v;
        update_from_lower_port2_v = update_mlay2suml_from_v_port2;
        valid_mlay2suml_from_v_port2 = valid_to_lower_port2_v;
        update_from_lower_port2_Rdata = update_mlay2suml_from_Rdata_port2;
        valid_mlay2suml_from_Rdata_port2 = valid_to_lower_port2_Rdata;
    end
    always_comb begin
        update_musl2mlay_to_Waddr_port1 = update_to_upper_port1_Waddr;
        valid_from_upper_port1_Waddr = valid_musl2mlay_to_Waddr_port1;
        update_musl2mlay_to_Wdata_port1 = update_to_upper_port1_Wdata;
        valid_from_upper_port1_Wdata = valid_musl2mlay_to_Wdata_port1;
        update_musl2mlay_to_Raddr_port2 = update_to_upper_port2_Raddr;
        valid_from_upper_port2_Raddr = valid_musl2mlay_to_Raddr_port2;
        update_musl2mlay_to_v_port2 = update_to_upper_port2_v;
        valid_from_upper_port2_v = valid_musl2mlay_to_v_port2;
    end
    always_comb begin
        CLK_v = CLK;
        RST_v = RST;
    end
    always_comb begin
        CLK_Waddr = CLK;
        RST_Waddr = RST;
    end
    always_comb begin
        CLK_Wdata = CLK;
        RST_Wdata = RST;
    end
    always_comb begin
        CLK_Raddr = CLK;
        RST_Raddr = RST;
    end
    always_comb begin
        CLK_Rdata = CLK;
        RST_Rdata = RST;
    end
endmodule
module v (
    output logic bready,
    input [1:0] bresp,
    input bvalid,
    output logic [12:0] awaddr,
    output logic [12:0] araddr,
    output logic [3:0] wstrb,
    output logic [31:0] wdata,
    input [31:0] rdata,
    input transinit,
    input CLK,
    input RST,
    output logic valid_to_lower_port1,
    input logic update_from_lower_port1,
    output logic valid_to_lower_port2,
    input logic update_from_lower_port2,
    input logic valid_from_upper_port2,
    output logic update_to_upper_port2
);
    localparam idle = 0;
    localparam addr1 = 1;
    localparam addr2 = 2;
    localparam addr3 = 3;
    localparam typeRegister = 4;
    localparam lenRegister = 5;
    localparam dataRegister = 6;
    localparam setStatus = 7;
    localparam readStatus = 8;
    localparam waitStatus = 9;
    localparam readall = 10;

    logic [(32 * 7)-1:0] dvec;
    logic [(32 * 7)-1:0] dbuf;
    logic [(32 * 7)-1:0] dtarget;
    reg [3:0] etherrecv;
    logic [31:0] _count;
    logic [31:0] _counter;
    logic [31:0] _subcount;
    logic [31:0] _waitcount;
    logic [3:0] ether;
    logic fire;
    logic phybusy;
    logic rissued;
    logic [31:0] rtemp;
    logic waitStatusDone;

    always_ff @( posedge CLK ) begin
        if (RST) begin
            etherrecv <= 0;
        end else begin
            case (etherrecv)
                idle: begin
                    if (transinit) begin
                        etherrecv <= addr1;
                    end
                end
                addr1: begin
                    if (((valid_from_upper_port2 & update_to_upper_port2) & (_subcount == 2))) begin
                        etherrecv <= addr2;
                    end
                end
                addr2: begin
                    if (((valid_from_upper_port2 & update_to_upper_port2) & (_counter == 2))) begin
                        etherrecv <= addr3;
                    end
                end
                addr3: begin
                    if (((valid_from_upper_port2 & update_to_upper_port2) & (_counter == 2))) begin
                        etherrecv <= typeRegister;
                    end
                end
                typeRegister: begin
                    if (((valid_from_upper_port2 & update_to_upper_port2) & (_counter == 2))) begin
                        etherrecv <= lenRegister;
                    end
                end
                lenRegister: begin
                    if (((valid_from_upper_port2 & update_to_upper_port2) & (_counter == 2))) begin
                        etherrecv <= dataRegister;
                    end
                end
                dataRegister: begin
                    if (((valid_from_upper_port2 & update_to_upper_port2) & ((_count == (7 - 1)) & (_subcount == 2)))) begin
                        etherrecv <= readall;
                    end
                end
                setStatus: begin
                    if (((valid_to_lower_port1 & update_from_lower_port1) & (_count == 2))) begin
                        etherrecv <= readStatus;
                    end
                end
                readStatus: begin
                    if (rissued) begin
                        etherrecv <= waitStatus;
                    end
                end
                waitStatus: begin
                    if (waitStatusDone) begin
                        etherrecv <= idle;
                    end else if (phybusy) begin
                        etherrecv <= readStatus;
                    end
                end
                readall: begin
                    if (((_waitcount == 200) & (_count == 11))) begin
                        etherrecv <= setStatus;
                    end
                end
            endcase
        end
    end
    always_comb begin
        ether = etherrecv;
        dvec[31:0] = 67502088;
        dvec[63:32] = 256;
        dvec[95:64] = 3472490590;
        dvec[127:96] = 33558700;
        dvec[159:128] = 0;
        dvec[191:160] = 279707648;
        dvec[223:192] = 256;
        rissued = (valid_to_lower_port2 & update_from_lower_port2);
        phybusy = ((valid_from_upper_port2 & update_to_upper_port2) & rdata[0]);
        waitStatusDone = ((valid_from_upper_port2 & update_to_upper_port2) & (~rdata[0]));
        bready = 1;
    end
    always_comb begin
        awaddr = 0;
        wstrb = 0;
        wdata = 0;
        araddr = 0;
        valid_to_lower_port1 = 0;
        valid_to_lower_port2 = 0;
        update_to_upper_port2 = 0;
        if ((ether == addr1)) begin
            if ((_subcount == 0)) begin
                awaddr = 0;
                wstrb = 15;
                wdata = (~0);
                valid_to_lower_port1 = fire;
                if ((valid_to_lower_port1 & update_from_lower_port1)) begin
                    
                end
            end else if ((_subcount == 1)) begin
                araddr = 0;
                valid_to_lower_port2 = 1;
                if ((valid_to_lower_port2 & update_from_lower_port2)) begin
                    
                end
            end else if ((_subcount == 2)) begin
                update_to_upper_port2 = 1;
                if ((valid_from_upper_port2 & update_to_upper_port2)) begin
                    
                end
            end
        end else if ((ether == addr2)) begin
            if ((_counter == 32'd0)) begin
                awaddr = 4;
                wstrb = 15;
                wdata = 65535;
                valid_to_lower_port1 = 1;
                if ((valid_to_lower_port1 & update_from_lower_port1)) begin
                    
                end
            end else if ((_counter == 1)) begin
                araddr = 4;
                valid_to_lower_port2 = 1;
                if ((valid_to_lower_port2 & update_from_lower_port2)) begin
                    
                end
            end else if ((_counter == 2)) begin
                update_to_upper_port2 = 1;
                if ((valid_from_upper_port2 & update_to_upper_port2)) begin
                    
                end
            end
        end else if ((ether == addr3)) begin
            if ((_counter == 0)) begin
                awaddr = 8;
                wstrb = 15;
                wdata = 3472490590;
                valid_to_lower_port1 = 1;
                if ((valid_to_lower_port1 & update_from_lower_port1)) begin
                    
                end
            end else if ((_counter == 1)) begin
                araddr = 8;
                valid_to_lower_port2 = 1;
                if ((valid_to_lower_port2 & update_from_lower_port2)) begin
                    
                end
            end else if ((_counter == 2)) begin
                update_to_upper_port2 = 1;
                if ((valid_from_upper_port2 & update_to_upper_port2)) begin
                    
                end
            end
        end else if ((ether == typeRegister)) begin
            if ((_counter == 0)) begin
                awaddr = 12;
                wstrb = 15;
                wdata = ((256 << 16) | 1544);
                valid_to_lower_port1 = 1;
                if ((valid_to_lower_port1 & update_from_lower_port1)) begin
                    
                end
            end else if ((_counter == 1)) begin
                araddr = 12;
                valid_to_lower_port2 = 1;
                if ((valid_to_lower_port2 & update_from_lower_port2)) begin
                    
                end
            end else if ((_counter == 2)) begin
                update_to_upper_port2 = 1;
                if ((valid_from_upper_port2 & update_to_upper_port2)) begin
                    
                end
            end
        end else if ((ether == lenRegister)) begin
            if ((_counter == 0)) begin
                awaddr = 2036;
                wstrb = 3;
                wdata = (28 + 14);
                valid_to_lower_port1 = 1;
                if ((valid_to_lower_port1 & update_from_lower_port1)) begin
                    
                end
            end else if ((_counter == 1)) begin
                araddr = 2036;
                valid_to_lower_port2 = 1;
                if ((valid_to_lower_port2 & update_from_lower_port2)) begin
                    
                end
            end else if ((_counter == 2)) begin
                update_to_upper_port2 = 1;
                if ((valid_from_upper_port2 & update_to_upper_port2)) begin
                    
                end
            end
        end else if ((ether == dataRegister)) begin
            if ((_subcount == 0)) begin
                awaddr = (16 + (_count[12:0] << 2));
                wstrb = 15;
                valid_to_lower_port1 = 1;
                wdata = dvec[((_count << 5) + 31) -: 32];
                if ((valid_to_lower_port1 & update_from_lower_port1)) begin
                    
                end
            end else if ((_subcount == 1)) begin
                araddr = (16 + (_count[12:0] << 2));
                valid_to_lower_port2 = 1;
                if ((valid_to_lower_port2 & update_from_lower_port2)) begin
                    
                end
            end else if ((_subcount == 2)) begin
                update_to_upper_port2 = 1;
                if ((valid_from_upper_port2 & update_to_upper_port2)) begin
                    if ((_count < (7 - 1))) begin
                        
                    end else begin
                        
                    end
                end
            end
        end else if ((ether == readall)) begin
            if ((_count == 11)) begin
                if ((_waitcount == 200)) begin
                    
                end else begin
                    
                end
            end else begin
                if ((_subcount == 0)) begin
                    araddr = (0 + (_count[12:0] << 2));
                    valid_to_lower_port2 = 1;
                    if ((valid_to_lower_port2 & update_from_lower_port2)) begin
                        
                    end
                end else begin
                    update_to_upper_port2 = 1;
                    if ((valid_from_upper_port2 & update_to_upper_port2)) begin
                        
                    end
                end
            end
        end else if ((ether == setStatus)) begin
            valid_to_lower_port1 = 0;
            if ((_count == 0)) begin
                araddr = 2044;
                valid_to_lower_port2 = 1;
                if ((valid_to_lower_port2 & update_from_lower_port2)) begin
                    
                end
            end else if ((_count == 1)) begin
                update_to_upper_port2 = 1;
                if ((valid_from_upper_port2 & update_to_upper_port2)) begin
                    
                end
            end else begin
                valid_to_lower_port1 = 1;
                awaddr = 2044;
                wstrb = 15;
                wdata[0] = 1;
                wdata[31:1] = rtemp[31:1];
                if ((valid_to_lower_port1 & update_from_lower_port1)) begin
                    
                end
            end
        end else begin
            valid_to_lower_port1 = 0;
        end
        if ((ether == readStatus)) begin
            araddr = 2044;
            valid_to_lower_port2 = 1;
        end
        if ((ether == waitStatus)) begin
            update_to_upper_port2 = 1;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            _count <= 0;
            _counter <= 0;
            _subcount <= 0;
            _waitcount <= 0;
            fire <= 0;
            rtemp <= 0;
        end else begin
            fire <= (fire | transinit);
            if ((ether == addr1)) begin
                if ((_subcount == 0)) begin
                    if ((valid_to_lower_port1 & update_from_lower_port1)) begin
                        _subcount <= 1;
                    end
                end else if ((_subcount == 1)) begin
                    if ((valid_to_lower_port2 & update_from_lower_port2)) begin
                        _subcount <= 2;
                    end
                end else if ((_subcount == 2)) begin
                    if ((valid_from_upper_port2 & update_to_upper_port2)) begin
                        _subcount <= 0;
                    end
                end
            end else if ((ether == addr2)) begin
                if ((_counter == 32'd0)) begin
                    if ((valid_to_lower_port1 & update_from_lower_port1)) begin
                        _counter <= 1;
                    end
                end else if ((_counter == 1)) begin
                    if ((valid_to_lower_port2 & update_from_lower_port2)) begin
                        _counter <= 2;
                    end
                end else if ((_counter == 2)) begin
                    if ((valid_from_upper_port2 & update_to_upper_port2)) begin
                        _counter <= 0;
                    end
                end
            end else if ((ether == addr3)) begin
                if ((_counter == 0)) begin
                    if ((valid_to_lower_port1 & update_from_lower_port1)) begin
                        _counter <= 1;
                    end
                end else if ((_counter == 1)) begin
                    if ((valid_to_lower_port2 & update_from_lower_port2)) begin
                        _counter <= 2;
                    end
                end else if ((_counter == 2)) begin
                    if ((valid_from_upper_port2 & update_to_upper_port2)) begin
                        _counter <= 0;
                    end
                end
            end else if ((ether == typeRegister)) begin
                if ((_counter == 0)) begin
                    if ((valid_to_lower_port1 & update_from_lower_port1)) begin
                        _counter <= 1;
                    end
                end else if ((_counter == 1)) begin
                    if ((valid_to_lower_port2 & update_from_lower_port2)) begin
                        _counter <= 2;
                    end
                end else if ((_counter == 2)) begin
                    if ((valid_from_upper_port2 & update_to_upper_port2)) begin
                        _counter <= 0;
                    end
                end
            end else if ((ether == lenRegister)) begin
                if ((_counter == 0)) begin
                    if ((valid_to_lower_port1 & update_from_lower_port1)) begin
                        _counter <= 1;
                    end
                end else if ((_counter == 1)) begin
                    if ((valid_to_lower_port2 & update_from_lower_port2)) begin
                        _counter <= 2;
                    end
                end else if ((_counter == 2)) begin
                    if ((valid_from_upper_port2 & update_to_upper_port2)) begin
                        _counter <= 0;
                    end
                end
            end else if ((ether == dataRegister)) begin
                if ((_subcount == 0)) begin
                    if ((valid_to_lower_port1 & update_from_lower_port1)) begin
                        _subcount <= 1;
                    end
                end else if ((_subcount == 1)) begin
                    if ((valid_to_lower_port2 & update_from_lower_port2)) begin
                        _subcount <= 2;
                    end
                end else if ((_subcount == 2)) begin
                    if ((valid_from_upper_port2 & update_to_upper_port2)) begin
                        _subcount <= 0;
                        if ((_count < (7 - 1))) begin
                            _count <= (_count + 1);
                        end else begin
                            _count <= 32'd0;
                        end
                    end
                end
            end else if ((ether == readall)) begin
                if ((_count == 11)) begin
                    if ((_waitcount == 200)) begin
                        _waitcount <= 0;
                        _count <= 0;
                    end else begin
                        _waitcount <= (_waitcount + 32'd1);
                    end
                end else begin
                    if ((_subcount == 0)) begin
                        if ((valid_to_lower_port2 & update_from_lower_port2)) begin
                            _subcount <= 1;
                        end
                    end else begin
                        if ((valid_from_upper_port2 & update_to_upper_port2)) begin
                            _subcount <= 32'd0;
                            _count <= (_count + 1);
                        end
                    end
                end
            end else if ((ether == setStatus)) begin
                if ((_count == 0)) begin
                    if ((valid_to_lower_port2 & update_from_lower_port2)) begin
                        _count <= (_count + 1);
                    end
                end else if ((_count == 1)) begin
                    rtemp <= rdata;
                    if ((valid_from_upper_port2 & update_to_upper_port2)) begin
                        _count <= (_count + 1);
                    end
                end else begin
                    if ((valid_to_lower_port1 & update_from_lower_port1)) begin
                        _count <= 0;
                    end
                end
            end else begin
                
            end
            if ((ether == readStatus)) begin
                
            end
            if ((ether == waitStatus)) begin
                
            end
        end
    end
endmodule
module Waddr (
    output logic [12:0] awaddr,
    input awready,
    output logic awvalid,
    input [12:0] awaddr_in,
    input CLK,
    input RST,
    input logic valid_from_upper_port1,
    output logic update_to_upper_port1
);
    always_comb begin
        awaddr = awaddr_in;
        update_to_upper_port1 = awready;
        awvalid = valid_from_upper_port1;
    end
endmodule
module Wdata (
    output logic [31:0] wdata,
    output logic [3:0] wstrb,
    output logic wvalid,
    input wready,
    input [31:0] wdata_in,
    input [3:0] wstrb_in,
    input CLK,
    input RST,
    input logic valid_from_upper_port1,
    output logic update_to_upper_port1
);
    always_comb begin
        wdata = wdata_in;
        wstrb = wstrb_in;
        update_to_upper_port1 = wready;
        wvalid = valid_from_upper_port1;
    end
endmodule
module Raddr (
    output logic [12:0] araddr,
    input arready,
    output logic arvalid,
    input [12:0] araddr_in,
    input CLK,
    input RST,
    input logic valid_from_upper_port2,
    output logic update_to_upper_port2
);
    always_comb begin
        araddr = araddr_in;
        update_to_upper_port2 = arready;
        arvalid = valid_from_upper_port2;
    end
endmodule
module Rdata (
    output logic rready,
    input rvalid,
    input [31:0] rdata,
    input [1:0] rresp,
    output logic [31:0] rdata_out,
    input CLK,
    input RST,
    output logic valid_to_lower_port2,
    input logic update_from_lower_port2
);
    always_comb begin
        rdata_out = rdata;
        valid_to_lower_port2 = rvalid;
        rready = update_from_lower_port2;
    end
endmodule
module imSUML_v_port1_to_Waddr_port1_and_Wdata_port1 (
    input valid_to_lower_port0,
    output logic update_from_lower_port0,
    output logic [1:0] valid_from_upper_port0,
    input [1:0] update_to_upper_port0,
    input CLK,
    input RST
);
    logic transphase_global;
    logic accepted_child1_comb;
    logic accepted_child1_reg;
    logic accepted_child2_comb;
    logic accepted_child2_reg;
    logic acceptedall;
    logic transphase_local_child1;
    logic transphase_local_child2;
    logic update_to_upper_port0_1;
    logic update_to_upper_port0_2;
    logic valid_from_upper_port0_1;
    logic valid_from_upper_port0_2;

    always_comb begin
        update_to_upper_port0_1 = update_to_upper_port0[0];
        update_to_upper_port0_2 = update_to_upper_port0[1];
    end
    always_comb begin
        valid_from_upper_port0[0] = valid_from_upper_port0_1;
        valid_from_upper_port0[1] = valid_from_upper_port0_2;
    end
    always_comb begin
        accepted_child1_comb = (valid_from_upper_port0_1 & update_to_upper_port0_1);
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            accepted_child1_reg <= 0;
        end else begin
            if (acceptedall) begin
                accepted_child1_reg <= 0;
            end else begin
                accepted_child1_reg <= (accepted_child1_comb | accepted_child1_reg);
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            transphase_local_child1 <= 0;
        end else begin
            if ((accepted_child1_comb | accepted_child1_reg)) begin
                transphase_local_child1 <= (~transphase_global);
            end
        end
    end
    always_comb begin
        valid_from_upper_port0_1 = (valid_to_lower_port0 & (~(~(transphase_local_child1 == transphase_global))));
    end
    always_comb begin
        accepted_child2_comb = (valid_from_upper_port0_2 & update_to_upper_port0_2);
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            accepted_child2_reg <= 0;
        end else begin
            if (acceptedall) begin
                accepted_child2_reg <= 0;
            end else begin
                accepted_child2_reg <= (accepted_child2_comb | accepted_child2_reg);
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            transphase_local_child2 <= 0;
        end else begin
            if ((accepted_child2_comb | accepted_child2_reg)) begin
                transphase_local_child2 <= (~transphase_global);
            end
        end
    end
    always_comb begin
        valid_from_upper_port0_2 = (valid_to_lower_port0 & (~(~(transphase_local_child2 == transphase_global))));
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            transphase_global <= 0;
        end else begin
            if (acceptedall) begin
                transphase_global <= (~transphase_global);
            end
        end
    end
    always_comb begin
        acceptedall = ((1'd1 & (accepted_child1_comb | accepted_child1_reg)) & (accepted_child2_comb | accepted_child2_reg));
    end
    always_comb begin
        update_from_lower_port0 = ((1'd1 & ((accepted_child1_comb | accepted_child1_reg) | update_to_upper_port0_1)) & ((accepted_child2_comb | accepted_child2_reg) | update_to_upper_port0_2));
    end
endmodule
module imSUML_v_port2_to_Raddr_port2 (
    input valid_to_lower_port0,
    output logic update_from_lower_port0,
    output logic valid_from_upper_port0,
    input update_to_upper_port0,
    input CLK,
    input RST
);
    logic transphase_global;
    logic accepted_child1_comb;
    logic accepted_child1_reg;
    logic acceptedall;
    logic transphase_local_child1;
    logic update_to_upper_port0_1;
    logic valid_from_upper_port0_1;

    always_comb begin
        update_to_upper_port0_1 = update_to_upper_port0;
    end
    always_comb begin
        valid_from_upper_port0 = valid_from_upper_port0_1;
    end
    always_comb begin
        accepted_child1_comb = (valid_from_upper_port0_1 & update_to_upper_port0_1);
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            accepted_child1_reg <= 0;
        end else begin
            if (acceptedall) begin
                accepted_child1_reg <= 0;
            end else begin
                accepted_child1_reg <= (accepted_child1_comb | accepted_child1_reg);
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            transphase_local_child1 <= 0;
        end else begin
            if ((accepted_child1_comb | accepted_child1_reg)) begin
                transphase_local_child1 <= (~transphase_global);
            end
        end
    end
    always_comb begin
        valid_from_upper_port0_1 = (valid_to_lower_port0 & (~(~(transphase_local_child1 == transphase_global))));
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            transphase_global <= 0;
        end else begin
            if (acceptedall) begin
                transphase_global <= (~transphase_global);
            end
        end
    end
    always_comb begin
        acceptedall = (1'd1 & (accepted_child1_comb | accepted_child1_reg));
    end
    always_comb begin
        update_from_lower_port0 = (1'd1 & ((accepted_child1_comb | accepted_child1_reg) | update_to_upper_port0_1));
    end
endmodule
module imSUML_Rdata_port2_to_v_port2 (
    input valid_to_lower_port0,
    output logic update_from_lower_port0,
    output logic valid_from_upper_port0,
    input update_to_upper_port0,
    input CLK,
    input RST
);
    logic transphase_global;
    logic accepted_child1_comb;
    logic accepted_child1_reg;
    logic acceptedall;
    logic transphase_local_child1;
    logic update_to_upper_port0_1;
    logic valid_from_upper_port0_1;

    always_comb begin
        update_to_upper_port0_1 = update_to_upper_port0;
    end
    always_comb begin
        valid_from_upper_port0 = valid_from_upper_port0_1;
    end
    always_comb begin
        accepted_child1_comb = (valid_from_upper_port0_1 & update_to_upper_port0_1);
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            accepted_child1_reg <= 0;
        end else begin
            if (acceptedall) begin
                accepted_child1_reg <= 0;
            end else begin
                accepted_child1_reg <= (accepted_child1_comb | accepted_child1_reg);
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            transphase_local_child1 <= 0;
        end else begin
            if ((accepted_child1_comb | accepted_child1_reg)) begin
                transphase_local_child1 <= (~transphase_global);
            end
        end
    end
    always_comb begin
        valid_from_upper_port0_1 = (valid_to_lower_port0 & (~(~(transphase_local_child1 == transphase_global))));
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            transphase_global <= 0;
        end else begin
            if (acceptedall) begin
                transphase_global <= (~transphase_global);
            end
        end
    end
    always_comb begin
        acceptedall = (1'd1 & (accepted_child1_comb | accepted_child1_reg));
    end
    always_comb begin
        update_from_lower_port0 = (1'd1 & ((accepted_child1_comb | accepted_child1_reg) | update_to_upper_port0_1));
    end
endmodule
module imMUSL_Waddr_port1_from_v_port1 (
    input update_to_upper_port0,
    output logic valid_from_upper_port0,
    input valid_to_lower_port0,
    output logic update_from_lower_port0,
    input CLK,
    input RST
);
    always_comb begin
        update_from_lower_port0 = (update_to_upper_port0 & (&(valid_to_lower_port0)));
    end
    always_comb begin
        valid_from_upper_port0 = (&(valid_to_lower_port0));
    end
endmodule
module imMUSL_Wdata_port1_from_v_port1 (
    input update_to_upper_port0,
    output logic valid_from_upper_port0,
    input valid_to_lower_port0,
    output logic update_from_lower_port0,
    input CLK,
    input RST
);
    always_comb begin
        update_from_lower_port0 = (update_to_upper_port0 & (&(valid_to_lower_port0)));
    end
    always_comb begin
        valid_from_upper_port0 = (&(valid_to_lower_port0));
    end
endmodule
module imMUSL_Raddr_port2_from_v_port2 (
    input update_to_upper_port0,
    output logic valid_from_upper_port0,
    input valid_to_lower_port0,
    output logic update_from_lower_port0,
    input CLK,
    input RST
);
    always_comb begin
        update_from_lower_port0 = (update_to_upper_port0 & (&(valid_to_lower_port0)));
    end
    always_comb begin
        valid_from_upper_port0 = (&(valid_to_lower_port0));
    end
endmodule
module imMUSL_v_port2_from_Rdata_port2 (
    input update_to_upper_port0,
    output logic valid_from_upper_port0,
    input valid_to_lower_port0,
    output logic update_from_lower_port0,
    input CLK,
    input RST
);
    always_comb begin
        update_from_lower_port0 = (update_to_upper_port0 & (&(valid_to_lower_port0)));
    end
    always_comb begin
        valid_from_upper_port0 = (&(valid_to_lower_port0));
    end
endmodule
