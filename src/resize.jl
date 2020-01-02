"""
    next_type(x::T)

Returns the immediately greater value of type `T`.
"""
function next_type(x::AbstractString)
    isempty(x) && return ""
    return x[1:prevind(x, lastindex(x))] * (last(x) + 1)
end
next_type(x::Symbol) = Symbol(next_type(string(x)))
next_type(x::AbstractChar) = x + 1
next_type(x::T) where {T<:AbstractFloat} = nextfloat(x)
next_type(x::T) where {T} = x + one(T)

"""
    prev_type(x::T)

Returns the immediately lesser value of type `T`.
"""
function prev_type(x::AbstractString)
    isempty(x) && return ""
    return x[1:prevind(x, lastindex(x))] * (last(x) - 1)
end
prev_type(x::Symbol) = Symbol(prev_type(string(x)))
prev_type(x::AbstractChar) = x - 1
prev_type(x::T) where {T<:AbstractFloat} = prevfloat(x)
prev_type(x::T) where {T} = x - one(T)

### TODO: all documentation below this
"""
    resize_first!(x, n::Integer)

Returns the collection `x` after growing or shrinking the first index to be of size `n`.
"""
function resize_first!(x, n::Integer)
    d = n - length(x)
    if d > 0
        return grow_first!(x, d)
    elseif d < 0
        return shrink_first!(x, abs(d))
    else  # d == 0
        return x
    end
end

"""
    resize_last!(x, n::Integer)

Returns the collection `x` after growing or shrinking the last index to be of size `n`.
"""
function resize_last!(x, n::Integer)
    d = n - length(x)
    if d > 0
        return grow_last!(x, d)
    elseif d < 0
        return shrink_last!(x, abs(d))
    else  # d == 0
        return x
    end
end

"""
    resize_first(x, n::Integer)

Returns a collection similar to `x` that grows or shrinks from the first index
to be of size `n`.
"""
function resize_first(x, n::Integer)
    d = n - length(x)
    if d > 0
        return grow_first(x, d)
    elseif d < 0
        return shrink_first(x, abs(d))
    else  # d == 0
        return copy(x)
    end
end

"""
    resize_last(x, n::Integer)

Returns a collection similar to `x` that grows or shrinks from the last index
to be of size `n`.
"""
function resize_last(x, n::Integer)
    d = n - length(x)
    if d > 0
        return grow_last(x, d)
    elseif d < 0
        return shrink_last(x, abs(d))
    else  # d == 0
        return copy(x)
    end
end

# Note that all `grow_*`/`shrink_*` functions ignore the possibility that `d` is
# negative. Although these are documented, they should probably be considered
# unsafe and only used internally.
"""
    grow_first!(x, n)

Returns the collection `x` after growing from the first index by `n` elements.
"""
function grow_first!(x::AbstractVector, n::Integer)
    i = first(x)
    return prepend!(x, reverse!([i = prev_type(i) for _ in 1:n]))
end
grow_first!(x::AbstractRange, n::Integer) = set_first!(x, first(x) - step(x) * n)

"""
    grow_last!(x, n)

Returns the collection `x` after growing from the last index by `n` elements.
"""
function grow_last!(x::AbstractVector, n::Integer)
    i = first(x)
    return append!(x, [i = next_type(i) for _ in 1:n])
end
grow_last!(x::AbstractRange, n::Integer) = set_last!(x, last(x) + step(x) * n)

"""
    grow_first(x, n)

Returns a collection similar to `x` that grows by `n` elements from the first index.
"""
function grow_first(x::AbstractVector, n::Integer)
    i = first(x)
    return prepend(x, reverse!([i = prev_type(i) for _ in 1:n]))
end
grow_first(x::AbstractRange, n::Integer) = set_first(x, first(x) - step(x) * n)

"""
    grow_first(x, n)

Returns a collection similar to `x` that grows by `n` elements from the last index.
"""
function grow_last(x::AbstractVector, n::Integer)
    i = first(x)
    return append(x, [i = next_type(i) for _ in 1:n])
end
grow_last(x::AbstractRange, n::Integer) = set_last(x, last(x) + step(x) * n)

"""
    shrink_first!(x, n)

Returns the collection `x` after shrinking from the first index by `n` elements.
"""
function shrink_first!(x::AbstractVector, n::Integer)
    for _ in 1:n
        popfirst!(x)
    end
    return x
end
shrink_first!(x::AbstractRange, n::Integer) = set_first!(x, first(x) + step(x) * n)

"""
    shrink_last!(x, n)

Returns the collection `x` after shrinking from the last index by `n` elements.
"""
function shrink_last!(x::AbstractVector, n::Integer)
    for _ in 1:n
        pop!(x)
    end
    return x
end
shrink_last!(x::AbstractRange, n::Integer) = set_last!(x, last(x) - step(x) * n)

"""
    shrink_first(x, n)

Returns a collection similar to `x` that shrinks by `n` elements from the first index.
"""
@propagate_inbounds shrink_first(x::AbstractVector, n::Integer) = x[(firstindex(x) - n):end]
shrink_first(x::AbstractRange, n::Integer) = set_first(x, first(x) + step(x) * n)

"""
    shrink_last(x, n)

Returns a collection similar to `x` that shrinks by `n` elements from the last index.
"""
@propagate_inbounds shrink_last(x::AbstractVector, n::Integer) = x[firstindex(x):end - n]
shrink_last(x::AbstractRange, n::Integer) = set_last(x, last(x) - step(x) * n)
