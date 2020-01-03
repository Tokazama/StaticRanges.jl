
"""
    combine_indices(x, y)

Returns the combined axes of `x` and `y` for broadcasting operations.
"""
combine_indices(x::AbstractArray, y::AbstractArray) = combine_indices(axes(x), axes(y))
function combine_indices(x::Tuple, y::Tuple)
    return (combine_index(first(x), first(y)), combine_indices(tail(x), tail(y))...)
end
combine_indices(x::Tuple{Any}, y::Tuple{}) = (first(x),)
combine_indices(x::Tuple{}, y::Tuple{Any}) = (first(y),)
combine_indices(x::Tuple{}, y::Tuple{}) = ()

"""
    combine_index(x, y)

Returns the combination of `x` and `y`, creating a new index. New subtypes of
`AbstractAxis` should implement a `combine_index` method.
"""
function combine_index(x::Axis, y::Axis)
    return Axis{combine_names(x, y)}(combine_keys(x, y), combine_values(x, y))
end
function combine_index(x::SimpleAxis, y::SimpleAxis)
    return SimpleAxis{combine_names(x, y)}(combine_values(x, y))
end
function combine_index(x::AbstractAxis, y::AbstractAxis)
    error("`combine_index` must be defined for new subtypes of AbstractAxis.")
end
combine_index(x::AbstractUnitRange, y::AbstractUnitRange) = combine_values(x, y)

"""
    combine_values(x, y)

Returns the combination of the values of `x` and `y`, creating a new index. New
subtypes of `AbstractAxis` may implement a unique `combine_values` method if 
needed. Default behavior is to use the return of `promote_rule(x, y)` for the
type of the combined values. 
"""
combine_values(x, y) = combine_values(promote_values_rule(x, y), values(x), values(y))
combine_values(::Type{T}, x, y) where {T<:AbstractUnitRange} = T(x)

"""
    combine_keys(x::AbstractAxis, y::AbstractAxis)

Returns the combination of the keys of `x` and `y`, creating a new index. New
subtypes of `AbstractAxis` may implement a unique `combine_keys` method if 
needed. Default behavior is to use the return of `promote_rule(x, y)` for the
type of the combined keys. 
"""
function combine_keys(x::AbstractAxis, y::AbstractAxis)
    return combine_keys(promote_keys_rule(x, y),keys(x), keys(y))
end

combine_keys(::Union{}, x, y) = combine_keys(typeof(x), x, y)
combine_keys(::Type{T}, x, y) where {T<:Union{OneTo,OneToRange}} = T(length(x))
combine_keys(::Type{T}, x, y) where {T<:AbstractUnitRange} = T(first(x), last(x))
function combine_keys(::Type{T}, x, y) where {T<:Union{StepRange,AbstractStepRange}}
    return T(first(x), step(x), last(x))
end
function combine_keys(::Type{T}, x, y) where {T<:Union{LinRange,AbstractLinRange}}
    return T(first(x), last(x), length(x))
end
function combine_keys(::Type{T}, x, y) where {T<:Union{StepRangeLen,AbstractStepRangeLen}}
    return T(first(x), step(x), length(x), x.offset)
end
combine_keys(::Type{T}, x, y) where {T<:AbstractVector} = copy(x)

"""
    combine_names(a, b)

Returns the combined name of `a` and `b`. The standard rules are:

* nothing + nothing = name
* nothing + name = name
* name + nothing = name
* name1 + name2 = name1

## Examples
```jldoctest
julia> a, b, n, = Axis{:a}(1:10), Axis{:b}(1:10), Axis(1:10);

julia> combine_names(a, b)
:a

julia> combine_names(a, n)
:a

julia> combine_names(b, n)
:b

julia> combine_names(n, n)

julia> combine_names(b, a)
:b
```
"""
#combine_names(a::Union{Symbol,Nothing}, b::AbstractAxis) = combine_names(a, axis_names(b))
#combine_names(a::AbstractAxis, b::Union{Symbol,Nothing}) = combine_names(axis_names(a), b)
#combine_names(a::AbstractAxis, b::AbstractAxis) = combine_names(axis_names(a), axis_names(b))
combine_names(a, b) = combine_names(axis_names(a), axis_names(b))

combine_names(a::Symbol, b::Symbol) = a
combine_names(::Nothing, b::Symbol) = b
combine_names(a::Symbol, ::Nothing) = a
combine_names(::Nothing, ::Nothing) = nothing
