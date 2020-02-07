"""
    SimpleAxis(v)

Povides an `AbstractAxis` interface for any `AbstractUnitRange`, `v `. `v` will
be considered both the `values` and `keys` of the return instance. 

## Examples

```jldoctest
julia> using StaticRanges

julia> x = SimpleAxis(2:10)
SimpleAxis(2:10)

julia> x[2]
3

julia> x[==(2)]
2

julia> x[2] == x[==(3)]
true

julia> x[>(2)]
SimpleAxis(3:10)
```
"""
struct SimpleAxis{V,Vs<:AbstractUnitRange{V}} <: AbstractAxis{V,V,Vs,Vs}
    _kv::Vs
end

Base.values(si::SimpleAxis) = getfield(si, :_kv)
Base.keys(si::SimpleAxis) = getfield(si, :_kv)

SimpleAxis(vs) = SimpleAxis{eltype(vs),typeof(vs)}(vs)

SimpleAxis{V,Vs}(idx::AbstractAxis) where {V,Vs} = SimpleAxis{V,Vs}(Vs(values(idx)))

# This is a bit tricky b/c it requires that we permit both the keys and vals
# to be set in order to have the same format as other AbstractAxis constructors
function StaticArrays.similar_type(
    ::Type{A},
    ks_type::Type=keys_type(A),
    vs_type::Type=values_type(A)
   ) where {A<:SimpleAxis}
    return SimpleAxis{eltype(vs_type),vs_type}
end

function set_first(x::SimpleAxis{V}, val::V) where {V}
    return SimpleAxis(set_first(values(x), val))
end


function set_first!(x::SimpleAxis{V}, val::V) where {K,V}
    can_set_first(x) || throw(MethodError(set_first!, (x, val)))
    set_first!(values(x), val)
    return x
end

function set_last!(x::SimpleAxis{V}, val::V) where {V}
    can_set_last(x) || throw(MethodError(set_last!, (x, val)))
    set_last!(values(x), val)
    return x
end

set_last(x::SimpleAxis{K}, val::K) where {K} = SimpleAxis(set_last(values(x), val))


can_set_length(::Type{T}) where {T<:SimpleAxis} = can_set_length(keys_type(T))
function set_length!(a::SimpleAxis, len::Int)
    can_set_length(a) || error("Cannot use set_length! for instances of typeof $(typeof(a)).")
    set_length!(values(a), len)
    return a
end

set_length(a::SimpleAxis, len::Int) = SimpleAxis(set_length(values(a), len))

StaticArrays.pop(x::SimpleAxis) = SimpleAxis(pop(values(x)))

StaticArrays.popfirst(x::SimpleAxis) = SimpleAxis(popfirst(values(x)))

Base.pop!(si::SimpleAxis) = pop!(values(si))

Base.popfirst!(si::SimpleAxis) = popfirst!(values(si))

function Base.show(io::IO, ::MIME"text/plain", a::SimpleAxis)
    print(io, "SimpleAxis($(values(a)))")
end

function Base.show(io::IO, a::SimpleAxis)
    print(io, "SimpleAxis($(values(a)))")
end

check_iterate(r::SimpleAxis, i) = check_iterate(values(r), i)
