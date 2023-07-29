# Basic Types

```@meta 
CurrentModule = VerilogWriter
DocTestSetup = quote
    using VerilogWriter
end
```
## Structs Description

This module offers several types that contain a structure of Verilog components, major parts of which are listed below. 


+ [Parameters](@ref)
  + [Oneparam](@ref)
+ [Ports](@ref)
  + [Oneport](@ref)
    + [Portdirec](@ref)
    + [Wiretype](@ref)
+ [Localparams](@ref)
  + [Onelocalparam](@ref)
+ [Wireexpr](@ref)
  + [Wireop](@ref)
+ [Decls](@ref)
  + [Onedecl](@ref)
+ [Assign](@ref)
+ [Alwayscontent](@ref)
  + [Alassign](@ref)
  + [Ifelseblock](@ref)
    + [Ifcontent](@ref)
  + [Atype](@ref)
  + [Edge](@ref)
+ [Vmodinst](@ref)
+ [Vmodule](@ref)
+ [Vmodenv](@ref)
  
```@setup 1
push!(LOAD_PATH,"../../src/")
using VerilogWriter
```


### Parameters 
```@example 1
println(showfield(Parameters)) # hide
```
```@docs
Parameters
```
#### Oneparam
```@example 1
println(showfield(Oneparam)) # hide
```
```@docs
Oneparam
```
### Ports 
```@example 1
println(showfield(Ports)) # hide
```
```@docs
Ports
```
#### Oneport 
```@example 1
println(showfield(Oneport)) # hide
```
```@docs
Oneport
```
#### Portdirec
```@example 1
println(string("Enum ", reduce((x, y)->string(x, " ", y), instances(Portdirec)))) # hide
```
```@docs
Portdirec
```

#### Wiretype 
```@example 1
println(string("Enum ", reduce((x, y)->string(x, " ", y), instances(Wiretype)))) # hide
```
```@docs
Wiretype
```

### Localparams
```@example 1
println(showfield(Localparams)) # hide
```
```@docs
Localparams
```

#### Onelocalparam
```@example 1
println(showfield(Onelocalparam)) # hide
```
```@docs
Onelocalparam
```

### Wireexpr
```@example 1
println(showfield(Wireexpr)) # hide
```
```@docs
Wireexpr

Wireexpr(n::String)
Wireexpr(n::Symbol)
Wireexpr(n::Int)
Wireexpr(op::Wireop, w::Wireexpr...)
Wireexpr(op::Wireop, v::Vector{Wireexpr})
Wireexpr(n::String, msb::T) where {T <: Union{Int, Wireexpr}}
Wireexpr(n::String, msb::T1, lsb::T2) where {T1 <: Union{Int, Wireexpr}, T2 <: Union{Int, Wireexpr}}
Wireexpr(w::Int, n::Int)
Wireexpr(expr::Wireexpr)
Wireexpr()
```
#### Wireop 
```@example 1
println(string("Enum ", reduce((x, y)->string(x, " ", y), instances(Wireop)))) # hide
```
```@docs
Wireop
```

### Decls
```@example 1
println(showfield(Decls)) # hide
```
```@docs
Decls
```
#### Onedecl
```@example 1
println(showfield(Onedecl)) # hide
```
```@docs
Onedecl
```
### Assign
```@example 1
println(showfield(Assign)) # hide
```
```@docs
Assign
```
### Alwayscontent
```@example 1
println(showfield(Alwayscontent)) # hide
```
```@docs
Alwayscontent
```
#### Alassign 
```@example 1
println(showfield(Alassign)) # hide
```
```@docs
Alassign
```
#### Ifelseblock 
```@example 1
println(showfield(Ifelseblock)) # hide
```
```@docs
Ifelseblock
```
##### Ifcontent 
```@example 1
println(showfield(Ifcontent)) # hide
```
```@docs
Ifcontent
```
#### Atype
```@example 1
println(string("Enum ", reduce((x, y)->string(x, " ", y), instances(Atype)))) # hide
```
```@docs
Atype
```
#### Edge 
```@example 1
println(string("Enum ", reduce((x, y)->string(x, " ", y), instances(Edge)))) # hide
```
```@docs
Edge
```
### Vmodinst
```@example 1
println(showfield(Vmodinst)) # hide
```
```@docs
Vmodinst
```
### Vmodule
```@example 1
println(showfield(Vmodule)) # hide
```
```@docs
Vmodule
```

### Vmodenv
```@example 1
println(showfield(Vmodenv)) # hide
```
```@docs
Vmodenv
```

## Converter Macros

As in previous examples we offer macros to convert Julia syntax into certain types described above. You may use these instead of calling constructors.

!!! note
    Note that conveter functions are now deprecated, everything should be handled with the macros.

All the macros listed below accept `Expr` object as its argument (e.g. `@mac x = 10` internally takes `:(x = 10)` as its argument,
see [Julia Documents](https://docs.julialang.org/en/v1/manual/metaprogramming/#man-macros) for more information.), and that is why variables inside the argument do not have to be declared anywhere else in the source code. The syntaxes each function requires in an argument are also described below (or may be easily inferred from the examples in this page and [Quick Start](@ref)).

(be care full not to foreget `(one space)` between macros and `(`, i.e. `@macro(a,b)` and `@macro (a,b)` are different, and the latter is used here.)


### List of Converter Macros

Written inside parentheses are the types of objects the functions return.

+ [parameters](@ref) ([Parameters](@ref))
  + [oneparam](@ref) ([Oneparam](@ref))
+ [ports](@ref) ([Ports](@ref))
  + [portoneline](@ref) ([Oneport](@ref))
+ [wireexpr](@ref) ([Wireexpr](@ref))
+ [localparams](@ref) ([Localparams](@ref))
  + [onelocalparam](@ref) ([Onelocalparam](@ref))
+ [decls](@ref) ([Decls](@ref))
  + [decloneline](@ref) (Vector{[Onedecl](@ref)})
+ [always](@ref) ([Alwayscontent](@ref))

### parameters
```@docs
parameters(expr::Expr)
```

#### oneparam
```@docs
oneparam(expr::Expr)
```

### ports
```@docs 
ports(::Expr)
ports(::Vector{Oneport})
```

#### portoneline 
```@docs
portoneline(::Expr)
```

### wireexpr
```@docs
wireexpr(::Expr)
wireexpr(::Wireexpr)
```

### localparams
```@docs
localparams(expr::Expr)
```

#### onelocalparam
```@docs
onelocalparam(expr::Expr)
```

### decls 
```@docs
decls(::Expr)
decls(::Vector{Onedecl})
decls(expr::Decls...)
```
#### decloneline
```@docs
decloneline(::Expr)
```

### always
```@docs
always(::Expr)
```

## Embed Objects

You can embed generated objects back into Verilog-like codes. The synatx is almost the same as those of [interpolation](https://docs.julialang.org/en/v1/manual/metaprogramming/#man-expression-interpolation).

By embedding objects as Julia AST, you can construct new objects that contain the information of embedded objects.

Every object (offered in this package) can be embedded almost anywhere it seems to be possible.

### Examples
```jldoctest
julia> a = @portoneline @in clk;

julia> b = @ports ($a; @out 8 dout); vshow(b);
(
    input clk,
    output [7:0] dout
);
type: Ports

julia> a = @ports (@in clk; @out 8 dout);

julia> b = @ports (@in resetn; $(a)); vshow(b);
(
    input resetn,
    input clk,
    output [7:0] dout
);
type: Ports

julia> a = @wireexpr (x + y) & z;

julia> b = @always (lhs = $(a) | w); vshow(b);
always_comb begin
    lhs = (((x + y) & z) | w);
end
type: Alwayscontent
```

## Miscellaneous Functions

### vshow 

`vshow` calls `Base.string` inside. You may convert objects into a string of verilog codes calling `Base.string`. See also [vexport](@ref).
```@docs
vshow
```

### vexport
```@docs
vexport
```

### vpush!
```@docs
vpush!
```

### sym2wire
```@docs
@sym2wire
```

### naiveinst
```@docs
naiveinst
```

### @preport
```@docs
@preport
```

### invports 
```@docs
invports
```