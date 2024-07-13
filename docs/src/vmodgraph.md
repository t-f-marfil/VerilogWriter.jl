# Module Connection

```@meta 
CurrentModule = VerilogWriter
DocTestSetup = quote
    using VerilogWriter
end
```

We offer here a tool to help creating a connection between multiple verilog modules.

## Vmodgraph

We handle connections in between `Vmodule`s using `Vmodgraph` objects.

```jldoctest m1
julia> g = Vmodgraph();
```

`Vmodgraph` is a callable object, and you may register connections between `Vmodule`s to this object.

```jldoctest m1
julia> a = Vmodule("a"); b = Vmodule("b");

julia> g(a => b);
```

We also offer a method to convert `Vmodgraph` into a graph written in DOT language, and the connections can be visualized this way.

```jldoctest m1
julia> dotgen(g; dpi=196) |> println;
digraph{
rankdir = LR;
dpi = 196;

a [shape=oval];
b [shape=oval];
a -> b;
}
```

Using, for example, Graphviz, the graph below would be generated.

![](./pic/g_ab.png)

## Connect Ports between Verilog Modules

The connection in the example above connected Vmodule `a` and `b`. However, there is no data transaction available between the modules. You may explicitly register name of ports to be connected between `Vmodule`s. Here we construct new connection from Midmodule `a` to `c`.

```jldoctest m1
julia> c = Vmodule("c");

julia> g(a => c, @pconnect dout => din);
```

Here we declared the connection between `a` and `c`. Note that at this time the Midmodules do not contain ports declared here. You also need to add the ports to each Midmodule object.

```jldoctest m1
julia> vpush!(a, @ports @out @logic 8 dout);

julia> vpush!(c, @ports @in 8 din);
```

## Generate List of Vmodule Objects

After adding logics and ports to each `Vmodule`, you may generate a list of `Vmodule`s exported from `Vmodgraph`.

```jldoctest m1
julia> vmods = layer2vmod!(g);

julia> println(typeof(vmods));
Vector{Vmodule}
```

At the head of the exported list of `Vmodule`s is the top level `Vmodule` which represents the whole `Vmodgraph`, and the rest are the modules which are instanciated inside the top module. You may call `vfinalize.(vmods)` to further conduct wire width inferences and wire declarations.

### Port Lifting

Each `Vmodule` objects can have (verilog) ports that are not connected to other `Vmodule`s. These ports are automatically added to the top level `Vmodule` when calling `layer2vmod!` and is accessible from outer verilog modules.
