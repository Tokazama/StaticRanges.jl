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

unsafe_findfirst(f, a::AbstractArray, ::ReverseOrdering) = searchsortedfirst(f.x, a, Reverse)
unsafe_findfirst(f, a::AbstractArray, ::ForwardOrdering) = searchsortedfirst(f.x, a, Forward)
function findfirst(f, a::AbstractArray, ro::Ordering)
    for (i, a_i) in pairs(a)
        f(a_i) && return i
    end
    return nothing
end

@propagate_inbounds find_first(f, x) = find_first(f, x, order(x))

# ==, isequal
function find_first(f::Fix2{<:Union{typeof(==),typeof(isequal)}}, r, ro::Ordering)
    if isempty(r)
        return nothing
    else
        idx = unsafe_findfirst(f.x, r, ro)
        @boundscheck if (firstindex(r) > idx || idx > lastindex(r)) || @inbounds(!f(r[idx]))
            return nothing
        end
        return idx
    end
end

# <, isless
function find_first(f::Fix2{<:Union{typeof(<),typeof(isless)}}, r, ::ForwardOrdering)
    @boundscheck if first(r) < f.x
        return firstindex(r)
    end
    return nothing
end
function find_first(f::Fix2{<:Union{typeof(<),typeof(isless)}}, r, ro::ReverseOrdering)
    idx = unsafe_findfirst(f.x, r, ro)
    @boundscheck if firstindex(r) > idx
        return 1
    end
    @boundscheck if lastindex(r) < idx
        return nothing
    end
    return f(@inbounds(r[idx])) ? idx : ((idx != lastindex(r)) ? idx + 1 : nothing)
end
find_first(f::Fix2{<:Union{typeof(<),typeof(isless)}}, r::AbstractRange, ::UnorderedOrdering) = nothing
function find_first(f::Fix2{<:Union{typeof(<),typeof(isless)}}, r::AbstractArray, ro::UnorderedOrdering)
    return unsafe_findfirst(f, r, ro)
end

# <=
function find_first(f::Fix2{typeof(<=)}, r, ::ForwardOrdering)
    @boundscheck if first(r) <= f.x
        return firstindex(r)
    end
    return nothing
end
function find_first(f::Fix2{typeof(<=)}, r, ro::ReverseOrdering)
    idx = unsafe_findfirst(f.x, r, ro)
    @boundscheck if lastindex(r) < idx
        return nothing
    end
    @boundscheck if firstindex(r) >= idx
        return 1
    end
    return @inbounds(f(r[idx])) ? idx : return idx - 1
end
find_first(f::Fix2{typeof(<=)}, r::AbstractRange, ::UnorderedOrdering) = nothing

function find_first(f::Fix2{typeof(<=)}, r::AbstractArray, ro::UnorderedOrdering)
    return unsafe_findfirst(f, r, ro)
end


# >
function find_first(f::Fix2{typeof(>)}, r, ro::ForwardOrdering)
    idx = unsafe_findfirst(f.x, r, ro)
    @boundscheck if lastindex(r) < idx
        return nothing
    end
    @boundscheck if firstindex(r) > idx
        return 1
    end
    return f(@inbounds(r[idx])) ? idx : (idx != lastindex(r) ? idx + 1 : nothing)
end
function find_first(f::Fix2{typeof(>)}, r, ::ReverseOrdering)
    @boundscheck if first(r) > f.x
        return firstindex(r)
    end
    return nothing
end
find_first(f::Fix2{typeof(>)}, r::AbstractRange, ::UnorderedOrdering) = nothing
function find_first(f::Fix2{typeof(>)}, r::AbstractArray, ro::UnorderedOrdering)
    return unsafe_findfirst(f, r, ro)
end

# >=
function find_first(f::Fix2{typeof(>=)}, r, ro::ForwardOrdering)
    idx = unsafe_findfirst(f.x, r, ro)
    @boundscheck if lastindex(r) < idx
        return nothing
    end
    @boundscheck if firstindex(r) > idx
        return 1
    end
    return f(@inbounds(r[idx])) ? idx : idx + 1
end
function find_first(f::Fix2{typeof(>=)}, r, ::ReverseOrdering)
    @boundscheck if first(r) >= f.x
        return firstindex(r)
    end
    return nothing
end
find_first(f::Fix2{typeof(>=)}, r::AbstractRange, ::UnorderedOrdering) = nothing
function find_first(f::Fix2{typeof(>=)}, r::AbstractArray, ro::UnorderedOrdering)
    return unsafe_findfirst(f, r, ro)
end

