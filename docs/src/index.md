# What You Can Do with `VerilogWriter.jl`

```@meta 
CurrentModule = VerilogWriter
DocTestSetup = quote
    using VerilogWriter
end
```

## Convert Verilog-like Julia Code into Objects

```jldoctest
julia> a = @portoneline @in x;

julia> vshow(a);
input x
type: Oneport

julia> b = @portoneline @out reg 8 d1, d2;

julia> vshow(b);
output reg [7:0] d1
type: Oneport
output reg [7:0] d2
type: Oneport
```
```jldoctest
c = @always (
    @posedge clk;
    
    d1 <= d2 + d3;
    if b1 && b2
        d4 <= d5 ^ d6 
    else
        d4 <= ~d4[7:0] 
    end
)
vshow(c)

# output

always_ff @( posedge clk ) begin
    d1 <= (d2 + d3);
    if ((b1 && b2)) begin
        d4 <= (d5 ^ d6);
    end else begin
        d4 <= ~d4[7:0];
    end
end
type: Alwayscontent
```

You may also create objects from constructors and apply some operations.
```jldoctest
julia> c = Wireexpr("wire1");

julia> d = Wireexpr("wire2");

julia> e = @wireexpr wire3 << 5;

julia> vshow((c & d) + e);
((wire1 & wire2) + (wire3 << 5))
type: Wireexpr
```

## Embed Generated Objects Back into Verilog-like Codes

Using [metaprogramming](https://docs.julialang.org/en/v1/manual/metaprogramming/), you would do, for example, 

```jldoctest
a = @always (
    d1 = d2 + d3;
    d4 = d4 & d5
)
b = always(:(
    $(a);
    if b1 == b2 
        d6 = ~d7
    end
))
vshow(b)

# output

always_comb begin
    d1 = (d2 + d3);
    d4 = (d4 & d5);
    if ((b1 == b2)) begin
        d6 = ~d7;
    end
end
type: Alwayscontent
```

Note that you cannot use macros when embedding objects in Verilog-like codes.

One application of this syntax would be 
```jldoctest
a = @ports (
    @in 8 bus1, bus2;
    @out 8 bus3
)
send = Vmodule(
    "send",
    ports(:(
        @in sendin;
        $(a)
    )),
    Decls(),
    Alwayscontent[]
)
recv = Vmodule(
    "recv",
    ports(:(
        @in recvin;
        $(invports(a))
    )),
    Decls(),
    Alwayscontent[]
)
vshow(send)
println()
vshow(recv)

# output

module send (
    input sendin,
    input [7:0] bus1,
    input [7:0] bus2,
    output [7:0] bus3
);
    



endmodule
type: Vmodule

module recv (
    input recvin,
    output [7:0] bus1,
    output [7:0] bus2,
    input [7:0] bus3
);
    



endmodule
type: Vmodule
```

where you can construct `Ports` objects first and embed them in multiple modules.

## Easy construction of Finite State Machines

```jldoctest
julia> fsm = FSM("nstate", "uno", "dos", "tres"); # create a new Finite State Machine

julia> transadd!(fsm, (@wireexpr b1 == b2), "uno" => "dos"); # transition from "uno" to "dos"

julia> transadd!(fsm, (@wireexpr b3), "uno" => "tres"); # "uno" to "tres"

julia> transadd!(fsm, (@wireexpr b4), "dos" => "uno"); # "dos" to "uno"

julia> vshow(fsm);
reg [1:0] nstate;

localparam uno = 0;
localparam dos = 1;
localparam tres = 2;

case (nstate)
    uno: begin
        if ((b1 == b2)) begin
            nstate <= dos;
        end else if (b3) begin
            nstate <= tres;
        end
    end
    dos: begin
        if (b4) begin
            nstate <= uno;
        end
    end
    tres: begin
        
    end
endcase
type: FSM
```

The case statement needs to be contained inside an always block.