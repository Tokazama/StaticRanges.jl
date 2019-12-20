@propagate_inbounds find_last(f, x) = find_last(f, x, order(x))

unsafe_findlast(f, r::AbstractRange, ::ForwardOrdering) = unsafe_findvalue(f.x, r)
unsafe_findlast(f, r::AbstractRange, ::ReverseOrdering) = unsafe_findvalue(f.x, r)

unsafe_findlast(f, a::AbstractArray, ::ReverseOrdering) = searchsortedlast(a, f.x, Reverse)
unsafe_findlast(f, a::AbstractArray, ::ForwardOrdering) = searchsortedlast(a, f.x, Forward)
function unsafe_findlast(f, a::AbstractArray, ro::Ordering)
    for (i, a_i) in Iterators.reverse(pairs(a))
        f(a_i) && return i
    end
    return nothing
end

# ==, isequal
function find_last(f::F2Eq, r, ro::Ordering)
    if isempty(r)
        return nothing
    else
        idx = unsafe_findlast(f, r, ro)
        @boundscheck if (firstindex(r) > idx || idx > lastindex(r)) || @inbounds(!f(r[idx]))
            return nothing
        end
        return idx
    end
end
# <, isless
function find_last(f::F2IsLess, r, ro::ForwardOrdering)
    idx = unsafe_findlast(f, r, ro)
    @boundscheck if lastindex(r) < idx
        return lastindex(r)
    end
    @boundscheck if firstindex(r) > idx
        return nothing
    end
    return f(@inbounds(r[idx])) ? idx : (idx != firstindex(r) ? idx - 1 : nothing)
end
function find_last(f::F2IsLess, r, ::ReverseOrdering)
    @boundscheck if last(r) < f.x
        return lastindex(r)
    end
    return nothing
end
find_last(f::F2IsLess, r::AbstractRange, ::UnorderedOrdering) = nothing
find_last(f::F2IsLess, r::AbstractArray, ro::UnorderedOrdering) = unsafe_findlast(f, r, ro)


# <=
function find_last(f::Fix2{typeof(<=)}, r, ro::ForwardOrdering)
    idx = unsafe_findlast(f, r, ro)
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
find_last(f::Fix2{typeof(<=)}, r::AbstractRange, ::UnorderedOrdering) = nothing

function find_last(f::Fix2{typeof(<=)}, r::AbstractArray, ro::UnorderedOrdering)
    return unsafe_findlast(f, r, ro)
end

# >
function find_last(f::Fix2{typeof(>)}, r, ::ForwardOrdering)
    @boundscheck if last(r) > f.x
        return lastindex(r)
    end
    return nothing
end
function find_last(f::Fix2{typeof(>)}, r, ro::ReverseOrdering)
    idx = unsafe_findlast(f, r, ro)
    @boundscheck if lastindex(r) < idx
        return lastindex(r)
    end
    @boundscheck if firstindex(r) > idx
        return nothing
    end
    return f(@inbounds(r[idx])) ? idx : (idx != firstindex(r) ? idx - 1 : nothing)
end
find_last(f::Fix2{typeof(>)}, r::AbstractRange, ::UnorderedOrdering) = nothing

function find_last(f::Fix2{typeof(>)}, r::AbstractArray, ro::UnorderedOrdering)
    return unsafe_findlast(f, r, ro)
end


# >=
function find_last(f::Fix2{typeof(>=)}, r, ::ForwardOrdering)
    @boundscheck if last(r) > f.x
        return lastindex(r)
    end
    return last(r) == f.x ? lastindex(r) : nothing
end

function find_last(f::Fix2{typeof(>=)}, r, ro::ReverseOrdering)
    idx = unsafe_findlast(f, r, ro)
    @boundscheck if lastindex(r) < idx
        return lastindex(r)
    end
    @boundscheck if firstindex(r) > idx
        return nothing
    end
    return f(@inbounds(r[idx])) ? idx : idx - 1
end
find_last(f::Fix2{typeof(>=)}, r::AbstractRange, ::UnorderedOrdering) = nothing

function find_last(f::Fix2{typeof(>=)}, r::AbstractArray, ro::UnorderedOrdering)
    return unsafe_findlast(f, r, ro)
end
