"""
    find_first()

# Examples

```jldoctest

r = 10:-1:1

find_first(<(5), r)



```
"""
@propagate_inbounds find_first(f, x) = find_first(f, x, order(x))

# ==, isequal
function find_first(f::Fix2{<:Union{typeof(==),typeof(isequal)}}, r, ::Ordering)
    if isempty(r)
        return nothing
    else
        idx = unsafe_findvalue(f.x, r)
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
find_first(f::Fix2{<:Union{typeof(<),typeof(isless)}}, r, ::UnorderedOrdering) = nothing
function find_first(f::Fix2{<:Union{typeof(<),typeof(isless)}}, r, ::ReverseOrdering)
    idx = unsafe_findvalue(f.x, r)
    @boundscheck if firstindex(r) > idx
        return 1
    end
    @boundscheck if lastindex(r) < idx
        return nothing
    end
    return f(@inbounds(r[idx])) ? idx : ((idx != lastindex(r)) ? idx + 1 : nothing)
end

# <=
function find_first(f::Fix2{typeof(<=)}, r, ::ForwardOrdering)
    @boundscheck if first(r) <= f.x
        return firstindex(r)
    end
    return nothing
end
find_first(f::Fix2{typeof(<=)}, r, ::UnorderedOrdering) = nothing
function find_first(f::Fix2{typeof(<=)}, r, ::ReverseOrdering)
    idx = unsafe_findvalue(f.x, r)
    @boundscheck if lastindex(r) < idx
        return nothing
    end
    @boundscheck if firstindex(r) >= idx
        return 1
    end
    return @inbounds(f(r[idx])) ? idx : return idx - 1
end

# >
function find_first(f::Fix2{typeof(>)}, r, ::ForwardOrdering)
    idx = unsafe_findvalue(f.x, r)
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
find_first(f::Fix2{typeof(>)}, r, ::UnorderedOrdering) = nothing

# >=
function find_first(f::Fix2{typeof(>=)}, r, ::ForwardOrdering)
    idx = unsafe_findvalue(f.x, r)
    @boundscheck if lastindex(r) < idx
        return nothing
    end
    @boundscheck if firstindex(r) > idx
        return 1
    end
    return f(@inbounds(r[idx])) ? idx : idx + 1
end
find_first(f::Fix2{typeof(>=)}, r, ::ReverseOrdering) = first(r) >= f.x ? firstindex(r) : nothing
find_first(f::Fix2{typeof(>=)}, r, ::UnorderedOrdering) = nothing
