# Basic Automation

```@meta 
CurrentModule = VerilogWriter
DocTestSetup = quote
    using VerilogWriter
end
```

We offer some tools to automatically add additional information inferred from a given Verilog-like codes.


## Reset in Always blocks

Given a content of always blocks, you may automatically reset all wires which appear at the LHS in the block.

```@docs
autoreset
```

```jldoctest
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
ad = autodecl(ac.content)

# output

ERROR: Wire width cannot be inferred for the following wires.
1. RST
2. b1
3. reg1 = dreg1 = reg4
```