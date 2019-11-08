# TODO: this should be in ArrayInterface
ArrayInterface.can_setindex(::Type{X}) where {X<:AbstractRange} = false

"""
    isstatic(x) -> Bool

Returns `true` if `x` is static.
"""
isstatic(::X) where {X} = isstatic(X)
isstatic(::Type{X}) where {X} = false
isstatic(::Type{X}) where {X<:SRange} = true

"""
    can_setfirst(x) -> Bool

Returns `true` if the first element of `x` can be set. If `x` is a range then
changing the first element will also change the length of `x`.
"""
can_setfirst(::X) where {X} = can_setfirst(X)
can_setfirst(::Type{X}) where {X} = can_setindex(X)
# TODO figure out how to make this possible
#can_setfirst(::Type{T}) where {T<:StepMRangeLen} = true
can_setfirst(::Type{T}) where {T<:LinMRange} = true
can_setfirst(::Type{T}) where {T<:StepMRange} = true
can_setfirst(::Type{T}) where {T<:UnitMRange} = true

"""
    setfirst!(x, val)

Set the first element of `x` to `val`.
"""
function setfirst!(x::AbstractVector{T}, val::T) where {T}
    can_setfirst(x) || throw(MethodError(setfirst!, (x, val)))
    setindex!(x, val, firstindex(x))
    return x
end
setfirst!(x::AbstractVector{T}, val) where {T} = setfirst!(x, convert(T, val))
setfirst!(r::LinMRange{T}, val::T) where {T} = (setfield!(r, :start, val); r)
setfirst!(r::StepMRange{T,S}, val::T) where {T,S} = (setfield!(r, :start, val); r)
setfirst!(r::UnitMRange{T}, val::T) where {T} = (setfield!(r, :start, val); r)

"""
    can_setlast(x) -> Bool

Returns `true` if the last element of `x` can be set. If `x` is a range then
changing the first element will also change the length of `x`.
"""
can_setlast(::X) where {X} = can_setlast(X)
can_setlast(::Type{X}) where {X} = can_setindex(X)
can_setlast(::Type{T}) where {T<:LinMRange} = true
can_setlast(::Type{T}) where {T<:StepMRange} = true
can_setlast(::Type{T}) where {T<:UnitMRange} = true
can_setlast(::Type{T}) where {T<:OneToMRange} = true

"""
    setlast!(x, val)

Set the last element of `x` to `val`.
"""
function setlast!(x::AbstractVector{T}, val::T) where {T}
    can_setlast(x) || throw(MethodError(setlast!, (x, val)))
    setindex!(x, val, lastindex(x))
    return x
end
setlast!(x::AbstractVector{T}, val) where {T} = setlast!(x, convert(T, val))
setlast!(r::LinMRange{T}, val::T) where {T} = (setfield!(r, :stop, val); r)
setlast!(r::StepMRange{T,S}, val::T) where {T,S} = (setfield!(r, :stop, val); r)
setlast!(r::UnitMRange{T}, val::T) where {T} = (setfield!(r, :stop, val); r)
setlast!(r::OneToMRange{T}, val::T) where {T} = (setfield!(r, :stop, val); r)


"""
    has_step(x) -> Bool

Returns `true` if type of `x` has `step` method defined.
"""
has_step(::X) where {X} = has_step(X)
has_step(::Type{T}) where {T} = false
has_step(::Type{T}) where {T<:AbstractRange} = true

"""
    can_setstep(x) -> Bool

Returns `true` if type of `x` has `step` field that can be set.
"""
can_setstep(::X) where {X} = can_setstep(X)
can_setstep(::Type{X}) where {X} = false
can_setstep(::Type{T}) where {T<:StepMRange} = true
can_setstep(::Type{T}) where {T<:StepMRangeLen} = true

"""
    setstep!(x, val)

Sets the `step` of `x` to `val`.
"""
setstep!(x::AbstractRange{T}, val) where {T} = setstep!(x, convert(T, val))
function setstep!(r::StepMRange{T,S}, val::S) where {T,S}
    setfield!(r, :step, val)
    setlast!(r, Base.steprange_last(first(r), val, last(r)))
    return r
end
setstep!(r::StepMRangeLen{T,R,S}, val::S) where {T,R,S} = (setfield!(r, :step, val); r)

"""
    can_setlength(x) -> Bool

Returns `true` if type of `x` can have its length set independent of changing
its first or last position.
"""
can_setlength(::T) where {T} = can_setlength(T)
can_setlength(::Type{T}) where {T} = false
can_setlength(::Type{T}) where {T<:LinMRange} = true
can_setlength(::Type{T}) where {T<:StepMRangeLen} = true

"""
    setlength!(x, len)

Change the length of `x` while maintaining it's first and last positions.
"""
setlength!(x::AbstractRange, val) = setlength!(x, Int(val))

function setlength!(r::LinMRange, len::Int)
    len >= 0 || throw(ArgumentError("setlength!($r, $len): negative length"))
    if len == 1
        r.start == r.stop || throw(ArgumentError("setlength!($r, $len): endpoints differ"))
        setfield!(r, :len, 1)
        setfield!(r, :lendiv, 1)
        return r
    end
    setfield!(r, :len, len)
    setfield!(r, :lendiv, max(len - 1, 1))
    return r
end

function setlength!(r::StepMRangeLen, len::Int)
    len >= 0 || throw(ArgumentError("length cannot be negative, got $len"))
    1 <= r.offset <= max(1,len) || throw(ArgumentError("StepMRangeLen: offset must be in [1,$len], got $offset"))
    setfield!(r, :len, len)
    return r
end

"""
    setref!(x)

Set the reference field of an instance of `StepMRangeLen`.
"""
setref!(r::StepMRangeLen{T,R,S}, val::R) where {T,R,S} = (setfield!(r, :ref, val); r)
setref!(r::StepMRangeLen{T,R,S}, val) where {T,R,S} = setref!(r, convert(R, val))

"""
    setoffset!(x)

Set the offset field of an instance of `StepMRangeLen`.
"""
function setoffset!(r::StepMRangeLen, val::Int)
    1 <= val <= max(1,r.len) || throw(ArgumentError("StepMRangeLen: offset must be in [1,$len], got $offset"))
    setfield!(r, :offset, val)
    return r
end
setoffset!(r::StepMRangeLen, val) = setoffset!(r, Int(val))

"UnorderedOrdering - Indicates that a collection's is not forward or reverse ordered."
struct UnorderedOrdering <: Ordering end
const Unordered = UnorderedOrdering()

"UnkownOrdering - Indicates that a collection's ordering is not known."
struct UnkownOrdering <: Ordering end
const UnkownOrder = UnkownOrdering()

"""
    isforward(x) -> Bool

Returns `true` if `x` is sorted forward.
"""
isforward(x) = issorted(x)
isforward(::ForwardOrdering) = true
isforward(::Ordering) = false
isforward(::AbstractUnitRange) = true
isforward(x::AbstractRange) = step(x) > 0

"""
    isreverse(x) -> Bool

Returns `true` if `x` is sorted in reverse.
"""
isreverse(x) = issorted(x, order=Reverse)
isreverse(::ReverseOrdering) = true
isreverse(::Ordering) = false
isreverse(::AbstractUnitRange) = false
isreverse(x::AbstractRange) = step(x) < 0

"""
    order(x) -> Ordering

Returns the ordering of `x`.
"""
order(x::T) where {T} = _order(order(T), x)
function _order(::UnkownOrdering, x)
    if isreverse(x)
        return Reverse
    elseif isforward(x)
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
forward, revers, etc).
"""
is_ordered(::Type{T}) where {T} = false
is_ordered(::Type{T}) where {T<:AbstractRange} = true
is_ordered(x::X) where {X} = is_ordered(X) ? true : isforward(x) || isreverse(x)

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
find_max(x, ::ForwardOrdering) = lastindex(x)
find_max(x, ::ReverseOrdering) = firstindex(x)
find_max(x, ::UnorderedOrdering) = findmax(x)

"""
    find_min(x)

Returns the index of the minimum value for `x`. Differes from `findmin` by
accounting for any sorting.
"""
find_min(x) = find_min(x, order(x))
find_min(x, ::ForwardOrdering) = firstindex(x)
find_min(x, ::ReverseOrdering) = lastindex(x)
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
    findfirst(isequal(x), collection) < findfirst(isequal(y), collection)
end

"""
    is_before(x::AbstractVector{T}, y::AbstractVector{T}) -> is_before(order(x), order(y), x, y)
    is_before(::Ordering, ::Ordering, x, y) -> Bool

Returns `true` if all elements in `x` are before all elements in `y`. Functionally
equivalent to `all(x .< y)`.
"""
is_before(x, y) = is_before(x, order(x), y, order(y))
is_before(x, xo, y, yo) = ordmax(x, xo) < ordmin(y, yo)

"""
    is_after(x::T, y::T, collection::AbstractVector{T}) -> Bool

Returns `true` if `x` is after `y` in `collection`.
"""
function is_after(x, y, collection)
    findfirst(isequal(x), collection) > findfirst(isequal(y), collection)
end

"""
    is_after(x::AbstractVector{T}, y::AbstractVector{T}) -> is_after(order(x), order(y), x, y)
    is_after(::Ordering, ::Ordering, x, y) -> Bool

Returns `true` if all elements in `x` are after all elements in `y`. Functionally
equivalent to `all(x .> y)`.
"""
is_after(x, y) = is_after(x, order(x), y, order(y))
is_after(x, xo, y, yo) = ordmin(x, xo) > ordmax(y, yo)

"""
    is_contiguous(x, y) = is_contiguous(order(x), order(y), x, y)
    is_contiguous(::Ordering, ::Ordering, x, y) -> Bool

Returns `true` if one of the ends of `x` may be extended by a single overlapping
end of `y`.

# Example
```
julia> is_contiguous(1:3, 3:4) == true

julia> is_contiguous(3:-1:1, 3:4) == true

julia> is_contiguous(3:-1:1, 4:-1:3) == true

julia> is_contiguous(1:3, 4:-1:3) == true

julia> is_contiguous(1:3, 2:4) == false
```
"""
is_contiguous(x, y) = is_contiguous(x, order(x), y, order(y))
function is_contiguous(x, ::ForwardOrdering, y, yo)
    return last(x) == ordmin(y, yo) || first(x) == ordmax(y, yo)
end
function is_contiguous(x, ::ReverseOrdering, y, yo)
    return last(x) == ordmax(y, yo) || first(x) == ordmin(y, yo)
end


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
