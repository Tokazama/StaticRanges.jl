
###
### OneToUnion
###
find_firstgteq(x, r::OneToUnion) = _find_firstgteq_oneto(x, r)

@inline function _find_firstgteq_oneto(x::Integer, r)
    if (x > last(r)) | (r.stop == 0)
        return nothing
    elseif x <= 1
        return 1
    else
        return x
    end
end

@inline function _find_firstgteq_oneto(x, r)
    if (x > last(r)) | (r.stop == 0)
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
find_firstgteq(x, r::AbstractUnitRange) = _find_firstgteq_unit(x, r)

function _find_firstgteq_unit(x::Integer, r)
    if (x > last(r)) | isempty(r)
        return nothing
    elseif x < first(r)
        return firstindex(r)
    else
        return unsafe_findvalue(x, r)
    end
end

function _find_firstgteq_unit(x, r)
    if (last(r) < x) | isempty(r)
        return nothing
    elseif first(r) > x
        return firstindex(r)
    else
        return unsafe_findvalue(x, r, RoundUp)
    end
end

@inline function find_firstgteq(x, r::AbstractRange{T}) where {T}
    if isempty(r)
        return nothing
    elseif step(r) > zero(T)
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

