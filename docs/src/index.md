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

You may also create objects from constructors.
```jldoctest
julia> c = Wireexpr("wire1");

julia> d = Wireexpr("wire2");

julia> e = @wireexpr wire3 << 5;

julia> vshow((c & d) + e);
((wire1 & wire2) + (wire3 << 5))
type: Wireexpr
```
