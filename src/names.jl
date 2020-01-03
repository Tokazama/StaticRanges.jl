"""
    axis_names(x)

Returns a tuple of names for each axis of `x`. If `x` is an `AbstractUnitRange`
then a `Symbol` will be returned if it has a name and `nothing` will be returned
if it doesn't.

## Examples
```jldoctest
julia> axis_names(Axis{:a}(1:10))
:a

julia> axis_names(1:10)

julia> axis_names((Axis{:a}(1:10), 1:10)
(:a, nothing)
```
"""
axis_names(::A) where {A<:AbstractAxis} = axis_names(A)
axis_names(::Type{<:AbstractAxis{name,K,V,Ks,Vs}}) where {name,K,V,Ks,Vs} = name
# if this one isn't defined then axis_names(Axis{:some_name}) doesn't work
axis_names(::Type{AbstractAxis{name,K,V,Ks,Vs}}) where {name,K,V,Ks,Vs} = name
axis_names(::AbstractUnitRange) = nothing
axis_names(x::AbstractArray) = axis_names(axes(x))
axis_names(x::AbstractArray, i::Int) = axis_names(axes(x, i))
axis_names(x::Tuple{Any,Vararg}) = (axis_names(first(x)), axis_names(tail(x))...)
axis_names(x::Tuple{}) = ()

"""
    to_axis(a, axis::Tuple) -> NTuple{N,Int}
    to_axis(a, axis) -> Int

Given an array or tuple of indices `a` returns the dimensions corresponding to
`dims` as `Int`. If `dims` is an integer this simply ensures that it is an `Int`
or converted to one. If `dims` is a `Symbol` this returns the dimension corresponding
to the provided name. If the named dimension is not present an error is returned.

## Examples
```jldoctest
julia> axs = (Axis{:a}(1:10), Axis{:b}(1:10), Axis(1:10));

julia> to_axis(axs, :a)
1

julia> to_axis(axs, :b)
2

julia> to_axis(axs, (:a, :b))
(1, 2)
```
"""
@inline to_axis(x::AbstractArray, d) = to_axis(axes(x), d)
@inline to_axis(x::Tuple, d) = _to_axis(x, d)

_to_axis(x::Tuple, d::Tuple) = (_to_axis(x, first(d)), _to_axis(x, tail(d))...)
_to_axis(x::Tuple, d::Tuple{}) = ()
_to_axis(x::Tuple, d::Union{Int,Colon}) = d
_to_axis(a::AbstractArray, d::Integer) = Int(d)

function _to_axis(x::Tuple, n::Symbol)::Int
    dimnum = __to_axis(x, n)
    if dimnum === 0
        throw(ArgumentError(
            "Specified name ($(repr(n))) does not match any dimension name ($x)"
        ))
    end
    return dimnum
end

function __to_axis(axs::NTuple{N,Any}, name::Symbol) where N
    for ii in 1:N
        axis_names(getfield(axs, ii)) === name && return ii
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
