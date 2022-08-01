# VerilogWriter.jl Document

## Brief Introduction 

If you have IJulia locally, execute
###### In[1]
```Julia
using VerilogWriter
```
(or make `.jl` file and execute codes with `julia <filename>.jl` instead.) and then

###### In[2]
```Julia
x = @always (
    dout = d1 + d2;
    if b1
        dout = ~d1
    elseif b2 
        dout = ~d2
    end
)
vshow(x)
```

(note that variables such as `dout`, `b1` are not declared anywhere.)

and now you see the following:

###### Out[2]
```
always_comb begin
    dout = (d1 + d2);
    if (b1) begin
        dout = ~d1;
    end else if (b2) begin
        dout = ~d2;
    end
end
type: Alwayscontent
```

Another example is 

###### In[3]
```Julia
prs = Parameters(Oneparam("splind", 5))

ps = @ports (
    @in clk, sig1, sig2;
    @in 8 din, din2;
    @out reg 8 dout
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
```

and now you get 

###### Out[3]
```
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

(of course this verilog module itself is far from being useful.)

## Introduction

This module offers a simple method to write on Julia  Verilog/SystemVerilog codes not as raw strings but as objects with certain structures, such as always-block-objects, port-declaration-objects, and so on (not as sophisticated as, for example, Chisel is, though).

The motivation here is that it would be nice if we could write Verilog/SystemVerilog with the power of the Julia language, with a minimal amount of additional syntaxes (function calls, constructors, etc.). 

As in the examples above, we offer, for instance, simple macros to convert Verilog-like Julia code into certain objects that have proper structure found in Verilog codes.

```@meta 
CurrentModule = VerilogWriter
```

## What is Left to be Done

It seems too many things are left to be done to make this `VerilogWriter.jl`, at least to some extent, useful, but to list few of them, 

### Unsupported Syntaxes
Lots of operators and syntaxes in Verilog/SystemVerilog is not supported (e.g. for, generate for, interfaces, tasks, always_latch, indexed part select, and so on), although some of them can be replaced by using Julia syntaxes instead (e.g. using Julia for loop and generate multiple `always` blocks instead of Verilog), or rather it 'should be' replaced to make use of the power of Julia language.

### Not Enough Handlers of the Structs 
We offer here some structs to imitate what is done in Verilog codes, but few functions to handle them are offered together. Still you can construct some more functions to handle the structs offered here, making it a little easier to make more complex Verilog modules.

One example might be making functions to infer wire bit width from always blocks and assign statements, similar to what is done in Chisel.