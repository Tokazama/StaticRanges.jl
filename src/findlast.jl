@propagate_inbounds find_last(f, x) = find_last(f, x, order(x))

function find_last(f::Fix2{<:Union{typeof(==),typeof(isequal)}}, r, ::Ordering)
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
function find_last(f::Fix2{<:Union{typeof(<),typeof(isless)}}, r, ::ForwardOrdering)
    idx = unsafe_findvalue(f.x, r)
    @boundscheck if lastindex(r) < idx
        return lastindex(r)
    end
    @boundscheck if firstindex(r) > idx
        return nothing
    end
    return f(@inbounds(r[idx])) ? idx : (idx != firstindex(r) ? idx - 1 : nothing)
end
function find_last(f::Fix2{<:Union{typeof(<),typeof(isless)}}, r, ::ReverseOrdering)
    @boundscheck if last(r) < f.x
        return lastindex(r)
    end
    return nothing
end
find_last(f::Fix2{<:Union{typeof(<),typeof(isless)}}, r, ::UnorderedOrdering) = nothing

# <=
function find_last(f::Fix2{typeof(<=)}, r, ::ForwardOrdering)
    idx = unsafe_findvalue(f.x, r)
    @boundscheck if lastindex(r) < idx
        return lastindex(r)
    end
    @boundscheck if firstindex(r) > idx
        return nothing
    end
    return f(@inbounds(r[idx])) ? idx : (idx != firstindex(r) ? idx - 1 : nothing)
end

function find_last(f::Fix2{typeof(<=)}, r, ::ReverseOrdering)
    @boundscheck if last(r) < f.x
        return lastindex(r)
    end
    return last(r) == f.x ? lastindex(r) : nothing
end
find_last(f::Fix2{typeof(<=)}, r, ::UnorderedOrdering) = nothing

# >
function find_last(f::Fix2{typeof(>)}, r, ::ForwardOrdering)
    @boundscheck if last(r) > f.x
        return lastindex(r)
    end
    return nothing
end
find_last(f::Fix2{typeof(>)}, r, ::UnorderedOrdering) = nothing
# TODO double check
function find_last(f::Fix2{typeof(>)}, r, ::ReverseOrdering)
    idx = unsafe_findvalue(f.x, r)
    @boundscheck if lastindex(r) < idx
        return lastindex(r)
    end
    @boundscheck if firstindex(r) > idx
        return nothing
    end
    return f(@inbounds(r[idx])) ? idx : (idx != firstindex(r) ? idx - 1 : nothing)
end

# >=
function find_last(f::Fix2{typeof(>=)}, r, ::ForwardOrdering)
    @boundscheck if last(r) > f.x
        return lastindex(r)
    end
    return last(r) == f.x ? lastindex(r) : nothing
end

find_last(f::Fix2{typeof(>=)}, r, ::UnorderedOrdering) = nothing
# TODO double check
function find_last(f::Fix2{typeof(>=)}, r, ::ReverseOrdering)
    idx = unsafe_findvalue(f.x, r)
    @boundscheck if lastindex(r) < idx
        return lastindex(r)
    end
    @boundscheck if firstindex(r) > idx
        return nothing
    end
    return f(@inbounds(r[idx])) ? idx : idx - 1
end
