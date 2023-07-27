export
    Midmoduletype, Midmodule, 
    Layerconn, Midport, Layergraph,
    defaultMidPid,
    IntermmodSigtype

export
    dotgen,
    Reglayer, Randlayer, FIFOlayer,
    @FIFOlayer, @Randlayer

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