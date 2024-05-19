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

In some cases reg/logic should not be reset (e.g. 2d array is initialized with \$readmemh and must not initialized in always block). To generate `Alwayscontent` that should not be reset by `autoreset` you may call `@nralways`.

```@docs
@nralways
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