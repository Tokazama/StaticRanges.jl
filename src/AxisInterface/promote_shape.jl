function Base.promote_shape(a::Tuple{Vararg{Union{AbstractUnitRange,<:AbstractAxis}}}, b)
    return _promote_shape(a, b)
end
function Base.promote_shape(a, b::Tuple{Vararg{Union{AbstractUnitRange,<:AbstractAxis}}})
    return _promote_shape(a, b)
end
function Base.promote_shape(
    a::Tuple{Vararg{Union{AbstractUnitRange,<:AbstractAxis}}},
    b::Tuple{Vararg{Union{AbstractUnitRange,<:AbstractAxis}}}
   )
    return _promote_shape(a, b)
end

function _promote_shape(a, b)
    if length(a) < length(b)
        return promote_shape(b, a)
    end
    for i=1:length(b)
        if a[i] != b[i]
            throw(DimensionMismatch("dimensions must match"))
        end
    end
    for i=length(b)+1:length(a)
        if a[i] != 1:1
            throw(DimensionMismatch("dimensions must match"))
        end
    end
    return a
end
