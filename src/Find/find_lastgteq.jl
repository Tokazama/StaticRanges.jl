
"""
    find_lastgteq(val, collection)

Return the last index of `collection` where the element is greater than or equal
to `val`. If no element of `collection` is greater than or equal to `val`, `nothing`
is returned.
"""
function find_lastgteq end

@inline function find_lastgteq(x, r::AbstractUnitRange)
    if last(r) < x
        return nothing
    else
        return lastindex(r)
    end
end

function find_lastgteq(x, r::AbstractRange{T}) where {T}
    if isempty(r)
        return nothing
    elseif step(r) > zero(T)
        if last(r) < x
            return nothing
        else
            return lastindex(r)
        end
    else  # step(r) < zero(T)
        idx = unsafe_findvalue(x, r)
        if firstindex(r) > idx
            return nothing
        elseif lastindex(r) <= idx
            return lastindex(r)
        elseif @inbounds(r[idx]) >= x
            return idx
        else
            return idx - oneunit(idx)
        end
    end
end

function find_lastgteq(x, a)
    for (i, a_i) in Iterators.reverse(pairs(a))
        a_i >= x && return i
    end
    return nothing
end

