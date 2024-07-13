module SampleAsciiEncoder (
    input rx_UARTRecv,
    input rvalid_dfp_AxiControl,
    output rready_dfp_AxiControl,
    output bready_dfp_AxiControl,
    output arvalid_dfp_AxiControl,
    input arready_dfp_AxiControl,
    output [12:0] araddr_dfp_AxiControl,
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
    output tx_UARTSend,
    output strbUpdate_CoreWrite,
    input CLK,
    input RST
);
    logic bothAccepted_InputParser;
    logic CLK_InputParser;
    logic awvalid_CoreWrite;
    logic [12:0] araddr_ufp_AxiControl;
    logic inValid_fifoForUart;
    logic RST_UARTRecv;
    logic outValid_fifoForUart;
    logic CLK_AsciiEncoder_source;
    logic CLK_UARTRecv;
    logic [15:0] addrData_AsciiEncoder_source;
    logic outUpdate_fifoForUart;
    logic RST_InputParser;
    logic inValid_AsciiEncoder_encodeToByteStream;
    logic [3:0] strbIn_CoreWrite;
    logic bvalid_ufp_AxiControl;
    logic wready_ufp_AxiControl;
    logic [111:0] din_AsciiEncoder_encodeToByteStream;
    logic [7:0] din_fifoForUart;
    logic rready_ufp_AxiControl;
    logic [31:0] dataData_AsciiEncoder_source;
    logic dataValid_CoreWrite;
    logic inValid_UARTSend;
    logic CLK_StrbSrc;
    logic arvalid_CoreWrite;
    logic [12:0] awaddr_CoreWrite;
    logic arready_ufp_AxiControl;
    logic inValid_AsciiEncoder_source;
    logic [1:0] rresp_ufp_AxiControl;
    logic [7:0] din_InputParser;
    logic dataUpdate_InputParser;
    logic CLK_AsciiEncoder_encodeToByteStream;
    logic [3:0] wstrb_CoreWrite;
    logic [7:0] dout_fifoForUart;
    logic [111:0] dout_AsciiEncoder_fifo;
    logic wready_CoreWrite;
    logic [3:0] wstrb_ufp_AxiControl;
    logic [7:0] dout_AsciiEncoder_encodeToByteStream;
    logic addrUpdate_InputParser;
    logic arready_CoreWrite;
    logic [12:0] addrIn_CoreWrite;
    logic RST_StrbSrc;
    logic RST_AsciiEncoder_source;
    logic outValid_AsciiEncoder_source;
    logic dataValid_InputParser;
    logic RST_CoreWrite;
    logic [111:0] dout_AsciiEncoder_source;
    logic RST_fifoForUart;
    logic [31:0] dataIn_CoreWrite;
    logic CLK_AsciiEncoder_fifo;
    logic [3:0] dout_StrbSrc;
    logic inUpdate_UARTSend;
    logic rvalid_CoreWrite;
    logic [31:0] rdata_CoreWrite;
    logic [31:0] dataData_InputParser;
    logic outValid_UARTRecv;
    logic [15:0] addrIn_WidthIntermediate;
    logic outUpdate_AsciiEncoder_encodeToByteStream;
    logic bready_CoreWrite;
    logic outUpdate_AsciiEncoder_fifo;
    logic dataUpdate_CoreWrite;
    logic [31:0] rdata_ufp_AxiControl;
    logic [111:0] din_AsciiEncoder_fifo;
    logic addrValid_InputParser;
    logic CLK_UARTSend;
    logic wvalid_ufp_AxiControl;
    logic [1:0] bresp_CoreWrite;
    logic [31:0] wdata_CoreWrite;
    logic [12:0] awaddr_ufp_AxiControl;
    logic inUpdate_AsciiEncoder_encodeToByteStream;
    logic RST_AsciiEncoder_fifo;
    logic [12:0] araddr_CoreWrite;
    logic [7:0] din_UARTSend;
    logic outValid_AsciiEncoder_fifo;
    logic CLK_AxiControl;
    logic outValid_AsciiEncoder_encodeToByteStream;
    logic awready_ufp_AxiControl;
    logic [31:0] wdata_ufp_AxiControl;
    logic inValid_InputParser;
    logic RST_UARTSend;
    logic CLK_fifoForUart;
    logic arvalid_ufp_AxiControl;
    logic CLK_WidthIntermediate;
    logic [7:0] dout_UARTRecv;
    logic addrUpdate_CoreWrite;
    logic wvalid_CoreWrite;
    logic inValid_AsciiEncoder_fifo;
    logic valid_StrbSrc;
    logic rvalid_ufp_AxiControl;
    logic rready_CoreWrite;
    logic bvalid_CoreWrite;
    logic RST_WidthIntermediate;
    logic [1:0] bresp_ufp_AxiControl;
    logic strbValid_CoreWrite;
    logic awvalid_ufp_AxiControl;
    logic [1:0] rresp_CoreWrite;
    logic CLK_CoreWrite;
    logic addrValid_CoreWrite;
    logic awready_CoreWrite;
    logic [12:0] addrOut_WidthIntermediate;
    logic RST_AsciiEncoder_encodeToByteStream;
    logic [15:0] addrData_InputParser;
    logic bready_ufp_AxiControl;
    logic inUpdate_InputParser;
    logic RST_AxiControl;

    AsciiEncoder_fifo AsciiEncoder_fifo_inst (
        .din(din_AsciiEncoder_fifo),
        .inValid(inValid_AsciiEncoder_fifo),
        .outValid(outValid_AsciiEncoder_fifo),
        .outUpdate(outUpdate_AsciiEncoder_fifo),
        .dout(dout_AsciiEncoder_fifo),
        .CLK(CLK_AsciiEncoder_fifo),
        .RST(RST_AsciiEncoder_fifo)
    );
    WidthIntermediate WidthIntermediate_inst (
        .addrIn(addrIn_WidthIntermediate),
        .addrOut(addrOut_WidthIntermediate),
        .CLK(CLK_WidthIntermediate),
        .RST(RST_WidthIntermediate)
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
    StrbSrc StrbSrc_inst (
        .valid(valid_StrbSrc),
        .dout(dout_StrbSrc),
        .CLK(CLK_StrbSrc),
        .RST(RST_StrbSrc)
    );
    UARTSend UARTSend_inst (
        .din(din_UARTSend),
        .tx(tx_UARTSend),
        .inValid(inValid_UARTSend),
        .inUpdate(inUpdate_UARTSend),
        .CLK(CLK_UARTSend),
        .RST(RST_UARTSend)
    );
    CoreWrite CoreWrite_inst (
        .addrValid(addrValid_CoreWrite),
        .addrUpdate(addrUpdate_CoreWrite),
        .addrIn(addrIn_CoreWrite),
        .dataValid(dataValid_CoreWrite),
        .dataUpdate(dataUpdate_CoreWrite),
        .dataIn(dataIn_CoreWrite),
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
    UARTRecv UARTRecv_inst (
        .rx(rx_UARTRecv),
        .dout(dout_UARTRecv),
        .outValid(outValid_UARTRecv),
        .CLK(CLK_UARTRecv),
        .RST(RST_UARTRecv)
    );
    AsciiEncoder_source AsciiEncoder_source_inst (
        .addrData(addrData_AsciiEncoder_source),
        .dataData(dataData_AsciiEncoder_source),
        .inValid(inValid_AsciiEncoder_source),
        .outValid(outValid_AsciiEncoder_source),
        .dout(dout_AsciiEncoder_source),
        .CLK(CLK_AsciiEncoder_source),
        .RST(RST_AsciiEncoder_source)
    );
    InputParser InputParser_inst (
        .din(din_InputParser),
        .inValid(inValid_InputParser),
        .inUpdate(inUpdate_InputParser),
        .addrValid(addrValid_InputParser),
        .addrUpdate(addrUpdate_InputParser),
        .addrData(addrData_InputParser),
        .dataValid(dataValid_InputParser),
        .dataUpdate(dataUpdate_InputParser),
        .dataData(dataData_InputParser),
        .bothAccepted(bothAccepted_InputParser),
        .CLK(CLK_InputParser),
        .RST(RST_InputParser)
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
    always_comb begin
        inValid_fifoForUart = outValid_UARTRecv;
        din_fifoForUart = dout_UARTRecv;
        addrIn_WidthIntermediate = addrData_InputParser;
        strbIn_CoreWrite = dout_StrbSrc;
        strbValid_CoreWrite = valid_StrbSrc;
        din_InputParser = dout_fifoForUart;
        inValid_InputParser = outValid_fifoForUart;
        outUpdate_fifoForUart = inUpdate_InputParser;
        araddr_ufp_AxiControl = araddr_CoreWrite;
        arvalid_ufp_AxiControl = arvalid_CoreWrite;
        awaddr_ufp_AxiControl = awaddr_CoreWrite;
        awvalid_ufp_AxiControl = awvalid_CoreWrite;
        bready_ufp_AxiControl = bready_CoreWrite;
        wdata_ufp_AxiControl = wdata_CoreWrite;
        wstrb_ufp_AxiControl = wstrb_CoreWrite;
        wvalid_ufp_AxiControl = wvalid_CoreWrite;
        rready_ufp_AxiControl = rready_CoreWrite;
        outUpdate_AsciiEncoder_encodeToByteStream = inUpdate_UARTSend;
        din_UARTSend = dout_AsciiEncoder_encodeToByteStream;
        inValid_UARTSend = outValid_AsciiEncoder_encodeToByteStream;
        addrUpdate_InputParser = addrUpdate_CoreWrite;
        dataUpdate_InputParser = dataUpdate_CoreWrite;
        din_AsciiEncoder_encodeToByteStream = dout_AsciiEncoder_fifo;
        inValid_AsciiEncoder_encodeToByteStream = outValid_AsciiEncoder_fifo;
        outUpdate_AsciiEncoder_fifo = inUpdate_AsciiEncoder_encodeToByteStream;
        din_AsciiEncoder_fifo = dout_AsciiEncoder_source;
        inValid_AsciiEncoder_fifo = outValid_AsciiEncoder_source;
        addrValid_CoreWrite = addrValid_InputParser;
        dataValid_CoreWrite = dataValid_InputParser;
        dataIn_CoreWrite = dataData_InputParser;
        addrData_AsciiEncoder_source = addrData_InputParser;
        dataData_AsciiEncoder_source = dataData_InputParser;
        inValid_AsciiEncoder_source = bothAccepted_InputParser;
        arready_CoreWrite = arready_ufp_AxiControl;
        awready_CoreWrite = awready_ufp_AxiControl;
        bresp_CoreWrite = bresp_ufp_AxiControl;
        bvalid_CoreWrite = bvalid_ufp_AxiControl;
        wready_CoreWrite = wready_ufp_AxiControl;
        rvalid_CoreWrite = rvalid_ufp_AxiControl;
        rdata_CoreWrite = rdata_ufp_AxiControl;
        rresp_CoreWrite = rresp_ufp_AxiControl;
        addrIn_CoreWrite = addrOut_WidthIntermediate;
    end
    always_comb begin
        CLK_AsciiEncoder_fifo = CLK;
        RST_AsciiEncoder_fifo = RST;
    end
    always_comb begin
        CLK_WidthIntermediate = CLK;
        RST_WidthIntermediate = RST;
    end
    always_comb begin
        CLK_AsciiEncoder_encodeToByteStream = CLK;
        RST_AsciiEncoder_encodeToByteStream = RST;
    end
    always_comb begin
        CLK_AxiControl = CLK;
        RST_AxiControl = RST;
    end
    always_comb begin
        CLK_StrbSrc = CLK;
        RST_StrbSrc = RST;
    end
    always_comb begin
        CLK_UARTSend = CLK;
        RST_UARTSend = RST;
    end
    always_comb begin
        CLK_CoreWrite = CLK;
        RST_CoreWrite = RST;
    end
    always_comb begin
        CLK_UARTRecv = CLK;
        RST_UARTRecv = RST;
    end
    always_comb begin
        CLK_AsciiEncoder_source = CLK;
        RST_AsciiEncoder_source = RST;
    end
    always_comb begin
        CLK_InputParser = CLK;
        RST_InputParser = RST;
    end
    always_comb begin
        CLK_fifoForUart = CLK;
        RST_fifoForUart = RST;
    end
endmodule
module AsciiEncoder_fifo (
    input [111:0] din,
    input inValid,
    output logic outValid,
    input outUpdate,
    output logic [111:0] dout,
    input CLK,
    input RST
);
    reg [111:0] _ram_fifoPatch_4 [255:0];
    logic [7:0] _rptr_fifoPatch_4;
    logic [7:0] _prevwptr_fifoPatch_4;
    logic _full_fifoPatch_4;
    logic [111:0] _doutBypassed_fifoPatch_4;
    logic _outvalid_fifoPatch_4;
    logic [111:0] _doutRam_fifoPatch_4;
    logic _rincr_fifoPatch_4;
    logic [7:0] _rptrComb_fifoPatch_4;
    logic _wincr_fifoPatch_4;
    logic _empty_fifoPatch_4;
    logic [111:0] _dout_fifoPatch_4;
    logic [7:0] _wptr_fifoPatch_4;
    logic _inready_fifoPatch_4;

    always_comb begin
        _empty_fifoPatch_4 = (_wptr_fifoPatch_4 == _rptr_fifoPatch_4);
        _full_fifoPatch_4 = ((_wptr_fifoPatch_4 + 8'd1) == _rptr_fifoPatch_4);
    end
    always_comb begin
        _rptrComb_fifoPatch_4 = _rptr_fifoPatch_4;
        if ((_wincr_fifoPatch_4 && (~_full_fifoPatch_4))) begin
            
        end
        if ((_rincr_fifoPatch_4 && (~_empty_fifoPatch_4))) begin
            _rptrComb_fifoPatch_4 = (_rptr_fifoPatch_4 + 8'd1);
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            _prevwptr_fifoPatch_4 <= 0;
            _rptr_fifoPatch_4 <= 0;
            _wptr_fifoPatch_4 <= 0;
        end else begin
            _prevwptr_fifoPatch_4 <= _wptr_fifoPatch_4;
            if ((_wincr_fifoPatch_4 && (~_full_fifoPatch_4))) begin
                _wptr_fifoPatch_4 <= (_wptr_fifoPatch_4 + 8'd1);
            end
            if ((_rincr_fifoPatch_4 && (~_empty_fifoPatch_4))) begin
                _rptr_fifoPatch_4 <= (_rptr_fifoPatch_4 + 8'd1);
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            _doutRam_fifoPatch_4 <= 0;
        end else begin
            _doutRam_fifoPatch_4 <= _ram_fifoPatch_4[_rptrComb_fifoPatch_4];
        end
    end
    always_comb begin
        if ((_prevwptr_fifoPatch_4 == _rptr_fifoPatch_4)) begin
            _dout_fifoPatch_4 = _doutBypassed_fifoPatch_4;
        end else begin
            _dout_fifoPatch_4 = _doutRam_fifoPatch_4;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            _doutBypassed_fifoPatch_4 <= 0;
        end else begin
            _doutBypassed_fifoPatch_4 <= din;
            if ((_prevwptr_fifoPatch_4 == _rptr_fifoPatch_4)) begin
                
            end else begin
                
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if ((_wincr_fifoPatch_4 && (~_full_fifoPatch_4))) begin
            _ram_fifoPatch_4[_wptr_fifoPatch_4] <= din;
        end
    end
    always_comb begin
        _outvalid_fifoPatch_4 = (~_empty_fifoPatch_4);
        _rincr_fifoPatch_4 = outUpdate;
        _inready_fifoPatch_4 = (~_full_fifoPatch_4);
        _wincr_fifoPatch_4 = inValid;
    end
    always_comb begin
        outValid = _outvalid_fifoPatch_4;
    end
    always_comb begin
        dout = _dout_fifoPatch_4;
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
module AsciiEncoder_encodeToByteStream (
    input [111:0] din,
    output logic [7:0] dout,
    output logic inUpdate,
    input inValid,
    output logic outValid,
    input outUpdate,
    input CLK,
    input RST
);
    logic [127:0] _result_binaryToHex_8;
    logic [31:0] _result_binaryToHex_25;
    logic [63:0] _result_binaryToHex_30;
    logic [239:0] _joinwith_asciiSpace_7;
    logic [255:0] totalWord;
    logic [31:0] _wire3_wireUnpack_6;
    logic [7:0] _extended_nibbleToHex_24;
    logic [7:0] _extended_nibbleToHex_12;
    logic [31:0] _extended_binaryToHex_30;
    logic [7:0] _ans_nibbleToHex_27;
    logic [7:0] _extended_nibbleToHex_38;
    logic [7:0] _ans_nibbleToHex_26;
    logic [7:0] _extended_nibbleToHex_10;
    logic [7:0] _extended_nibbleToHex_32;
    logic [7:0] _ans_nibbleToHex_23;
    logic [7:0] _extended_nibbleToHex_36;
    logic requestToUpperContinue;
    logic [7:0] _extended_nibbleToHex_14;
    logic [7:0] _extended_nibbleToHex_35;
    logic [111:0] _buffer_interceptBuffer_5;
    logic [7:0] _extended_nibbleToHex_9;
    logic [7:0] _extended_nibbleToHex_27;
    logic [7:0] _ans_nibbleToHex_36;
    logic initProcess;
    logic lastByte;
    logic [7:0] _ans_nibbleToHex_15;
    logic [7:0] _ans_nibbleToHex_21;
    logic [7:0] _extended_nibbleToHex_34;
    logic [31:0] byteCounter;
    logic [7:0] _extended_nibbleToHex_15;
    logic [7:0] _ans_nibbleToHex_33;
    logic [7:0] _ans_nibbleToHex_37;
    logic [7:0] _ans_nibbleToHex_14;
    logic [7:0] _ans_nibbleToHex_16;
    logic [7:0] _extended_nibbleToHex_28;
    logic [7:0] _extended_nibbleToHex_20;
    logic [15:0] _extended_binaryToHex_25;
    logic [7:0] _extended_nibbleToHex_26;
    logic [7:0] _extended_nibbleToHex_22;
    logic [7:0] _extended_nibbleToHex_23;
    logic working;
    logic [7:0] _ans_nibbleToHex_34;
    logic [7:0] _ans_nibbleToHex_12;
    logic [7:0] _extended_nibbleToHex_11;
    logic [7:0] _extended_nibbleToHex_19;
    logic [7:0] _ans_nibbleToHex_9;
    logic [7:0] _extended_nibbleToHex_31;
    logic [7:0] _ans_nibbleToHex_17;
    logic [7:0] _extended_nibbleToHex_33;
    logic [7:0] _ans_nibbleToHex_28;
    logic [7:0] _extended_nibbleToHex_13;
    logic [7:0] _ans_nibbleToHex_24;
    logic [7:0] _ans_nibbleToHex_35;
    logic [7:0] _ans_nibbleToHex_18;
    logic [7:0] _extended_nibbleToHex_16;
    logic [111:0] _interceptBuffer_5;
    logic [7:0] _extended_nibbleToHex_29;
    logic [7:0] _ans_nibbleToHex_38;
    logic [7:0] _ans_nibbleToHex_10;
    logic [7:0] _ans_nibbleToHex_29;
    logic [7:0] _ans_nibbleToHex_31;
    logic [7:0] _ans_nibbleToHex_19;
    logic [63:0] _extended_binaryToHex_8;
    logic [7:0] _ans_nibbleToHex_20;
    logic [7:0] _ans_nibbleToHex_22;
    logic [7:0] _ans_nibbleToHex_13;
    logic [7:0] _ans_nibbleToHex_32;
    logic [63:0] _wire1_wireUnpack_6;
    logic [7:0] _extended_nibbleToHex_37;
    logic [7:0] _ans_nibbleToHex_11;
    logic [7:0] _extended_nibbleToHex_17;
    logic [7:0] _extended_nibbleToHex_18;
    logic [7:0] _extended_nibbleToHex_21;
    logic [15:0] _wire2_wireUnpack_6;

    always_comb begin
        if ((inUpdate & inValid)) begin
            _interceptBuffer_5 = din;
        end else begin
            _interceptBuffer_5 = _buffer_interceptBuffer_5;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            _buffer_interceptBuffer_5 <= 0;
        end else begin
            if ((inUpdate & inValid)) begin
                _buffer_interceptBuffer_5 <= din;
            end else begin
                
            end
        end
    end
    always_comb begin
        _wire1_wireUnpack_6 = _interceptBuffer_5[63:0];
        _wire2_wireUnpack_6 = _interceptBuffer_5[79:64];
        _wire3_wireUnpack_6 = _interceptBuffer_5[111:80];
    end
    always_comb begin
        _extended_binaryToHex_8 = 64'd0;
        _extended_binaryToHex_8[63:0] = _wire1_wireUnpack_6;
    end
    always_comb begin
        _extended_nibbleToHex_9 = 8'd0;
        _extended_nibbleToHex_9[3:0] = _extended_binaryToHex_8[3:0];
        if ((_extended_binaryToHex_8[3:0] < 10)) begin
            _ans_nibbleToHex_9 = (_extended_nibbleToHex_9 + 48);
        end else begin
            _ans_nibbleToHex_9 = (_extended_nibbleToHex_9 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_10 = 8'd0;
        _extended_nibbleToHex_10[3:0] = _extended_binaryToHex_8[7:4];
        if ((_extended_binaryToHex_8[7:4] < 10)) begin
            _ans_nibbleToHex_10 = (_extended_nibbleToHex_10 + 48);
        end else begin
            _ans_nibbleToHex_10 = (_extended_nibbleToHex_10 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_11 = 8'd0;
        _extended_nibbleToHex_11[3:0] = _extended_binaryToHex_8[11:8];
        if ((_extended_binaryToHex_8[11:8] < 10)) begin
            _ans_nibbleToHex_11 = (_extended_nibbleToHex_11 + 48);
        end else begin
            _ans_nibbleToHex_11 = (_extended_nibbleToHex_11 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_12 = 8'd0;
        _extended_nibbleToHex_12[3:0] = _extended_binaryToHex_8[15:12];
        if ((_extended_binaryToHex_8[15:12] < 10)) begin
            _ans_nibbleToHex_12 = (_extended_nibbleToHex_12 + 48);
        end else begin
            _ans_nibbleToHex_12 = (_extended_nibbleToHex_12 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_13 = 8'd0;
        _extended_nibbleToHex_13[3:0] = _extended_binaryToHex_8[19:16];
        if ((_extended_binaryToHex_8[19:16] < 10)) begin
            _ans_nibbleToHex_13 = (_extended_nibbleToHex_13 + 48);
        end else begin
            _ans_nibbleToHex_13 = (_extended_nibbleToHex_13 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_14 = 8'd0;
        _extended_nibbleToHex_14[3:0] = _extended_binaryToHex_8[23:20];
        if ((_extended_binaryToHex_8[23:20] < 10)) begin
            _ans_nibbleToHex_14 = (_extended_nibbleToHex_14 + 48);
        end else begin
            _ans_nibbleToHex_14 = (_extended_nibbleToHex_14 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_15 = 8'd0;
        _extended_nibbleToHex_15[3:0] = _extended_binaryToHex_8[27:24];
        if ((_extended_binaryToHex_8[27:24] < 10)) begin
            _ans_nibbleToHex_15 = (_extended_nibbleToHex_15 + 48);
        end else begin
            _ans_nibbleToHex_15 = (_extended_nibbleToHex_15 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_16 = 8'd0;
        _extended_nibbleToHex_16[3:0] = _extended_binaryToHex_8[31:28];
        if ((_extended_binaryToHex_8[31:28] < 10)) begin
            _ans_nibbleToHex_16 = (_extended_nibbleToHex_16 + 48);
        end else begin
            _ans_nibbleToHex_16 = (_extended_nibbleToHex_16 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_17 = 8'd0;
        _extended_nibbleToHex_17[3:0] = _extended_binaryToHex_8[35:32];
        if ((_extended_binaryToHex_8[35:32] < 10)) begin
            _ans_nibbleToHex_17 = (_extended_nibbleToHex_17 + 48);
        end else begin
            _ans_nibbleToHex_17 = (_extended_nibbleToHex_17 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_18 = 8'd0;
        _extended_nibbleToHex_18[3:0] = _extended_binaryToHex_8[39:36];
        if ((_extended_binaryToHex_8[39:36] < 10)) begin
            _ans_nibbleToHex_18 = (_extended_nibbleToHex_18 + 48);
        end else begin
            _ans_nibbleToHex_18 = (_extended_nibbleToHex_18 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_19 = 8'd0;
        _extended_nibbleToHex_19[3:0] = _extended_binaryToHex_8[43:40];
        if ((_extended_binaryToHex_8[43:40] < 10)) begin
            _ans_nibbleToHex_19 = (_extended_nibbleToHex_19 + 48);
        end else begin
            _ans_nibbleToHex_19 = (_extended_nibbleToHex_19 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_20 = 8'd0;
        _extended_nibbleToHex_20[3:0] = _extended_binaryToHex_8[47:44];
        if ((_extended_binaryToHex_8[47:44] < 10)) begin
            _ans_nibbleToHex_20 = (_extended_nibbleToHex_20 + 48);
        end else begin
            _ans_nibbleToHex_20 = (_extended_nibbleToHex_20 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_21 = 8'd0;
        _extended_nibbleToHex_21[3:0] = _extended_binaryToHex_8[51:48];
        if ((_extended_binaryToHex_8[51:48] < 10)) begin
            _ans_nibbleToHex_21 = (_extended_nibbleToHex_21 + 48);
        end else begin
            _ans_nibbleToHex_21 = (_extended_nibbleToHex_21 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_22 = 8'd0;
        _extended_nibbleToHex_22[3:0] = _extended_binaryToHex_8[55:52];
        if ((_extended_binaryToHex_8[55:52] < 10)) begin
            _ans_nibbleToHex_22 = (_extended_nibbleToHex_22 + 48);
        end else begin
            _ans_nibbleToHex_22 = (_extended_nibbleToHex_22 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_23 = 8'd0;
        _extended_nibbleToHex_23[3:0] = _extended_binaryToHex_8[59:56];
        if ((_extended_binaryToHex_8[59:56] < 10)) begin
            _ans_nibbleToHex_23 = (_extended_nibbleToHex_23 + 48);
        end else begin
            _ans_nibbleToHex_23 = (_extended_nibbleToHex_23 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_24 = 8'd0;
        _extended_nibbleToHex_24[3:0] = _extended_binaryToHex_8[63:60];
        if ((_extended_binaryToHex_8[63:60] < 10)) begin
            _ans_nibbleToHex_24 = (_extended_nibbleToHex_24 + 48);
        end else begin
            _ans_nibbleToHex_24 = (_extended_nibbleToHex_24 + 55);
        end
    end
    always_comb begin
        _result_binaryToHex_8[127:120] = _ans_nibbleToHex_9;
        _result_binaryToHex_8[119:112] = _ans_nibbleToHex_10;
        _result_binaryToHex_8[111:104] = _ans_nibbleToHex_11;
        _result_binaryToHex_8[103:96] = _ans_nibbleToHex_12;
        _result_binaryToHex_8[95:88] = _ans_nibbleToHex_13;
        _result_binaryToHex_8[87:80] = _ans_nibbleToHex_14;
        _result_binaryToHex_8[79:72] = _ans_nibbleToHex_15;
        _result_binaryToHex_8[71:64] = _ans_nibbleToHex_16;
        _result_binaryToHex_8[63:56] = _ans_nibbleToHex_17;
        _result_binaryToHex_8[55:48] = _ans_nibbleToHex_18;
        _result_binaryToHex_8[47:40] = _ans_nibbleToHex_19;
        _result_binaryToHex_8[39:32] = _ans_nibbleToHex_20;
        _result_binaryToHex_8[31:24] = _ans_nibbleToHex_21;
        _result_binaryToHex_8[23:16] = _ans_nibbleToHex_22;
        _result_binaryToHex_8[15:8] = _ans_nibbleToHex_23;
        _result_binaryToHex_8[7:0] = _ans_nibbleToHex_24;
    end
    always_comb begin
        _extended_binaryToHex_25 = 16'd0;
        _extended_binaryToHex_25[15:0] = _wire2_wireUnpack_6;
    end
    always_comb begin
        _extended_nibbleToHex_26 = 8'd0;
        _extended_nibbleToHex_26[3:0] = _extended_binaryToHex_25[3:0];
        if ((_extended_binaryToHex_25[3:0] < 10)) begin
            _ans_nibbleToHex_26 = (_extended_nibbleToHex_26 + 48);
        end else begin
            _ans_nibbleToHex_26 = (_extended_nibbleToHex_26 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_27 = 8'd0;
        _extended_nibbleToHex_27[3:0] = _extended_binaryToHex_25[7:4];
        if ((_extended_binaryToHex_25[7:4] < 10)) begin
            _ans_nibbleToHex_27 = (_extended_nibbleToHex_27 + 48);
        end else begin
            _ans_nibbleToHex_27 = (_extended_nibbleToHex_27 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_28 = 8'd0;
        _extended_nibbleToHex_28[3:0] = _extended_binaryToHex_25[11:8];
        if ((_extended_binaryToHex_25[11:8] < 10)) begin
            _ans_nibbleToHex_28 = (_extended_nibbleToHex_28 + 48);
        end else begin
            _ans_nibbleToHex_28 = (_extended_nibbleToHex_28 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_29 = 8'd0;
        _extended_nibbleToHex_29[3:0] = _extended_binaryToHex_25[15:12];
        if ((_extended_binaryToHex_25[15:12] < 10)) begin
            _ans_nibbleToHex_29 = (_extended_nibbleToHex_29 + 48);
        end else begin
            _ans_nibbleToHex_29 = (_extended_nibbleToHex_29 + 55);
        end
    end
    always_comb begin
        _result_binaryToHex_25[31:24] = _ans_nibbleToHex_26;
        _result_binaryToHex_25[23:16] = _ans_nibbleToHex_27;
        _result_binaryToHex_25[15:8] = _ans_nibbleToHex_28;
        _result_binaryToHex_25[7:0] = _ans_nibbleToHex_29;
    end
    always_comb begin
        _extended_binaryToHex_30 = 32'd0;
        _extended_binaryToHex_30[31:0] = _wire3_wireUnpack_6;
    end
    always_comb begin
        _extended_nibbleToHex_31 = 8'd0;
        _extended_nibbleToHex_31[3:0] = _extended_binaryToHex_30[3:0];
        if ((_extended_binaryToHex_30[3:0] < 10)) begin
            _ans_nibbleToHex_31 = (_extended_nibbleToHex_31 + 48);
        end else begin
            _ans_nibbleToHex_31 = (_extended_nibbleToHex_31 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_32 = 8'd0;
        _extended_nibbleToHex_32[3:0] = _extended_binaryToHex_30[7:4];
        if ((_extended_binaryToHex_30[7:4] < 10)) begin
            _ans_nibbleToHex_32 = (_extended_nibbleToHex_32 + 48);
        end else begin
            _ans_nibbleToHex_32 = (_extended_nibbleToHex_32 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_33 = 8'd0;
        _extended_nibbleToHex_33[3:0] = _extended_binaryToHex_30[11:8];
        if ((_extended_binaryToHex_30[11:8] < 10)) begin
            _ans_nibbleToHex_33 = (_extended_nibbleToHex_33 + 48);
        end else begin
            _ans_nibbleToHex_33 = (_extended_nibbleToHex_33 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_34 = 8'd0;
        _extended_nibbleToHex_34[3:0] = _extended_binaryToHex_30[15:12];
        if ((_extended_binaryToHex_30[15:12] < 10)) begin
            _ans_nibbleToHex_34 = (_extended_nibbleToHex_34 + 48);
        end else begin
            _ans_nibbleToHex_34 = (_extended_nibbleToHex_34 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_35 = 8'd0;
        _extended_nibbleToHex_35[3:0] = _extended_binaryToHex_30[19:16];
        if ((_extended_binaryToHex_30[19:16] < 10)) begin
            _ans_nibbleToHex_35 = (_extended_nibbleToHex_35 + 48);
        end else begin
            _ans_nibbleToHex_35 = (_extended_nibbleToHex_35 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_36 = 8'd0;
        _extended_nibbleToHex_36[3:0] = _extended_binaryToHex_30[23:20];
        if ((_extended_binaryToHex_30[23:20] < 10)) begin
            _ans_nibbleToHex_36 = (_extended_nibbleToHex_36 + 48);
        end else begin
            _ans_nibbleToHex_36 = (_extended_nibbleToHex_36 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_37 = 8'd0;
        _extended_nibbleToHex_37[3:0] = _extended_binaryToHex_30[27:24];
        if ((_extended_binaryToHex_30[27:24] < 10)) begin
            _ans_nibbleToHex_37 = (_extended_nibbleToHex_37 + 48);
        end else begin
            _ans_nibbleToHex_37 = (_extended_nibbleToHex_37 + 55);
        end
    end
    always_comb begin
        _extended_nibbleToHex_38 = 8'd0;
        _extended_nibbleToHex_38[3:0] = _extended_binaryToHex_30[31:28];
        if ((_extended_binaryToHex_30[31:28] < 10)) begin
            _ans_nibbleToHex_38 = (_extended_nibbleToHex_38 + 48);
        end else begin
            _ans_nibbleToHex_38 = (_extended_nibbleToHex_38 + 55);
        end
    end
    always_comb begin
        _result_binaryToHex_30[63:56] = _ans_nibbleToHex_31;
        _result_binaryToHex_30[55:48] = _ans_nibbleToHex_32;
        _result_binaryToHex_30[47:40] = _ans_nibbleToHex_33;
        _result_binaryToHex_30[39:32] = _ans_nibbleToHex_34;
        _result_binaryToHex_30[31:24] = _ans_nibbleToHex_35;
        _result_binaryToHex_30[23:16] = _ans_nibbleToHex_36;
        _result_binaryToHex_30[15:8] = _ans_nibbleToHex_37;
        _result_binaryToHex_30[7:0] = _ans_nibbleToHex_38;
    end
    always_comb begin
        _joinwith_asciiSpace_7[127:0] = _result_binaryToHex_8;
        _joinwith_asciiSpace_7[167:136] = _result_binaryToHex_25;
        _joinwith_asciiSpace_7[239:176] = _result_binaryToHex_30;
        _joinwith_asciiSpace_7[135:128] = 32;
        _joinwith_asciiSpace_7[175:168] = 32;
    end
    always_comb begin
        lastByte = (byteCounter == 31);
        totalWord[239:0] = _joinwith_asciiSpace_7;
        totalWord[247:240] = 13;
        totalWord[255:248] = 10;
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
module UARTSend (
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
module CoreWrite (
    input addrValid,
    output logic addrUpdate,
    input [12:0] addrIn,
    input dataValid,
    output logic dataUpdate,
    input [31:0] dataIn,
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
        awaddr = addrIn;
        wdata = dataIn;
        wstrb = strbIn;
        wvalid = (strbValid & dataValid);
        dataUpdate = (wready & strbValid);
        strbUpdate = (wready & dataValid);
        awvalid = addrValid;
        addrUpdate = awready;
        bready = 1;
        araddr = 0;
        arvalid = 0;
        rready = 0;
    end
endmodule
module UARTRecv (
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
module AsciiEncoder_source (
    input [15:0] addrData,
    input [31:0] dataData,
    input inValid,
    output logic outValid,
    output logic [111:0] dout,
    input CLK,
    input RST
);
    logic [111:0] _result_wireConcat_3;
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
        _result_wireConcat_3[63:0] = counter;
        _result_wireConcat_3[79:64] = addrData;
        _result_wireConcat_3[111:80] = dataData;
    end
    always_comb begin
        dout = _result_wireConcat_3;
    end
endmodule
module InputParser (
    input [7:0] din,
    input inValid,
    output logic inUpdate,
    output logic addrValid,
    input addrUpdate,
    output logic [15:0] addrData,
    output logic dataValid,
    input dataUpdate,
    output logic [31:0] dataData,
    output logic bothAccepted,
    input CLK,
    input RST
);
    logic [47:0] buffer;
    logic dataAccepted;
    logic [31:0] bufferIndexHead;
    logic addrAccepted;
    logic [31:0] minusOne32;
    logic [31:0] zero32;
    logic [31:0] counter;

    always_comb begin
        bothAccepted = (addrAccepted & dataAccepted);
        inUpdate = (counter < 6);
        addrValid = 0;
        dataValid = 0;
        zero32 = 32'd0;
        minusOne32 = (~zero32);
        bufferIndexHead = (((counter + 1) << 3) + minusOne32);
        addrData = buffer[15:0];
        dataData = buffer[47:16];
        if ((inUpdate & inValid)) begin
            
        end else if (bothAccepted) begin
            
        end
        if ((counter == 6)) begin
            addrValid = (~addrAccepted);
            dataValid = (~dataAccepted);
            if (bothAccepted) begin
                
            end else begin
                if (addrUpdate) begin
                    
                end
                if (dataUpdate) begin
                    
                end
            end
        end
        if ((inUpdate & inValid)) begin
            
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            addrAccepted <= 0;
            buffer <= 0;
            counter <= 0;
            dataAccepted <= 0;
        end else begin
            if ((inUpdate & inValid)) begin
                counter <= (counter + 32'd1);
            end else if (bothAccepted) begin
                counter <= 0;
            end
            if ((counter == 6)) begin
                if (bothAccepted) begin
                    addrAccepted <= 0;
                    dataAccepted <= 0;
                end else begin
                    if (addrUpdate) begin
                        addrAccepted <= 1'd1;
                    end
                    if (dataUpdate) begin
                        dataAccepted <= 1'd1;
                    end
                end
            end
            if ((inUpdate & inValid)) begin
                buffer[bufferIndexHead -: 8] <= din;
            end
        end
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
    reg [7:0] _ram_fifoPatch_2 [511:0];
    logic _inready_fifoPatch_2;
    logic [7:0] _doutBypassed_fifoPatch_2;
    logic _outvalid_fifoPatch_2;
    logic [7:0] _doutRam_fifoPatch_2;
    logic [8:0] _rptrComb_fifoPatch_2;
    logic [8:0] _wptr_fifoPatch_2;
    logic _wincr_fifoPatch_2;
    logic _rincr_fifoPatch_2;
    logic [8:0] _rptr_fifoPatch_2;
    logic [8:0] _prevwptr_fifoPatch_2;
    logic _full_fifoPatch_2;
    logic _empty_fifoPatch_2;
    logic [7:0] _dout_fifoPatch_2;

    always_comb begin
        _empty_fifoPatch_2 = (_wptr_fifoPatch_2 == _rptr_fifoPatch_2);
        _full_fifoPatch_2 = ((_wptr_fifoPatch_2 + 9'd1) == _rptr_fifoPatch_2);
    end
    always_comb begin
        _rptrComb_fifoPatch_2 = _rptr_fifoPatch_2;
        if ((_wincr_fifoPatch_2 && (~_full_fifoPatch_2))) begin
            
        end
        if ((_rincr_fifoPatch_2 && (~_empty_fifoPatch_2))) begin
            _rptrComb_fifoPatch_2 = (_rptr_fifoPatch_2 + 9'd1);
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            _prevwptr_fifoPatch_2 <= 0;
            _rptr_fifoPatch_2 <= 0;
            _wptr_fifoPatch_2 <= 0;
        end else begin
            _prevwptr_fifoPatch_2 <= _wptr_fifoPatch_2;
            if ((_wincr_fifoPatch_2 && (~_full_fifoPatch_2))) begin
                _wptr_fifoPatch_2 <= (_wptr_fifoPatch_2 + 9'd1);
            end
            if ((_rincr_fifoPatch_2 && (~_empty_fifoPatch_2))) begin
                _rptr_fifoPatch_2 <= (_rptr_fifoPatch_2 + 9'd1);
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            _doutRam_fifoPatch_2 <= 0;
        end else begin
            _doutRam_fifoPatch_2 <= _ram_fifoPatch_2[_rptrComb_fifoPatch_2];
        end
    end
    always_comb begin
        if ((_prevwptr_fifoPatch_2 == _rptr_fifoPatch_2)) begin
            _dout_fifoPatch_2 = _doutBypassed_fifoPatch_2;
        end else begin
            _dout_fifoPatch_2 = _doutRam_fifoPatch_2;
        end
    end
    always_ff @( posedge CLK ) begin
        if (RST) begin
            _doutBypassed_fifoPatch_2 <= 0;
        end else begin
            _doutBypassed_fifoPatch_2 <= din;
            if ((_prevwptr_fifoPatch_2 == _rptr_fifoPatch_2)) begin
                
            end else begin
                
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if ((_wincr_fifoPatch_2 && (~_full_fifoPatch_2))) begin
            _ram_fifoPatch_2[_wptr_fifoPatch_2] <= din;
        end
    end
    always_comb begin
        _outvalid_fifoPatch_2 = (~_empty_fifoPatch_2);
        _rincr_fifoPatch_2 = outUpdate;
        _inready_fifoPatch_2 = (~_full_fifoPatch_2);
        _wincr_fifoPatch_2 = inValid;
    end
    always_comb begin
        outValid = _outvalid_fifoPatch_2;
        dout = _dout_fifoPatch_2;
    end
endmodule
