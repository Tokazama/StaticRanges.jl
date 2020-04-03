
@inline function find_firstlteq(x, r::AbstractUnitRange)
    @boundscheck if first(r) > x
        return nothing
    end
    return firstindex(r)
end

@inline function find_firstlteq(x, r::AbstractRange{T}) where {T}
    if step(r) > zero(T)
        @boundscheck if first(r) > x
            return nothing
        end
        return firstindex(r)
    elseif step(r) < zero(T)
        idx = unsafe_findvalue(x, r)
        @boundscheck if (lastindex(r) < idx)
            return nothing
        end
        if firstindex(r) >= idx
            return firstindex(r)
        elseif @inbounds(r[idx]) <= x
            return idx
        else
            return idx - oneunit(idx)
        end
    else  # isempty(r)
        return nothing
    end
end

function find_firstlteq(x, a)
    for (i, a_i) in pairs(a)
        a_i <= x && return i
    end
    return nothing
end

