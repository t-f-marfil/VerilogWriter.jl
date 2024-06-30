macro exportMidlevel()
    quote
        export
            Midmoduletype, Midmodule, 
            Layerconn, Midport, Mmodgraph, @pconnect,
            defaultMidPid,
            IntermmodSigtype

        export
            dotgen,
            Regmmod, Randmmod, FIFOmmod,
            @FIFOmmod, @Randmmod

        # verilog debug
        export
            debugAdd!

        export lrand, lreg, lfifo
        export imvalid, imupdate

        export 
            imcontrolUpstream, imcontrolDownstream,
            layer2vmod!,
            imacceptedLower, imacceptedUpper

        export
            fifogen

        export
            getname, getmmod, getpid

        export
            uartRecv, uartSend
    end
end
