
"""
    find_firstgt(val, collection)

Return the first index of `collection` where the element is greater than `val`.
If no element of `collection` is greater than `val`, `nothing` is returned.
"""
function find_firstgt end


###
### OneToUnion
###
find_firstgt(x, r::OneToUnion) = _find_firstgt_oneto(x, r)

@inline function _find_firstgt_oneto(x::Integer, r)
    if (x >= last(r)) | (r.stop == 0)
        return nothing
    elseif x < 1
        return 1
    else
        return x + 1
    end
end

@inline function _find_firstgt_oneto(x, r)
    if (x >= last(r)) | (r.stop == 0)
        return nothing
    elseif x < 1
        return 1
    else
        return unsafe_findvalue(x, r) + 1
    end
end

###
### AbstractUnitRange
###
find_firstgt(x, r::AbstractUnitRange) = _find_firstgt_unit(x, r)

@inline function _find_firstgt_unit(x::Integer, r)
    if (x >= last(r)) | isempty(r)
        return nothing
    elseif x < first(r)
        return firstindex(r)
    else
        # b/c +1 get's to the value isequal and we want greater
        return (x - first(r)) + 2
    end
end

@inline function _find_firstgt_unit(x, r)
    if (last(r) <= x) | isempty(r)
        return nothing
    elseif first(r) > x
        return firstindex(r)
    else
        idx = unsafe_findvalue(x, r, RoundUp)
        if idx > x
            return idx
        else
            return idx + oneunit(idx)
        end
    end
end

###
### AbstractRange
###
function find_firstgt(x, r::AbstractRange{T}) where {T}
    if isempty(r)
        return nothing
    elseif step(r) > zero(T)
        if (last(r) <= x) | isempty(r)
            return nothing
        elseif first(r) > x
            return firstindex(r)
        else
            idx = unsafe_findvalue(x, r, RoundUp)
            if @inbounds(r[idx]) > x
                return idx
            else
                return idx + oneunit(idx)
            end
        end
    else  # step(r) < zero(T)
        if first(r) > x
            return firstindex(r)
        elseif last(r) < x
            return nothing
        else
            return unsafe_findvalue(x, r, RoundUp)
        end
    end
end

function find_firstgt(x, a)
    for (i, a_i) in pairs(a)
        a_i > x && return i
    end
    return nothing
end

