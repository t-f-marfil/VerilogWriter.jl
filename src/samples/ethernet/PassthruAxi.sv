module PassthruAxi (
    output bready_CoreWrite,
    output [12:0] awaddr_CoreWrite,
    output arvalid_CoreWrite,
    output [12:0] araddr_CoreWrite,
    output [3:0] wstrb_CoreWrite,
    output strbUpdate_CoreWrite,
    input [1:0] bresp_CoreWrite,
    input [31:0] rdata_CoreWrite,
    output awvalid_CoreWrite,
    input [1:0] rresp_CoreWrite,
    output rready_CoreWrite,
    input bvalid_CoreWrite,
    output [31:0] wdata_CoreWrite,
    input rvalid_CoreWrite,
    input awready_CoreWrite,
    input arready_CoreWrite,
    input wready_CoreWrite,
    output wvalid_CoreWrite,
    input rx_UartRecv_etherPassthru,
    output tx_UartSend_etherPassthru,
    input CLK,
    input RST
);
    logic [31:0] wDataIn_CoreWrite;
    logic CLK_InputParser;
    logic rDataValid_InputParser;
    logic outValid_UartRecv_etherPassthru;
    logic inValid_fifoForUart;
    logic CLK_AsciiEncoder_source;
    logic outValid_fifoForUart;
    logic wDataValid_InputParser;
    logic RST_UartRecv_etherPassthru;
    logic [15:0] addrData_AsciiEncoder_source;
    logic RST_UartSend_etherPassthru;
    logic outUpdate_fifoForUart;
    logic wAddrUpdate_InputParser;
    logic RST_InputParser;
    logic inValid_AsciiEncoder_encodeToByteStream;
    logic [3:0] strbIn_CoreWrite;
    logic rAddrValid_CoreWrite;
    logic [119:0] din_AsciiEncoder_encodeToByteStream;
    logic [7:0] din_fifoForUart;
    logic [7:0] opcode_AsciiEncoder_source;
    logic wAddrValid_CoreWrite;
    logic rAddrValid_InputParser;
    logic CLK_StrbSrc;
    logic [31:0] rData_InputParser;
    logic inValid_AsciiEncoder_source;
    logic wAddrUpdate_CoreWrite;
    logic [7:0] din_InputParser;
    logic CLK_AsciiEncoder_encodeToByteStream;
    logic [7:0] dout_fifoForUart;
    logic [119:0] dout_AsciiEncoder_fifo;
    logic [7:0] dout_AsciiEncoder_encodeToByteStream;
    logic RST_StrbSrc;
    logic RST_AsciiEncoder_source;
    logic outValid_AsciiEncoder_source;
    logic RST_CoreWrite;
    logic [119:0] dout_AsciiEncoder_source;
    logic RST_fifoForUart;
    logic CLK_AsciiEncoder_fifo;
    logic inValid_UartSend_etherPassthru;
    logic [3:0] dout_StrbSrc;
    logic [12:0] wAddrIn_CoreWrite;
    logic rDataValid_CoreWrite;
    logic [15:0] addrIn_WidthIntermediate;
    logic [31:0] wData_InputParser;
    logic [7:0] opcode_InputParser;
    logic outUpdate_AsciiEncoder_encodeToByteStream;
    logic outUpdate_AsciiEncoder_fifo;
    logic [119:0] din_AsciiEncoder_fifo;
    logic [31:0] rDataOut_CoreWrite;
    logic rDataUpdate_CoreWrite;
    logic inUpdate_AsciiEncoder_encodeToByteStream;
    logic rAddrUpdate_CoreWrite;
    logic RST_AsciiEncoder_fifo;
    logic [31:0] data_AsciiEncoder_source;
    logic outValid_AsciiEncoder_fifo;
    logic CLK_UartRecv_etherPassthru;
    logic CLK_UartSend_etherPassthru;
    logic transEnd_InputParser;
    logic outValid_AsciiEncoder_encodeToByteStream;
    logic [7:0] dout_UartRecv_etherPassthru;
    logic inValid_InputParser;
    logic CLK_fifoForUart;
    logic rAddrUpdate_InputParser;
    logic CLK_WidthIntermediate;
    logic [12:0] rAddrIn_CoreWrite;
    logic inUpdate_UartSend_etherPassthru;
    logic inValid_AsciiEncoder_fifo;
    logic wDataUpdate_InputParser;
    logic valid_StrbSrc;
    logic rDataUpdate_InputParser;
    logic RST_WidthIntermediate;
    logic strbValid_CoreWrite;
    logic CLK_CoreWrite;
    logic [12:0] addrOut_WidthIntermediate;
    logic wDataUpdate_CoreWrite;
    logic wDataValid_CoreWrite;
    logic RST_AsciiEncoder_encodeToByteStream;
    logic [31:0] transData_InputParser;
    logic [7:0] din_UartSend_etherPassthru;
    logic wAddrValid_InputParser;
    logic [15:0] addrData_InputParser;
    logic inUpdate_InputParser;

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
    fifoForUart fifoForUart_inst (
        .inValid(inValid_fifoForUart),
        .outUpdate(outUpdate_fifoForUart),
        .din(din_fifoForUart),
        .dout(dout_fifoForUart),
        .outValid(outValid_fifoForUart),
        .CLK(CLK_fifoForUart),
        .RST(RST_fifoForUart)
    );
    UartRecv_etherPassthru UartRecv_etherPassthru_inst (
        .rx(rx_UartRecv_etherPassthru),
        .dout(dout_UartRecv_etherPassthru),
        .outValid(outValid_UartRecv_etherPassthru),
        .CLK(CLK_UartRecv_etherPassthru),
        .RST(RST_UartRecv_etherPassthru)
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
    UartSend_etherPassthru UartSend_etherPassthru_inst (
        .din(din_UartSend_etherPassthru),
        .tx(tx_UartSend_etherPassthru),
        .inValid(inValid_UartSend_etherPassthru),
        .inUpdate(inUpdate_UartSend_etherPassthru),
        .CLK(CLK_UartSend_etherPassthru),
        .RST(RST_UartSend_etherPassthru)
    );
    StrbSrc StrbSrc_inst (
        .valid(valid_StrbSrc),
        .dout(dout_StrbSrc),
        .CLK(CLK_StrbSrc),
        .RST(RST_StrbSrc)
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
    always_comb begin
        strbIn_CoreWrite = dout_StrbSrc;
        strbValid_CoreWrite = valid_StrbSrc;
        wAddrValid_CoreWrite = wAddrValid_InputParser;
        rAddrValid_CoreWrite = rAddrValid_InputParser;
        wDataValid_CoreWrite = wDataValid_InputParser;
        wDataIn_CoreWrite = wData_InputParser;
        rDataUpdate_CoreWrite = rDataUpdate_InputParser;
        din_AsciiEncoder_fifo = dout_AsciiEncoder_source;
        inValid_AsciiEncoder_fifo = outValid_AsciiEncoder_source;
        outUpdate_AsciiEncoder_fifo = inUpdate_AsciiEncoder_encodeToByteStream;
        din_UartSend_etherPassthru = dout_AsciiEncoder_encodeToByteStream;
        inValid_UartSend_etherPassthru = outValid_AsciiEncoder_encodeToByteStream;
        outUpdate_fifoForUart = inUpdate_InputParser;
        wAddrIn_CoreWrite = addrOut_WidthIntermediate;
        rAddrIn_CoreWrite = addrOut_WidthIntermediate;
        opcode_AsciiEncoder_source = opcode_InputParser;
        addrData_AsciiEncoder_source = addrData_InputParser;
        data_AsciiEncoder_source = transData_InputParser;
        inValid_AsciiEncoder_source = transEnd_InputParser;
        outUpdate_AsciiEncoder_encodeToByteStream = inUpdate_UartSend_etherPassthru;
        din_AsciiEncoder_encodeToByteStream = dout_AsciiEncoder_fifo;
        inValid_AsciiEncoder_encodeToByteStream = outValid_AsciiEncoder_fifo;
        din_InputParser = dout_fifoForUart;
        inValid_InputParser = outValid_fifoForUart;
        inValid_fifoForUart = outValid_UartRecv_etherPassthru;
        din_fifoForUart = dout_UartRecv_etherPassthru;
        wAddrUpdate_InputParser = wAddrUpdate_CoreWrite;
        rAddrUpdate_InputParser = rAddrUpdate_CoreWrite;
        wDataUpdate_InputParser = wDataUpdate_CoreWrite;
        rData_InputParser = rDataOut_CoreWrite;
        rDataValid_InputParser = rDataValid_CoreWrite;
        addrIn_WidthIntermediate = addrData_InputParser;
    end
    always_comb begin
        CLK_CoreWrite = CLK;
        RST_CoreWrite = RST;
    end
    always_comb begin
        CLK_fifoForUart = CLK;
        RST_fifoForUart = RST;
    end
    always_comb begin
        CLK_UartRecv_etherPassthru = CLK;
        RST_UartRecv_etherPassthru = RST;
    end
    always_comb begin
        CLK_AsciiEncoder_fifo = CLK;
        RST_AsciiEncoder_fifo = RST;
    end
    always_comb begin
        CLK_UartSend_etherPassthru = CLK;
        RST_UartSend_etherPassthru = RST;
    end
    always_comb begin
        CLK_StrbSrc = CLK;
        RST_StrbSrc = RST;
    end
    always_comb begin
        CLK_AsciiEncoder_encodeToByteStream = CLK;
        RST_AsciiEncoder_encodeToByteStream = RST;
    end
    always_comb begin
        CLK_InputParser = CLK;
        RST_InputParser = RST;
    end
    always_comb begin
        CLK_AsciiEncoder_source = CLK;
        RST_AsciiEncoder_source = RST;
    end
    always_comb begin
        CLK_WidthIntermediate = CLK;
        RST_WidthIntermediate = RST;
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
module fifoForUart (
    input inValid,
    input outUpdate,
    input [7:0] din,
    output logic [7:0] dout,
    output logic outValid,
    input CLK,
    input RST
);
    reg [7:0] _ram_fifoPatch_1 [1023:0];
    logic [9:0] _wptr_fifoPatch_1;
    logic _empty_fifoPatch_1;
    logic [7:0] _dout_fifoPatch_1;
    logic [9:0] _rptr_fifoPatch_1;
    logic _full_fifoPatch_1;
    logic [7:0] _doutBypassed_fifoPatch_1;
    logic [9:0] _prevwptr_fifoPatch_1;
    logic [7:0] _doutRam_fifoPatch_1;
    logic _inready_fifoPatch_1;
    logic _rincr_fifoPatch_1;
    logic [9:0] _rptrComb_fifoPatch_1;
    logic _outvalid_fifoPatch_1;
    logic _wincr_fifoPatch_1;

    always_comb begin
        _empty_fifoPatch_1 = (_wptr_fifoPatch_1 == _rptr_fifoPatch_1);
        _full_fifoPatch_1 = ((_wptr_fifoPatch_1 + 10'd1) == _rptr_fifoPatch_1);
    end
    always_comb begin
        _rptrComb_fifoPatch_1 = _rptr_fifoPatch_1;
        if ((_wincr_fifoPatch_1 && (~_full_fifoPatch_1))) begin
            
        end
        if ((_rincr_fifoPatch_1 && (~_empty_fifoPatch_1))) begin
            _rptrComb_fifoPatch_1 = (_rptr_fifoPatch_1 + 10'd1);
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            _prevwptr_fifoPatch_1 <= 0;
            _rptr_fifoPatch_1 <= 0;
            _wptr_fifoPatch_1 <= 0;
        end else begin
            _prevwptr_fifoPatch_1 <= _wptr_fifoPatch_1;
            if ((_wincr_fifoPatch_1 && (~_full_fifoPatch_1))) begin
                _wptr_fifoPatch_1 <= (_wptr_fifoPatch_1 + 10'd1);
            end
            if ((_rincr_fifoPatch_1 && (~_empty_fifoPatch_1))) begin
                _rptr_fifoPatch_1 <= (_rptr_fifoPatch_1 + 10'd1);
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            _doutRam_fifoPatch_1 <= 0;
        end else begin
            _doutRam_fifoPatch_1 <= _ram_fifoPatch_1[_rptrComb_fifoPatch_1];
        end
    end
    always_comb begin
        if ((_prevwptr_fifoPatch_1 == _rptr_fifoPatch_1)) begin
            _dout_fifoPatch_1 = _doutBypassed_fifoPatch_1;
        end else begin
            _dout_fifoPatch_1 = _doutRam_fifoPatch_1;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            _doutBypassed_fifoPatch_1 <= 0;
        end else begin
            _doutBypassed_fifoPatch_1 <= din;
            if ((_prevwptr_fifoPatch_1 == _rptr_fifoPatch_1)) begin
                
            end else begin
                
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if ((_wincr_fifoPatch_1 && (~_full_fifoPatch_1))) begin
            _ram_fifoPatch_1[_wptr_fifoPatch_1] <= din;
        end
    end
    always_comb begin
        _outvalid_fifoPatch_1 = (~_empty_fifoPatch_1);
        _rincr_fifoPatch_1 = outUpdate;
        _inready_fifoPatch_1 = (~_full_fifoPatch_1);
        _wincr_fifoPatch_1 = inValid;
    end
    always_comb begin
        outValid = _outvalid_fifoPatch_1;
        dout = _dout_fifoPatch_1;
    end
endmodule
module UartRecv_etherPassthru (
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
module AsciiEncoder_fifo (
    input [119:0] din,
    input inValid,
    output logic outValid,
    input outUpdate,
    output logic [119:0] dout,
    input CLK,
    input RST
);
    reg [119:0] _ram_fifoPatch_3 [255:0];
    logic [7:0] _wptr_fifoPatch_3;
    logic [7:0] _rptr_fifoPatch_3;
    logic _wincr_fifoPatch_3;
    logic [119:0] _doutRam_fifoPatch_3;
    logic _empty_fifoPatch_3;
    logic _full_fifoPatch_3;
    logic [7:0] _rptrComb_fifoPatch_3;
    logic _rincr_fifoPatch_3;
    logic [119:0] _doutBypassed_fifoPatch_3;
    logic _inready_fifoPatch_3;
    logic [7:0] _prevwptr_fifoPatch_3;
    logic _outvalid_fifoPatch_3;
    logic [119:0] _dout_fifoPatch_3;

    always_comb begin
        _empty_fifoPatch_3 = (_wptr_fifoPatch_3 == _rptr_fifoPatch_3);
        _full_fifoPatch_3 = ((_wptr_fifoPatch_3 + 8'd1) == _rptr_fifoPatch_3);
    end
    always_comb begin
        _rptrComb_fifoPatch_3 = _rptr_fifoPatch_3;
        if ((_wincr_fifoPatch_3 && (~_full_fifoPatch_3))) begin
            
        end
        if ((_rincr_fifoPatch_3 && (~_empty_fifoPatch_3))) begin
            _rptrComb_fifoPatch_3 = (_rptr_fifoPatch_3 + 8'd1);
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            _prevwptr_fifoPatch_3 <= 0;
            _rptr_fifoPatch_3 <= 0;
            _wptr_fifoPatch_3 <= 0;
        end else begin
            _prevwptr_fifoPatch_3 <= _wptr_fifoPatch_3;
            if ((_wincr_fifoPatch_3 && (~_full_fifoPatch_3))) begin
                _wptr_fifoPatch_3 <= (_wptr_fifoPatch_3 + 8'd1);
            end
            if ((_rincr_fifoPatch_3 && (~_empty_fifoPatch_3))) begin
                _rptr_fifoPatch_3 <= (_rptr_fifoPatch_3 + 8'd1);
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            _doutRam_fifoPatch_3 <= 0;
        end else begin
            _doutRam_fifoPatch_3 <= _ram_fifoPatch_3[_rptrComb_fifoPatch_3];
        end
    end
    always_comb begin
        if ((_prevwptr_fifoPatch_3 == _rptr_fifoPatch_3)) begin
            _dout_fifoPatch_3 = _doutBypassed_fifoPatch_3;
        end else begin
            _dout_fifoPatch_3 = _doutRam_fifoPatch_3;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            _doutBypassed_fifoPatch_3 <= 0;
        end else begin
            _doutBypassed_fifoPatch_3 <= din;
            if ((_prevwptr_fifoPatch_3 == _rptr_fifoPatch_3)) begin
                
            end else begin
                
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if ((_wincr_fifoPatch_3 && (~_full_fifoPatch_3))) begin
            _ram_fifoPatch_3[_wptr_fifoPatch_3] <= din;
        end
    end
    always_comb begin
        _outvalid_fifoPatch_3 = (~_empty_fifoPatch_3);
        _rincr_fifoPatch_3 = outUpdate;
        _inready_fifoPatch_3 = (~_full_fifoPatch_3);
        _wincr_fifoPatch_3 = inValid;
    end
    always_comb begin
        outValid = _outvalid_fifoPatch_3;
    end
    always_comb begin
        dout = _dout_fifoPatch_3;
    end
endmodule
module UartSend_etherPassthru (
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
    logic [127:0] _result_binaryToHex_7;
    logic [15:0] _result_binaryToHex_24;
    logic [31:0] _result_binaryToHex_27;
    logic [63:0] _result_binaryToHex_32;
    logic [263:0] _joinwith_asciiSpace_6;
    logic [279:0] totalWord;
    logic [7:0] _extended_nibbleToHex_12;
    logic [7:0] _ans_nibbleToHex_39;
    logic [7:0] _extended_nibbleToHex_38;
    logic [7:0] _ans_nibbleToHex_26;
    logic [7:0] _extended_nibbleToHex_10;
    logic [7:0] _ans_nibbleToHex_23;
    logic [7:0] _extended_nibbleToHex_36;
    logic requestToUpperContinue;
    logic [7:0] _extended_nibbleToHex_14;
    logic [7:0] _extended_nibbleToHex_35;
    logic [7:0] _extended_nibbleToHex_9;
    logic [7:0] _ans_nibbleToHex_36;
    logic initProcess;
    logic [15:0] _wire3_wireUnpack_5;
    logic lastByte;
    logic [7:0] _ans_nibbleToHex_15;
    logic [7:0] _ans_nibbleToHex_21;
    logic [15:0] _extended_binaryToHex_27;
    logic [7:0] _extended_nibbleToHex_34;
    logic [31:0] byteCounter;
    logic [7:0] _extended_nibbleToHex_15;
    logic [31:0] _extended_binaryToHex_32;
    logic [7:0] _ans_nibbleToHex_33;
    logic [7:0] _ans_nibbleToHex_37;
    logic [63:0] _wire1_wireUnpack_5;
    logic [7:0] _ans_nibbleToHex_30;
    logic [7:0] _extended_nibbleToHex_40;
    logic [7:0] _ans_nibbleToHex_14;
    logic [7:0] _ans_nibbleToHex_16;
    logic [7:0] _ans_nibbleToHex_25;
    logic [7:0] _extended_nibbleToHex_25;
    logic [7:0] _extended_nibbleToHex_28;
    logic [7:0] _extended_nibbleToHex_20;
    logic [7:0] _extended_nibbleToHex_26;
    logic [7:0] _extended_nibbleToHex_22;
    logic [7:0] _extended_nibbleToHex_23;
    logic working;
    logic [7:0] _ans_nibbleToHex_34;
    logic [7:0] _ans_nibbleToHex_12;
    logic [7:0] _extended_nibbleToHex_11;
    logic [7:0] _extended_nibbleToHex_19;
    logic [7:0] _ans_nibbleToHex_9;
    logic [7:0] _extended_nibbleToHex_30;
    logic [7:0] _extended_nibbleToHex_31;
    logic [7:0] _ans_nibbleToHex_17;
    logic [7:0] _wire2_wireUnpack_5;
    logic [119:0] _interceptBuffer_4;
    logic [7:0] _extended_nibbleToHex_33;
    logic [7:0] _ans_nibbleToHex_28;
    logic [7:0] _extended_nibbleToHex_13;
    logic [7:0] _ans_nibbleToHex_35;
    logic [7:0] _ans_nibbleToHex_18;
    logic [7:0] _extended_nibbleToHex_16;
    logic [7:0] _ans_nibbleToHex_38;
    logic [7:0] _extended_nibbleToHex_29;
    logic [7:0] _ans_nibbleToHex_10;
    logic [7:0] _ans_nibbleToHex_29;
    logic [7:0] _ans_nibbleToHex_31;
    logic [7:0] _ans_nibbleToHex_19;
    logic [7:0] _ans_nibbleToHex_20;
    logic [7:0] _extended_nibbleToHex_39;
    logic [31:0] _wire4_wireUnpack_5;
    logic [7:0] _ans_nibbleToHex_22;
    logic [7:0] _extended_nibbleToHex_8;
    logic [7:0] _ans_nibbleToHex_13;
    logic [7:0] _extended_binaryToHex_24;
    logic [7:0] _ans_nibbleToHex_40;
    logic [7:0] _extended_nibbleToHex_37;
    logic [7:0] _ans_nibbleToHex_8;
    logic [7:0] _ans_nibbleToHex_11;
    logic [7:0] _extended_nibbleToHex_17;
    logic [119:0] _buffer_interceptBuffer_4;
    logic [7:0] _extended_nibbleToHex_18;
    logic [7:0] _extended_nibbleToHex_21;
    logic [63:0] _extended_binaryToHex_7;

    always_comb begin
        if ((inUpdate & inValid)) begin
            _interceptBuffer_4 = din;
        end else begin
            _interceptBuffer_4 = _buffer_interceptBuffer_4;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            _buffer_interceptBuffer_4 <= 0;
        end else begin
            if ((inUpdate & inValid)) begin
                _buffer_interceptBuffer_4 <= din;
            end else begin
                
            end
        end
    end
    always_comb begin
        _wire1_wireUnpack_5 = _interceptBuffer_4[63:0];
        _wire2_wireUnpack_5 = _interceptBuffer_4[71:64];
        _wire3_wireUnpack_5 = _interceptBuffer_4[87:72];
        _wire4_wireUnpack_5 = _interceptBuffer_4[119:88];
    end
    always_comb begin
        _extended_binaryToHex_7 = 64'd0;
        _extended_binaryToHex_7[63:0] = _wire1_wireUnpack_5;
    end
    always_comb begin
        _extended_nibbleToHex_8 = 8'd0;
        _extended_nibbleToHex_8[3:0] = _extended_binaryToHex_7[3:0];
        if ((_extended_binaryToHex_7[3:0] < 10)) begin
            _ans_nibbleToHex_8 = (_extended_nibbleToHex_8 + 48);
        end else begin
            _ans_nibbleToHex_8 = (_extended_nibbleToHex_8 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_9 = 8'd0;
        _extended_nibbleToHex_9[3:0] = _extended_binaryToHex_7[7:4];
        if ((_extended_binaryToHex_7[7:4] < 10)) begin
            _ans_nibbleToHex_9 = (_extended_nibbleToHex_9 + 48);
        end else begin
            _ans_nibbleToHex_9 = (_extended_nibbleToHex_9 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_10 = 8'd0;
        _extended_nibbleToHex_10[3:0] = _extended_binaryToHex_7[11:8];
        if ((_extended_binaryToHex_7[11:8] < 10)) begin
            _ans_nibbleToHex_10 = (_extended_nibbleToHex_10 + 48);
        end else begin
            _ans_nibbleToHex_10 = (_extended_nibbleToHex_10 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_11 = 8'd0;
        _extended_nibbleToHex_11[3:0] = _extended_binaryToHex_7[15:12];
        if ((_extended_binaryToHex_7[15:12] < 10)) begin
            _ans_nibbleToHex_11 = (_extended_nibbleToHex_11 + 48);
        end else begin
            _ans_nibbleToHex_11 = (_extended_nibbleToHex_11 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_12 = 8'd0;
        _extended_nibbleToHex_12[3:0] = _extended_binaryToHex_7[19:16];
        if ((_extended_binaryToHex_7[19:16] < 10)) begin
            _ans_nibbleToHex_12 = (_extended_nibbleToHex_12 + 48);
        end else begin
            _ans_nibbleToHex_12 = (_extended_nibbleToHex_12 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_13 = 8'd0;
        _extended_nibbleToHex_13[3:0] = _extended_binaryToHex_7[23:20];
        if ((_extended_binaryToHex_7[23:20] < 10)) begin
            _ans_nibbleToHex_13 = (_extended_nibbleToHex_13 + 48);
        end else begin
            _ans_nibbleToHex_13 = (_extended_nibbleToHex_13 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_14 = 8'd0;
        _extended_nibbleToHex_14[3:0] = _extended_binaryToHex_7[27:24];
        if ((_extended_binaryToHex_7[27:24] < 10)) begin
            _ans_nibbleToHex_14 = (_extended_nibbleToHex_14 + 48);
        end else begin
            _ans_nibbleToHex_14 = (_extended_nibbleToHex_14 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_15 = 8'd0;
        _extended_nibbleToHex_15[3:0] = _extended_binaryToHex_7[31:28];
        if ((_extended_binaryToHex_7[31:28] < 10)) begin
            _ans_nibbleToHex_15 = (_extended_nibbleToHex_15 + 48);
        end else begin
            _ans_nibbleToHex_15 = (_extended_nibbleToHex_15 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_16 = 8'd0;
        _extended_nibbleToHex_16[3:0] = _extended_binaryToHex_7[35:32];
        if ((_extended_binaryToHex_7[35:32] < 10)) begin
            _ans_nibbleToHex_16 = (_extended_nibbleToHex_16 + 48);
        end else begin
            _ans_nibbleToHex_16 = (_extended_nibbleToHex_16 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_17 = 8'd0;
        _extended_nibbleToHex_17[3:0] = _extended_binaryToHex_7[39:36];
        if ((_extended_binaryToHex_7[39:36] < 10)) begin
            _ans_nibbleToHex_17 = (_extended_nibbleToHex_17 + 48);
        end else begin
            _ans_nibbleToHex_17 = (_extended_nibbleToHex_17 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_18 = 8'd0;
        _extended_nibbleToHex_18[3:0] = _extended_binaryToHex_7[43:40];
        if ((_extended_binaryToHex_7[43:40] < 10)) begin
            _ans_nibbleToHex_18 = (_extended_nibbleToHex_18 + 48);
        end else begin
            _ans_nibbleToHex_18 = (_extended_nibbleToHex_18 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_19 = 8'd0;
        _extended_nibbleToHex_19[3:0] = _extended_binaryToHex_7[47:44];
        if ((_extended_binaryToHex_7[47:44] < 10)) begin
            _ans_nibbleToHex_19 = (_extended_nibbleToHex_19 + 48);
        end else begin
            _ans_nibbleToHex_19 = (_extended_nibbleToHex_19 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_20 = 8'd0;
        _extended_nibbleToHex_20[3:0] = _extended_binaryToHex_7[51:48];
        if ((_extended_binaryToHex_7[51:48] < 10)) begin
            _ans_nibbleToHex_20 = (_extended_nibbleToHex_20 + 48);
        end else begin
            _ans_nibbleToHex_20 = (_extended_nibbleToHex_20 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_21 = 8'd0;
        _extended_nibbleToHex_21[3:0] = _extended_binaryToHex_7[55:52];
        if ((_extended_binaryToHex_7[55:52] < 10)) begin
            _ans_nibbleToHex_21 = (_extended_nibbleToHex_21 + 48);
        end else begin
            _ans_nibbleToHex_21 = (_extended_nibbleToHex_21 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_22 = 8'd0;
        _extended_nibbleToHex_22[3:0] = _extended_binaryToHex_7[59:56];
        if ((_extended_binaryToHex_7[59:56] < 10)) begin
            _ans_nibbleToHex_22 = (_extended_nibbleToHex_22 + 48);
        end else begin
            _ans_nibbleToHex_22 = (_extended_nibbleToHex_22 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_23 = 8'd0;
        _extended_nibbleToHex_23[3:0] = _extended_binaryToHex_7[63:60];
        if ((_extended_binaryToHex_7[63:60] < 10)) begin
            _ans_nibbleToHex_23 = (_extended_nibbleToHex_23 + 48);
        end else begin
            _ans_nibbleToHex_23 = (_extended_nibbleToHex_23 + 55);
        end
    end
    always_comb begin
        _result_binaryToHex_7[127:120] = _ans_nibbleToHex_8;
        _result_binaryToHex_7[119:112] = _ans_nibbleToHex_9;
        _result_binaryToHex_7[111:104] = _ans_nibbleToHex_10;
        _result_binaryToHex_7[103:96] = _ans_nibbleToHex_11;
        _result_binaryToHex_7[95:88] = _ans_nibbleToHex_12;
        _result_binaryToHex_7[87:80] = _ans_nibbleToHex_13;
        _result_binaryToHex_7[79:72] = _ans_nibbleToHex_14;
        _result_binaryToHex_7[71:64] = _ans_nibbleToHex_15;
        _result_binaryToHex_7[63:56] = _ans_nibbleToHex_16;
        _result_binaryToHex_7[55:48] = _ans_nibbleToHex_17;
        _result_binaryToHex_7[47:40] = _ans_nibbleToHex_18;
        _result_binaryToHex_7[39:32] = _ans_nibbleToHex_19;
        _result_binaryToHex_7[31:24] = _ans_nibbleToHex_20;
        _result_binaryToHex_7[23:16] = _ans_nibbleToHex_21;
        _result_binaryToHex_7[15:8] = _ans_nibbleToHex_22;
        _result_binaryToHex_7[7:0] = _ans_nibbleToHex_23;
    end
    always_comb begin
        _extended_binaryToHex_24 = 8'd0;
        _extended_binaryToHex_24[7:0] = _wire2_wireUnpack_5;
    end
    always_comb begin
        _extended_nibbleToHex_25 = 8'd0;
        _extended_nibbleToHex_25[3:0] = _extended_binaryToHex_24[3:0];
        if ((_extended_binaryToHex_24[3:0] < 10)) begin
            _ans_nibbleToHex_25 = (_extended_nibbleToHex_25 + 48);
        end else begin
            _ans_nibbleToHex_25 = (_extended_nibbleToHex_25 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_26 = 8'd0;
        _extended_nibbleToHex_26[3:0] = _extended_binaryToHex_24[7:4];
        if ((_extended_binaryToHex_24[7:4] < 10)) begin
            _ans_nibbleToHex_26 = (_extended_nibbleToHex_26 + 48);
        end else begin
            _ans_nibbleToHex_26 = (_extended_nibbleToHex_26 + 55);
        end
    end
    always_comb begin
        _result_binaryToHex_24[15:8] = _ans_nibbleToHex_25;
        _result_binaryToHex_24[7:0] = _ans_nibbleToHex_26;
    end
    always_comb begin
        _extended_binaryToHex_27 = 16'd0;
        _extended_binaryToHex_27[15:0] = _wire3_wireUnpack_5;
    end
    always_comb begin
        _extended_nibbleToHex_28 = 8'd0;
        _extended_nibbleToHex_28[3:0] = _extended_binaryToHex_27[3:0];
        if ((_extended_binaryToHex_27[3:0] < 10)) begin
            _ans_nibbleToHex_28 = (_extended_nibbleToHex_28 + 48);
        end else begin
            _ans_nibbleToHex_28 = (_extended_nibbleToHex_28 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_29 = 8'd0;
        _extended_nibbleToHex_29[3:0] = _extended_binaryToHex_27[7:4];
        if ((_extended_binaryToHex_27[7:4] < 10)) begin
            _ans_nibbleToHex_29 = (_extended_nibbleToHex_29 + 48);
        end else begin
            _ans_nibbleToHex_29 = (_extended_nibbleToHex_29 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_30 = 8'd0;
        _extended_nibbleToHex_30[3:0] = _extended_binaryToHex_27[11:8];
        if ((_extended_binaryToHex_27[11:8] < 10)) begin
            _ans_nibbleToHex_30 = (_extended_nibbleToHex_30 + 48);
        end else begin
            _ans_nibbleToHex_30 = (_extended_nibbleToHex_30 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_31 = 8'd0;
        _extended_nibbleToHex_31[3:0] = _extended_binaryToHex_27[15:12];
        if ((_extended_binaryToHex_27[15:12] < 10)) begin
            _ans_nibbleToHex_31 = (_extended_nibbleToHex_31 + 48);
        end else begin
            _ans_nibbleToHex_31 = (_extended_nibbleToHex_31 + 55);
        end
    end
    always_comb begin
        _result_binaryToHex_27[31:24] = _ans_nibbleToHex_28;
        _result_binaryToHex_27[23:16] = _ans_nibbleToHex_29;
        _result_binaryToHex_27[15:8] = _ans_nibbleToHex_30;
        _result_binaryToHex_27[7:0] = _ans_nibbleToHex_31;
    end
    always_comb begin
        _extended_binaryToHex_32 = 32'd0;
        _extended_binaryToHex_32[31:0] = _wire4_wireUnpack_5;
    end
    always_comb begin
        _extended_nibbleToHex_33 = 8'd0;
        _extended_nibbleToHex_33[3:0] = _extended_binaryToHex_32[3:0];
        if ((_extended_binaryToHex_32[3:0] < 10)) begin
            _ans_nibbleToHex_33 = (_extended_nibbleToHex_33 + 48);
        end else begin
            _ans_nibbleToHex_33 = (_extended_nibbleToHex_33 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_34 = 8'd0;
        _extended_nibbleToHex_34[3:0] = _extended_binaryToHex_32[7:4];
        if ((_extended_binaryToHex_32[7:4] < 10)) begin
            _ans_nibbleToHex_34 = (_extended_nibbleToHex_34 + 48);
        end else begin
            _ans_nibbleToHex_34 = (_extended_nibbleToHex_34 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_35 = 8'd0;
        _extended_nibbleToHex_35[3:0] = _extended_binaryToHex_32[11:8];
        if ((_extended_binaryToHex_32[11:8] < 10)) begin
            _ans_nibbleToHex_35 = (_extended_nibbleToHex_35 + 48);
        end else begin
            _ans_nibbleToHex_35 = (_extended_nibbleToHex_35 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_36 = 8'd0;
        _extended_nibbleToHex_36[3:0] = _extended_binaryToHex_32[15:12];
        if ((_extended_binaryToHex_32[15:12] < 10)) begin
            _ans_nibbleToHex_36 = (_extended_nibbleToHex_36 + 48);
        end else begin
            _ans_nibbleToHex_36 = (_extended_nibbleToHex_36 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_37 = 8'd0;
        _extended_nibbleToHex_37[3:0] = _extended_binaryToHex_32[19:16];
        if ((_extended_binaryToHex_32[19:16] < 10)) begin
            _ans_nibbleToHex_37 = (_extended_nibbleToHex_37 + 48);
        end else begin
            _ans_nibbleToHex_37 = (_extended_nibbleToHex_37 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_38 = 8'd0;
        _extended_nibbleToHex_38[3:0] = _extended_binaryToHex_32[23:20];
        if ((_extended_binaryToHex_32[23:20] < 10)) begin
            _ans_nibbleToHex_38 = (_extended_nibbleToHex_38 + 48);
        end else begin
            _ans_nibbleToHex_38 = (_extended_nibbleToHex_38 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_39 = 8'd0;
        _extended_nibbleToHex_39[3:0] = _extended_binaryToHex_32[27:24];
        if ((_extended_binaryToHex_32[27:24] < 10)) begin
            _ans_nibbleToHex_39 = (_extended_nibbleToHex_39 + 48);
        end else begin
            _ans_nibbleToHex_39 = (_extended_nibbleToHex_39 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_40 = 8'd0;
        _extended_nibbleToHex_40[3:0] = _extended_binaryToHex_32[31:28];
        if ((_extended_binaryToHex_32[31:28] < 10)) begin
            _ans_nibbleToHex_40 = (_extended_nibbleToHex_40 + 48);
        end else begin
            _ans_nibbleToHex_40 = (_extended_nibbleToHex_40 + 55);
        end
    end
    always_comb begin
        _result_binaryToHex_32[63:56] = _ans_nibbleToHex_33;
        _result_binaryToHex_32[55:48] = _ans_nibbleToHex_34;
        _result_binaryToHex_32[47:40] = _ans_nibbleToHex_35;
        _result_binaryToHex_32[39:32] = _ans_nibbleToHex_36;
        _result_binaryToHex_32[31:24] = _ans_nibbleToHex_37;
        _result_binaryToHex_32[23:16] = _ans_nibbleToHex_38;
        _result_binaryToHex_32[15:8] = _ans_nibbleToHex_39;
        _result_binaryToHex_32[7:0] = _ans_nibbleToHex_40;
    end
    always_comb begin
        _joinwith_asciiSpace_6[127:0] = _result_binaryToHex_7;
        _joinwith_asciiSpace_6[151:136] = _result_binaryToHex_24;
        _joinwith_asciiSpace_6[191:160] = _result_binaryToHex_27;
        _joinwith_asciiSpace_6[263:200] = _result_binaryToHex_32;
        _joinwith_asciiSpace_6[135:128] = 32;
        _joinwith_asciiSpace_6[159:152] = 32;
        _joinwith_asciiSpace_6[199:192] = 32;
    end
    always_comb begin
        lastByte = (byteCounter == 34);
        totalWord[263:0] = _joinwith_asciiSpace_6;
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
    logic [119:0] _result_wireConcat_2;
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
        _result_wireConcat_2[63:0] = counter;
        _result_wireConcat_2[71:64] = opcode;
        _result_wireConcat_2[87:72] = addrData;
        _result_wireConcat_2[119:88] = data;
    end
    always_comb begin
        dout = _result_wireConcat_2;
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
