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
    reg [12:0] _reg_readonlyqueue_1 [12:0];
    reg [31:0] _reg_readonlyqueue_2 [12:0];
    reg [0:0] _reg_readonlyqueue_3 [12:0];
    reg [0:0] _reg_readonlyqueue_4 [12:0];
    logic [2:0] _bitbundle_1;
    logic addrIsRead;
    logic _ans_onceAtRisingEdge_3;
    logic [3:0] _preindex_readonlyqueue_1;
    logic [3:0] _preindex_readonlyqueue_4;
    logic [3:0] _index_readonlyqueue_3;
    logic _iterdone_readonlyqueue_2;
    logic [31:0] _outdata_readonlyqueue_2;
    logic _valid_readonlyqueue_1;
    logic _valid_readonlyqueue_4;
    logic _initWait_readonlyqueue_2;
    logic [12:0] _outdata_readonlyqueue_1;
    logic _ans_onceAtRisingEdge_1;
    logic _zipped_zippedSpike_1;
    logic updateReqAddrWrite;
    logic [3:0] _index_readonlyqueue_1;
    logic _outdata_readonlyqueue_4;
    logic _prevzipped_zippedSpike_1;
    logic [3:0] _index_readonlyqueue_4;
    logic updateReqRead;
    logic _initWait_readonlyqueue_1;
    logic _ans_onceAtRisingEdge_2;
    logic waccepted;
    logic [3:0] _index_readonlyqueue_2;
    logic _buf_onceAtRisingEdge_2;
    logic rstCleared;
    logic [3:0] _preindex_readonlyqueue_3;
    logic _valid_readonlyqueue_3;
    logic dataIsRead;
    logic _valid_readonlyqueue_2;
    logic addrIsWrite;
    logic _initWait_readonlyqueue_4;
    logic [31:0] spikeCount;
    logic startCount;
    logic _initWait_readonlyqueue_3;
    logic [3:0] _preindex_readonlyqueue_2;
    logic awaccepted;
    logic spike;
    logic _iterdone_readonlyqueue_4;
    logic updateReqDataWrite;
    logic updateReqAddr;
    logic _buf_onceAtRisingEdge_3;
    logic restart;
    logic _buf_onceAtRisingEdge_1;
    logic updateReqData;
    logic dataIsWrite;
    logic _outdata_readonlyqueue_3;
    logic _iterdone_readonlyqueue_1;
    logic _iterdone_readonlyqueue_3;

    initial begin
        $readmemh("arpProbeAddr.mem", _reg_readonlyqueue_1, 0, 12);
        $readmemh("arpProbeData.mem", _reg_readonlyqueue_2, 0, 12);
        $readmemh("arpProbeOpcode.mem", _reg_readonlyqueue_3, 0, 12);
        $readmemh("arpProbeOpcode.mem", _reg_readonlyqueue_4, 0, 12);
    end

    always_comb begin
        _index_readonlyqueue_1 = 0;
        if (restart) begin
            _index_readonlyqueue_1 = 0;
        end else if ((updateReqAddr & _valid_readonlyqueue_1)) begin
            if ((_preindex_readonlyqueue_1 == 12)) begin
                _index_readonlyqueue_1 = 0;
            end else begin
                _index_readonlyqueue_1 = (_preindex_readonlyqueue_1 + 1);
            end
        end else begin
            _index_readonlyqueue_1 = _preindex_readonlyqueue_1;
        end
        if (restart) begin
            
        end else if ((updateReqAddr & _valid_readonlyqueue_1)) begin
            if ((_preindex_readonlyqueue_1 == 12)) begin
                
            end else begin
                
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if ((~rstn)) begin
            _iterdone_readonlyqueue_1 <= 0;
            _preindex_readonlyqueue_1 <= 0;
        end else begin
            if (restart) begin
                
            end else if ((updateReqAddr & _valid_readonlyqueue_1)) begin
                if ((_preindex_readonlyqueue_1 == 12)) begin
                    
                end else begin
                    
                end
            end else begin
                
            end
            if (restart) begin
                _preindex_readonlyqueue_1 <= 0;
                _iterdone_readonlyqueue_1 <= 0;
            end else if ((updateReqAddr & _valid_readonlyqueue_1)) begin
                if ((_preindex_readonlyqueue_1 == 12)) begin
                    _preindex_readonlyqueue_1 <= 4'd0;
                    _iterdone_readonlyqueue_1 <= 1'd1;
                end else begin
                    _preindex_readonlyqueue_1 <= (_preindex_readonlyqueue_1 + 1);
                end
            end
        end
    end
    always_comb begin
        _valid_readonlyqueue_1 = (_initWait_readonlyqueue_1 & (~_iterdone_readonlyqueue_1));
    end
    always_ff @( posedge CLK ) begin
        if ((~rstn)) begin
            _initWait_readonlyqueue_1 <= 0;
        end else begin
            _initWait_readonlyqueue_1 <= 1'd1;
        end
    end
    always_ff @( posedge CLK ) begin
        _outdata_readonlyqueue_1 <= _reg_readonlyqueue_1[_index_readonlyqueue_1];
    end
    always_comb begin
        _index_readonlyqueue_2 = 0;
        if (restart) begin
            _index_readonlyqueue_2 = 0;
        end else if ((updateReqData & _valid_readonlyqueue_2)) begin
            if ((_preindex_readonlyqueue_2 == 12)) begin
                _index_readonlyqueue_2 = 0;
            end else begin
                _index_readonlyqueue_2 = (_preindex_readonlyqueue_2 + 1);
            end
        end else begin
            _index_readonlyqueue_2 = _preindex_readonlyqueue_2;
        end
        if (restart) begin
            
        end else if ((updateReqData & _valid_readonlyqueue_2)) begin
            if ((_preindex_readonlyqueue_2 == 12)) begin
                
            end else begin
                
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if ((~rstn)) begin
            _iterdone_readonlyqueue_2 <= 0;
            _preindex_readonlyqueue_2 <= 0;
        end else begin
            if (restart) begin
                
            end else if ((updateReqData & _valid_readonlyqueue_2)) begin
                if ((_preindex_readonlyqueue_2 == 12)) begin
                    
                end else begin
                    
                end
            end else begin
                
            end
            if (restart) begin
                _preindex_readonlyqueue_2 <= 0;
                _iterdone_readonlyqueue_2 <= 0;
            end else if ((updateReqData & _valid_readonlyqueue_2)) begin
                if ((_preindex_readonlyqueue_2 == 12)) begin
                    _preindex_readonlyqueue_2 <= 4'd0;
                    _iterdone_readonlyqueue_2 <= 1'd1;
                end else begin
                    _preindex_readonlyqueue_2 <= (_preindex_readonlyqueue_2 + 1);
                end
            end
        end
    end
    always_comb begin
        _valid_readonlyqueue_2 = (_initWait_readonlyqueue_2 & (~_iterdone_readonlyqueue_2));
    end
    always_ff @( posedge CLK ) begin
        if ((~rstn)) begin
            _initWait_readonlyqueue_2 <= 0;
        end else begin
            _initWait_readonlyqueue_2 <= 1'd1;
        end
    end
    always_ff @( posedge CLK ) begin
        _outdata_readonlyqueue_2 <= _reg_readonlyqueue_2[_index_readonlyqueue_2];
    end
    always_comb begin
        _index_readonlyqueue_3 = 0;
        if (restart) begin
            _index_readonlyqueue_3 = 0;
        end else if ((updateReqAddr & _valid_readonlyqueue_3)) begin
            if ((_preindex_readonlyqueue_3 == 12)) begin
                _index_readonlyqueue_3 = 0;
            end else begin
                _index_readonlyqueue_3 = (_preindex_readonlyqueue_3 + 1);
            end
        end else begin
            _index_readonlyqueue_3 = _preindex_readonlyqueue_3;
        end
        if (restart) begin
            
        end else if ((updateReqAddr & _valid_readonlyqueue_3)) begin
            if ((_preindex_readonlyqueue_3 == 12)) begin
                
            end else begin
                
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if ((~rstn)) begin
            _iterdone_readonlyqueue_3 <= 0;
            _preindex_readonlyqueue_3 <= 0;
        end else begin
            if (restart) begin
                
            end else if ((updateReqAddr & _valid_readonlyqueue_3)) begin
                if ((_preindex_readonlyqueue_3 == 12)) begin
                    
                end else begin
                    
                end
            end else begin
                
            end
            if (restart) begin
                _preindex_readonlyqueue_3 <= 0;
                _iterdone_readonlyqueue_3 <= 0;
            end else if ((updateReqAddr & _valid_readonlyqueue_3)) begin
                if ((_preindex_readonlyqueue_3 == 12)) begin
                    _preindex_readonlyqueue_3 <= 4'd0;
                    _iterdone_readonlyqueue_3 <= 1'd1;
                end else begin
                    _preindex_readonlyqueue_3 <= (_preindex_readonlyqueue_3 + 1);
                end
            end
        end
    end
    always_comb begin
        _valid_readonlyqueue_3 = (_initWait_readonlyqueue_3 & (~_iterdone_readonlyqueue_3));
    end
    always_ff @( posedge CLK ) begin
        if ((~rstn)) begin
            _initWait_readonlyqueue_3 <= 0;
        end else begin
            _initWait_readonlyqueue_3 <= 1'd1;
        end
    end
    always_ff @( posedge CLK ) begin
        _outdata_readonlyqueue_3 <= _reg_readonlyqueue_3[_index_readonlyqueue_3];
    end
    always_comb begin
        _index_readonlyqueue_4 = 0;
        if (restart) begin
            _index_readonlyqueue_4 = 0;
        end else if ((updateReqData & _valid_readonlyqueue_4)) begin
            if ((_preindex_readonlyqueue_4 == 12)) begin
                _index_readonlyqueue_4 = 0;
            end else begin
                _index_readonlyqueue_4 = (_preindex_readonlyqueue_4 + 1);
            end
        end else begin
            _index_readonlyqueue_4 = _preindex_readonlyqueue_4;
        end
        if (restart) begin
            
        end else if ((updateReqData & _valid_readonlyqueue_4)) begin
            if ((_preindex_readonlyqueue_4 == 12)) begin
                
            end else begin
                
            end
        end
    end
    always_ff @( posedge CLK ) begin
        if ((~rstn)) begin
            _iterdone_readonlyqueue_4 <= 0;
            _preindex_readonlyqueue_4 <= 0;
        end else begin
            if (restart) begin
                
            end else if ((updateReqData & _valid_readonlyqueue_4)) begin
                if ((_preindex_readonlyqueue_4 == 12)) begin
                    
                end else begin
                    
                end
            end else begin
                
            end
            if (restart) begin
                _preindex_readonlyqueue_4 <= 0;
                _iterdone_readonlyqueue_4 <= 0;
            end else if ((updateReqData & _valid_readonlyqueue_4)) begin
                if ((_preindex_readonlyqueue_4 == 12)) begin
                    _preindex_readonlyqueue_4 <= 4'd0;
                    _iterdone_readonlyqueue_4 <= 1'd1;
                end else begin
                    _preindex_readonlyqueue_4 <= (_preindex_readonlyqueue_4 + 1);
                end
            end
        end
    end
    always_comb begin
        _valid_readonlyqueue_4 = (_initWait_readonlyqueue_4 & (~_iterdone_readonlyqueue_4));
    end
    always_ff @( posedge CLK ) begin
        if ((~rstn)) begin
            _initWait_readonlyqueue_4 <= 0;
        end else begin
            _initWait_readonlyqueue_4 <= 1'd1;
        end
    end
    always_ff @( posedge CLK ) begin
        _outdata_readonlyqueue_4 <= _reg_readonlyqueue_4[_index_readonlyqueue_4];
    end
    always_comb begin
        _ans_onceAtRisingEdge_1 = (_buf_onceAtRisingEdge_1 | (wvalid & wready));
        if (_zipped_zippedSpike_1) begin
            
        end else begin
            
        end
    end
    always_ff @( posedge CLK ) begin
        if ((~rstn)) begin
            _buf_onceAtRisingEdge_1 <= 0;
        end else begin
            if (_zipped_zippedSpike_1) begin
                _buf_onceAtRisingEdge_1 <= 0;
            end else begin
                _buf_onceAtRisingEdge_1 <= (_buf_onceAtRisingEdge_1 | (wvalid & wready));
            end
        end
    end
    always_comb begin
        _ans_onceAtRisingEdge_2 = (_buf_onceAtRisingEdge_2 | (awvalid & awready));
        if (_zipped_zippedSpike_1) begin
            
        end else begin
            
        end
    end
    always_ff @( posedge CLK ) begin
        if ((~rstn)) begin
            _buf_onceAtRisingEdge_2 <= 0;
        end else begin
            if (_zipped_zippedSpike_1) begin
                _buf_onceAtRisingEdge_2 <= 0;
            end else begin
                _buf_onceAtRisingEdge_2 <= (_buf_onceAtRisingEdge_2 | (awvalid & awready));
            end
        end
    end
    always_comb begin
        _ans_onceAtRisingEdge_3 = (_buf_onceAtRisingEdge_3 | (bready & bvalid));
        if (_zipped_zippedSpike_1) begin
            
        end else begin
            
        end
    end
    always_ff @( posedge CLK ) begin
        if ((~rstn)) begin
            _buf_onceAtRisingEdge_3 <= 0;
        end else begin
            if (_zipped_zippedSpike_1) begin
                _buf_onceAtRisingEdge_3 <= 0;
            end else begin
                _buf_onceAtRisingEdge_3 <= (_buf_onceAtRisingEdge_3 | (bready & bvalid));
            end
        end
    end
    always_comb begin
        _bitbundle_1[0] = _ans_onceAtRisingEdge_1;
        _bitbundle_1[1] = _ans_onceAtRisingEdge_2;
        _bitbundle_1[2] = _ans_onceAtRisingEdge_3;
    end
    always_comb begin
        _zipped_zippedSpike_1 = (&(_bitbundle_1));
    end
    always_ff @( posedge CLK ) begin
        if ((~rstn)) begin
            _prevzipped_zippedSpike_1 <= 0;
        end else begin
            _prevzipped_zippedSpike_1 <= _zipped_zippedSpike_1;
        end
    end
    always_comb begin
        spike = 0;
        if (_zipped_zippedSpike_1) begin
            
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
            if (_zipped_zippedSpike_1) begin
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
        addrIsWrite = (_valid_readonlyqueue_3 & (_outdata_readonlyqueue_3 == 1));
        addrIsRead = (_valid_readonlyqueue_3 & (_outdata_readonlyqueue_3 == 0));
        dataIsWrite = (_valid_readonlyqueue_4 & (_outdata_readonlyqueue_4 == 1));
        dataIsRead = (_valid_readonlyqueue_4 & (_outdata_readonlyqueue_4 == 0));
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
        awvalid = (((_valid_readonlyqueue_1 & addrIsWrite) & rstCleared) & (~awaccepted));
        updateReqAddrWrite = spike;
        awaddr = _outdata_readonlyqueue_1;
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
        wvalid = (((_valid_readonlyqueue_2 & dataIsWrite) & rstCleared) & (~waccepted));
        updateReqDataWrite = spike;
        wdata = _outdata_readonlyqueue_2;
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
        arvalid = ((_valid_readonlyqueue_1 & addrIsRead) & rstCleared);
        araddr = _outdata_readonlyqueue_1;
        updateReqRead = (arvalid & arready);
    end
    always_comb begin
        bready = 1;
        rready = 1;
    end
endmodule
