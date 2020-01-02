"""
    dimnames(x)

Returns a tuple of names for each dimension of `x`. If `x` is an `AbstractUnitRange`
then a `Symbol` will be returned if it has a name and `nothing` will be returned
if it doesn't.

## Examples
```jldoctest
julia> dimnames(Axis{:a}(1:10))
:a

julia> dimnames(1:10)

julia> dimnames((Axis{:a}(1:10), 1:10)
(:a, nothing)
```
"""
dimnames(::AbstractAxis{name}) where {name} = name
dimnames(::AbstractUnitRange) = nothing
dimnames(x::AbstractArray) = dimnames(axes(x))
dimnames(x::AbstractArray, i::Int) = dimnames(axes(x, i))
dimnames(x::Tuple{Any,Vararg}) = (dimnames(first(x)), dimnames(tail(x))...)
dimnames(x::Tuple{}) = ()

"""
    to_dims(a, dims::Tuple) -> NTuple{N,Int}
    to_dims(a, dims) -> Int

Given an array or tuple of indices `a` returns the dimensions corresponding to
`dims` as `Int`. If `dims` is an integer this simply ensures that it is an `Int`
or converted to one. If `dims` is a `Symbol` this returns the dimension corresponding
to the provided name. If the named dimension is not present an error is returned.

## Examples
```jldoctest
julia> axs = (Axis{:a}(1:10), Axis{:b}(1:10), Axis(1:10));

julia> to_dims(axs, :a)
1

julia> to_dims(axs, :b)
2

julia> to_dims(axs, (:a, :b))
(1, 2)
```
"""
@inline to_dims(x::AbstractArray, d) = to_dims(axes(x), d)
@inline to_dims(x::Tuple, d) = _to_dims(x, d)

_to_dims(x::Tuple, d::Tuple) = (_to_dims(x, first(d)), _to_dims(x, tail(d))...)
_to_dims(x::Tuple, d::Tuple{}) = ()
_to_dims(x::Tuple, d::Union{Int,Colon}) = d
_to_dims(a::AbstractArray, d::Integer) = Int(d)

function _to_dims(x::Tuple, n::Symbol)::Int
    dimnum = __to_dim(x, n)
    if dimnum === 0
        throw(ArgumentError(
            "Specified name ($(repr(n))) does not match any dimension name ($x)"
        ))
    end
    return dimnum
end

function __to_dim(axs::NTuple{N,Any}, name::Symbol) where N
    for ii in 1:N
        dimnames(getfield(axs, ii)) === name && return ii
    end
    return 0
end

"""
    unname(x)

Remove the name from a `x`. If `x` doesn't have a name the same instance of `x`
is returned.

## Examples
```jldoctest
julia> aidx, nidx, uidx, = Axis{:a}(1:10), Axis(1:10), 1:10

julia> unname(aidx)
Axis(1:10)

julia> unname(nidx)
Axis(1:10)

julia> unname(uidx)
1:10
```
"""
unname(x) = copy(x)
unname(nt::NamedTuple{names}) where {names} = Tuple(nt)
unname(x::Tuple) = unname.(x)
unname(idx::Axis) = Axis(keys(idx), values(idx), AllUnique, LengthChecked)
unname(si::SimpleAxis) = SimpleAxis(keys(si))
