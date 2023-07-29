export
    Midmoduletype, Midmodule, 
    Layerconn, Midport, Mmodgraph,
    defaultMidPid,
    IntermmodSigtype

export
    dotgen,
    Regmmod, Randmmod, FIFOmmod,
    @FIFOmmod, @Randmmod

for myenum in [Midmoduletype, IntermmodSigtype]
    for i in instances(myenum)
        eval(:(export $(Symbol(i))))
    end
end

export 
    nametoupper, nametolower,
    layer2vmod!,
    imacceptedLower, imacceptedUpper

export
    fifogen

export
    getname, getmmod, getpid

export
    uartRecv, uartSend