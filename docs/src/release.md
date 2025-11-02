# Release Note

## History

### 0.5.1 (WIP)

+ Wires in width inference error are now displayed in an alphabetical order
+ Items in `Vmodenv` can be displayed in an alphabetial order with `Base.string(::Vmodenv, true)`
+ `Wireexpr` for Verilog wire concatentaion is implemented (e.g. `{a, b[10:0]}`)
+ `default` block is introduced in `Case` type
+ Add sample modules that work as an experimental HTTP server

### 0.5.0

+ Start building documents with github actions
+ Refactored width inference
+ Inference accross multiple verilog modules is implemented
+ [`Readmemh`](@ref) is available to initialize reg / logic with Verilog `readmemh` statement.
    + [`@nralways`](@ref) that gerates `Alwayscontent` that is not reset by `autoreset` is also available.
+ Add patch methods to easily generate wires with certain functionality.
+ Simple simulation source for Verilator is available through [`verilatorSimrun`](@ref) method.
+ Simplified midlevel connections, renamed to `Vmodgraph`
+ Split methods into multiple submodules
