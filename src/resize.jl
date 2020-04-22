

function nprev_type(x::T, n) where {T}
    return [x = prev_type(x) for _ in 1:n]::Vector{T}
end
function nnext_type(x::T, n) where {T}
    return [x = next_type(x) for _ in 1:n]::Vector{T}
end

"""
    next_type(x::T)

Returns the immediately greater value of type `T`.

## Examples
```jldoctest
julia> using StaticRanges

julia> StaticRanges.next_type("b")
"c"

julia> StaticRanges.next_type(:b)
:c

julia> StaticRanges.next_type('a')
'b': ASCII/Unicode U+0062 (category Ll: Letter, lowercase)

julia> StaticRanges.next_type(1)
2

julia> StaticRanges.next_type(2.0)
2.0000000000000004

julia> StaticRanges.next_type("")
""
```
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

## Examples
```jldoctest
julia> using StaticRanges

julia> StaticRanges.prev_type("b")
"a"

julia> StaticRanges.prev_type(:b)
:a

julia> StaticRanges.prev_type('b')
'a': ASCII/Unicode U+0061 (category Ll: Letter, lowercase)

julia> StaticRanges.prev_type(1)
0

julia> StaticRanges.prev_type(1.0)
0.9999999999999999

julia> StaticRanges.prev_type("")
""
```
"""
function prev_type(x::AbstractString)
    isempty(x) && return ""
    return x[1:prevind(x, lastindex(x))] * (last(x) - 1)
end
prev_type(x::Symbol) = Symbol(prev_type(string(x)))
prev_type(x::AbstractChar) = x - 1
prev_type(x::T) where {T<:AbstractFloat} = prevfloat(x)
prev_type(x::T) where {T} = x - one(T)
"""
    grow_last(x, n)

Returns a collection similar to `x` that grows by `n` elements from the last index.

## Examples
```jldoctest
julia> using StaticRanges

julia> mr = UnitMRange(1, 10)
UnitMRange(1:10)

julia> StaticRanges.grow_last(mr, 2)
UnitMRange(1:12)
```
"""
@inline function grow_last(x::AbstractVector, n::Integer)
    i = last(x)

    return vcat(x, nnext_type(i, n))
end
grow_last(x::AbstractRange, n::Integer) = set_last(x, last(x) + step(x) * n)

"""
    grow_last!(x, n)

Returns the collection `x` after growing from the last index by `n` elements.

## Examples
```jldoctest
julia> using StaticRanges

julia> mr = UnitMRange(1, 10)
UnitMRange(1:10)

julia> StaticRanges.grow_last!(mr, 2);

julia> mr
UnitMRange(1:12)
```
"""
function grow_last!(x::AbstractVector, n::Integer)
    i = last(x)
    return append!(x, nnext_type(i, n))
end
grow_last!(x::AbstractRange, n::Integer) = set_last!(x, last(x) + step(x) * n)
"""
    grow_first(x, n)

Returns a collection similar to `x` that grows by `n` elements from the first index.

## Examples
```jldoctest
julia> using StaticRanges

julia> mr = UnitMRange(1, 10)
UnitMRange(1:10)

julia> StaticRanges.grow_first(mr, 2)
UnitMRange(-1:10)
```
"""
function grow_first(x::AbstractVector, n::Integer)
    i = first(x)
    return vcat(reverse!(nprev_type(i, n)), x)
end
grow_first(x::AbstractRange, n::Integer) = set_first(x, first(x) - step(x) * n)

"""
    grow_first!(x, n)

Returns the collection `x` after growing from the first index by `n` elements.

## Examples
```jldoctest
julia> using StaticRanges

julia> mr = UnitMRange(1, 10)
UnitMRange(1:10)

julia> StaticRanges.grow_first!(mr, 2);

julia> mr
UnitMRange(-1:10)
```
"""
function grow_first!(x::AbstractVector, n::Integer)
    i = first(x)
    return prepend!(x, reverse!(nprev_type(i, n)))
end
grow_first!(x::AbstractRange, n::Integer) = set_first!(x, first(x) - step(x) * n)

"""
    shrink_last!(x, n)

Returns the collection `x` after shrinking from the last index by `n` elements.

## Examples
```jldoctest
julia> using StaticRanges

julia> mr = UnitMRange(1, 10)
UnitMRange(1:10)

julia> StaticRanges.shrink_last!(mr, 2);

julia> mr
UnitMRange(1:8)
```
"""
function shrink_last!(x::AbstractVector, n::Integer)
    for _ in 1:n
        pop!(x)
    end
    return x
end
shrink_last!(x::AbstractRange, n::Integer) = set_last!(x, last(x) - step(x) * n)

"""
    shrink_last(x, n)

Returns a collection similar to `x` that shrinks by `n` elements from the last index.

## Examples
```jldoctest
julia> using StaticRanges

julia> mr = UnitMRange(1, 10)
UnitMRange(1:10)

julia> StaticRanges.shrink_last(mr, 2)
UnitMRange(1:8)
```
"""
@propagate_inbounds shrink_last(x::AbstractVector, n::Integer) = x[firstindex(x):end - n]
shrink_last(x::AbstractRange, n::Integer) = set_last(x, last(x) - step(x) * n)

"""
    shrink_first(x, n)

Returns a collection similar to `x` that shrinks by `n` elements from the first index.

## Examples
```jldoctest
julia> using StaticRanges

julia> mr = UnitMRange(1, 10)
UnitMRange(1:10)

julia> StaticRanges.shrink_first(mr, 2)
UnitMRange(3:10)
```
"""
@propagate_inbounds shrink_first(x::AbstractVector, n::Integer) = x[(firstindex(x) + n):end]
shrink_first(x::AbstractRange, n::Integer) = set_first(x, first(x) + step(x) * n)
shrink_first(x::OneTo{T}, n::Integer) where {T} = UnitRange{T}(1 + n, last(x))
shrink_first(x::OneToMRange{T}, n::Integer) where {T} = UnitMRange{T}(1 + n, last(x))
shrink_first(x::OneToSRange{T}, n::Integer) where {T} = UnitSRange{T}(1 + n, last(x))

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
    resize_last(x, n::Integer)

Returns a collection similar to `x` that grows or shrinks from the last index
to be of size `n`.

## Examples

```jldoctest
julia> using StaticRanges

julia> x = collect(1:5);

julia> StaticRanges.resize_last(x, 2)
2-element Array{Int64,1}:
 1
 2

julia> StaticRanges.resize_last(x, 7)
7-element Array{Int64,1}:
 1
 2
 3
 4
 5
 6
 7

julia>  StaticRanges.resize_last(x, 5)
5-element Array{Int64,1}:
 1
 2
 3
 4
 5

```
"""
@inline function resize_last(x, n::Integer)
    d = n - length(x)
    if d > 0
        return grow_last(x, d)
    elseif d < 0
        return shrink_last(x, abs(d))
    else  # d == 0
        return x
    end
end

"""
    resize_last!(x, n::Integer)

Returns the collection `x` after growing or shrinking the last index to be of size `n`.

## Examples

```jldoctest
julia> using StaticRanges

julia> x = collect(1:5);

julia> StaticRanges.resize_last!(x, 2);

julia> x
2-element Array{Int64,1}:
 1
 2

julia> StaticRanges.resize_last!(x, 5);

julia> x
5-element Array{Int64,1}:
 1
 2
 3
 4
 5

```
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

## Examples

```jldoctest
julia> using StaticRanges

julia> x = collect(1:5);

julia> StaticRanges.resize_first(x, 2)
2-element Array{Int64,1}:
 4
 5

julia> StaticRanges.resize_first(x, 7)
7-element Array{Int64,1}:
 -1
  0
  1
  2
  3
  4
  5

julia> StaticRanges.resize_first(x, 5)
5-element Array{Int64,1}:
 1
 2
 3
 4
 5
```
"""
@inline function resize_first(x, n::Integer)
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
    resize_first!(x, n::Integer)

Returns the collection `x` after growing or shrinking the first index to be of size `n`.

## Examples

```jldoctest
julia> using StaticRanges

julia> x = collect(1:5);

julia> StaticRanges.resize_first!(x, 2);

julia> x
2-element Array{Int64,1}:
 4
 5

julia> StaticRanges.resize_first!(x, 6);

julia> x
6-element Array{Int64,1}:
 0
 1
 2
 3
 4
 5

julia> StaticRanges.resize_first!(x, 6) === x
true

```
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

