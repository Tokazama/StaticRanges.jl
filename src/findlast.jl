
function Base.findlast(f::Function, x::Union{OneToRange,StaticUnitRange,AbstractLinRange,AbstractStepRange,AbstractStepRangeLen})
    return find_last(f, x)
end

find_last(f, x) = find_last(f, x, order(x))

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
    if lastindex(r) < idx
        return lastindex(r)
    elseif firstindex(r) > idx
        return nothing
    elseif f(@inbounds(r[idx]))
        return idx
    elseif idx != firstindex(r)
        return idx - 1
    else
        return nothing
    end
end
find_last(f::Fix2{<:Union{typeof(<),typeof(isless)}}, r, ::ReverseOrdering) = last(r) < f.x ? lastindex(r) : nothing
find_last(f::Fix2{<:Union{typeof(<),typeof(isless)}}, r, ::UnorderedOrdering) = nothing

# <=
function find_last(f::Fix2{typeof(<=)}, r, ::ForwardOrdering)
    if f(last(r))
        return lastindex(r)
    elseif first(r) > f.x
        return nothing
    else
        idx = unsafe_findvalue(f.x, r)
        if f(@inbounds(r[idx]))
            return idx
        elseif idx != firstindex(r)
            return idx - 1
        end
    end
end
find_last(f::Fix2{typeof(<=)}, r, ::ReverseOrdering) = f(last(r)) ? lastindex(r) : nothing
find_last(f::Fix2{typeof(<=)}, r, ::UnorderedOrdering) = nothing

# >
find_last(f::Fix2{typeof(>)}, r, ::ForwardOrdering) = last(r) > f.x ? lastindex(r) : nothing
find_last(f::Fix2{typeof(>)}, r, ::UnorderedOrdering) = nothing
function find_last(f::Fix2{typeof(>)}, r, ::ReverseOrdering)
    if last(r) > f.x
        return lastindex(r)
    elseif first(r) < f.x
        return nothing
    else
        idx = unsafe_findvalue(f.x, r)
        if f(@inbounds(r[idx]))
            return idx
        elseif idx != firstindex(r)
            return idx - 1
        end
    end
end

# >=
find_last(f::Fix2{typeof(>=)}, r, ::ForwardOrdering) = last(r) >= f.x ? lastindex(r) : nothing
find_last(f::Fix2{typeof(>=)}, r, ::UnorderedOrdering) = nothing
function find_last(f::Fix2{typeof(>=)}, r, ::ReverseOrdering)
    if first(r) < f.x
        return nothing
    elseif last(r) > f.x 
        return lastindex(r)
    else
        idx = unsafe_findvalue(f.x, r)
        if f(@inbounds(r[idx]))
            return idx
        else
            return idx - 1
        end
    end
end
