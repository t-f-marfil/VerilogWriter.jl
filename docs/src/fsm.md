# Finite State Machine

We offer here an easy way to construct a Finite State Machine (FSM). 

Finite State Machine is a common structure used in a hardware design. Offering a simple method to construct a FSM may be useful.

## Procedure of Designing a FSM

### Construct a FSM

First construct a FSM defining name of states and the machine itself.

```@docs
@FSM
FSM(name, state::String...)
FSM(name, states::Vector{String})
```

### Add Transition Rules

Add a new rule with `transadd!`.

```@docs 
transadd!
```

As shown above `cond` is the condition to be true when the transition occurs, and as `newtrans` argument you assign a `Pair` object of strings, `"srcstate" => "deststate"`. You may instead call macro `@tstate srcstate => deststate`.

```@docs
@tstate
```

### Generate Condition to be True when Transition Occurs

After adding transition rules you may generate `wireexpr` which would be true only when the transition occurs.

```@docs
transcond
```

### Convert from FSM to Verilog Codes

We offer methods to generate several components in verilog, which compose FSM structure.

They are 
+ A `case` statement for transition between states
+ `reg` declaration that holds the current state information.
+ `localparams` each of which represents one state in the FSM.

```@docs
fsmconv
```

You may also prewiew all of these with `vshow(x::FSM)`.

## Struct FSM Description

```@setup 1
push!(LOAD_PATH,"../../src/")
using VerilogWriter
```
```@example 1
println(showfield(FSM)) # hide
```
```@docs
FSM
```