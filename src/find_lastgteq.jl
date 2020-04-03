
@inline function find_lastgteq(x, r::AbstractUnitRange)
    if last(r) < x
        return nothing
    else
        return lastindex(r)
    end
end

function find_lastgteq(x, r::AbstractRange{T}) where {T}
    if step(r) > zero(T)
        if last(r) < x
            return nothing
        else
            return lastindex(r)
        end
    elseif step(r) < zero(T)
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
    else  # isempty(r)
        return nothing
    end
end

function find_lastgteq(x, a)
    for (i, a_i) in Iterators.reverse(pairs(a))
        a_i >= x && return i
    end
    return nothing
end

