let
    g = generateEtherLiteControllerAll("v1")

    vs = layer2vmod!(g, false, name="EtherCoreSimpleInterface_v1")
    vs = vfinalize(vs)
    vexport(vs)

    wrapper = wrappergen(vs[begin])
    vexport("$(getname(wrapper)).v", wrapper)
end

let
    vmisc, g = generateSimpleNetworkSystem("1")
    vmods = layer2vmod!(g, false, name="SimpleNetworkSystem")
    vmods = vcat(vmods, vmisc)

    vmods = vfinalize(vmods)
    vexport(vmods)

    wrapper = wrappergen(vmods[begin])
    vexport("$(getname(wrapper)).v", wrapper)

    open("$(getname(vmods[begin])).pu", "w") do io
        umlgen!(io, g)
    end
end
