function calc_checksum(src_data::Vector{UInt8})
    data = view(src_data, 1:length(src_data))
    if (length(src_data) & 0x1) == 1
        data = vcat(data, [UInt8(0)])
    end

    nibble_count = length(data) >> 1
    nibble_count |> println
    checksum = 0
    for i in 1:nibble_count
        checksum += (Int(data[2i-1]) << 8) + data[2i]
    end

    while (checksum >> 16) != 0
        checksum = (checksum & 0xFFFF) + (checksum >> 16)
    end

    return checksum
end

function generateHttpResponseGenerator(data::Vector{UInt8}, name)
    v = Vmodule("SampleHttpResponseGenerator_$name")
    prts = @ports (
        @in CLK, RST;

        @in rx_valid;
        @out @logic rx_ready;
        @in 32 rx_data;
        @in 2 rx_strb;

        @out @logic tx_valid, tx_last;
        @in tx_ready;
        @out @logic 32 tx_data;
        # checksum and total length must be valid when tx_valid is asserted
        @out @logic 16 tx_checksum, tx_total_length
    )

    fsm = @FSM state init,sending
    transadd!(fsm, @wireexpr(prev_rx_valid & ~rx_valid), @tstate init => sending)
    transadd!(fsm, @wireexpr(tx_ready & tx_last), @tstate sending => init)
    
    checksum = calc_checksum(data)
    alconst = @always (
        tx_checksum = $(Wireexpr(16, checksum));
        tx_total_length = $(Wireexpr(16, length(data)));
    )
    alcounter = @always (
        prev_rx_valid <= rx_valid;
        if state == init
            counter <= $(Wireexpr(32, 0))
        else
            if tx_valid & tx_ready
                counter <= counter + 1
            end
        end
    )

    dwordcount = (length(data) >> 2) + (length(data) % 4 > 0 ? 1 : 0)
    data_view = view(data, 1:length(data))
    if length(data) != (dwordcount << 2)
        data_view = vcat(data_view, zeros(UInt8, 4 - (length(data) % 4)))
    end

    alctrl = @always (
        tx_valid = state == sending;
        tx_last = counter == $(dwordcount - 1);
        rx_ready = 1;
    )
    cond_buf = Vector{Wireexpr}(undef,0)
    cont_buf = Vector{Ifcontent}(undef, 0)

    for i in 1:dwordcount
        push!(cond_buf, @wireexpr(counter == $(i-1)))
        dword_view = data_view[4(i-1)+1:4i]
        dword_val = (Int(dword_view[4])<<24) | (Int(dword_view[3])<<16) | (Int(dword_view[2])<<8) | dword_view[1]
        push!(cont_buf, @ifcontent (
            tx_data = $(Wireexpr(32, dword_val))
        ))
    end
    push!(cont_buf, @ifcontent (tx_data = 0))

    aldata = @always ($(Ifelseblock(cond_buf, cont_buf)))
    vpush!.(v, (
        prts, fsm,
        alconst, alcounter, alctrl, aldata
    ))
    return v
end
