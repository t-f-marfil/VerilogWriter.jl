"""
Struct for a Finite State Machine, not the flying spaghetti monster.

Each column of matrices are for the source state, and row for 
the destination state.

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

FSM(name, state::String...) = FSM(name, [i for i in state])

FSM(name, states::Vector{String}) = FSM(name, states, 
    Array{Ifcontent}(undef, length(states), length(states)),
    fill(false, length(states), length(states)))

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
                    Ifcontent([Alassign(Wireexpr(x.name), Wireexpr(x.states[i]), atype)], []))
            end
        end

        ifc = Ifcontent([], [ifb])
        push!(conds, Wireexpr(state) => ifc)
    end

    Case(Wireexpr(x.name), conds)
end

function transadd!(x::FSM, cond::Wireexpr, newtrans)
    sfrom, sto = newtrans
    sfromind, stoind = (findall(x -> x == i, x.states)[] for i in (sfrom, sto))

    x.transvalid[stoind, sfromind] = true 
    x.transcond[stoind, sfromind] = cond 
end