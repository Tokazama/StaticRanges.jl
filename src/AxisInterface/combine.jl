
keys_or_nothing(x::AbstractAxis) = keys(x)
keys_or_nothing(x) = nothing

"""
    combine_axis(x, y)

Returns the combination of `x` and `y`, creating a new index. New subtypes of
`AbstractAxis` should implement a `combine_axis` method.
"""
combine_axis(x::X, y::Y) where {X, Y} = combine_axis(promote_rule(X, Y), x, y)

combine_axis(::Type{T}, x, y) where {T<:SimpleAxis} = SimpleAxis(combine_values(values(x), values(y)))
function combine_axis(::Type{T}, x, y) where {T<:AbstractAxis}
    similar_type(T)(combine_keys(keys_or_nothing(x), keys_or_nothing(y)), combine_values(values(x), values(y)))
end
combine_axis(::Type{T}, x, y) where {T} = combine_values(values(x), values(y))

"""
    combine_values(x, y)

Returns the combination of the values of `x` and `y`, creating a new index. New
subtypes of `AbstractAxis` may implement a unique `combine_values` method if 
needed. Default behavior is to use the return of `promote_rule(x, y)` for the
type of the combined values. 
"""
combine_values(x, y) = combine_values(promote_values_rule(x, y), values(x), values(y))
combine_values(::Type{T}, x, y) where {T<:OneToUnion} = T(length(x))
combine_values(::Type{T}, x, y) where {T<:AbstractUnitRange} = T(first(x), last(x))

"""
    combine_keys(x::AbstractAxis, y::AbstractAxis)

Returns the combination of the keys of `x` and `y`, creating a new index. New
subtypes of `AbstractAxis` may implement a unique `combine_keys` method if 
needed. Default behavior is to use the return of `promote_rule(x, y)` for the
type of the combined keys. 
"""
combine_keys(::Nothing, y) = y
combine_keys(x, ::Nothing) = x
# TODO gracefully error
combine_keys(x::X, y::Y) where {X,Y} = combine_keys(promote_keys_rule(X, Y), x, y)
combine_keys(::Type{T}, x, y) where {T} = convert(T, x)
function combine_keys(::Type{Union{}}, x::X, y::Y) where {X,Y}
    error("No method available for combining keys of type $X and $Y.")
end

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

