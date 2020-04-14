
"""
    find_firstlt(val, collection)

Return the first index of `collection` where the element is less than `val`.
If no element of `collection` is less than `val`, `nothing` is returned.
"""
function find_firstlt end

@inline function find_firstlt(x, r::AbstractUnitRange)
    if (first(r) >= x) | isempty(r)
        return nothing
    else
        return firstindex(r)
    end
end

@inline function find_firstlt(x, r::AbstractRange{T}) where {T}
    if isempty(r)
        return nothing
    elseif step(r) > zero(T)
        if first(r) >= x
            return nothing
        else
            return firstindex(r)
        end
    else  # step(r) < zero(T)
        idx = unsafe_findvalue(x, r)
        if lastindex(r) <= idx
            return nothing
        elseif firstindex(r) > idx
            return firstindex(r)
        elseif @inbounds(r[idx]) < x
            return idx
        else
            return idx + oneunit(idx)
        end
    end
end

function find_firstlt(x, a)
    for (i, a_i) in pairs(a)
        a_i < x && return i
    end
    return nothing
end
