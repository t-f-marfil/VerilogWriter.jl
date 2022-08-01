# Component Structs

```@meta 
CurrentModule = VerilogWriter
DocTestSetup = quote
    using VerilogWriter
end
```
## Structs Description

This module offers several structs that contain a structure of Verilog components, major ones of which are listed below. 


+ [Parameters](@ref)
  + [Oneparam](@ref)
+ [Ports](@ref)
  + [Oneport](@ref)
    + [Portdirec](@ref)
    + [Wiretype](@ref)
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
+ [Vmodule](@ref)
  
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

### Wireexpr
```@example 1
println(showfield(Wireexpr)) # hide
```
```@docs
Wireexpr
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
### Vmodule
```@example 1
println(showfield(Vmodule)) # hide
```
```@docs
Vmodule
```

## Converter Functions/Macros

As in previous examples we offer functions and macros to convert Julia syntax into certain structs described above. You may use these instead of calling constructors.

All the functions listed below accept `Expr` object as its argument (e.g. :(x = 10),
see [Julia Documents](https://docs.julialang.org/en/v1/manual/metaprogramming/#Expressions-and-evaluation) for more information.), and that is why variables inside the argument `Expr` object do not have to be declared anywhere else in the source code. The syntaxes each function requires in a argument `Expr` objects are also described below (or may be easily inferred from the examples here and [Brief Introduction](@ref)).

As you see in [Brief Introduction](@ref) there are macros that do the same thing as functions listed below (and both macro and function has the same name). As macros take `Expr` object as its argument, you can write codes in a slightly more simple manner with macros. For example,
```
always(:(
    @posedge clk; 

    w1 <= w2;
    if b1 == b2 
        w3 <= w4
    end
))
```
is equivalent to 
```
@always (
    @posedge clk; 

    w1 <= w2;
    if b1 == b2 
        w3 <= w4
    end
)
```

(be care full not to foreget `(one space)` between macros and `(`, i.e. `@macro(a;b)` and `@macro (a;b)` are different.)

But sometimes there are things what macros cannot do (at least to me it seems impossible in macros), an example is having `for` loop inside expressions.
```Julia
d = always(:(
    if b1 
        $([:($(Symbol("x$i")) = $(Symbol("y$i"))) for i in 1:3]...)
    end
))
vshow(d)
```
and this outputs
```
always_comb begin
    if (b1) begin
        x1 = y1;
        x2 = y2;
        x3 = y3;
    end
end
type: Alwayscontent
```

## List of Converter Functions/Macros

Written inside parentheses are the types of objects the functions return.

+ [ports](@ref) ([Ports](@ref))
  + [portoneline](@ref) ([Oneport](@ref))
+ [wireexpr](@ref) ([Wireexpr](@ref))
+ [decls](@ref) ([Decls](@ref))
  + [decloneline](@ref) ([Onedecl](@ref))
+ [always](@ref) ([Alwayscontent](@ref))
  + [oneblock](@ref)  ([Ifelseblock](@ref),[Alassign](@ref))

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

### decls 
```@docs
decls(::Expr)
decls(::Vector{Onedecl})
```
#### decloneline
```@docs
decloneline(::Expr)
```

### always
```@docs
always(::Expr)
```

#### oneblock 
```@docs
oneblock(::Expr)
oneblock(expr::T) where {T <: Union{Alassign, Ifelseblock}}
```

## Embedding Objects

You can embed generated objects back into Verilog-like codes. Note that because we ask you to make use of metaprogramming ([`interpolation`](https://docs.julialang.org/en/v1/manual/metaprogramming/#man-expression-interpolation) in particular), macros cannot be used for the purpose. 

By embedding objects as Julia AST, you can construct new objects that contain the information of embedded objects.

Every object (offered in this package) can be embedded almost anywhere it seems to be possible.

### Examples
```jldoctest
julia> a = @portoneline @in clk;

julia> b = ports(:($(a); @out 8 dout)); vshow(b);
(
    input clk,
    output [7:0] dout
);

type: Ports

julia> a = @ports (@in clk; @out 8 dout);

julia> b = ports(:(@in resetn; $(a))); vshow(b);
(
    input resetn,
    input clk,
    output [7:0] dout
);

type: Ports

julia> a = @wireexpr (x + y) & z;

julia> b = always(:(lhs = $(a) | w)); vshow(b);
always_comb begin
    lhs = (((x + y) & z) | w);
end
type: Alwayscontent
```

## Other Functions

### vshow 
```@docs
vshow(::Any)
```

### invports 
```@docs
invports
```

#### invport 
```@docs
invport
```