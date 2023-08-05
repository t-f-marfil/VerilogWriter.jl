"""
+ vcopy3 is significantly slower than others, while copy2 consumes more memory space than vcopy3.
+ coefficient for vans length in vcopy2 has little if any effect on run time, even though it directly affects memory consumption.
"""
function vcopy1(v::Vector{T}) where {T}
    vans = Vector{T}(undef, length(v))
    for i in eachindex(v)
        vans[i] = v[i]
    end
    return v
end

function vcopy2(v::Vector{T}) where {T}
    vans = Vector{T}(undef, 3length(v))
    icount = 0
    for i in eachindex(v)
        vans[i] = v[i]
        icount += 1
    end
    return resize!(vans, icount)
end

function vcopy3(v::Vector{T}) where {T}
    vans = T[]
    for i in v
        push!(vans, i)
    end
    return vans
end

"""
+ when length of tup gets bigger the difference in performance increases
+ tupsep2 is the fastest, tupsep1 the latest
"""
function tupsep1(tup)
    v1, v2 = Vector{Int}(undef, length(tup)), Vector{Float64}(undef, length(tup))
    count1 = 0
    count2 = 0
    for i in tup
        if i isa Int
            v1[count1+=1] = i
        else
            v2[count2+=1] = i
        end
    end
    resize!(v1, count1), resize!(v2, count2)
end
f(v1, v2, x::Int, count) = (v1[count[1]+=1] = x; return nothing)
f(v1, v2, x::Float64, count) = (v2[count[2]+=1] = x; return nothing)
function tupsep2(tup)
    v1, v2 = Vector{Int}(undef, length(tup)), Vector{Float64}(undef, length(tup))
    # count1, count2 = 0, 0
    count = [0, 0]

    # @code_warntype f.(Ref(v1), Ref(v2), tup, Ref(count))
    f.(Ref(v1), Ref(v2), tup, Ref(count))
    resize!(v1, count[1]), resize!(v2, count[2])
end
function tupsep3(tup)
    v1, v2 = Vector{Int}(undef, length(tup)), Vector{Float64}(undef, length(tup))
    count1, count2 = 0, 0
    # count = [0, 0]

    f(x::Int) = (v1[count1+=1] = x; nothing)
    f(x::Float64) = (v2[count2+=1] = x; nothing)
    # @code_warntype f.(Ref(v1), Ref(v2), tup, Ref(count))
    # f.(Ref(v1), Ref(v2), tup, Ref(count))
    f.(tup)
    resize!(v1, count1), resize!(v2, count2)
end

"""
+ using IOBuffer is significantly faster
"""
function strpush1(n)
    ans = string()
    c = 'c'
    for _ in 1:n
        ans = string(ans, c)
    end
    return ans
end
function strpush2(n)
    ans = IOBuffer()
    c = 'c'
    for _ in 1:n
        write(ans, c)
    end
    return String(take!(ans))
end