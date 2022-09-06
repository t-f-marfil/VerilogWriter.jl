"""
    @strerror(arg)

Get exception message as `String`.
"""
macro strerror(arg)
    quote 
        try 
            $(esc(arg))
            # return ""
            ""
        catch e 
            buf = IOBuffer()
            showerror(buf, e) 
            # return String(take!(buf))
            String(take!(buf))
            # return sprint(showerror, e)
        end
    end
end

"""
    dictstr(d)

Sort by key and convert to `String` each pair in `d::dict`.
"""
function dictstr(d)
    v = sort([i for i in d], by=x->x[1])
    txt = ""
    for p in v 
        txt *= string(string(p[1]), " => ", string(p[2]), "\n")
    end
    rstrip(txt)
end

"""
    dictprint(d)

Print `d` using `dictstr`.
"""
function dictprint(d)
    println(dictstr(d))
end