
"""
    find_firstgteq(val, collection)

Return the first index of `collection` where the element is greater than or equal
to `val`. If no element of `collection` is greater than or equal to `val`, `nothing`
is returned.
"""
function find_firstgteq(x, r::AbstractRange)
    if isempty(r)
        return nothing
    else
        return unsafe_find_firstgteq(x, r)
    end
end


###
### OneToUnion
###
@inline function unsafe_find_firstgteq(x::Integer, r::OneToUnion)
    if x > last(r)
        return nothing
    elseif x <= 1
        return 1
    else
        return x
    end
end

@inline function unsafe_find_firstgteq(x, r::OneToUnion)
    if x > last(r)
        return nothing
    elseif x <= 1
        return 1
    else
        return unsafe_findvalue(x, r, RoundUp)
    end
end

###
### AbstractUnitRange
###

function unsafe_find_firstgteq(x::Integer, r::AbstractUnitRange)
    if x > last(r)
        return nothing
    elseif x < first(r)
        return firstindex(r)
    else
        return unsafe_findvalue(x, r)
    end
end

function unsafe_find_firstgteq(x, r)
    if last(r) < x
        return nothing
    elseif first(r) > x
        return firstindex(r)
    else
        return unsafe_findvalue(x, r, RoundUp)
    end
end

###
### AbstractRange
###
@inline function unsafe_find_firstgteq(x, r::AbstractRange{T}) where {T}
    if step(r) > zero(T)
        if last(r) < x
            return nothing
        elseif first(r) >= x
            return firstindex(r)
        else
            idx = unsafe_findvalue(x, r, RoundUp)
            if @inbounds(r[idx]) >= x
                return idx
            else
                return idx + oneunit(idx)
            end
        end
    else  # step(r) < zero(T)
        if first(r) >= x
            return firstindex(r)
        else
            return nothing
        end
    end
end

function find_firstgteq(x, a)
    for (i, a_i) in pairs(a)
        a_i >= x && return i
    end
    return nothing
end

