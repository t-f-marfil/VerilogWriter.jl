# Simulation with Verilator

We offer a simple method to run simulation on verilog modules using verilator (verilator must be installed beforehand).

```@docs
verilatorSimrun
acceptableInVerilatorTest
```

```@setup 1
push!(LOAD_PATH,"../../src/")
using VerilogWriter
```

```@example 1
println(showfield(VerilatorOption)) # hide
```

```@docs
VerilatorOption
```
