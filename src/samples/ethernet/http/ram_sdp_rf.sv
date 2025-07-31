// read-first simple dual port with block ram
module ram_sdp_rf #(
    parameter addrlen = 10,
    parameter datawid = 32
)(
    // input clka, clkb,
    input clk, 
    // input ena, enb, wea, web,
    input enread, enwrite,
    // input [addrlen-1:0] addra, addrb,
    input [addrlen-1:0] addrin, addrout,
    // input [datawid-1:0] dia,dib,
    input [datawid-1:0] din,
    // output reg [datawid-1:0] doa,dob
    output reg [datawid-1:0] dout
);

(* ram_style = "block" *)    reg [datawid-1:0] ram [(1 << addrlen)-1:0];

    // initial statement
    // initial begin
    //     $readmemb("zeroclear.mem", ram);
    // end

    always_ff @(posedge clk) begin 
        // if (ena) begin
        if (enread) begin
            // if (wea) ram[addra] <= dia;
            // doa <= ram[addra];
            dout <= ram[addrout];
        end
    end

    always_ff @(posedge clk) begin 
        // if (enb) begin
        if (enwrite) begin
            // if (web) ram[addrb] <= dib;
            ram[addrin] <= din;
            // dob <= ram[addrb];
        end
    end
endmodule

