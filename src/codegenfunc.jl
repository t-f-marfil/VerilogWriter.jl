"""
    eachfieldconstruct(strc)

Make contructors for `struct strc`.

# Example
For 
```
struct S 
a::A
b::B
...
end
```
constructors
```
S(x::A) = S(x, B(),...)
S(x::B) = S(A(), x,...)
```
will be generated. Note that `A(), B()` should 
return appropriate objects.
"""
function eachfieldconstruct(strc)
    for (ind, t) in enumerate(strc.types)
        args = Any[:($(t)()) for t in strc.types]
        targ = :x
        args[ind] = targ
        q = quote 
            $(Symbol(string(strc)))($(targ)::$(t)) = $(strc)($(args...))
        end
        eval(q)
    end
end
# macro eachfieldconstruct(strc)
#     quote
#         for (ind, t) in enumerate($(strc).types)
#             args = Any[:($(t)()) for t in $(strc).types]
#             targ = :x
#             args[ind] = targ
#             q = quote 
#                 $(Symbol(string($(strc))))($(targ)::$(t)) = $($(strc))($(args...))
#             end
#             eval(q)
#         end
#     end
# end
