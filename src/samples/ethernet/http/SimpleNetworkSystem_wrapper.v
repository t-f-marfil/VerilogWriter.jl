module SimpleNetworkSystem_wrapper (
    output ufp_ready,
    input ufp_valid,
    input ufp_last,
    input [31:0] ufp_data,
    output debug_valid_srv,
    output [71:0] debug_data_srv,
    input start,
    output dfp_awvalid,
    output [31:0] dfp_wdata,
    output [7:0] dfp_awlen,
    output dfp_wlast,
    output dfp_wvalid,
    input dfp_awready,
    input dfp_wready,
    input CLK,
    input RST
);
    SimpleNetworkSystem uSimpleNetworkSystem (
        .ufp_ready(ufp_ready),
        .ufp_valid(ufp_valid),
        .ufp_last(ufp_last),
        .ufp_data(ufp_data),
        .debug_valid_srv(debug_valid_srv),
        .debug_data_srv(debug_data_srv),
        .start(start),
        .dfp_awvalid(dfp_awvalid),
        .dfp_wdata(dfp_wdata),
        .dfp_awlen(dfp_awlen),
        .dfp_wlast(dfp_wlast),
        .dfp_wvalid(dfp_wvalid),
        .dfp_awready(dfp_awready),
        .dfp_wready(dfp_wready),
        .CLK(CLK),
        .RST(RST)
    );

endmodule
