module ArpProbe (
    input CLK,
    input rstn,
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
    input btn
);
    logic [168:0] data_readOnlyQueue_13;
    logic [415:0] data_readOnlyQueue_14;
    logic [12:0] data_readOnlyQueue_15;
    logic [12:0] data_readOnlyQueue_16;
    logic [2:0] _bitbundle_4;
    logic addrIsRead;
    logic [10:0] sliceIndex_readOnlyQueue_14;
    logic _ans_onceAtRisingEdge_11;
    logic updateReqRead;
    logic _ans_onceAtRisingEdge_12;
    logic [31:0] spikeCount;
    logic restart;
    logic _buf_onceAtRisingEdge_10;
    logic startCount;
    logic updateReqData;
    logic waccepted;
    logic valid_readOnlyQueue_13;
    logic _ans_onceAtRisingEdge_10;
    logic dataIsWrite;
    logic [5:0] sliceIndex_readOnlyQueue_15;
    logic [9:0] counter_readOnlyQueue_13;
    logic _prevzipped_zippedSpike_4;
    logic _buf_onceAtRisingEdge_11;
    logic [5:0] counter_readOnlyQueue_16;
    logic [31:0] outData_readOnlyQueue_14;
    logic valid_readOnlyQueue_16;
    logic rstCleared;
    logic outData_readOnlyQueue_16;
    logic updateReqAddrWrite;
    logic [9:0] sliceIndex_readOnlyQueue_13;
    logic dataIsRead;
    logic _zipped_zippedSpike_4;
    logic awaccepted;
    logic [5:0] sliceIndex_readOnlyQueue_16;
    logic [12:0] outData_readOnlyQueue_13;
    logic valid_readOnlyQueue_15;
    logic spike;
    logic _buf_onceAtRisingEdge_12;
    logic valid_readOnlyQueue_14;
    logic updateReqDataWrite;
    logic updateReqAddr;
    logic addrIsWrite;
    logic [10:0] counter_readOnlyQueue_14;
    logic [5:0] counter_readOnlyQueue_15;
    logic outData_readOnlyQueue_15;

    always_comb begin
        valid_readOnlyQueue_13 = (~(counter_readOnlyQueue_13 == 10'd13));
    end
    always_ff @( posedge CLK ) begin
        if ((~rstn)) begin
            counter_readOnlyQueue_13 <= 0;
        end else begin
            if (restart) begin
                counter_readOnlyQueue_13 <= 0;
            end else if (updateReqAddr) begin
                if (valid_readOnlyQueue_13) begin
                    counter_readOnlyQueue_13 <= (counter_readOnlyQueue_13 + 1);
                end
            end
        end
    end
    always_comb begin
        sliceIndex_readOnlyQueue_13 = 0;
        if ((~valid_readOnlyQueue_13)) begin
            sliceIndex_readOnlyQueue_13 = counter_readOnlyQueue_13;
        end else begin
            sliceIndex_readOnlyQueue_13 = (counter_readOnlyQueue_13 + 1);
        end
    end
    always_comb begin
        outData_readOnlyQueue_13 = data_readOnlyQueue_13[((sliceIndex_readOnlyQueue_13 * 13) - 1) -: 13];
    end
    always_comb begin
        data_readOnlyQueue_13[12 -: 13] = 13'd0;
        data_readOnlyQueue_13[25 -: 13] = 13'd4;
        data_readOnlyQueue_13[38 -: 13] = 13'd8;
        data_readOnlyQueue_13[51 -: 13] = 13'd12;
        data_readOnlyQueue_13[64 -: 13] = 13'd16;
        data_readOnlyQueue_13[77 -: 13] = 13'd20;
        data_readOnlyQueue_13[90 -: 13] = 13'd24;
        data_readOnlyQueue_13[103 -: 13] = 13'd28;
        data_readOnlyQueue_13[116 -: 13] = 13'd32;
        data_readOnlyQueue_13[129 -: 13] = 13'd36;
        data_readOnlyQueue_13[142 -: 13] = 13'd40;
        data_readOnlyQueue_13[155 -: 13] = 13'd2036;
        data_readOnlyQueue_13[168 -: 13] = 13'd2044;
    end
    always_comb begin
        valid_readOnlyQueue_14 = (~(counter_readOnlyQueue_14 == 11'd13));
    end
    always_ff @( posedge CLK ) begin
        if ((~rstn)) begin
            counter_readOnlyQueue_14 <= 0;
        end else begin
            if (restart) begin
                counter_readOnlyQueue_14 <= 0;
            end else if (updateReqData) begin
                if (valid_readOnlyQueue_14) begin
                    counter_readOnlyQueue_14 <= (counter_readOnlyQueue_14 + 1);
                end
            end
        end
    end
    always_comb begin
        sliceIndex_readOnlyQueue_14 = 0;
        if ((~valid_readOnlyQueue_14)) begin
            sliceIndex_readOnlyQueue_14 = counter_readOnlyQueue_14;
        end else begin
            sliceIndex_readOnlyQueue_14 = (counter_readOnlyQueue_14 + 1);
        end
    end
    always_comb begin
        outData_readOnlyQueue_14 = data_readOnlyQueue_14[((sliceIndex_readOnlyQueue_14 * 32) - 1) -: 32];
    end
    always_comb begin
        data_readOnlyQueue_14[31 -: 32] = 32'd4294967295;
        data_readOnlyQueue_14[63 -: 32] = 32'd65535;
        data_readOnlyQueue_14[95 -: 32] = 32'd3472490590;
        data_readOnlyQueue_14[127 -: 32] = 32'd16778760;
        data_readOnlyQueue_14[159 -: 32] = 32'd67502088;
        data_readOnlyQueue_14[191 -: 32] = 32'd256;
        data_readOnlyQueue_14[223 -: 32] = 32'd3472490590;
        data_readOnlyQueue_14[255 -: 32] = 32'd0;
        data_readOnlyQueue_14[287 -: 32] = 32'd0;
        data_readOnlyQueue_14[319 -: 32] = 32'd4272488448;
        data_readOnlyQueue_14[351 -: 32] = 32'd2570;
        data_readOnlyQueue_14[383 -: 32] = 32'd42;
        data_readOnlyQueue_14[415 -: 32] = 32'd1;
    end
    always_comb begin
        valid_readOnlyQueue_15 = (~(counter_readOnlyQueue_15 == 6'd13));
    end
    always_ff @( posedge CLK ) begin
        if ((~rstn)) begin
            counter_readOnlyQueue_15 <= 0;
        end else begin
            if (restart) begin
                counter_readOnlyQueue_15 <= 0;
            end else if (updateReqAddr) begin
                if (valid_readOnlyQueue_15) begin
                    counter_readOnlyQueue_15 <= (counter_readOnlyQueue_15 + 1);
                end
            end
        end
    end
    always_comb begin
        sliceIndex_readOnlyQueue_15 = 0;
        if ((~valid_readOnlyQueue_15)) begin
            sliceIndex_readOnlyQueue_15 = counter_readOnlyQueue_15;
        end else begin
            sliceIndex_readOnlyQueue_15 = (counter_readOnlyQueue_15 + 1);
        end
    end
    always_comb begin
        outData_readOnlyQueue_15 = data_readOnlyQueue_15[((sliceIndex_readOnlyQueue_15 * 1) - 1) -: 1];
    end
    always_comb begin
        data_readOnlyQueue_15[0 -: 1] = 1'd1;
        data_readOnlyQueue_15[1 -: 1] = 1'd1;
        data_readOnlyQueue_15[2 -: 1] = 1'd1;
        data_readOnlyQueue_15[3 -: 1] = 1'd1;
        data_readOnlyQueue_15[4 -: 1] = 1'd1;
        data_readOnlyQueue_15[5 -: 1] = 1'd1;
        data_readOnlyQueue_15[6 -: 1] = 1'd1;
        data_readOnlyQueue_15[7 -: 1] = 1'd1;
        data_readOnlyQueue_15[8 -: 1] = 1'd1;
        data_readOnlyQueue_15[9 -: 1] = 1'd1;
        data_readOnlyQueue_15[10 -: 1] = 1'd1;
        data_readOnlyQueue_15[11 -: 1] = 1'd1;
        data_readOnlyQueue_15[12 -: 1] = 1'd1;
    end
    always_comb begin
        valid_readOnlyQueue_16 = (~(counter_readOnlyQueue_16 == 6'd13));
    end
    always_ff @( posedge CLK ) begin
        if ((~rstn)) begin
            counter_readOnlyQueue_16 <= 0;
        end else begin
            if (restart) begin
                counter_readOnlyQueue_16 <= 0;
            end else if (updateReqData) begin
                if (valid_readOnlyQueue_16) begin
                    counter_readOnlyQueue_16 <= (counter_readOnlyQueue_16 + 1);
                end
            end
        end
    end
    always_comb begin
        sliceIndex_readOnlyQueue_16 = 0;
        if ((~valid_readOnlyQueue_16)) begin
            sliceIndex_readOnlyQueue_16 = counter_readOnlyQueue_16;
        end else begin
            sliceIndex_readOnlyQueue_16 = (counter_readOnlyQueue_16 + 1);
        end
    end
    always_comb begin
        outData_readOnlyQueue_16 = data_readOnlyQueue_16[((sliceIndex_readOnlyQueue_16 * 1) - 1) -: 1];
    end
    always_comb begin
        data_readOnlyQueue_16[0 -: 1] = 1'd1;
        data_readOnlyQueue_16[1 -: 1] = 1'd1;
        data_readOnlyQueue_16[2 -: 1] = 1'd1;
        data_readOnlyQueue_16[3 -: 1] = 1'd1;
        data_readOnlyQueue_16[4 -: 1] = 1'd1;
        data_readOnlyQueue_16[5 -: 1] = 1'd1;
        data_readOnlyQueue_16[6 -: 1] = 1'd1;
        data_readOnlyQueue_16[7 -: 1] = 1'd1;
        data_readOnlyQueue_16[8 -: 1] = 1'd1;
        data_readOnlyQueue_16[9 -: 1] = 1'd1;
        data_readOnlyQueue_16[10 -: 1] = 1'd1;
        data_readOnlyQueue_16[11 -: 1] = 1'd1;
        data_readOnlyQueue_16[12 -: 1] = 1'd1;
    end
    always_comb begin
        _ans_onceAtRisingEdge_10 = (_buf_onceAtRisingEdge_10 | (wvalid & wready));
        if (_zipped_zippedSpike_4) begin
            
        end else begin
            
        end
    end
    always_ff @( posedge CLK ) begin
        if ((~rstn)) begin
            _buf_onceAtRisingEdge_10 <= 0;
        end else begin
            if (_zipped_zippedSpike_4) begin
                _buf_onceAtRisingEdge_10 <= 0;
            end else begin
                _buf_onceAtRisingEdge_10 <= (_buf_onceAtRisingEdge_10 | (wvalid & wready));
            end
        end
    end
    always_comb begin
        _ans_onceAtRisingEdge_11 = (_buf_onceAtRisingEdge_11 | (awvalid & awready));
        if (_zipped_zippedSpike_4) begin
            
        end else begin
            
        end
    end
    always_ff @( posedge CLK ) begin
        if ((~rstn)) begin
            _buf_onceAtRisingEdge_11 <= 0;
        end else begin
            if (_zipped_zippedSpike_4) begin
                _buf_onceAtRisingEdge_11 <= 0;
            end else begin
                _buf_onceAtRisingEdge_11 <= (_buf_onceAtRisingEdge_11 | (awvalid & awready));
            end
        end
    end
    always_comb begin
        _ans_onceAtRisingEdge_12 = (_buf_onceAtRisingEdge_12 | (bready & bvalid));
        if (_zipped_zippedSpike_4) begin
            
        end else begin
            
        end
    end
    always_ff @( posedge CLK ) begin
        if ((~rstn)) begin
            _buf_onceAtRisingEdge_12 <= 0;
        end else begin
            if (_zipped_zippedSpike_4) begin
                _buf_onceAtRisingEdge_12 <= 0;
            end else begin
                _buf_onceAtRisingEdge_12 <= (_buf_onceAtRisingEdge_12 | (bready & bvalid));
            end
        end
    end
    always_comb begin
        _bitbundle_4[0] = _ans_onceAtRisingEdge_10;
        _bitbundle_4[1] = _ans_onceAtRisingEdge_11;
        _bitbundle_4[2] = _ans_onceAtRisingEdge_12;
    end
    always_comb begin
        _zipped_zippedSpike_4 = (&(_bitbundle_4));
    end
    always_ff @( posedge CLK ) begin
        if ((~rstn)) begin
            _prevzipped_zippedSpike_4 <= 0;
        end else begin
            _prevzipped_zippedSpike_4 <= _zipped_zippedSpike_4;
        end
    end
    always_comb begin
        spike = 0;
        if (_zipped_zippedSpike_4) begin
            
        end else if ((spikeCount == 50)) begin
            spike = 1;
        end
        if ((spikeCount == 50)) begin
            
        end else if (startCount) begin
            
        end
    end
    always_ff @( posedge CLK ) begin
        if ((~rstn)) begin
            spikeCount <= 0;
            startCount <= 0;
        end else begin
            if (_zipped_zippedSpike_4) begin
                startCount <= 1'd1;
            end else if ((spikeCount == 50)) begin
                startCount <= 0;
            end
            if ((spikeCount == 50)) begin
                spikeCount <= 0;
            end else if (startCount) begin
                spikeCount <= (spikeCount + 32'd1);
            end
        end
    end
    always_comb begin
        addrIsWrite = (valid_readOnlyQueue_15 & (outData_readOnlyQueue_15 == 1));
        addrIsRead = (valid_readOnlyQueue_15 & (outData_readOnlyQueue_15 == 0));
        dataIsWrite = (valid_readOnlyQueue_16 & (outData_readOnlyQueue_16 == 1));
        dataIsRead = (valid_readOnlyQueue_16 & (outData_readOnlyQueue_16 == 0));
        updateReqAddr = (updateReqAddrWrite | updateReqRead);
        updateReqData = (updateReqDataWrite | updateReqRead);
    end
    always_ff @( posedge CLK ) begin
        if ((~rstn)) begin
            rstCleared <= 0;
        end else begin
            if (btn) begin
                rstCleared <= 1;
            end
        end
    end
    always_comb begin
        awvalid = (((valid_readOnlyQueue_13 & addrIsWrite) & rstCleared) & (~awaccepted));
        updateReqAddrWrite = spike;
        awaddr = outData_readOnlyQueue_13;
        restart = 1'd0;
        if (spike) begin
            
        end else begin
            
        end
    end
    always_ff @( posedge CLK ) begin
        if ((~rstn)) begin
            awaccepted <= 0;
        end else begin
            if (spike) begin
                awaccepted <= 0;
            end else begin
                awaccepted <= (awaccepted | (awvalid & awready));
            end
        end
    end
    always_comb begin
        wvalid = (((valid_readOnlyQueue_14 & dataIsWrite) & rstCleared) & (~waccepted));
        updateReqDataWrite = spike;
        wdata = outData_readOnlyQueue_14;
        wstrb = (~0);
        if (spike) begin
            
        end else begin
            
        end
    end
    always_ff @( posedge CLK ) begin
        if ((~rstn)) begin
            waccepted <= 0;
        end else begin
            if (spike) begin
                waccepted <= 0;
            end else begin
                waccepted <= (waccepted | (wvalid & wready));
            end
        end
    end
    always_comb begin
        arvalid = ((valid_readOnlyQueue_13 & addrIsRead) & rstCleared);
        araddr = outData_readOnlyQueue_13;
        updateReqRead = (arvalid & arready);
    end
    always_comb begin
        bready = 1;
        rready = 1;
    end
endmodule
