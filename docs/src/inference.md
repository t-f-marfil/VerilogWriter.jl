# Basic Automation

```@meta 
CurrentModule = VerilogWriter
DocTestSetup = quote
    using VerilogWriter
end
```
```@setup top
using VerilogWriter
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
```

`env` in an argument for `autodecl` is of type `Vmodenv`.

```@docs
vfinalize
```