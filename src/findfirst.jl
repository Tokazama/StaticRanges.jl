
"""
    find_first(predicate::Function, A)

Return the index or key of the first element of A for which predicate returns
true. Return nothing if there is no such element.

Indices or keys are of the same type as those returned by keys(A) and pairs(A).

# Examples

```jldoctest
julia> A = [1, 4, 2, 2]
4-element Array{Int64,1}:
1
4
2
2

julia> find_first(iseven, A)
2

julia> find_first(x -> x>10, A) # returns nothing, but not printed in the REPL

julia> find_first(isequal(4), A)
2

julia> A = [1 4; 2 2]
2×2 Array{Int64,2}:
1  4
2  2

julia> find_first(iseven, A)
CartesianIndex(2, 1)
```
"""
find_first

unsafe_findfirst(val, r::AbstractRange, ::ForwardOrdering) = unsafe_findvalue(val, r)
unsafe_findfirst(val, r::AbstractRange, ::ReverseOrdering) = unsafe_findvalue(val, r)

unsafe_findfirst(val, a::LinearIndices, ::ReverseOrdering) = unsafe_findfirst(val, axes(a, 1), Reverse)
unsafe_findfirst(val, a::LinearIndices, ::ForwardOrdering) = unsafe_findfirst(val, axes(a, 1), Forward)

# FIXME: this needs an explicit method and not just a fallback
function unsafe_findfirst(val, a::AbstractArray, ::ReverseOrdering)
    return searchsortedfirst(a, val, Reverse)
end
function unsafe_findfirst(val, a::AbstractArray, ::ForwardOrdering)
    return searchsortedfirst(a, val, Forward)
end


@propagate_inbounds find_first(f, x) = find_first(f, x, order(x))

find_first(f::Fix2{<:Union{typeof(==),typeof(isequal)}}, a, o) = _find_first_eq(f.x, a, o)
find_first(f::Fix2{<:Union{typeof(<),typeof(isless)}}, a, o) = _find_first_lt(f.x, a, o)
find_first(f::Fix2{typeof(<=)}, a, o) = _find_first_lteq(f.x, a, o)
find_first(f::Fix2{typeof(>)}, a, o) = _find_first_gt(f.x, a, o)
find_first(f::Fix2{typeof(>=)}, a, o) = _find_first_gteq(f.x, a, o)
find_first(f, a, o) = _find_first(f, a, o)  # fall back

function _find_first(f, a, o)
    for (i, a_i) in pairs(a)
        f(a_i) && return i
    end
    return nothing
end

# ==, isequal
function _find_first_eq(x, r, ro::Ordering)
    if isempty(r)
        return nothing
    else
        idx = unsafe_findfirst(x, r, ro)
        @boundscheck if (firstindex(r) > idx || idx > lastindex(r)) || @inbounds(r[idx]) != x
            return nothing
        end
        return idx
    end
end
function _find_first_eq(x, r, ::UnorderedOrdering)
    return r isa AbstractRange ? nothing : unsafe_findfirst(x, r, ro)
end

# <, isless
function _find_first_lt(x, r, ::ForwardOrdering)
    @boundscheck if first(r) < x
        return firstindex(r)
    end
    return nothing
end
function _find_first_lt(x, r, ro::ReverseOrdering)
    idx = unsafe_findfirst(x, r, ro)
    @boundscheck if firstindex(r) > idx
        return 1
    end
    @boundscheck if lastindex(r) < idx
        return nothing
    end
    return @inbounds(r[idx]) < x ? idx : ((idx != lastindex(r)) ? idx + 1 : nothing)
end
function _find_first_lt(x, r, ::UnorderedOrdering)
    return r isa AbstractRange ? nothing : unsafe_findfirst(x, r, ro)
end

# <=
function _find_first_lteq(x, r, ::ForwardOrdering)
    @boundscheck if first(r) <= x
        return firstindex(r)
    end
    return nothing
end
function _find_first_lteq(x, r, ro::ReverseOrdering)
    idx = unsafe_findfirst(x, r, ro)
    @boundscheck if lastindex(r) < idx
        return nothing
    end
    @boundscheck if firstindex(r) >= idx
        return 1
    end
    return @inbounds(r[idx]) <= x ? idx : return idx - 1
end
function _find_first_lteq(x, r, ::UnorderedOrdering)
    return r isa AbstractRange ? nothing : unsafe_findfirst(x, r, ro)
end

# >
@propagate_inbounds function _find_first_gt(x, r, ro::ForwardOrdering)
    return __find_first_gt(x, r, unsafe_findfirst(x, r, ro))
end
__find_first_gt(x, r, ::Nothing) = nothing
function __find_first_gt(x, r, idx)
    @boundscheck if lastindex(r) < idx
        return nothing
    end
    @boundscheck if firstindex(r) > idx
        return 1
    end
    return @inbounds(r[idx]) > x ? idx : (idx != lastindex(r) ? idx + 1 : nothing)
end
function _find_first_gt(x, r, ::ReverseOrdering)
    @boundscheck if first(r) > x
        return firstindex(r)
    end
    return nothing
end
function _find_first_gt(x, r, ::UnorderedOrdering)
    return r isa AbstractRange ? nothing : unsafe_findfirst(x, r, ro)
end

# >=
@propagate_inbounds function _find_first_gteq(x, r, ro::ForwardOrdering)
    return __find_first_gteq(x, r, unsafe_findfirst(x, r, ro))
end
__find_first_gteq(x, r, ::Nothing) = nothing
function __find_first_gteq(x, r, idx)
    @boundscheck if lastindex(r) < idx
        return nothing
    end
    @boundscheck if firstindex(r) > idx
        return 1
    end
    return @inbounds(r[idx]) >= x ? idx : idx + 1
end
function _find_first_gteq(x, r, ::ReverseOrdering)
    @boundscheck if first(r) >= x
        return firstindex(r)
    end
    return nothing
end

function _find_first_gteq(x, r, ::UnorderedOrdering)
    return r isa AbstractRange ? nothing : unsafe_findfirst(x, r, ro)
end

