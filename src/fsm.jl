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
    transcond::Matrix{Wireexpr}
    transvalid::Matrix{Bool}
    function FSM(n, s, tc, tv)
        length(unique(s)) == length(s) || error(
            "the same state name is registered more than once.\n",
            "list of states: $(string(s))"
        )
        new(n, s, tc, tv)
    end
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
    @FSM(mname, states)

Create `FSM` with variables of (machine itself / states) names.

With the macro there is no need to explicitly make a string object for 
machine/state names.

# Example 
```jldoctest
julia> m = @FSM m1 (s1, s2); # same as "@FSM(m1, (s1, s2))"

julia> vshow(m)
reg m1;

localparam s1 = 0;
localparam s2 = 1;

case (m1)
    s1: begin
        
    end
    s2: begin
        
    end
endcase
type: FSM
```
"""
macro FSM(mname, states)
    quote 
        FSM($(string(mname)), $(string.(states.args)))
    end
end

"""
    @tstate(arg)

Helper macro for argument in `transadd!`. 

Convert a pair of variables to a pair of strings.
```jldoctest
julia> @tstate a => b
"a" => "b"

julia> m = @FSM machine s1, s2;

julia> transadd!(m, (@wireexpr b), @tstate s1 => s2);

julia> vshow(m)
reg machine;

localparam s1 = 0;
localparam s2 = 1;

case (machine)
    s1: begin
        if (b) begin
            machine <= s2;
        end
    end
    s2: begin
        
    end
endcase
type: FSM
```
"""
macro tstate(arg)
    args = arg.args 
    args[1] == :(=>) || error("$(args[1]) is not a pair constructor.")
    quote
        $(string(args[2])) => $(string(args[3]))
    end
end

"""
    transadd!(x::FSM, cond::Wireexpr, newtrans::Pair{String, String})

Add a new transition rule for the state machine `x`.

The new rule here is:
+ The transition from state `newtrans[1]` to state `newtrans[2]`
+ This transition occures when `cond` is true and the current state is `newtrans[1]`

# Examples
```jldoctest
julia> fsm = @FSM nstate (uno, dos, tres); # create a FSM

julia> transadd!(fsm, (@wireexpr b1 == b2), @tstate uno => dos); # transition from "uno" to "dos" when "b1 == b2"

julia> vshow(fsmconv(Case, fsm));
case (nstate)
    uno: begin
        if ((b1 == b2)) begin
            nstate <= dos;
        end
    end
    dos: begin
        
    end
    tres: begin
        
    end
endcase
type: Case
```
"""
function transadd!(x::FSM, cond::Wireexpr, newtrans::Pair{String, String})
    sfrom, sto = newtrans
    # sfromind, stoind = (findall(x -> x == i, x.states)[] for i in (sfrom, sto))
    sfromindv, stoindv = (findall(x -> x == i, x.states) for i in (sfrom, sto))
    (length(sfromindv) == 1 && length(stoindv) == 1) || error(
        "$(length(sfromindv)) source state$(length(sfromindv) > 1 ? "s" : "") and ",
        "$(length(stoindv)) dest state$(length(stoindv) > 1 ? "s" : "") found.\n",
        "(src => dest) = ($(string(newtrans)))"
    )
    sfromind, stoind = sfromindv[1], stoindv[1]

    x.transvalid[stoind, sfromind] = true
    x.transcond[stoind, sfromind] = cond
    nothing
end

function transadd!(x::FSM, rules::Vector{Tuple{Wireexpr, Pair{String, String}}})
    for (c, nt) in rules 
        transadd!(x, c, nt)
    end
    nothing
end

"""
    transcond(m::FSM, states::Pair{String, String})

Get the `wireexpr` whose value should be `true` iff the state of 
the FSM changes from `states[1]` to `states[2]`.

# Examples
```jldoctest
julia> m = @FSM fsm s1, s2, s3; transadd!(m, (@wireexpr b1 == TCOND), @tstate s1=>s2); vshow(fsmconv(Case, m));
case (fsm)
    s1: begin
        if ((b1 == TCOND)) begin
            fsm <= s2;
        end
    end
    s2: begin
        
    end
    s3: begin
        
    end
endcase
type: Case

julia> t = transcond(m, @tstate s1 => s2); vshow(t);
((fsm == s1) && (b1 == TCOND))
type: Wireexpr

julia> t = transcond(m, @tstate s2 => s1);
ERROR: transition rule not registered for "s2" => "s1".
```
"""
function transcond(m, states::Pair{String, String})
    sfromind, stoind = (findfirst(x -> x == st, m.states) for st in states)
    (sfromind != nothing && stoind != nothing) || error(
        "either of states $(string(states)) not found, \n",
        "index (from, to) = ($(string(sfromind)), $(string(stoind)))."
    )

    m.transvalid[stoind, sfromind] || error(
        "transition rule not registered for $(string(states))."
    )
    
    sfrom = states[1]
    statecond = Wireexpr(logieq, Wireexpr(m.name), Wireexpr(sfrom))
    edge = m.transcond[stoind, sfromind]
    Wireexpr(land, statecond, edge)
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
    fsmconv(::Type{Ifcontent}, x::FSM)

Convert `FSM` logic to `Ifcontent` object.

When `vshow(fsmconv(Ifcontent, x))` is evaluated one 
case block will be the only output.
"""
function fsmconv(::Type{Ifcontent}, x::FSM)
    Ifcontent(fsmconv(Case, x))
end 

function fsmconv(::Type{Alwayscontent}, x::FSM)
    Alwayscontent(fsmconv(Ifcontent, x))
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

Generate localparams that declare the value which corresponds to each state.
"""
function fsmconv(::Type{Localparams}, x::FSM)
    ans = Onelocalparam[]

    for i in 1:length(x.states)
        push!(ans, onelocalparam(:($(Symbol(x.states[i])) = $(i-1))))
    end

    Localparams(ans)
end
