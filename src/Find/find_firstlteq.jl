
"""
    find_firstlteq(val, collection)

Return the first index of `collection` where the element is less than or equal to
`val`. If no element of `collection` is less than or equal to `val`, `nothing`
is returned.
"""
function find_firstlteq end


@inline function find_firstlteq(x, r::OneToUnion)
    if (r.stop == 0) | (1 > x)
        return nothing
    else
        return firstindex(r)
    end
end

@inline function find_firstlteq(x, r::AbstractUnitRange)
    if isempty(r) | (first(r) > x)
        return nothing
    else
        return firstindex(r)
    end
end

@inline function find_firstlteq(x, r::AbstractRange{T}) where {T}
    if isempty(r)
        return nothing
    elseif step(r) > zero(T)
        if first(r) > x
            return nothing
        else
            return firstindex(r)
        end
    else  # step(r) < zero(T)
        if first(r) <= x
            return firstindex(r)
        elseif last(r) > x
            return nothing
        else
            idx = unsafe_findvalue(x, r)
            if @inbounds(r[idx]) <= x
                return idx
            else
                return idx + oneunit(idx)
            end
        end
    end
end

function find_firstlteq(x, a)
    for (i, a_i) in pairs(a)
        a_i <= x && return i
    end
    return nothing
end

