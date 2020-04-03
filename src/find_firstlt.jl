
@inline function find_firstlt(x, r::AbstractUnitRange)
    if first(r) >= x
        return nothing
    else
        return firstindex(r)
    end
end

@inline function find_firstlt(x, r::AbstractRange{T}) where {T}
    if step(r) > zero(T)
        if first(r) >= x
            return nothing
        else
            return firstindex(r)
        end
    elseif step(r) < zero(T)
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
    else
        return nothing
    end
end

function find_firstlt(x, a)
    for (i, a_i) in pairs(a)
        x < a_i && return i
    end
    return nothing
end

