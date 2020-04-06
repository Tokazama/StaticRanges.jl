
function find_lastlteq(x, r::AbstractUnitRange)
    if last(r) <= x
        return lastindex(r)
    elseif (first(r) > x) | isempty(r)
        return nothing
    else
        idx = unsafe_findvalue(x, r)
        if @inbounds(r[idx]) <= x
            return idx
        elseif idx != firstindex(r)
            return idx - oneunit(idx)
        else
            return nothing
        end
    end
end

function find_lastlteq(x, r::AbstractRange{T}) where {T}
    if isempty(r)
        return nothing
    elseif step(r) > zero(T)
        if last(r) <= x
            return lastindex(r)
        elseif first(r) > x
            return nothing
        else
            idx = unsafe_findvalue(x, r)
            if @inbounds(r[idx]) <= x
                return idx
            elseif idx != firstindex(r)
                return idx - oneunit(idx)
            else
                return nothing
            end
        end
    else  # step(r) < zero(T)
        if last(r) <= x
            return lastindex(r)
        else
            return nothing
        end
    end
end

function find_lastlteq(x, a)
    for (i, a_i) in Iterators.reverse(pairs(a))
        a_i <= x && return i
    end
    return nothing
end

