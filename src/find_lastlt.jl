
@inline function find_lastlt(x, r::AbstractUnitRange)
    idx = unsafe_findvalue(x, r)
    if firstindex(r) > idx
        return nothing
    elseif lastindex(r) < idx
        return lastindex(r)
    else
        if @inbounds(r[idx]) < x
            idx
        else
            if idx != firstindex(r)
                return idx - oneunit(idx)
            else
                return nothing
            end
        end
    end
end

@inline function find_lastlt(x, r::AbstractRange{T}) where {T}
    if isempty(r)
        return nothing
    elseif step(r) > zero(T)
        idx = unsafe_findvalue(x, r)
        if firstindex(r) > idx
            return nothing
        elseif lastindex(r) < idx
            return lastindex(r)
        else
            if @inbounds(r[idx]) < x
                idx
            else
                if idx != firstindex(r)
                    return idx - oneunit(idx)
                else
                    return nothing
                end
            end
        end
    else  # step(r) < zero(T)
        if last(r) >= x
            return nothing
        else
            return lastindex(r)
        end
    end
end

function find_lastlt(x, a)
    for (i, a_i) in Iterators.reverse(pairs(a))
        a_i < x && return i
    end
    return nothing
end

