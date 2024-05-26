# Release Note

## History

### 0.4.1

+ Start building documents with github actions
+ Refactored width inference
+ Inference accross multiple verilog modules is implemented
+ [`Readmemh`](@ref) is available to initialize reg / logic with Verilog `readmemh` statement.
    + [`@nralways`](@ref) that gerates `Alwayscontent` that is not reset by `autoreset` is also available.
+ Add patch methods to easily generate wires with certain functionality.
