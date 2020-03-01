
"UnorderedOrdering - Indicates that a collection's is not forward or reverse ordered."
struct UnorderedOrdering <: Ordering end
const Unordered = UnorderedOrdering()

"UnkownOrdering - Indicates that a collection's ordering is not known."
struct UnkownOrdering <: Ordering end
const UnkownOrder = UnkownOrdering()

"""
    is_forward(x) -> Bool

Returns `true` if `x` is sorted forward.

## Examples
```jldoctest
julia> using StaticRanges

julia> fr = 1:2:10
1:2:9

julia> rr = 10:-2:1
10:-2:2

julia> is_forward(fr)
true

julia> is_forward(rr)
false
```
"""
is_forward(x) = isempty(x) ? false : issorted(x)
is_forward(::ForwardOrdering) = true
is_forward(::Ordering) = false
is_forward(::AbstractUnitRange) = true
is_forward(x::AbstractRange) = step(x) > 0

"""
    is_reverse(x) -> Bool

Returns `true` if `x` is sorted in reverse.

## Examples
```jldoctest
julia> using StaticRanges

julia> fr = 1:2:10
1:2:9

julia> rr = 10:-2:1
10:-2:2

julia> is_reverse(fr)
false

julia> is_reverse(rr)
true
```
"""
is_reverse(x) = isempty(x) ? false : issorted(x, order=Reverse)
is_reverse(::ReverseOrdering) = true
is_reverse(::Ordering) = false
is_reverse(::AbstractUnitRange) = false
is_reverse(x::AbstractRange) = step(x) < 0

"""
    order(x) -> Ordering

Returns the ordering of `x`.
"""
order(x::T) where {T} = _order(order(T), x)
function _order(::UnkownOrdering, x)
    if is_reverse(x)
        return Reverse
    elseif is_forward(x)
        return Forward
    else
        return Unordered
    end
end
_order(xo::Ordering, x) = xo
order(::Type{T}) where {T} = UnkownOrder
order(::Type{T}) where {T<:AbstractUnitRange} = Forward

"""
    is_ordered(x) -> Bool

Returns `true` if `x` is ordered. `is_ordered` should return the same value that
`issorted` would on `x` except it doesn't specify how it's sorted (e.g.,
forward, reverse, etc).
"""
is_ordered(::Type{T}) where {T} = false
is_ordered(::Type{T}) where {T<:AbstractRange} = true
is_ordered(x::X) where {X} = is_ordered(X) ? true : is_forward(x) || is_reverse(x)
is_ordered(::ForwardOrdering) = true
is_ordered(::ReverseOrdering) = true
is_ordered(::UnorderedOrdering) = false


"""
    ordmax(x) = ordmax(x, order(x))
    ordmax(x::T, ::Ordering) -> T

Finds the maximum of `x` using information about its ordering.
"""
ordmax(x) = ordmax(x, order(x))
ordmax(x, ::ForwardOrdering) = last(x)
ordmax(x, ::ReverseOrdering) = first(x)
ordmax(x, ::UnorderedOrdering) = maximum(x)

"""
    ordmin(x) = ordmin(x, order(x))
    ordmin(x::T, ::Ordering) -> T

Finds the minimum of `x` using information about its ordering.
"""
ordmin(x) = ordmin(x, order(x))
ordmin(x, ::ForwardOrdering) = first(x)
ordmin(x, ::ReverseOrdering) = last(x)
ordmin(x, ::UnorderedOrdering) = minimum(x)

"""
    find_max(x)

Returns the index of the maximum value for `x`. Differes from `findmax` by
accounting for any sorting.
"""
find_max(x) = find_max(x, order(x))
find_max(x, ::ForwardOrdering) = (last(x), lastindex(x))
find_max(x, ::ReverseOrdering) = (first(x), firstindex(x))
find_max(x, ::UnorderedOrdering) = findmax(x)

"""
    find_min(x)

Returns the index of the minimum value for `x`. Differes from `findmin` by
accounting for any sorting.
"""
find_min(x) = find_min(x, order(x))
find_min(x, ::ForwardOrdering) = (first(x), firstindex(x))
find_min(x, ::ReverseOrdering) = (last(x), lastindex(x))
find_min(x, ::UnorderedOrdering) = findmin(x)

"""
    is_within(x, y) -> Bool

Returns `true` if all of `x` is found within `y`.
"""
is_within(x, y) = is_within(x, order(x), y, order(y))
is_within(x, xo, y, yo) = (ordmin(x, xo) >= ordmin(y, yo)) && (ordmax(x, xo) <= ordmax(y, yo))

"""
    gtmax(x, y) -> Bool

Returns `true` if the maximum of `x` is greater than that of `y`.
"""
gtmax(x, y) = gtmax(x, order(x), y, order(y))
gtmax(x, xo, y, yo) = ordmax(x, xo) > ordmax(y, yo)

"""
    ltmax(x, y) -> Bool

Returns `true` if the maximum of `x` is less than that of `y`.
"""
ltmax(x, y) = ltmax(x, order(x), y, order(y))
ltmax(x, xo, y, yo) = ordmax(x, xo) < ordmax(y, yo)

"""
    eqmax(x, y) -> Bool

Returns `true` if the maximum of `x` and `y` are equal.
"""
eqmax(x, y) = eqmax(x, order(x), y, order(y))
eqmax(x, xo, y, yo) = ordmax(x, xo) == ordmax(y, yo)


"""
    gtmin(x, y) -> Bool

Returns `true` if the minimum of `x` is greater than that of `y`.
"""
gtmin(x, y) = gtmin(x, order(x), y, order(y))
gtmin(x, xo, y, yo) = ordmin(x, xo) > ordmin(y, yo)

"""
    ltmin(x, y) -> Bool

Returns `true` if the minimum of `x` is less than that of `y`.
"""
ltmin(x, y) = ltmin(x, order(x), y, order(y))
ltmin(x, xo, y, yo) = ordmin(x, xo) < ordmin(y, yo)

"""
    eqmin(x, y) -> Bool

Returns `true` if the minimum of `x` and `y` are equal.
"""
eqmin(x, y) = eqmin(x, order(x), y, order(y))
eqmin(x, xo, y, yo) = ordmin(x, xo) == ordmin(y, yo)

"""
    group_max(x, y[, z...])

Returns the maximum value of all collctions.
"""
group_max(x, y, z...) = max(group_max(x, y), group_max(z...))
group_max(x) = ordmax(x)
group_max(x, y) = _group_max(x, order(x), y, order(y))
_group_max(x, xo, y, yo) = max(ordmax(x, xo), ordmax(y, yo))

"""
    group_min(x, y[, z...])

Returns the minimum value of all collctions.
"""
group_min(x, y, z...) = min(group_min(x, y), group_min(z...))
group_min(x) = ordmin(x)
group_min(x, y) = _group_min(x, order(x), y, order(y))
_group_min(x, xo, y, yo) = min(ordmin(x, xo), ordmin(y, yo))

"""
    cmpmax(x, y)
"""
cmpmax(x, y) = cmpmax(x, order(x), y, order(y))
cmpmax(x, xo, y, yo) = ltmax(x, xo, y, yo) ? -1 : (gtmax(x, xo, y, yo) ? 1 : 0)

"""
    cmpmin(x, y)
"""
cmpmin(x, y) = cmpmin(x, order(x), y, order(y))
cmpmin(x, xo, y, yo) = ltmin(x, xo, y, yo) ? -1 : (gtmin(x, xo, y, yo) ? 1 : 0)

"""
    min_of_group_max(x, y)

Returns the minimum of maximum of `x` and `y`. Functionally equivalent to
`min(maximum(x), maximum(y))` but uses trait information about ordering for
improved performance.
"""
min_of_group_max(x, y) = min_of_group_max(x, order(x), y, order(y))
min_of_group_max(x, xo, y, yo) = min(ordmax(x, xo), ordmax(y, yo))

"""
    max_of_group_min(x, y)

Returns the maximum of minimum of `x` and `y`. Functionally equivalent to
`max(minimum(x), minimum(y))` but uses trait information about ordering for
improved performance.
"""
max_of_group_min(x, y) = max_of_group_min(x, order(x), y, order(y))
max_of_group_min(x, xo, y, yo) = max(ordmin(x, xo), ordmin(y, yo))

"""
    is_before(x::T, y::T, collection::AbstractVector{T}) -> Bool

Returns `true` if `x` is before `y` in `collection`.
"""
function is_before(x, y, collection)
    find_first(isequal(x), collection) < find_first(isequal(y), collection)
end

"""
    is_before(x::AbstractVector{T}, y::AbstractVector{T}) -> is_before(order(x), order(y), x, y)
    is_before(::Ordering, ::Ordering, x, y) -> Bool

Returns `true` if all elements in `x` are before all elements in `y`. Functionally
equivalent to `all(x .< y)`.

## Examples
```jldoctest
julia> using StaticRanges

julia> r1 = 1:5
1:5

julia> r2 = 6:10
6:10

julia> is_before(r2, r1)
false

julia> is_before(r1, r2)
true
```
"""
is_before(x, y) = is_before(x, order(x), y, order(y))
is_before(x, xo, y, yo) = ordmax(x, xo) < ordmin(y, yo)

"""
    is_after(x::T, y::T, collection::AbstractVector{T}) -> Bool

Returns `true` if `x` is after `y` in `collection`.
"""
function is_after(x, y, collection)
    find_first(isequal(x), collection) > find_first(isequal(y), collection)
end

"""
    is_after(x::AbstractVector{T}, y::AbstractVector{T}) -> is_after(order(x), order(y), x, y)
    is_after(::Ordering, ::Ordering, x, y) -> Bool

Returns `true` if all elements in `x` are after all elements in `y`. Functionally
equivalent to `all(x .> y)`.

## Examples
```jldoctest
julia> using StaticRanges

julia> r1 = 1:5
1:5

julia> r2 = 6:10
6:10

julia> is_after(r2, r1)
true

julia> is_after(r1, r2)
false
```
"""
is_after(x, y) = is_after(x, order(x), y, order(y))
is_after(x, xo, y, yo) = ordmin(x, xo) > ordmax(y, yo)

"""
    is_contiguous(x, y) = is_contiguous(order(x), order(y), x, y)
    is_contiguous(::Ordering, ::Ordering, x, y) -> Bool

Returns `true` if one of the ends of `x` may be extended by a single overlapping
end of `y`.

# Example
```jldoctest
julia> using StaticRanges

julia> is_contiguous(1:3, 3:4)
true

julia> is_contiguous(3:-1:1, 3:4)
true

julia> is_contiguous(3:-1:1, 4:-1:3)
true

julia> is_contiguous(1:3, 4:-1:3)
true

julia> is_contiguous(1:3, 2:4)
false
```
"""
is_contiguous(x, y) = is_contiguous(x, order(x), y, order(y))
function is_contiguous(x, ::ForwardOrdering, y, yo)
    return last(x) == ordmin(y, yo) || first(x) == ordmax(y, yo)
end
function is_contiguous(x, ::ReverseOrdering, y, yo)
    return last(x) == ordmax(y, yo) || first(x) == ordmin(y, yo)
end

