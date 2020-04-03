
@inline function find_lastgt(x, r::AbstractUnitRange)
    if isempty(r) | (last(r) <= x)
        return nothing
    else
        return lastindex(r)
    end
end

@inline function find_lastgt(x, r::AbstractRange{T}) where {T}
    if step(r) > zero(T)
        if last(r) <= x
            return nothing
        else
            return lastindex(r)
        end
    elseif step(r) < zero(T)
        if first(r) <= x
            return nothing
        elseif last(r) > x
            return lastindex(r)
        else
            idx = unsafe_findvalue(x, r)
            if (@inbounds(r[idx]) == x) & (idx != firstindex(r))
                return idx - oneunit(idx)
            else
                return idx
            end
        end
        
    else
        return nothing
    end
end

@inline function find_lastgt(x, a)
    for (i, a_i) in Iterators.reverse(pairs(a))
        x > a_i && return i
    end
    return nothing
end

