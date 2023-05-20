# Generate Verilog Module
```@meta 
CurrentModule = VerilogWriter
DocTestSetup = quote
    using VerilogWriter
end
```
## Define the Name of a Module

We offer an type `Vmodule`, which imitates Verilog modules. Instantiate it defining its name.

```jldoctest t1
julia> m = Vmodule("test");

julia> vshow(m)
module test ();

endmodule
type: Vmodule
```

A module named `test` is generated here.

## Define Ports, Parameters, Localparams, and Wires

Define ports, parameters, localparams, and wire/reg/logics as a Julia type we offer. Details on the types are at [Component Structs](@ref).

Add them to the module `test` calling [`vpush!`](@ref).

```jldoctest t1
julia> pa = @parameters (dummy = 10 << 2);

julia> po = @ports (@in CLK, RST; @in 8 din; @out @reg -1 dout);

julia> lp = @localparams (A = 1; B = 2; C = A + B);

julia> ds = @decls (@reg dumreg; @wire A+B<<C dumwire);

julia> f(p) = vpush!(m, p); map(f, (pa, po, lp, ds));

julia> vshow(m);
module test #(
    parameter dummy = (10 << 2)
)(
    input CLK,
    input RST,
    input [7:0] din,
    output reg [unknown] dout
);
    localparam A = 1;
    localparam B = 2;
    localparam C = (A + B);

    reg dumreg;
    wire [(A + (B << C))-1:0] dumwire;


endmodule
type: Vmodule
```

Syntaxes for each types (usage of `@ports`, `@decls`, etc.) are at [List of Converter Functions/Macros](@ref).

Instead of calling `vpush!` you may pass additional information to constructors of `Vmodule`.
You may also wrap ports, parameters, etc. into type `Vmodenv`.

```julia
env = Vmodenv(pa, po, lp, ds); Vmodule("test", env);
```

would generate the same result.


## Define Combinational/Sequential Logics

You may write always blocks in Julia syntax, and add them to `test` module. Details at [List of Converter Functions/Macros](@ref).

```jldoctest t1
julia> a1 = @always (dout <= din[3:0]); vshow(a1)
always_ff @( unknownedge  ) begin
    dout <= din[3:0];
end
type: Alwayscontent

julia> a2 = @always (dumreg = |(dumwire); duminfer = ~dumreg); vshow(a2);
always_comb begin
    dumreg = (|(dumwire));
    duminfer = (~dumreg);
end
type: Alwayscontent

julia> vpush!(m, a1); vpush!(m, a2);
```

## Finalize Verilog Module

In the codes above some output was not completely of Verilog syntax (e.g. `@( unknownedge )`), and lacked some wire declarations (e.g. `duminfer` was not declared).
You may automatically deal with these problems, for detailed information see also [Basic Automation](@ref).

```jldoctest t1
julia> m = vfinalize(m); vshow(m); # not `finalize`
module test #(
    parameter dummy = (10 << 2)
)(
    input CLK,
    input RST,
    input [7:0] din,
    output reg [3:0] dout
);
    localparam A = 1;
    localparam B = 2;
    localparam C = (A + B);

    reg dumreg;
    wire [(A + (B << C))-1:0] dumwire;
    logic duminfer;

    always_ff @( posedge CLK ) begin
        if (RST) begin
            dout <= 0;
        end else begin
            dout <= din[3:0];
        end
    end
    always_comb begin
        dumreg = (|(dumwire));
        duminfer = (~dumreg);
    end
endmodule
type: Vmodule
```
