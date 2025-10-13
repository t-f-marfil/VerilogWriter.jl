module btnToEdge (
    input CLK, RST,
    input btn,
    output dout
);

(* async_reg = "true" *) reg [2:0] sync;

always @(posedge CLK) begin
    if (RST) begin
        sync <= 0;
    end else begin
        sync <= {sync[1:0], btn};
    end
end

assign dout = sync[1] & ~sync[2];
    
endmodule