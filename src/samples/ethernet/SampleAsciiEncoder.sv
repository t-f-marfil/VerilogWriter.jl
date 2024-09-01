module SampleAsciiEncoder (
    input rx_UartRecv_etherBypass,
    output strbUpdate_CoreWrite,
    output tx_UartSend_etherBypass,
    output rready_dfp_AxiControl,
    output bready_dfp_AxiControl,
    output arvalid_dfp_AxiControl,
    output [12:0] araddr_dfp_AxiControl,
    input arready_dfp_AxiControl,
    output [3:0] wstrb_dfp_AxiControl,
    output [12:0] awaddr_dfp_AxiControl,
    input wready_dfp_AxiControl,
    output awvalid_dfp_AxiControl,
    output [31:0] wdata_dfp_AxiControl,
    input [1:0] bresp_dfp_AxiControl,
    input [1:0] rresp_dfp_AxiControl,
    input awready_dfp_AxiControl,
    input [31:0] rdata_dfp_AxiControl,
    input bvalid_dfp_AxiControl,
    output wvalid_dfp_AxiControl,
    input rvalid_dfp_AxiControl,
    input CLK,
    input RST
);
    logic inUpdate_UartSend_etherBypass;
    logic [31:0] wDataIn_CoreWrite;
    logic CLK_InputParser;
    logic awvalid_CoreWrite;
    logic rDataValid_InputParser;
    logic [12:0] araddr_ufp_AxiControl;
    logic inValid_fifoForUart;
    logic CLK_AsciiEncoder_source;
    logic outValid_fifoForUart;
    logic wDataValid_InputParser;
    logic [15:0] addrData_AsciiEncoder_source;
    logic outUpdate_fifoForUart;
    logic wAddrUpdate_InputParser;
    logic RST_InputParser;
    logic inValid_AsciiEncoder_encodeToByteStream;
    logic RST_UartSend_etherBypass;
    logic [3:0] strbIn_CoreWrite;
    logic CLK_UartSend_etherBypass;
    logic bvalid_ufp_AxiControl;
    logic wready_ufp_AxiControl;
    logic rAddrValid_CoreWrite;
    logic [119:0] din_AsciiEncoder_encodeToByteStream;
    logic [7:0] din_fifoForUart;
    logic rready_ufp_AxiControl;
    logic [7:0] opcode_AsciiEncoder_source;
    logic wAddrValid_CoreWrite;
    logic rAddrValid_InputParser;
    logic CLK_StrbSrc;
    logic arvalid_CoreWrite;
    logic [12:0] awaddr_CoreWrite;
    logic [31:0] rData_InputParser;
    logic arready_ufp_AxiControl;
    logic [1:0] rresp_ufp_AxiControl;
    logic inValid_AsciiEncoder_source;
    logic wAddrUpdate_CoreWrite;
    logic [7:0] din_InputParser;
    logic CLK_AsciiEncoder_encodeToByteStream;
    logic RST_UartRecv_etherBypass;
    logic [3:0] wstrb_CoreWrite;
    logic [7:0] dout_fifoForUart;
    logic wready_CoreWrite;
    logic [119:0] dout_AsciiEncoder_fifo;
    logic [3:0] wstrb_ufp_AxiControl;
    logic inValid_UartSend_etherBypass;
    logic [7:0] dout_AsciiEncoder_encodeToByteStream;
    logic arready_CoreWrite;
    logic RST_StrbSrc;
    logic RST_AsciiEncoder_source;
    logic outValid_AsciiEncoder_source;
    logic outValid_UartRecv_etherBypass;
    logic RST_CoreWrite;
    logic [119:0] dout_AsciiEncoder_source;
    logic [12:0] wAddrIn_CoreWrite;
    logic rDataValid_CoreWrite;
    logic RST_fifoForUart;
    logic [3:0] dout_StrbSrc;
    logic CLK_AsciiEncoder_fifo;
    logic rvalid_CoreWrite;
    logic [31:0] rdata_CoreWrite;
    logic [15:0] addrIn_WidthIntermediate;
    logic [31:0] wData_InputParser;
    logic [7:0] opcode_InputParser;
    logic outUpdate_AsciiEncoder_encodeToByteStream;
    logic bready_CoreWrite;
    logic [31:0] rdata_ufp_AxiControl;
    logic outUpdate_AsciiEncoder_fifo;
    logic [7:0] dout_UartRecv_etherBypass;
    logic CLK_UartRecv_etherBypass;
    logic [119:0] din_AsciiEncoder_fifo;
    logic wvalid_ufp_AxiControl;
    logic [1:0] bresp_CoreWrite;
    logic [31:0] rDataOut_CoreWrite;
    logic [31:0] wdata_CoreWrite;
    logic rDataUpdate_CoreWrite;
    logic [12:0] awaddr_ufp_AxiControl;
    logic inUpdate_AsciiEncoder_encodeToByteStream;
    logic rAddrUpdate_CoreWrite;
    logic RST_AsciiEncoder_fifo;
    logic [31:0] data_AsciiEncoder_source;
    logic [12:0] araddr_CoreWrite;
    logic outValid_AsciiEncoder_fifo;
    logic transEnd_InputParser;
    logic CLK_AxiControl;
    logic awready_ufp_AxiControl;
    logic outValid_AsciiEncoder_encodeToByteStream;
    logic [31:0] wdata_ufp_AxiControl;
    logic inValid_InputParser;
    logic CLK_fifoForUart;
    logic arvalid_ufp_AxiControl;
    logic rAddrUpdate_InputParser;
    logic CLK_WidthIntermediate;
    logic [12:0] rAddrIn_CoreWrite;
    logic wDataUpdate_InputParser;
    logic rvalid_ufp_AxiControl;
    logic wvalid_CoreWrite;
    logic inValid_AsciiEncoder_fifo;
    logic valid_StrbSrc;
    logic rDataUpdate_InputParser;
    logic [7:0] din_UartSend_etherBypass;
    logic rready_CoreWrite;
    logic bvalid_CoreWrite;
    logic RST_WidthIntermediate;
    logic [1:0] bresp_ufp_AxiControl;
    logic strbValid_CoreWrite;
    logic awvalid_ufp_AxiControl;
    logic [1:0] rresp_CoreWrite;
    logic CLK_CoreWrite;
    logic awready_CoreWrite;
    logic [12:0] addrOut_WidthIntermediate;
    logic wDataUpdate_CoreWrite;
    logic wDataValid_CoreWrite;
    logic RST_AsciiEncoder_encodeToByteStream;
    logic [31:0] transData_InputParser;
    logic wAddrValid_InputParser;
    logic [15:0] addrData_InputParser;
    logic bready_ufp_AxiControl;
    logic inUpdate_InputParser;
    logic RST_AxiControl;

    UartRecv_etherBypass UartRecv_etherBypass_inst (
        .rx(rx_UartRecv_etherBypass),
        .dout(dout_UartRecv_etherBypass),
        .outValid(outValid_UartRecv_etherBypass),
        .CLK(CLK_UartRecv_etherBypass),
        .RST(RST_UartRecv_etherBypass)
    );
    CoreWrite CoreWrite_inst (
        .wAddrValid(wAddrValid_CoreWrite),
        .wAddrUpdate(wAddrUpdate_CoreWrite),
        .wAddrIn(wAddrIn_CoreWrite),
        .rAddrValid(rAddrValid_CoreWrite),
        .rAddrUpdate(rAddrUpdate_CoreWrite),
        .rAddrIn(rAddrIn_CoreWrite),
        .wDataValid(wDataValid_CoreWrite),
        .wDataUpdate(wDataUpdate_CoreWrite),
        .wDataIn(wDataIn_CoreWrite),
        .rDataOut(rDataOut_CoreWrite),
        .rDataValid(rDataValid_CoreWrite),
        .rDataUpdate(rDataUpdate_CoreWrite),
        .strbValid(strbValid_CoreWrite),
        .strbUpdate(strbUpdate_CoreWrite),
        .strbIn(strbIn_CoreWrite),
        .araddr(araddr_CoreWrite),
        .arready(arready_CoreWrite),
        .arvalid(arvalid_CoreWrite),
        .awaddr(awaddr_CoreWrite),
        .awready(awready_CoreWrite),
        .awvalid(awvalid_CoreWrite),
        .bready(bready_CoreWrite),
        .bresp(bresp_CoreWrite),
        .bvalid(bvalid_CoreWrite),
        .wdata(wdata_CoreWrite),
        .wstrb(wstrb_CoreWrite),
        .wvalid(wvalid_CoreWrite),
        .wready(wready_CoreWrite),
        .rready(rready_CoreWrite),
        .rvalid(rvalid_CoreWrite),
        .rdata(rdata_CoreWrite),
        .rresp(rresp_CoreWrite),
        .CLK(CLK_CoreWrite),
        .RST(RST_CoreWrite)
    );
    UartSend_etherBypass UartSend_etherBypass_inst (
        .din(din_UartSend_etherBypass),
        .tx(tx_UartSend_etherBypass),
        .inValid(inValid_UartSend_etherBypass),
        .inUpdate(inUpdate_UartSend_etherBypass),
        .CLK(CLK_UartSend_etherBypass),
        .RST(RST_UartSend_etherBypass)
    );
    fifoForUart fifoForUart_inst (
        .inValid(inValid_fifoForUart),
        .outUpdate(outUpdate_fifoForUart),
        .din(din_fifoForUart),
        .dout(dout_fifoForUart),
        .outValid(outValid_fifoForUart),
        .CLK(CLK_fifoForUart),
        .RST(RST_fifoForUart)
    );
    AsciiEncoder_fifo AsciiEncoder_fifo_inst (
        .din(din_AsciiEncoder_fifo),
        .inValid(inValid_AsciiEncoder_fifo),
        .outValid(outValid_AsciiEncoder_fifo),
        .outUpdate(outUpdate_AsciiEncoder_fifo),
        .dout(dout_AsciiEncoder_fifo),
        .CLK(CLK_AsciiEncoder_fifo),
        .RST(RST_AsciiEncoder_fifo)
    );
    AsciiEncoder_source AsciiEncoder_source_inst (
        .opcode(opcode_AsciiEncoder_source),
        .addrData(addrData_AsciiEncoder_source),
        .data(data_AsciiEncoder_source),
        .inValid(inValid_AsciiEncoder_source),
        .outValid(outValid_AsciiEncoder_source),
        .dout(dout_AsciiEncoder_source),
        .CLK(CLK_AsciiEncoder_source),
        .RST(RST_AsciiEncoder_source)
    );
    WidthIntermediate WidthIntermediate_inst (
        .addrIn(addrIn_WidthIntermediate),
        .addrOut(addrOut_WidthIntermediate),
        .CLK(CLK_WidthIntermediate),
        .RST(RST_WidthIntermediate)
    );
    StrbSrc StrbSrc_inst (
        .valid(valid_StrbSrc),
        .dout(dout_StrbSrc),
        .CLK(CLK_StrbSrc),
        .RST(RST_StrbSrc)
    );
    AxiControl AxiControl_inst (
        .araddr_ufp(araddr_ufp_AxiControl),
        .arready_ufp(arready_ufp_AxiControl),
        .arvalid_ufp(arvalid_ufp_AxiControl),
        .awaddr_ufp(awaddr_ufp_AxiControl),
        .awready_ufp(awready_ufp_AxiControl),
        .awvalid_ufp(awvalid_ufp_AxiControl),
        .bready_ufp(bready_ufp_AxiControl),
        .bresp_ufp(bresp_ufp_AxiControl),
        .bvalid_ufp(bvalid_ufp_AxiControl),
        .wdata_ufp(wdata_ufp_AxiControl),
        .wstrb_ufp(wstrb_ufp_AxiControl),
        .wvalid_ufp(wvalid_ufp_AxiControl),
        .wready_ufp(wready_ufp_AxiControl),
        .rready_ufp(rready_ufp_AxiControl),
        .rvalid_ufp(rvalid_ufp_AxiControl),
        .rdata_ufp(rdata_ufp_AxiControl),
        .rresp_ufp(rresp_ufp_AxiControl),
        .araddr_dfp(araddr_dfp_AxiControl),
        .arready_dfp(arready_dfp_AxiControl),
        .arvalid_dfp(arvalid_dfp_AxiControl),
        .awaddr_dfp(awaddr_dfp_AxiControl),
        .awready_dfp(awready_dfp_AxiControl),
        .awvalid_dfp(awvalid_dfp_AxiControl),
        .bready_dfp(bready_dfp_AxiControl),
        .bresp_dfp(bresp_dfp_AxiControl),
        .bvalid_dfp(bvalid_dfp_AxiControl),
        .wdata_dfp(wdata_dfp_AxiControl),
        .wstrb_dfp(wstrb_dfp_AxiControl),
        .wvalid_dfp(wvalid_dfp_AxiControl),
        .wready_dfp(wready_dfp_AxiControl),
        .rready_dfp(rready_dfp_AxiControl),
        .rvalid_dfp(rvalid_dfp_AxiControl),
        .rdata_dfp(rdata_dfp_AxiControl),
        .rresp_dfp(rresp_dfp_AxiControl),
        .CLK(CLK_AxiControl),
        .RST(RST_AxiControl)
    );
    InputParser InputParser_inst (
        .din(din_InputParser),
        .inValid(inValid_InputParser),
        .inUpdate(inUpdate_InputParser),
        .wAddrValid(wAddrValid_InputParser),
        .rAddrValid(rAddrValid_InputParser),
        .wAddrUpdate(wAddrUpdate_InputParser),
        .rAddrUpdate(rAddrUpdate_InputParser),
        .addrData(addrData_InputParser),
        .wDataValid(wDataValid_InputParser),
        .wDataUpdate(wDataUpdate_InputParser),
        .wData(wData_InputParser),
        .rData(rData_InputParser),
        .rDataUpdate(rDataUpdate_InputParser),
        .rDataValid(rDataValid_InputParser),
        .transEnd(transEnd_InputParser),
        .transData(transData_InputParser),
        .opcode(opcode_InputParser),
        .CLK(CLK_InputParser),
        .RST(RST_InputParser)
    );
    AsciiEncoder_encodeToByteStream AsciiEncoder_encodeToByteStream_inst (
        .din(din_AsciiEncoder_encodeToByteStream),
        .dout(dout_AsciiEncoder_encodeToByteStream),
        .inUpdate(inUpdate_AsciiEncoder_encodeToByteStream),
        .inValid(inValid_AsciiEncoder_encodeToByteStream),
        .outValid(outValid_AsciiEncoder_encodeToByteStream),
        .outUpdate(outUpdate_AsciiEncoder_encodeToByteStream),
        .CLK(CLK_AsciiEncoder_encodeToByteStream),
        .RST(RST_AsciiEncoder_encodeToByteStream)
    );
    always_comb begin
        wAddrValid_CoreWrite = wAddrValid_InputParser;
        rAddrValid_CoreWrite = rAddrValid_InputParser;
        wDataValid_CoreWrite = wDataValid_InputParser;
        wDataIn_CoreWrite = wData_InputParser;
        rDataUpdate_CoreWrite = rDataUpdate_InputParser;
        addrIn_WidthIntermediate = addrData_InputParser;
        wAddrIn_CoreWrite = addrOut_WidthIntermediate;
        rAddrIn_CoreWrite = addrOut_WidthIntermediate;
        araddr_ufp_AxiControl = araddr_CoreWrite;
        arvalid_ufp_AxiControl = arvalid_CoreWrite;
        awaddr_ufp_AxiControl = awaddr_CoreWrite;
        awvalid_ufp_AxiControl = awvalid_CoreWrite;
        bready_ufp_AxiControl = bready_CoreWrite;
        wdata_ufp_AxiControl = wdata_CoreWrite;
        wstrb_ufp_AxiControl = wstrb_CoreWrite;
        wvalid_ufp_AxiControl = wvalid_CoreWrite;
        rready_ufp_AxiControl = rready_CoreWrite;
        wAddrUpdate_InputParser = wAddrUpdate_CoreWrite;
        rAddrUpdate_InputParser = rAddrUpdate_CoreWrite;
        wDataUpdate_InputParser = wDataUpdate_CoreWrite;
        rData_InputParser = rDataOut_CoreWrite;
        rDataValid_InputParser = rDataValid_CoreWrite;
        arready_CoreWrite = arready_ufp_AxiControl;
        awready_CoreWrite = awready_ufp_AxiControl;
        bresp_CoreWrite = bresp_ufp_AxiControl;
        bvalid_CoreWrite = bvalid_ufp_AxiControl;
        wready_CoreWrite = wready_ufp_AxiControl;
        rvalid_CoreWrite = rvalid_ufp_AxiControl;
        rdata_CoreWrite = rdata_ufp_AxiControl;
        rresp_CoreWrite = rresp_ufp_AxiControl;
        outUpdate_fifoForUart = inUpdate_InputParser;
        strbIn_CoreWrite = dout_StrbSrc;
        strbValid_CoreWrite = valid_StrbSrc;
        din_AsciiEncoder_encodeToByteStream = dout_AsciiEncoder_fifo;
        inValid_AsciiEncoder_encodeToByteStream = outValid_AsciiEncoder_fifo;
        din_UartSend_etherBypass = dout_AsciiEncoder_encodeToByteStream;
        inValid_UartSend_etherBypass = outValid_AsciiEncoder_encodeToByteStream;
        outUpdate_AsciiEncoder_fifo = inUpdate_AsciiEncoder_encodeToByteStream;
        outUpdate_AsciiEncoder_encodeToByteStream = inUpdate_UartSend_etherBypass;
        din_AsciiEncoder_fifo = dout_AsciiEncoder_source;
        inValid_AsciiEncoder_fifo = outValid_AsciiEncoder_source;
        opcode_AsciiEncoder_source = opcode_InputParser;
        addrData_AsciiEncoder_source = addrData_InputParser;
        data_AsciiEncoder_source = transData_InputParser;
        inValid_AsciiEncoder_source = transEnd_InputParser;
        inValid_fifoForUart = outValid_UartRecv_etherBypass;
        din_fifoForUart = dout_UartRecv_etherBypass;
        din_InputParser = dout_fifoForUart;
        inValid_InputParser = outValid_fifoForUart;
    end
    always_comb begin
        CLK_UartRecv_etherBypass = CLK;
        RST_UartRecv_etherBypass = RST;
    end
    always_comb begin
        CLK_CoreWrite = CLK;
        RST_CoreWrite = RST;
    end
    always_comb begin
        CLK_UartSend_etherBypass = CLK;
        RST_UartSend_etherBypass = RST;
    end
    always_comb begin
        CLK_fifoForUart = CLK;
        RST_fifoForUart = RST;
    end
    always_comb begin
        CLK_AsciiEncoder_fifo = CLK;
        RST_AsciiEncoder_fifo = RST;
    end
    always_comb begin
        CLK_AsciiEncoder_source = CLK;
        RST_AsciiEncoder_source = RST;
    end
    always_comb begin
        CLK_WidthIntermediate = CLK;
        RST_WidthIntermediate = RST;
    end
    always_comb begin
        CLK_StrbSrc = CLK;
        RST_StrbSrc = RST;
    end
    always_comb begin
        CLK_AxiControl = CLK;
        RST_AxiControl = RST;
    end
    always_comb begin
        CLK_InputParser = CLK;
        RST_InputParser = RST;
    end
    always_comb begin
        CLK_AsciiEncoder_encodeToByteStream = CLK;
        RST_AsciiEncoder_encodeToByteStream = RST;
    end
endmodule
module UartRecv_etherBypass (
    input rx,
    output reg [7:0] dout,
    output logic outValid,
    input CLK,
    input RST
);
    localparam sidle = 0;
    localparam sstart = 1;
    localparam sdata = 2;
    localparam sstop = 3;

    reg [1:0] recvstate;
    logic nextbyte;
    logic [2:0] bitcount;
    logic [31:0] cyclecount;

    always_ff @( posedge CLK ) begin
        if (RST) begin
            recvstate <= 0;
        end else begin
            case (recvstate)
                sidle: begin
                    if ((rx == 0)) begin
                        recvstate <= sstart;
                    end
                end
                sstart: begin
                    if (((recvstate == sstart) && ((cyclecount == 433) && (rx == 1)))) begin
                        recvstate <= sidle;
                    end else if ((cyclecount == 32'd867)) begin
                        recvstate <= sdata;
                    end
                end
                sdata: begin
                    if (((cyclecount == 32'd867) & (bitcount == 3'd7))) begin
                        recvstate <= sstop;
                    end
                end
                sstop: begin
                    if (((cyclecount == 433) & (~nextbyte))) begin
                        recvstate <= sidle;
                    end else if (((cyclecount == 433) & nextbyte)) begin
                        recvstate <= sstart;
                    end
                end
            endcase
        end
    end
    always_comb begin
        nextbyte = (rx == 0);
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            bitcount <= 0;
            cyclecount <= 0;
        end else begin
            if (((recvstate == sstart) && ((cyclecount == 433) && (rx == 1)))) begin
                cyclecount <= 0;
            end else if (((recvstate == sstop) && (cyclecount == 433))) begin
                cyclecount <= 0;
            end else if ((cyclecount == 867)) begin
                cyclecount <= 0;
            end else begin
                if ((~(recvstate == sidle))) begin
                    cyclecount <= (cyclecount + 1);
                end
            end
            if (((cyclecount == 32'd867) & (recvstate == sdata))) begin
                bitcount <= (bitcount + 1);
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            dout <= 0;
        end else begin
            if (((cyclecount == 433) & (recvstate == sdata))) begin
                dout[bitcount] <= rx;
            end else if (((cyclecount == 433) & (recvstate == sstart))) begin
                dout <= 0;
            end
        end
    end
    always_comb begin
        outValid = ((recvstate == sstop) & (cyclecount == 433));
    end
endmodule
module CoreWrite (
    input wAddrValid,
    output logic wAddrUpdate,
    input [12:0] wAddrIn,
    input rAddrValid,
    output logic rAddrUpdate,
    input [12:0] rAddrIn,
    input wDataValid,
    output logic wDataUpdate,
    input [31:0] wDataIn,
    output logic [31:0] rDataOut,
    output logic rDataValid,
    input rDataUpdate,
    input strbValid,
    output logic strbUpdate,
    input [3:0] strbIn,
    output logic [12:0] araddr,
    input arready,
    output logic arvalid,
    output logic [12:0] awaddr,
    input awready,
    output logic awvalid,
    output logic bready,
    input [1:0] bresp,
    input bvalid,
    output logic [31:0] wdata,
    output logic [3:0] wstrb,
    output logic wvalid,
    input wready,
    output logic rready,
    input rvalid,
    input [31:0] rdata,
    input [1:0] rresp,
    input CLK,
    input RST
);
    always_comb begin
        awaddr = wAddrIn;
        wdata = wDataIn;
        wstrb = strbIn;
        wvalid = (strbValid & wDataValid);
        wDataUpdate = (wready & strbValid);
        strbUpdate = (wready & wDataValid);
        awvalid = wAddrValid;
        wAddrUpdate = awready;
        bready = 1;
        araddr = rAddrIn;
        arvalid = rAddrValid;
        rAddrUpdate = arready;
        rready = rDataUpdate;
        rDataValid = rvalid;
        rDataOut = rdata;
    end
endmodule
module UartSend_etherBypass (
    input [7:0] din,
    output logic tx,
    input inValid,
    output logic inUpdate,
    input CLK,
    input RST
);
    localparam sidle = 0;
    localparam sstart = 1;
    localparam sdata = 2;
    localparam sstop = 3;

    reg [1:0] sendstate;
    logic [7:0] dbuf;
    logic acceptNext;
    logic [2:0] bitcount;
    logic [31:0] cyclecount;

    always_ff @( posedge CLK ) begin
        if (RST) begin
            sendstate <= 0;
        end else begin
            case (sendstate)
                sidle: begin
                    if (inValid) begin
                        sendstate <= sstart;
                    end
                end
                sstart: begin
                    if ((cyclecount == 32'd867)) begin
                        sendstate <= sdata;
                    end
                end
                sdata: begin
                    if (((cyclecount == 32'd867) & (bitcount == 3'd7))) begin
                        sendstate <= sstop;
                    end
                end
                sstop: begin
                    if (((cyclecount == 32'd867) & (~acceptNext))) begin
                        sendstate <= sidle;
                    end else if (((cyclecount == 32'd867) & acceptNext)) begin
                        sendstate <= sstart;
                    end
                end
            endcase
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            bitcount <= 0;
            cyclecount <= 0;
        end else begin
            if ((cyclecount == 867)) begin
                cyclecount <= 0;
            end else begin
                if ((~(sendstate == sidle))) begin
                    cyclecount <= (cyclecount + 1);
                end
            end
            if (((cyclecount == 32'd867) & (sendstate == sdata))) begin
                bitcount <= (bitcount + 1);
            end
        end
    end
    always_comb begin
        acceptNext = 0;
        if (inValid) begin
            if ((sendstate == sidle)) begin
                acceptNext = 1;
            end else if (((sendstate == sstop) && (cyclecount == 867))) begin
                acceptNext = 1;
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            dbuf <= 0;
        end else begin
            if (acceptNext) begin
                dbuf <= din;
            end
        end
    end
    always_comb begin
        tx = 1;
        if ((sendstate == sstart)) begin
            tx = 0;
        end else if ((sendstate == sdata)) begin
            tx = dbuf[bitcount];
        end
    end
    always_comb begin
        inUpdate = (((sendstate == sstop) && (cyclecount == 867)) || (sendstate == sidle));
    end
endmodule
module fifoForUart (
    input inValid,
    input outUpdate,
    input [7:0] din,
    output logic [7:0] dout,
    output logic outValid,
    input CLK,
    input RST
);
    reg [7:0] _ram_fifoPatch_361 [511:0];
    logic [8:0] _wptr_fifoPatch_361;
    logic [7:0] _dout_fifoPatch_361;
    logic [8:0] _rptr_fifoPatch_361;
    logic _empty_fifoPatch_361;
    logic _full_fifoPatch_361;
    logic [7:0] _doutRam_fifoPatch_361;
    logic [8:0] _prevwptr_fifoPatch_361;
    logic _wincr_fifoPatch_361;
    logic _outvalid_fifoPatch_361;
    logic _rincr_fifoPatch_361;
    logic [8:0] _rptrComb_fifoPatch_361;
    logic [7:0] _doutBypassed_fifoPatch_361;
    logic _inready_fifoPatch_361;

    always_comb begin
        _empty_fifoPatch_361 = (_wptr_fifoPatch_361 == _rptr_fifoPatch_361);
        _full_fifoPatch_361 = ((_wptr_fifoPatch_361 + 9'd1) == _rptr_fifoPatch_361);
    end
    always_comb begin
        _rptrComb_fifoPatch_361 = _rptr_fifoPatch_361;
        if ((_wincr_fifoPatch_361 && (~_full_fifoPatch_361))) begin
            
        end
        if ((_rincr_fifoPatch_361 && (~_empty_fifoPatch_361))) begin
            _rptrComb_fifoPatch_361 = (_rptr_fifoPatch_361 + 9'd1);
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            _prevwptr_fifoPatch_361 <= 0;
            _rptr_fifoPatch_361 <= 0;
            _wptr_fifoPatch_361 <= 0;
        end else begin
            _prevwptr_fifoPatch_361 <= _wptr_fifoPatch_361;
            if ((_wincr_fifoPatch_361 && (~_full_fifoPatch_361))) begin
                _wptr_fifoPatch_361 <= (_wptr_fifoPatch_361 + 9'd1);
            end
            if ((_rincr_fifoPatch_361 && (~_empty_fifoPatch_361))) begin
                _rptr_fifoPatch_361 <= (_rptr_fifoPatch_361 + 9'd1);
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            _doutRam_fifoPatch_361 <= 0;
        end else begin
            _doutRam_fifoPatch_361 <= _ram_fifoPatch_361[_rptrComb_fifoPatch_361];
        end
    end
    always_comb begin
        if ((_prevwptr_fifoPatch_361 == _rptr_fifoPatch_361)) begin
            _dout_fifoPatch_361 = _doutBypassed_fifoPatch_361;
        end else begin
            _dout_fifoPatch_361 = _doutRam_fifoPatch_361;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            _doutBypassed_fifoPatch_361 <= 0;
        end else begin
            _doutBypassed_fifoPatch_361 <= din;
            if ((_prevwptr_fifoPatch_361 == _rptr_fifoPatch_361)) begin
                
            end else begin
                
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if ((_wincr_fifoPatch_361 && (~_full_fifoPatch_361))) begin
            _ram_fifoPatch_361[_wptr_fifoPatch_361] <= din;
        end
    end
    always_comb begin
        _outvalid_fifoPatch_361 = (~_empty_fifoPatch_361);
        _rincr_fifoPatch_361 = outUpdate;
        _inready_fifoPatch_361 = (~_full_fifoPatch_361);
        _wincr_fifoPatch_361 = inValid;
    end
    always_comb begin
        outValid = _outvalid_fifoPatch_361;
        dout = _dout_fifoPatch_361;
    end
endmodule
module AsciiEncoder_fifo (
    input [119:0] din,
    input inValid,
    output logic outValid,
    input outUpdate,
    output logic [119:0] dout,
    input CLK,
    input RST
);
    reg [119:0] _ram_fifoPatch_363 [255:0];
    logic [119:0] _doutRam_fifoPatch_363;
    logic [7:0] _prevwptr_fifoPatch_363;
    logic [7:0] _wptr_fifoPatch_363;
    logic _rincr_fifoPatch_363;
    logic [119:0] _dout_fifoPatch_363;
    logic _outvalid_fifoPatch_363;
    logic _wincr_fifoPatch_363;
    logic [7:0] _rptr_fifoPatch_363;
    logic _full_fifoPatch_363;
    logic _empty_fifoPatch_363;
    logic [119:0] _doutBypassed_fifoPatch_363;
    logic [7:0] _rptrComb_fifoPatch_363;
    logic _inready_fifoPatch_363;

    always_comb begin
        _empty_fifoPatch_363 = (_wptr_fifoPatch_363 == _rptr_fifoPatch_363);
        _full_fifoPatch_363 = ((_wptr_fifoPatch_363 + 8'd1) == _rptr_fifoPatch_363);
    end
    always_comb begin
        _rptrComb_fifoPatch_363 = _rptr_fifoPatch_363;
        if ((_wincr_fifoPatch_363 && (~_full_fifoPatch_363))) begin
            
        end
        if ((_rincr_fifoPatch_363 && (~_empty_fifoPatch_363))) begin
            _rptrComb_fifoPatch_363 = (_rptr_fifoPatch_363 + 8'd1);
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            _prevwptr_fifoPatch_363 <= 0;
            _rptr_fifoPatch_363 <= 0;
            _wptr_fifoPatch_363 <= 0;
        end else begin
            _prevwptr_fifoPatch_363 <= _wptr_fifoPatch_363;
            if ((_wincr_fifoPatch_363 && (~_full_fifoPatch_363))) begin
                _wptr_fifoPatch_363 <= (_wptr_fifoPatch_363 + 8'd1);
            end
            if ((_rincr_fifoPatch_363 && (~_empty_fifoPatch_363))) begin
                _rptr_fifoPatch_363 <= (_rptr_fifoPatch_363 + 8'd1);
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            _doutRam_fifoPatch_363 <= 0;
        end else begin
            _doutRam_fifoPatch_363 <= _ram_fifoPatch_363[_rptrComb_fifoPatch_363];
        end
    end
    always_comb begin
        if ((_prevwptr_fifoPatch_363 == _rptr_fifoPatch_363)) begin
            _dout_fifoPatch_363 = _doutBypassed_fifoPatch_363;
        end else begin
            _dout_fifoPatch_363 = _doutRam_fifoPatch_363;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            _doutBypassed_fifoPatch_363 <= 0;
        end else begin
            _doutBypassed_fifoPatch_363 <= din;
            if ((_prevwptr_fifoPatch_363 == _rptr_fifoPatch_363)) begin
                
            end else begin
                
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if ((_wincr_fifoPatch_363 && (~_full_fifoPatch_363))) begin
            _ram_fifoPatch_363[_wptr_fifoPatch_363] <= din;
        end
    end
    always_comb begin
        _outvalid_fifoPatch_363 = (~_empty_fifoPatch_363);
        _rincr_fifoPatch_363 = outUpdate;
        _inready_fifoPatch_363 = (~_full_fifoPatch_363);
        _wincr_fifoPatch_363 = inValid;
    end
    always_comb begin
        outValid = _outvalid_fifoPatch_363;
    end
    always_comb begin
        dout = _dout_fifoPatch_363;
    end
endmodule
module AsciiEncoder_source (
    input [7:0] opcode,
    input [15:0] addrData,
    input [31:0] data,
    input inValid,
    output logic outValid,
    output logic [119:0] dout,
    input CLK,
    input RST
);
    logic [119:0] _result_wireConcat_362;
    logic resetCount;
    logic [63:0] counter;

    always_ff @( posedge CLK ) begin
        if (RST) begin
            counter <= 0;
        end else begin
            if (resetCount) begin
                counter <= 0;
            end else if (inValid) begin
                counter <= (counter + 64'd1);
            end
        end
    end
    always_comb begin
        resetCount = 1'd0;
        outValid = inValid;
    end
    always_comb begin
        _result_wireConcat_362[63:0] = counter;
        _result_wireConcat_362[71:64] = opcode;
        _result_wireConcat_362[87:72] = addrData;
        _result_wireConcat_362[119:88] = data;
    end
    always_comb begin
        dout = _result_wireConcat_362;
    end
endmodule
module WidthIntermediate (
    input [15:0] addrIn,
    output logic [12:0] addrOut,
    input CLK,
    input RST
);
    always_comb begin
        addrOut = addrIn[12:0];
    end
endmodule
module StrbSrc (
    output logic valid,
    output logic [3:0] dout,
    input CLK,
    input RST
);
    always_comb begin
        valid = 1;
        dout = (~0);
    end
endmodule
module AxiControl (
    input [12:0] araddr_ufp,
    output logic arready_ufp,
    input arvalid_ufp,
    input [12:0] awaddr_ufp,
    output logic awready_ufp,
    input awvalid_ufp,
    input bready_ufp,
    output logic [1:0] bresp_ufp,
    output logic bvalid_ufp,
    input [31:0] wdata_ufp,
    input [3:0] wstrb_ufp,
    input wvalid_ufp,
    output logic wready_ufp,
    input rready_ufp,
    output logic rvalid_ufp,
    output logic [31:0] rdata_ufp,
    output logic [1:0] rresp_ufp,
    output logic [12:0] araddr_dfp,
    input arready_dfp,
    output logic arvalid_dfp,
    output logic [12:0] awaddr_dfp,
    input awready_dfp,
    output logic awvalid_dfp,
    output logic bready_dfp,
    input [1:0] bresp_dfp,
    input bvalid_dfp,
    output logic [31:0] wdata_dfp,
    output logic [3:0] wstrb_dfp,
    output logic wvalid_dfp,
    input wready_dfp,
    output logic rready_dfp,
    input rvalid_dfp,
    input [31:0] rdata_dfp,
    input [1:0] rresp_dfp,
    input CLK,
    input RST
);
    logic wvalidCtrl;
    logic [31:0] wCounter;
    logic wreadyCtrl;
    logic [31:0] awCounter;
    logic awreadyCtrl;
    logic awvalidCtrl;

    always_comb begin
        araddr_dfp = araddr_ufp;
        arready_ufp = arready_dfp;
        arvalid_dfp = arvalid_ufp;
        awaddr_dfp = awaddr_ufp;
        bready_dfp = bready_ufp;
        bresp_ufp = bresp_dfp;
        bvalid_ufp = bvalid_dfp;
        wdata_dfp = wdata_ufp;
        wstrb_dfp = wstrb_ufp;
        rready_dfp = rready_ufp;
        rvalid_ufp = rvalid_dfp;
        rdata_ufp = rdata_dfp;
        rresp_ufp = rresp_dfp;
    end
    always_comb begin
        awvalidCtrl = (awCounter == 0);
        awreadyCtrl = (awCounter == 0);
        wvalidCtrl = (wCounter == 0);
        wreadyCtrl = (wCounter == 0);
        awvalid_dfp = (awvalid_ufp & awvalidCtrl);
        awready_ufp = (awready_dfp & awreadyCtrl);
        wvalid_dfp = (wvalid_ufp & wvalidCtrl);
        wready_ufp = (wready_dfp & wreadyCtrl);
        if ((awvalid_ufp & awready_ufp)) begin
            
        end else if ((~(awCounter == 0))) begin
            
        end
        if ((wvalid_ufp & wready_ufp)) begin
            
        end else if ((~(wCounter == 0))) begin
            
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            awCounter <= 0;
            wCounter <= 0;
        end else begin
            if ((awvalid_ufp & awready_ufp)) begin
                awCounter <= 32'd50;
            end else if ((~(awCounter == 0))) begin
                awCounter <= (awCounter + (~0));
            end
            if ((wvalid_ufp & wready_ufp)) begin
                wCounter <= 32'd50;
            end else if ((~(wCounter == 0))) begin
                wCounter <= (wCounter + (~0));
            end
        end
    end
endmodule
module InputParser (
    input [7:0] din,
    input inValid,
    output logic inUpdate,
    output logic wAddrValid,
    output logic rAddrValid,
    input wAddrUpdate,
    input rAddrUpdate,
    output logic [15:0] addrData,
    output logic wDataValid,
    input wDataUpdate,
    output logic [31:0] wData,
    input [31:0] rData,
    output logic rDataUpdate,
    input rDataValid,
    output logic transEnd,
    output logic [31:0] transData,
    output logic [7:0] opcode,
    input CLK,
    input RST
);
    logic [55:0] buffer;
    logic addrAccepted;
    logic dataAccepted;
    logic [31:0] bufferIndexHead;
    logic [31:0] rDataBuffer;
    logic [31:0] zero32;
    logic bothAccepted;
    logic [31:0] minusOne32;
    logic [31:0] counter;

    always_comb begin
        bothAccepted = (addrAccepted & dataAccepted);
        transEnd = bothAccepted;
        inUpdate = (counter < 7);
        wAddrValid = 0;
        wDataValid = 0;
        rAddrValid = 0;
        rDataUpdate = 0;
        zero32 = 32'd0;
        minusOne32 = (~zero32);
        bufferIndexHead = (((counter + 1) << 3) + minusOne32);
        opcode = buffer[7:0];
        addrData = buffer[23:8];
        wData = buffer[55:24];
        transData = 0;
        if ((inUpdate & inValid)) begin
            
        end else if (transEnd) begin
            
        end
        if ((counter == 7)) begin
            if ((opcode == 1)) begin
                wAddrValid = (~addrAccepted);
                wDataValid = (~dataAccepted);
                if (bothAccepted) begin
                    
                end else begin
                    if (wAddrUpdate) begin
                        
                    end
                    if (wDataUpdate) begin
                        
                    end
                end
            end else if ((opcode == 2)) begin
                rAddrValid = (~addrAccepted);
                rDataUpdate = (~dataAccepted);
                if (bothAccepted) begin
                    
                end else begin
                    if (rAddrUpdate) begin
                        
                    end
                    if (rDataValid) begin
                        
                    end
                end
            end
        end
        if ((inUpdate & inValid)) begin
            
        end
        if ((opcode == 1)) begin
            transData = wData;
        end else if ((opcode == 2)) begin
            transData = rDataBuffer;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            addrAccepted <= 0;
            buffer <= 0;
            counter <= 0;
            dataAccepted <= 0;
            rDataBuffer <= 0;
        end else begin
            if ((inUpdate & inValid)) begin
                counter <= (counter + 32'd1);
            end else if (transEnd) begin
                counter <= 0;
            end
            if ((counter == 7)) begin
                if ((opcode == 1)) begin
                    if (bothAccepted) begin
                        addrAccepted <= 0;
                        dataAccepted <= 0;
                    end else begin
                        if (wAddrUpdate) begin
                            addrAccepted <= 1'd1;
                        end
                        if (wDataUpdate) begin
                            dataAccepted <= 1'd1;
                        end
                    end
                end else if ((opcode == 2)) begin
                    if (bothAccepted) begin
                        addrAccepted <= 0;
                        dataAccepted <= 0;
                    end else begin
                        if (rAddrUpdate) begin
                            addrAccepted <= 1;
                        end
                        if (rDataValid) begin
                            dataAccepted <= 1;
                            rDataBuffer <= rData;
                        end
                    end
                end
            end
            if ((inUpdate & inValid)) begin
                buffer[bufferIndexHead -: 8] <= din;
            end
            if ((opcode == 1)) begin
                
            end else if ((opcode == 2)) begin
                
            end
        end
    end
endmodule
module AsciiEncoder_encodeToByteStream (
    input [119:0] din,
    output logic [7:0] dout,
    output logic inUpdate,
    input inValid,
    output logic outValid,
    input outUpdate,
    input CLK,
    input RST
);
    logic [127:0] _result_binaryToHex_367;
    logic [15:0] _result_binaryToHex_384;
    logic [31:0] _result_binaryToHex_387;
    logic [63:0] _result_binaryToHex_392;
    logic [263:0] _joinwith_asciiSpace_366;
    logic [279:0] totalWord;
    logic [7:0] _ans_nibbleToHex_379;
    logic [7:0] _extended_nibbleToHex_390;
    logic [7:0] _extended_nibbleToHex_395;
    logic [7:0] _ans_nibbleToHex_381;
    logic [7:0] _extended_nibbleToHex_398;
    logic [7:0] _ans_nibbleToHex_378;
    logic [7:0] _extended_binaryToHex_384;
    logic [7:0] _ans_nibbleToHex_374;
    logic [7:0] _ans_nibbleToHex_380;
    logic [7:0] _ans_nibbleToHex_376;
    logic [7:0] _ans_nibbleToHex_375;
    logic [7:0] _extended_nibbleToHex_391;
    logic [7:0] _ans_nibbleToHex_398;
    logic [7:0] _extended_nibbleToHex_370;
    logic [7:0] _ans_nibbleToHex_377;
    logic [7:0] _ans_nibbleToHex_399;
    logic [7:0] _extended_nibbleToHex_368;
    logic requestToUpperContinue;
    logic [7:0] _ans_nibbleToHex_368;
    logic [7:0] _extended_nibbleToHex_378;
    logic initProcess;
    logic [63:0] _extended_binaryToHex_367;
    logic [7:0] _extended_nibbleToHex_380;
    logic [7:0] _ans_nibbleToHex_369;
    logic lastByte;
    logic [7:0] _ans_nibbleToHex_394;
    logic [7:0] _extended_nibbleToHex_374;
    logic [31:0] _wire4_wireUnpack_365;
    logic [7:0] _extended_nibbleToHex_382;
    logic [7:0] _ans_nibbleToHex_391;
    logic [31:0] _extended_binaryToHex_392;
    logic [31:0] byteCounter;
    logic [7:0] _extended_nibbleToHex_376;
    logic [119:0] _buffer_interceptBuffer_364;
    logic [7:0] _extended_nibbleToHex_381;
    logic [7:0] _extended_nibbleToHex_371;
    logic [7:0] _ans_nibbleToHex_397;
    logic [7:0] _extended_nibbleToHex_394;
    logic [7:0] _ans_nibbleToHex_386;
    logic [7:0] _extended_nibbleToHex_369;
    logic [15:0] _extended_binaryToHex_387;
    logic [7:0] _wire2_wireUnpack_365;
    logic [7:0] _extended_nibbleToHex_372;
    logic [7:0] _extended_nibbleToHex_388;
    logic [7:0] _extended_nibbleToHex_396;
    logic [7:0] _extended_nibbleToHex_383;
    logic [63:0] _wire1_wireUnpack_365;
    logic working;
    logic [7:0] _extended_nibbleToHex_393;
    logic [7:0] _extended_nibbleToHex_397;
    logic [7:0] _ans_nibbleToHex_395;
    logic [7:0] _ans_nibbleToHex_370;
    logic [7:0] _ans_nibbleToHex_383;
    logic [7:0] _ans_nibbleToHex_400;
    logic [7:0] _ans_nibbleToHex_389;
    logic [15:0] _wire3_wireUnpack_365;
    logic [119:0] _interceptBuffer_364;
    logic [7:0] _extended_nibbleToHex_373;
    logic [7:0] _extended_nibbleToHex_389;
    logic [7:0] _ans_nibbleToHex_373;
    logic [7:0] _extended_nibbleToHex_386;
    logic [7:0] _ans_nibbleToHex_393;
    logic [7:0] _extended_nibbleToHex_400;
    logic [7:0] _ans_nibbleToHex_396;
    logic [7:0] _extended_nibbleToHex_399;
    logic [7:0] _ans_nibbleToHex_390;
    logic [7:0] _extended_nibbleToHex_377;
    logic [7:0] _extended_nibbleToHex_375;
    logic [7:0] _extended_nibbleToHex_379;
    logic [7:0] _ans_nibbleToHex_388;
    logic [7:0] _ans_nibbleToHex_372;
    logic [7:0] _ans_nibbleToHex_382;
    logic [7:0] _extended_nibbleToHex_385;
    logic [7:0] _ans_nibbleToHex_385;
    logic [7:0] _ans_nibbleToHex_371;

    always_comb begin
        if ((inUpdate & inValid)) begin
            _interceptBuffer_364 = din;
        end else begin
            _interceptBuffer_364 = _buffer_interceptBuffer_364;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            _buffer_interceptBuffer_364 <= 0;
        end else begin
            if ((inUpdate & inValid)) begin
                _buffer_interceptBuffer_364 <= din;
            end else begin
                
            end
        end
    end
    always_comb begin
        _wire1_wireUnpack_365 = _interceptBuffer_364[63:0];
        _wire2_wireUnpack_365 = _interceptBuffer_364[71:64];
        _wire3_wireUnpack_365 = _interceptBuffer_364[87:72];
        _wire4_wireUnpack_365 = _interceptBuffer_364[119:88];
    end
    always_comb begin
        _extended_binaryToHex_367 = 64'd0;
        _extended_binaryToHex_367[63:0] = _wire1_wireUnpack_365;
    end
    always_comb begin
        _extended_nibbleToHex_368 = 8'd0;
        _extended_nibbleToHex_368[3:0] = _extended_binaryToHex_367[3:0];
        if ((_extended_binaryToHex_367[3:0] < 10)) begin
            _ans_nibbleToHex_368 = (_extended_nibbleToHex_368 + 48);
        end else begin
            _ans_nibbleToHex_368 = (_extended_nibbleToHex_368 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_369 = 8'd0;
        _extended_nibbleToHex_369[3:0] = _extended_binaryToHex_367[7:4];
        if ((_extended_binaryToHex_367[7:4] < 10)) begin
            _ans_nibbleToHex_369 = (_extended_nibbleToHex_369 + 48);
        end else begin
            _ans_nibbleToHex_369 = (_extended_nibbleToHex_369 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_370 = 8'd0;
        _extended_nibbleToHex_370[3:0] = _extended_binaryToHex_367[11:8];
        if ((_extended_binaryToHex_367[11:8] < 10)) begin
            _ans_nibbleToHex_370 = (_extended_nibbleToHex_370 + 48);
        end else begin
            _ans_nibbleToHex_370 = (_extended_nibbleToHex_370 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_371 = 8'd0;
        _extended_nibbleToHex_371[3:0] = _extended_binaryToHex_367[15:12];
        if ((_extended_binaryToHex_367[15:12] < 10)) begin
            _ans_nibbleToHex_371 = (_extended_nibbleToHex_371 + 48);
        end else begin
            _ans_nibbleToHex_371 = (_extended_nibbleToHex_371 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_372 = 8'd0;
        _extended_nibbleToHex_372[3:0] = _extended_binaryToHex_367[19:16];
        if ((_extended_binaryToHex_367[19:16] < 10)) begin
            _ans_nibbleToHex_372 = (_extended_nibbleToHex_372 + 48);
        end else begin
            _ans_nibbleToHex_372 = (_extended_nibbleToHex_372 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_373 = 8'd0;
        _extended_nibbleToHex_373[3:0] = _extended_binaryToHex_367[23:20];
        if ((_extended_binaryToHex_367[23:20] < 10)) begin
            _ans_nibbleToHex_373 = (_extended_nibbleToHex_373 + 48);
        end else begin
            _ans_nibbleToHex_373 = (_extended_nibbleToHex_373 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_374 = 8'd0;
        _extended_nibbleToHex_374[3:0] = _extended_binaryToHex_367[27:24];
        if ((_extended_binaryToHex_367[27:24] < 10)) begin
            _ans_nibbleToHex_374 = (_extended_nibbleToHex_374 + 48);
        end else begin
            _ans_nibbleToHex_374 = (_extended_nibbleToHex_374 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_375 = 8'd0;
        _extended_nibbleToHex_375[3:0] = _extended_binaryToHex_367[31:28];
        if ((_extended_binaryToHex_367[31:28] < 10)) begin
            _ans_nibbleToHex_375 = (_extended_nibbleToHex_375 + 48);
        end else begin
            _ans_nibbleToHex_375 = (_extended_nibbleToHex_375 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_376 = 8'd0;
        _extended_nibbleToHex_376[3:0] = _extended_binaryToHex_367[35:32];
        if ((_extended_binaryToHex_367[35:32] < 10)) begin
            _ans_nibbleToHex_376 = (_extended_nibbleToHex_376 + 48);
        end else begin
            _ans_nibbleToHex_376 = (_extended_nibbleToHex_376 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_377 = 8'd0;
        _extended_nibbleToHex_377[3:0] = _extended_binaryToHex_367[39:36];
        if ((_extended_binaryToHex_367[39:36] < 10)) begin
            _ans_nibbleToHex_377 = (_extended_nibbleToHex_377 + 48);
        end else begin
            _ans_nibbleToHex_377 = (_extended_nibbleToHex_377 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_378 = 8'd0;
        _extended_nibbleToHex_378[3:0] = _extended_binaryToHex_367[43:40];
        if ((_extended_binaryToHex_367[43:40] < 10)) begin
            _ans_nibbleToHex_378 = (_extended_nibbleToHex_378 + 48);
        end else begin
            _ans_nibbleToHex_378 = (_extended_nibbleToHex_378 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_379 = 8'd0;
        _extended_nibbleToHex_379[3:0] = _extended_binaryToHex_367[47:44];
        if ((_extended_binaryToHex_367[47:44] < 10)) begin
            _ans_nibbleToHex_379 = (_extended_nibbleToHex_379 + 48);
        end else begin
            _ans_nibbleToHex_379 = (_extended_nibbleToHex_379 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_380 = 8'd0;
        _extended_nibbleToHex_380[3:0] = _extended_binaryToHex_367[51:48];
        if ((_extended_binaryToHex_367[51:48] < 10)) begin
            _ans_nibbleToHex_380 = (_extended_nibbleToHex_380 + 48);
        end else begin
            _ans_nibbleToHex_380 = (_extended_nibbleToHex_380 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_381 = 8'd0;
        _extended_nibbleToHex_381[3:0] = _extended_binaryToHex_367[55:52];
        if ((_extended_binaryToHex_367[55:52] < 10)) begin
            _ans_nibbleToHex_381 = (_extended_nibbleToHex_381 + 48);
        end else begin
            _ans_nibbleToHex_381 = (_extended_nibbleToHex_381 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_382 = 8'd0;
        _extended_nibbleToHex_382[3:0] = _extended_binaryToHex_367[59:56];
        if ((_extended_binaryToHex_367[59:56] < 10)) begin
            _ans_nibbleToHex_382 = (_extended_nibbleToHex_382 + 48);
        end else begin
            _ans_nibbleToHex_382 = (_extended_nibbleToHex_382 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_383 = 8'd0;
        _extended_nibbleToHex_383[3:0] = _extended_binaryToHex_367[63:60];
        if ((_extended_binaryToHex_367[63:60] < 10)) begin
            _ans_nibbleToHex_383 = (_extended_nibbleToHex_383 + 48);
        end else begin
            _ans_nibbleToHex_383 = (_extended_nibbleToHex_383 + 55);
        end
    end
    always_comb begin
        _result_binaryToHex_367[127:120] = _ans_nibbleToHex_368;
        _result_binaryToHex_367[119:112] = _ans_nibbleToHex_369;
        _result_binaryToHex_367[111:104] = _ans_nibbleToHex_370;
        _result_binaryToHex_367[103:96] = _ans_nibbleToHex_371;
        _result_binaryToHex_367[95:88] = _ans_nibbleToHex_372;
        _result_binaryToHex_367[87:80] = _ans_nibbleToHex_373;
        _result_binaryToHex_367[79:72] = _ans_nibbleToHex_374;
        _result_binaryToHex_367[71:64] = _ans_nibbleToHex_375;
        _result_binaryToHex_367[63:56] = _ans_nibbleToHex_376;
        _result_binaryToHex_367[55:48] = _ans_nibbleToHex_377;
        _result_binaryToHex_367[47:40] = _ans_nibbleToHex_378;
        _result_binaryToHex_367[39:32] = _ans_nibbleToHex_379;
        _result_binaryToHex_367[31:24] = _ans_nibbleToHex_380;
        _result_binaryToHex_367[23:16] = _ans_nibbleToHex_381;
        _result_binaryToHex_367[15:8] = _ans_nibbleToHex_382;
        _result_binaryToHex_367[7:0] = _ans_nibbleToHex_383;
    end
    always_comb begin
        _extended_binaryToHex_384 = 8'd0;
        _extended_binaryToHex_384[7:0] = _wire2_wireUnpack_365;
    end
    always_comb begin
        _extended_nibbleToHex_385 = 8'd0;
        _extended_nibbleToHex_385[3:0] = _extended_binaryToHex_384[3:0];
        if ((_extended_binaryToHex_384[3:0] < 10)) begin
            _ans_nibbleToHex_385 = (_extended_nibbleToHex_385 + 48);
        end else begin
            _ans_nibbleToHex_385 = (_extended_nibbleToHex_385 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_386 = 8'd0;
        _extended_nibbleToHex_386[3:0] = _extended_binaryToHex_384[7:4];
        if ((_extended_binaryToHex_384[7:4] < 10)) begin
            _ans_nibbleToHex_386 = (_extended_nibbleToHex_386 + 48);
        end else begin
            _ans_nibbleToHex_386 = (_extended_nibbleToHex_386 + 55);
        end
    end
    always_comb begin
        _result_binaryToHex_384[15:8] = _ans_nibbleToHex_385;
        _result_binaryToHex_384[7:0] = _ans_nibbleToHex_386;
    end
    always_comb begin
        _extended_binaryToHex_387 = 16'd0;
        _extended_binaryToHex_387[15:0] = _wire3_wireUnpack_365;
    end
    always_comb begin
        _extended_nibbleToHex_388 = 8'd0;
        _extended_nibbleToHex_388[3:0] = _extended_binaryToHex_387[3:0];
        if ((_extended_binaryToHex_387[3:0] < 10)) begin
            _ans_nibbleToHex_388 = (_extended_nibbleToHex_388 + 48);
        end else begin
            _ans_nibbleToHex_388 = (_extended_nibbleToHex_388 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_389 = 8'd0;
        _extended_nibbleToHex_389[3:0] = _extended_binaryToHex_387[7:4];
        if ((_extended_binaryToHex_387[7:4] < 10)) begin
            _ans_nibbleToHex_389 = (_extended_nibbleToHex_389 + 48);
        end else begin
            _ans_nibbleToHex_389 = (_extended_nibbleToHex_389 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_390 = 8'd0;
        _extended_nibbleToHex_390[3:0] = _extended_binaryToHex_387[11:8];
        if ((_extended_binaryToHex_387[11:8] < 10)) begin
            _ans_nibbleToHex_390 = (_extended_nibbleToHex_390 + 48);
        end else begin
            _ans_nibbleToHex_390 = (_extended_nibbleToHex_390 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_391 = 8'd0;
        _extended_nibbleToHex_391[3:0] = _extended_binaryToHex_387[15:12];
        if ((_extended_binaryToHex_387[15:12] < 10)) begin
            _ans_nibbleToHex_391 = (_extended_nibbleToHex_391 + 48);
        end else begin
            _ans_nibbleToHex_391 = (_extended_nibbleToHex_391 + 55);
        end
    end
    always_comb begin
        _result_binaryToHex_387[31:24] = _ans_nibbleToHex_388;
        _result_binaryToHex_387[23:16] = _ans_nibbleToHex_389;
        _result_binaryToHex_387[15:8] = _ans_nibbleToHex_390;
        _result_binaryToHex_387[7:0] = _ans_nibbleToHex_391;
    end
    always_comb begin
        _extended_binaryToHex_392 = 32'd0;
        _extended_binaryToHex_392[31:0] = _wire4_wireUnpack_365;
    end
    always_comb begin
        _extended_nibbleToHex_393 = 8'd0;
        _extended_nibbleToHex_393[3:0] = _extended_binaryToHex_392[3:0];
        if ((_extended_binaryToHex_392[3:0] < 10)) begin
            _ans_nibbleToHex_393 = (_extended_nibbleToHex_393 + 48);
        end else begin
            _ans_nibbleToHex_393 = (_extended_nibbleToHex_393 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_394 = 8'd0;
        _extended_nibbleToHex_394[3:0] = _extended_binaryToHex_392[7:4];
        if ((_extended_binaryToHex_392[7:4] < 10)) begin
            _ans_nibbleToHex_394 = (_extended_nibbleToHex_394 + 48);
        end else begin
            _ans_nibbleToHex_394 = (_extended_nibbleToHex_394 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_395 = 8'd0;
        _extended_nibbleToHex_395[3:0] = _extended_binaryToHex_392[11:8];
        if ((_extended_binaryToHex_392[11:8] < 10)) begin
            _ans_nibbleToHex_395 = (_extended_nibbleToHex_395 + 48);
        end else begin
            _ans_nibbleToHex_395 = (_extended_nibbleToHex_395 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_396 = 8'd0;
        _extended_nibbleToHex_396[3:0] = _extended_binaryToHex_392[15:12];
        if ((_extended_binaryToHex_392[15:12] < 10)) begin
            _ans_nibbleToHex_396 = (_extended_nibbleToHex_396 + 48);
        end else begin
            _ans_nibbleToHex_396 = (_extended_nibbleToHex_396 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_397 = 8'd0;
        _extended_nibbleToHex_397[3:0] = _extended_binaryToHex_392[19:16];
        if ((_extended_binaryToHex_392[19:16] < 10)) begin
            _ans_nibbleToHex_397 = (_extended_nibbleToHex_397 + 48);
        end else begin
            _ans_nibbleToHex_397 = (_extended_nibbleToHex_397 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_398 = 8'd0;
        _extended_nibbleToHex_398[3:0] = _extended_binaryToHex_392[23:20];
        if ((_extended_binaryToHex_392[23:20] < 10)) begin
            _ans_nibbleToHex_398 = (_extended_nibbleToHex_398 + 48);
        end else begin
            _ans_nibbleToHex_398 = (_extended_nibbleToHex_398 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_399 = 8'd0;
        _extended_nibbleToHex_399[3:0] = _extended_binaryToHex_392[27:24];
        if ((_extended_binaryToHex_392[27:24] < 10)) begin
            _ans_nibbleToHex_399 = (_extended_nibbleToHex_399 + 48);
        end else begin
            _ans_nibbleToHex_399 = (_extended_nibbleToHex_399 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_400 = 8'd0;
        _extended_nibbleToHex_400[3:0] = _extended_binaryToHex_392[31:28];
        if ((_extended_binaryToHex_392[31:28] < 10)) begin
            _ans_nibbleToHex_400 = (_extended_nibbleToHex_400 + 48);
        end else begin
            _ans_nibbleToHex_400 = (_extended_nibbleToHex_400 + 55);
        end
    end
    always_comb begin
        _result_binaryToHex_392[63:56] = _ans_nibbleToHex_393;
        _result_binaryToHex_392[55:48] = _ans_nibbleToHex_394;
        _result_binaryToHex_392[47:40] = _ans_nibbleToHex_395;
        _result_binaryToHex_392[39:32] = _ans_nibbleToHex_396;
        _result_binaryToHex_392[31:24] = _ans_nibbleToHex_397;
        _result_binaryToHex_392[23:16] = _ans_nibbleToHex_398;
        _result_binaryToHex_392[15:8] = _ans_nibbleToHex_399;
        _result_binaryToHex_392[7:0] = _ans_nibbleToHex_400;
    end
    always_comb begin
        _joinwith_asciiSpace_366[127:0] = _result_binaryToHex_367;
        _joinwith_asciiSpace_366[151:136] = _result_binaryToHex_384;
        _joinwith_asciiSpace_366[191:160] = _result_binaryToHex_387;
        _joinwith_asciiSpace_366[263:200] = _result_binaryToHex_392;
        _joinwith_asciiSpace_366[135:128] = 32;
        _joinwith_asciiSpace_366[159:152] = 32;
        _joinwith_asciiSpace_366[199:192] = 32;
    end
    always_comb begin
        lastByte = (byteCounter == 34);
        totalWord[263:0] = _joinwith_asciiSpace_366;
        totalWord[271:264] = 13;
        totalWord[279:272] = 10;
        dout = totalWord[((byteCounter << 3) + 7) -: 8];
        outValid = working;
        inUpdate = 0;
        if ((outValid & outUpdate)) begin
            if (lastByte) begin
                
            end else begin
                
            end
        end
        if ((inValid & inUpdate)) begin
            
        end else if ((lastByte && (outValid & outUpdate))) begin
            
        end
        if ((inUpdate & inValid)) begin
            
        end
        if ((lastByte && (outValid & outUpdate))) begin
            inUpdate = 1;
            if ((~inValid)) begin
                
            end
        end else if ((requestToUpperContinue || (~initProcess))) begin
            inUpdate = 1;
            if (inValid) begin
                
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            byteCounter <= 0;
            initProcess <= 0;
            requestToUpperContinue <= 0;
            working <= 0;
        end else begin
            if ((outValid & outUpdate)) begin
                if (lastByte) begin
                    byteCounter <= 32'd0;
                end else begin
                    byteCounter <= (byteCounter + 1);
                end
            end
            if ((inValid & inUpdate)) begin
                working <= 1'd1;
            end else if ((lastByte && (outValid & outUpdate))) begin
                working <= 0;
            end
            if ((inUpdate & inValid)) begin
                initProcess <= 1'd1;
            end
            if ((lastByte && (outValid & outUpdate))) begin
                if ((~inValid)) begin
                    requestToUpperContinue <= 1'd1;
                end
            end else if ((requestToUpperContinue || (~initProcess))) begin
                if (inValid) begin
                    requestToUpperContinue <= 0;
                end
            end
        end
    end
endmodule
