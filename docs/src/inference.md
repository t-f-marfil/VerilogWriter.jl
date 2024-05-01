# Automatic Inference

```@meta 
CurrentModule = VerilogWriter
DocTestSetup = quote
    using VerilogWriter
end
```

We offer some tools to automatically add additional information inferred from a given Verilog-like codes.


## Reset in Always Blocks

Given a content of always blocks, you may automatically reset all wires which appear at the LHS in the block.

```@docs
autoreset
```

## Automatic Wire Declaration

```@docs
autodecl
autodeclVmodlist

WidthInferenceStatus
widthInferenceCompleted
throwIfInferenceIsIncomplete
```

```@docs
vfinalize
```