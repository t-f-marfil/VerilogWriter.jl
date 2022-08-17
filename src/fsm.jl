"""
Struct for a Finite State Machine, not the Flying Spaghetti Monster.

Each column of matrices corresponds to the source state, and row for 
the destination state. Not supposed to directly edit the content of matrices without
using handlers.

```
[
    false false 
    true  false
]
```
in `transvalid` means transition from the 1st state to 
the 2nd state is provided.
"""
struct FSM 
    name::String
    states::Vector{String}
    transcond::Array{Wireexpr}
    transvalid::Array{Bool}
end

"""
    FSM(name, state::String...)

Create an FSM object with name `name`, whose states are `state...`.
"""
FSM(name, state::String...) = FSM(name, [i for i in state])
"""
    FSM(name, states::Vector{String})

Create an FSM object with name `name`, whose states are `states`.
"""
FSM(name, states::Vector{String}) = FSM(name, states, 
    Array{Ifcontent}(undef, length(states), length(states)),
    fill(false, length(states), length(states)))


function Base.string(x::FSM)
    txt = ""
    txt *= string(fsmconv(Onedecl, x))
    txt *= "\n\n"
    txt *= string(fsmconv(Localparams, x))
    txt *= "\n\n"
    txt *= string(fsmconv(Case, x))
    txt 
end


"""
    fsmconv(::Type{Case}, x::FSM)

Convert `FSM` object into `Case` object.
"""
function fsmconv(::Type{Case}, x::FSM)
    fsmconv(Case, x, ff)
end

"""
    fsmconv(::Type{Case}, x::FSM, atype::Atype)

Accept as an argument `atype` to be used in assignments inside 
a case statement. Defaults to `ff` in the method `fsmconv(::Type{Case}, x::FSM)`.
"""
function fsmconv(::Type{Case}, x::FSM, atype::Atype)
    conds = Vector{Pair{Wireexpr, Ifcontent}}(undef, 0)
    
    for (ind, state) in enumerate(x.states)
        ifb = Ifelseblock()
        for i in length(x.states):-1:1
            if x.transvalid[i, ind] 
                ifadd!(ifb, x.transcond[i, ind],
                    Ifcontent([Alassign(Wireexpr(x.name), Wireexpr(x.states[i]), atype)], Ifelseblock[]))
            end
        end

        ifc = Ifcontent(Alassign[], [ifb])
        push!(conds, Wireexpr(state) => ifc)
    end

    Case(Wireexpr(x.name), conds)
end

"""
    fsmconv(::Type{Onedecl}, x::FSM)

Generate one `reg` declaration in verilog that holds the state value at the time.
"""
function fsmconv(::Type{Onedecl}, x::FSM)
    wid = ceil(log(2, length(x.states)))
    wid = Int(wid)
    Onedecl(reg, wid, x.name)
end

"""
    fsmconv(::Type{Localparams}, x::FSM)

Generate localparams that declares the value which corresponds to each state.
"""
function fsmconv(::Type{Localparams}, x::FSM)
    ans = Onelocalparam[]

    for i in 1:length(x.states)
        push!(ans, onelocalparam(:($(Symbol(x.states[i])) = $(i-1))))
    end

    Localparams(ans)
end


function transadd!(x::FSM, cond::Wireexpr, newtrans)
    sfrom, sto = newtrans
    sfromind, stoind = (findall(x -> x == i, x.states)[] for i in (sfrom, sto))

    x.transvalid[stoind, sfromind] = true 
    x.transcond[stoind, sfromind] = cond 
end