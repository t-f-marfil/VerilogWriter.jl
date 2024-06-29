generateAsciiEncoder!(g, ports) = generateAsciiEncoder!(g, ports, 256, "")


function generateAsciiEncoder!(g::Mmodgraph, prts::Ports, fifoDepth::Integer, name::AbstractString)
    @assert all(p -> Int(getwidth(p)) > 0 && (getdirec(p) == pin), [p for p in prts])

    # concatenate input ports and push data into FIFO
    vsource = Vmodule("AsciiEncoder_source$(name)")
    vpush!(vsource, prts)

    wires = [@wireexpr($(getname(p))) for p in prts]
    widths = [Int(getwidth(p)) for p in prts]

    counterWidth = 64
    srcPorts = @ports (
        @in inValid;
        @out @logic outValid
    )
    alControl = @always (
        resetCount = $(Wireexpr(1, 0));

        outValid = inValid
    )
    alCounter = @always (
        if resetCount
            counter <= 0
        elseif inValid
            counter <= counter + $(Wireexpr(counterWidth, 1))
        end
    )
    vpush!.(vsource, (srcPorts, alCounter, alControl))


    widthList = [counterWidth; widths]
    wconcat, p = wireConcat([@wireexpr(counter); wires], widthList)
    concatLength = sum(widths) + counterWidth
    vpush!(vsource, p)
    vpush!(vsource, @always dout = $wconcat)
    vpush!(vsource, @ports @out @logic $concatLength dout)

    # FIFO
    vfifo = Vmodule("AsciiEncoder_fifo$name")
    # fifoDepth = 256
    vpush!(vfifo, @ports (
        @in $concatLength din;
        @in inValid;
        @out @logic outValid;
        @in outUpdate
    ))
    (inready, outvalid, dout), p = fifoPatch(fifoDepth, concatLength, @wireexpr(din), @wireexpr(inValid), @wireexpr(outUpdate))
    vpush!(vfifo, p)
    
    vpush!(vfifo, @always (
        # invalid = inValid;
        # $(imcontrolUpstream(imupdate)) = $inready;

        outValid = $outvalid
    ))
    vpush!(vfifo, @always dout = $dout)
    vpush!(vfifo, @ports @out @logic $concatLength dout)

    # get data from fifo and export to uart tx module
    vencode = Vmodule("AsciiEncoder_encodeToByteStream$name")
    vpush!(vencode, @ports @in $concatLength din)
    dinBuffer, pbuffer = interceptBuffer(@wireexpr(din), @wireexpr(inUpdate & inValid))
    vpush!(vencode, pbuffer)
    wires, punpack = wireUnpack(dinBuffer, widthList)
    vpush!(vencode, punpack)


    joined, pjoined = outputAsciiEncoded(wires, widthList)
    vpush!(vencode, pjoined)
    joinedLength = sum(widthToAsciiEncodedWidth.(widthList)) + 8*(length(widthList) - 1)
    joinedByteLength = joinedLength >> 3

    vpush!(vencode, @ports (
        @out @logic 8 dout;
        @out @logic inUpdate;
        @in inValid;
        @out @logic outValid;
        @in outUpdate
    ))

    # joinedBuffer, pbuffer = interceptBuffer(joined, imacceptedUpper())
    # vpush!(vencode, pbuffer)

    vpush!(vencode, @decls @logic $(joinedLength + 2*8) totalWord)
    
    toByteAl = @cpalways (
        # ascii encoded bytes + newline (\r\n)
        lastByte = byteCounter == $((joinedByteLength + 2) - 1);

        totalWord[$(joinedLength-1):0] = $joined;
        totalWord[$(joinedLength + 7):$joinedLength] = $(Int('\r'));
        totalWord[$(joinedLength + 15):$(joinedLength + 8)] = $(Int('\n'));
        
        dout = totalWord[((byteCounter << 3) + 7)-:8];
        if outValid & outUpdate
            if lastByte
                byteCounter <= $(Wireexpr(32, 0))
            else
                byteCounter <= byteCounter + 1
            end
        end;

        if inValid & inUpdate
            working <= $(Wireexpr(1, 1))
        elseif lastByte && (outValid & outUpdate)
            working <= 0
        end;

        outValid = working;

        inUpdate = 0;
        if inUpdate & inValid
            initProcess <= $(Wireexpr(1, 1))
        end;

        if lastByte && (outValid & outUpdate)
            inUpdate = 1
            if ~inValid
                requestToUpperContinue <= $(Wireexpr(1, 1))
            end
        elseif requestToUpperContinue || ~initProcess
            inUpdate = 1
            if inValid
                requestToUpperContinue <= 0
            end
        end
    )
    vpush!(vencode, toByteAl...)

    msource = Midmodule(vsource)
    mfifo = Midmodule(vfifo)
    mencode = Midmodule(vencode)

    g(
        msource => mfifo, 
        @pconnect (
            dout => din,
            outValid => inValid
        )
    )

    g(
        mfifo => mencode,
        @pconnect (
            dout => din,
            outValid => inValid
        )
    )
    g(
        mencode => mfifo,
        @pconnect (
            inUpdate => outUpdate
        )
    )

    # return layer2vmod!(g, name=name)
    return msource, mfifo, mencode
end