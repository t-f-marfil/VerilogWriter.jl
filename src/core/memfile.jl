"""
    dumpMemfile(io::IO, data::V, width) where {V<:Vector}

Generate .mem file (read in `\$readmemb, \$readmemh` statement)
from `data` and `width` and write it at `io`.

`data` is supposed to be integer value.
"""
function dumpMemfile(io::IO, data::V, width) where {V<:Vector}
    hexLength = ceil(width / 4) |> Int
    for item in data
        write(io, string(item, base=16, pad=hexLength))
        write(io, "\n")
    end
    return nothing
end
