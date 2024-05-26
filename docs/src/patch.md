# Patch

```@meta
CurrentModule = VerilogWriter
DocTestSetup = quote
    using VerilogWriter
end
```

We offer some methods to generate group of wires / always blocks with certain functionality.

These methods return `Vpatch` object which contains wire declarations and always blocks so that wires returned together with the `Vpatch` object can achieve an expected behavior.

```@docs
Vpatch
```

Example of using patch methods:

```jldoctest
julia> w, p = isAtRisingEdge(@wireexpr(data)); vshow(w); # returns a wire and a `Vpatch` object. `w` is a wire which is set to 1 iff `data` is at rising edge.
_risingEdge_1
type: Wireexpr

julia> v = Vmodule("test"); vpush!(v, p); vshow(v); # `Vpatch` object can be pushed into `Vmodule` object.
module test ();
    always_comb begin
        _risingEdge_1 = ((_prev_risingEdge_1 == 1'd0) & (data == 1'd1));
    end
    always_ff @( unknownedge  ) begin
        _prev_risingEdge_1 <= data;
    end
endmodule
type: Vmodule
```

Wires generated in patch methods are named with care to avoid generating wires with identical name. To achieve the goal most of these methods take `name::AbstractString` as the last argument.

Usually an Integer value which is incremented every time a method is called is passed to the `name` argument. To make methods declaration simple, we offer an helper macro `@vstdpatch`.

```@docs
@vstdpatch
```

## Basic Patches

```@docs
posedgePrec
bitbundle
nonegedge
posedgeSync
invertBitOrder
isAtRisingEdge
interceptBuffer
onceHigh
zipSpike
```

## RAM Related Patches

```@docs
readOnlyQueueComb
readOnlyQueue
fifoPatch
```
