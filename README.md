# VerilogWriter.jl

[![CI](https://github.com/t-f-marfil/VerilogWriter.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/t-f-marfil/VerilogWriter.jl/actions/workflows/CI.yml)

A package to generate Verilog/SystemVerilog codes and offer an introductory HLS (high level synthesis) on Julia.

You may:
+ Convert Verilog-like Julia code into objects
+ Embed generated objects back into Verilog-like codes
+ Automatically infer wire width in always-blocks
+ Construct Finite State Machines in a simple method

Examples and full documents are available [here](https://t-f-marfil.github.io/VerilogWriter.jl/).

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
```systemverilog
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
ps = @ports (
    @in b1, RST
)
ds = @decls (
    @reg 8 dreg1
)
c = ifcontent(:(
    reg1 <= dreg1;
    if b1 
        reg2 <= reg1[7:6]
        reg3 <= reg1[0]
        reg4 <= reg1
        reg5 <= $(Wireexpr(32, 4))
    else 
        reg5 <= 0
    end
))
ac = autoreset(c)
env = Vmodenv(Parameters(), ps, Localparams(), ds)
ad = autodecl(ac.content, env)

vshow(ad)
vshow(ac)
```

###### Out[3]

```systemverilog
reg [7:0] reg1;
reg [1:0] reg2;
reg reg3;
reg [7:0] reg4;
reg [31:0] reg5;
type: Decls
always_ff @( posedge CLK ) begin
    if (RST) begin
        reg1 <= 0;
        reg2 <= 0;
        reg3 <= 0;
        reg4 <= 0;
        reg5 <= 0;
    end else begin
        reg1 <= dreg1;
        if (b1) begin
            reg2 <= reg1[7:6];
            reg3 <= reg1[0];
            reg4 <= reg1;
            reg5 <= 32'd4;
        end else begin
            reg5 <= 0;
        end
    end
end
type: Alwayscontent
```

(of course this verilog module itself is far from being useful.)

## Introduction

This package offers a simple method to write on Julia Verilog/SystemVerilog codes not as raw strings but as objects with certain structures, such as always-block-objects, port-declaration-objects, and so on (not as sophisticated as, for example, Chisel is, though).

The motivation here is that it would be nice if we could write Verilog/SystemVerilog with the power of the Julia language, with a minimal amount of additional syntaxes (function calls, constructors, etc.). 

As in the examples above, we offer, for instance, simple macros to convert Verilog-like Julia code into certain objects that have proper structure found in Verilog codes.

## Usage 

This module is not yet registered, so
```Julia
using Pkg
Pkg.add(PackageSpec(url="https://github.com/t-f-marfil/VerilogWriter.jl"))
```
would work. Or simply 
```
git clone "https://github.com/t-f-marfil/VerilogWriter.jl"
```
and try `tutorial.ipynb` in `/src`.

Dockerfile to build environment with julia and this module is also available in this repository.


## What is Left to be Done

It seems too many things are left to be done to make this `VerilogWriter.jl`, at least to some extent, useful, but to list few of them, 

### Unsupported Syntaxes
Lots of operators and syntaxes in Verilog/SystemVerilog is not supported (e.g. for, generate for, interfaces, tasks, always_latch, indexed part select, and so on), although some of them can be replaced by using Julia syntaxes instead (e.g. using Julia for loop and generate multiple `always` blocks instead of Verilog), or rather it 'should be' replaced to make use of the power of Julia language.

### Not Enough Handlers of the Structs 
We offer here some structs to imitate what is done in Verilog codes, but few functions to handle them are offered together. Still you can construct some more functions to handle the structs offered here, making it a little easier to make more complex Verilog modules.