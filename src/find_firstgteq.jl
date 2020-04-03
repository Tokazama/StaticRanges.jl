
find_firstgteq(x, r::AbstractUnitRange) = _find_firstgteq_unit(x, r)
function _find_firstgteq_unit(x::Integer, r)
    if x > last(r)
        return nothing
    elseif x < first(r)
        return firstindex(r)
    else
        return unsafe_findvalue(x, r)
    end
end

function _find_firstgteq_unit(x, r)
    if last(r) < x
        return nothing
    elseif first(r) > x
        return firstindex(r)
    else
        return _find_firstgteq_unit(round(Integer, x, RoundUp), r)
    end
end

@inline function find_firstgteq(x, r::AbstractRange{T}) where {T}
    if step(r) > zero(T)
        idx = unsafe_findvalue(x, r)
        if lastindex(r) < idx
            return nothing
        elseif firstindex(r) > idx
            return firstindex(r)
        elseif @inbounds(r[idx]) == x
            return idx
        else
            return idx + oneunit(idx)
        end
    elseif step(r) < zero(T)
        if first(r) >= x
            return firstindex(r)
        else
            return nothing
        end
    else  # isempty(r)
        return nothing
    end
end

function find_firstgteq(x, a)
    for (i, a_i) in pairs(a)
        x >= a_i && return i
    end
    return nothing
end

