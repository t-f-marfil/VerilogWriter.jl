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

julia> b = @portoneline @out @reg 8 d1, d2;

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
```jldoctest
prs = @parameters splind = 5

ps = @ports (
    @in clk, sig1, sig2;
    @in 8 din, din2;
    @out @reg 8 dout
)

ds = @decls (
    @reg 8 dbuf
)

proc = @always (
    @posedge clk;

    if sig2 && |(din2)
        dbuf <= din 
    elseif sig1 ^ sig2
        dout[7:splind] <= dbuf[7:splind]
        dout[splind-1:0] <= din[splind-1:0]
    else
        dout <= ~din 
    end
)

mymod = Vmodule(
    "mymodule",
    prs,
    ps,
    ds,
    Assign[],
    [proc]
)

vshow(mymod, systemverilog=false)

# output

module mymodule #(
    parameter splind = 5
)(
    input clk,
    input sig1,
    input sig2,
    input [7:0] din,
    input [7:0] din2,
    output reg [7:0] dout
);
    reg [7:0] dbuf;

    always @( posedge clk ) begin
        if ((sig2 && |(din2))) begin
            dbuf <= din;
        end else if ((sig1 ^ sig2)) begin
            dout[7:splind] <= dbuf[7:splind];
            dout[(splind - 1):0] <= din[(splind - 1):0];
        end else begin
            dout <= ~din;
        end
    end
endmodule
type: Vmodule
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

## Wire Width Inference

```jldoctest wwi; output=false
ds = @decls (
    @wire dwire1;
    @wire 10 dwire2
)

c = @ifcontent (
    reg1 = 0;
    reg2 = 0;
    if dwire1
        reg1 = dwire2[0] & dwire2[1]
        reg2 = dwire2 + 1
    end
)

env = Vmodenv(
    Parameters(),
    Ports(),
    Localparams(),
    ds
)

# output

Vmodenv(Parameters(Oneparam[]), Ports(Oneport[]), Localparams(Onelocalparam[]), Decls(Onedecl[Onedecl(wire, Wireexpr(literal, "", Wireexpr[], -1, 1), "dwire1", false, Wireexpr(id, "", Wireexpr[], -1, -1)), Onedecl(wire, Wireexpr(literal, "", Wireexpr[], -1, 10), "dwire2", false, Wireexpr(id, "", Wireexpr[], -1, -1))]))
```

```jldoctest wwi
julia> autodecl(c); # fail in width inference with no additional information
ERROR: Wire width cannot be inferred for the following wires.
1. dwire1
2. reg2 = dwire2

julia> nenv = autodecl(c, env); vshow(nenv); # using information in `env`
wire dwire1;
wire [9:0] dwire2;
logic reg1;
logic [9:0] reg2;
type: Vmodenv
```

## Easy construction of Finite State Machines

```jldoctest
julia> fsm = @FSM nstate (uno, dos, tres); # create a new Finite State Machine

julia> transadd!(fsm, (@wireexpr b1 == b2), @tstate uno => dos); # transition from "uno" to "dos"

julia> transadd!(fsm, (@wireexpr b3), @tstate uno => tres); # "uno" to "tres"

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

You may need to include the case statement inside an always block.