
"""
    combine_axis(x, y)

Returns the combination of `x` and `y`, creating a new index. New subtypes of
`AbstractAxis` should implement a `combine_axis` method.
"""
combine_axis(x::Axis, y::Axis) = Axis(combine_keys(x, y), combine_values(x, y))
combine_axis(x::SimpleAxis, y::SimpleAxis) = SimpleAxis(combine_values(x, y))
function combine_axis(x::AbstractAxis, y::AbstractAxis)
    error("`combine_axis` must be defined for new subtypes of AbstractAxis.")
end
combine_axis(x::AbstractUnitRange, y::AbstractUnitRange) = combine_values(x, y)

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

function Broadcast.broadcast_shape(
    shape1::Tuple,
    shape2::Tuple{Vararg{<:AbstractAxis}},
    shapes::Tuple...
   )
    return Broadcast.broadcast_shape(_bcs(shape1, shape2), shapes...)
end

function Broadcast.broadcast_shape(
    shape1::Tuple{Vararg{<:AbstractAxis}},
    shape2::Tuple,
    shapes::Tuple...
   )
    return Broadcast.broadcast_shape(_bcs(shape1, shape2), shapes...)
end
function Broadcast.broadcast_shape(
    shape1::Tuple{Vararg{<:AbstractAxis}},
    shape2::Tuple{Vararg{<:AbstractAxis}},
    shapes::Tuple...
   )
    return Broadcast.broadcast_shape(_bcs(shape1, shape2), shapes...)
end

# _bcs consolidates two shapes into a single output shape
_bcs(::Tuple{}, ::Tuple{}) = ()
_bcs(::Tuple{}, newshape::Tuple) = (newshape[1], _bcs((), tail(newshape))...)
_bcs(shape::Tuple, ::Tuple{}) = (shape[1], _bcs(tail(shape), ())...)
function _bcs(shape::Tuple, newshape::Tuple)
    return (_bcs1(first(shape), first(newshape)), _bcs(tail(shape), tail(newshape))...)
end
# _bcs1 handles the logic for a single dimension
_bcs1(a::Integer, b::Integer) = a == 1 ? b : (b == 1 ? a : (a == b ? a : throw(DimensionMismatch("arrays could not be broadcast to a common size; got a dimension with lengths $a and $b"))))
_bcs1(a::Integer, b) = a == 1 ? b : (first(b) == 1 && last(b) == a ? b : throw(DimensionMismatch("arrays could not be broadcast to a common size; got a dimension with lengths $a and $(length(b))")))
_bcs1(a, b::Integer) = _bcs1(b, a)
function _bcs1(a, b)
    if _bcsm(b, a)
        return combine_axis(b, a)
    else
        if _bcsm(a, b)
            return combine_axis(a, b)
        else
            throw(DimensionMismatch("arrays could not be broadcast to a common size; got a dimension with lengths $(length(a)) and $(length(b))"))
        end
    end
end
# _bcsm tests whether the second index is consistent with the first
_bcsm(a, b) = a == b || length(b) == 1
_bcsm(a, b::Number) = b == 1
_bcsm(a::Number, b::Number) = a == b || b == 1


