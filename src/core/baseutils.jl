function Base.convert(::Type{String}, x::Symbol)
    string(x)
end

"Convert oneparam and onelocalparam with each other."
function Base.convert(::Type{Oneparam}, x::Onelocalparam)
    Oneparam(x.name, x.val)
end

"Convert parameters and localparams with each other."
function Base.convert(::Type{Parameters}, x::Localparams)
    Parameters(convert.(Oneparam, x.val))
end

"Convert oneparam and onelocalparam with each other."
function Base.convert(::Type{Onelocalparam}, x::Oneparam)
    Onelocalparam(x.name, x.val)
end

"Convert parameters and localparams with each other."
function Base.convert(::Type{Localparams}, x::Parameters)
    Localparams(convert.(Onelocalparam, x.val))
end

"""
    Base.iterate(x::Wireexpr)

Needed to deal with some return value that may be 
either Wireexpr or Vector{Wireexpr}.
May cause type instability, but it is already inevitable
in parsing AST.
"""
function Base.iterate(x::Wireexpr)
    (x, nothing)
end

function Base.iterate(x::Wireexpr, ::Nothing)
    nothing
end

"""
    Base.:isequal(uno::Wireexpr, dos::Wireexpr)

Equality for `Wireexpr`.

Note that `Base.:(==)` for Wireexpr is defined to create a new Wireexpr object.
"""
function Base.isequal(uno::Wireexpr, dos::Wireexpr)
    hash(uno) == hash(dos)
end

function Base.:(==)(uno::Oneport, dos::Oneport)
    hash(uno) == hash(dos)
end

function Base.:(==)(uno::Onedecl, dos::Onedecl)
    hash(uno) == hash(dos)
end

"""
    Base.:(==)(uno::Decls, dos::Decls)

Equality for `Decls`. Ignore order in which Onedecl is stored.
"""
function Base.:(==)(uno::Decls, dos::Decls)
    return issetequal(Set(uno.val), Set(dos.val))
end

macro basehashgen(tt...)
    qs = [
        esc(
            quote
                function Base.hash(x::$(t), h::UInt)
                    hash(Tuple(map(i -> getproperty(x, i), fieldnames($(t)))), h)
                end
            end
        ) for t in tt
    ]

    Expr(:block, qs...)
end

@basehashgen(
    Wireexpr,
    Ports,
        Oneport,
    Parameters,
        Oneparam,
    Localparams,
        Onelocalparam,
    Decls,
        Onedecl,
    Vmodinst,
    Assign,
    Alwayscontent,
        Sensitivity,
            Ifcontent,
                Ifelseblock,
                Case
)

# """
#     Base.hash(x::Wireexpr, h::UInt)

# Hash for `Wireexpr` to make it acceptable as keys for `Dict`.
# """
# function Base.hash(x::Wireexpr, h::UInt)
#     hash(Tuple(map(i -> getfield(x, i), fieldnames(Wireexpr))), h)
# end

# function Base.hash(x::Oneport, h::UInt)
#     hash(Tuple(map(i -> getfield(x, i), fieldnames(Oneport))), h)
# end

macro nonIternonBcast(arg)
    q = quote
        function Base.iterate(iter::$arg, ::Nothing)
            nothing
        end
        function Base.iterate(iter::$arg)
            (iter, nothing)
        end
        function Base.broadcastable(b::$arg)
            Ref(b)
        end
    end
    esc(q)
end
macro valIterBcast(arg)
    quote
        function Base.iterate(iter::$arg, state)
            iterate(iter.val, state)
        end
        function Base.iterate(iter::$arg)
            iterate(iter.val)
        end
        function Base.length(iter::$arg)
            length(iter.val)
        end
        function Base.broadcastable(b::$arg)
            b.val
        end
    end
end


# function Base.iterate(iter::Ports)
#     iterate(iter.val)
# end
# function Base.iterate(iter::Ports, state)
#     iterate(iter.val, state)
# end
# function Base.length(iter::Ports)
#     length(iter.val)
# end
@valIterBcast Ports

@nonIternonBcast Onelocalparam

# function Base.broadcastable(b::Localparams)
#     b.val
# end
@valIterBcast Localparams

# function Base.iterate(iter::Decls)
#     iterate(iter.val)
# end
# function Base.iterate(iter::Decls, state)
#     iterate(iter.val, state)
# end
# function Base.length(iter::Decls)
#     length(iter.val)
# end
@valIterBcast Decls

function Base.iterate(iter::Parameters)
    iterate(iter.val)
end
function Base.iterate(iter::Parameters, state)
    iterate(iter.val, state)
end
function Base.length(iter::Parameters)
    length(iter.val)
end

# function Base.iterate(x::Vmodule)
#     (x, nothing)
# end

# function Base.iterate(x::Vmodule, ::Nothing)
#     nothing
# end

# function Base.broadcastable(x::Vmodule)
#     Ref(x)
# end
@nonIternonBcast Vmodule

function Base.Int(w::Wireexpr)
    w.operation == literal || error(string(w), " cannot be converted to Int")
    return w.value
end