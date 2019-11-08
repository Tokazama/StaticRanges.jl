function Base.findfirst(f::Function, r::Union{OneToRange,StaticUnitRange,AbstractLinRange,AbstractStepRange,AbstractStepRangeLen})
    return find_first(f, r)
end

find_first(f, x) = find_first(f, x, order(x))

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
find_first(f::Fix2{<:Union{typeof(<),typeof(isless)}}, r, ::ForwardOrdering) = first(r) < f.x ? firstindex(r) : nothing
find_first(f::Fix2{<:Union{typeof(<),typeof(isless)}}, r, ::UnorderedOrdering) = nothing
function find_first(f::Fix2{<:Union{typeof(<),typeof(isless)}}, r, ::ReverseOrdering)
    idx = unsafe_findvalue(f.x, r)
    if firstindex(r) > idx
        return 1
    elseif lastindex(r) < idx
        return nothing
    elseif f(@inbounds(r[idx]))
        return idx
    elseif idx != lastindex(r)
        return idx + 1
    else
        return nothing
    end
end

# <=
find_first(f::Fix2{typeof(<=)}, r, ::ForwardOrdering) = first(r) <= f.x ? firstindex(r) : nothing
find_first(f::Fix2{typeof(<=)}, r, ::UnorderedOrdering) = nothing
function find_first(f::Fix2{typeof(<=)}, r, ::ReverseOrdering)
    idx = unsafe_findvalue(f.x, r)
    if lastindex(r) < idx
        return nothing
    elseif firstindex(r) >= idx
        return 1
    elseif (@inbounds(f(r[idx])))
        return idx
    else 
        return idx - 1
    end
end

# >
function find_first(f::Fix2{typeof(>)}, r, ::ForwardOrdering)
    idx = unsafe_findvalue(f.x, r)
    if last(r) < f.x
        return nothing
    elseif first(r) > f.x
        return 1
    else
        if f(@inbounds(r[idx]))
            return idx
        elseif idx != lastindex(r)
            return idx + 1
        else
            return nothing
        end
    end
end
find_first(f::Fix2{typeof(>)}, r, ::ReverseOrdering) = first(r) > f.x ? firstindex(r) : nothing
find_first(f::Fix2{typeof(>)}, r, ::UnorderedOrdering) = nothing

# >=
function find_first(f::Fix2{typeof(>=)}, r, ::ForwardOrdering)
    idx = unsafe_findvalue(f.x, r)
    if last(r) < f.x
        return nothing
    elseif first(r) > f.x
        return firstindex(r)
    elseif f(@inbounds(r[idx]))
        return idx
    else
        return idx + 1
    end
end
find_first(f::Fix2{typeof(>=)}, r, ::ReverseOrdering) = first(r) >= f.x ? firstindex(r) : nothing
find_first(f::Fix2{typeof(>=)}, r, ::UnorderedOrdering) = nothing
