# TODO combine_axes_shortest like https://github.com/invenia/NamedDims.jl/blob/master/src/name_core.jl#L243
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
combine_index(x::Axis, y::Axis) = Axis(combine_keys(x, y), combine_values(x, y))
combine_index(x::SimpleAxis, y::SimpleAxis) = SimpleAxis(combine_values(x, y))
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
    return combine_keys(promote_keys_rule(x, y), keys(x), keys(y))
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


###
###
###
Broadcast.combine_axes(A::AxisIndices, B::AxisIndices) = _combine_axes(axes(A), axes(B))
Broadcast.combine_axes(A::AxisIndices, B::AbstractArray) = _combine_axes(axes(A), axes(B))
Broadcast.combine_axes(A::AbstractArray, B::AxisIndices) = _combine_axes(axes(A), axes(B))
Broadcast.combine_axes(A::AxisIndices) = indices(A)

_combine_axes(a::Tuple{Any,Vararg{Any}}, b::Tuple{Any,Vararg{Any}}) = combine_indices(a, b)
#    (combine_indices(first(a), first(b))..., _combine_axes(tail(a), tail(b))...)
#end
_combine_axes(a::Tuple{Any,Vararg{Any}}, b::Tuple{}) = a
_combine_axes(a::Tuple{}, b::Tuple{Any,Vararg{Any}}) = b
_combine_axes(a::Tuple{}, b::Tuple{}) = ()

function Broadcast.combine_axes(
    A::Tuple{<:AbstractAxis, Vararg{Any}},
    B::Tuple{<:AbstractAxis, Vararg{Any}}
   )
    return (combine_indices(first(A), first(B))..., combine_axes(tail(A), tail(B))...)
end

function Broadcast.combine_axes(
    A::Tuple{<:AbstractAxis, Vararg{Any}},
    B::Tuple{Any, Vararg{Any}}
   )
    return (combine_indices(first(A), first(B))..., combine_axes(tail(A), tail(B))...)
end

function Broadcast.combine_axes(
    A::Tuple{Any, Vararg{Any}},
    B::Tuple{<:AbstractAxis, Vararg{Any}}
   )
    return (combine_indices(first(A), first(B))..., combine_axes(tail(A), tail(B))...)
end

function Broadcast.combine_axes(A::Tuple{}, B::Tuple{<:AbstractAxis, Vararg{Any}})
    return (combine_indices(first(B))..., combine_axes(A, tail(B))...)
end

function Broadcast.combine_axes(A::Tuple{<:AbstractAxis, Vararg{Any}}, B::Tuple{})
    return (combine_indices(first(A))..., combine_axes(tail(A), B)...)
end

