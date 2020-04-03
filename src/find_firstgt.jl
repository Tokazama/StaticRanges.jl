
find_firstgt(x, r::OneToUnion) = _find_firstgt_oneto(x, r)

@inline function _find_firstgt_oneto(x::Integer, r)
    if x >= last(r)
        return nothing
    elseif x < 1
        return 1
    else
        return x + 1
    end
end

@inline function _find_firstgt_oneto(x, r)
    idx = round(Integer, x, RoundUp)
    if idx > x
        if idx < 1
            return nothing
        elseif idx >= last(r)
            return 1
        else
            return x
        end
    else
        return _find_firstgt_oneto(idx, r)
    end
end

find_firstgt(x, r::AbstractUnitRange) = _find_firstgt_unit(x, r)

@inline function _find_firstgt_unit(x::Integer, r)
    if x >= last(r)
        return nothing
    elseif x < first(r)
        return firstindex(r)
    else
        # b/c +1 get's to the value isequal and we want greater
        return (x - first(r)) + 2
    end
end

@inline function _find_firstgt_unit(x, r)
    xnew = round(Integer, x, RoundUp)
    if xnew > x
        if xnew >= lastindex(r)
            return nothing
        elseif xnew < firstindex(r)
            return firstindex(r)
        else
            return unsafe_findvalue(xnew, r)
        end
    else
        return _find_firstgt_unit(xnew, r)
    end
end

@inline function find_firstgt(x, r::AbstractRange{T}) where {T}
    if step(r) > zero(T)
        idx = unsafe_findvalue(x, r)
        if idx < firstindex(r)
            return firstindex(r)
        elseif idx > lastindex(r)
            return nothing
        elseif (@inbounds(r[idx]) == x) & (idx != lastindex(r))
            return idx + oneunit(idx)
        else
            return nothing
        end
    elseif step(r) < zero(T)
        idx = unsafe_findvalue(x, r)
        if idx > lastindex(r)
            return lastindex(r)
        elseif idx < firstindex(r)
            return nothing
        elseif (@inbounds(r[idx]) == x) & (idx != firstindex(r))
            return idx - oneunit(idx)
        else
            return nothing
        end
    else  # isempty(r)
        return nothing
    end
end

function find_firstgt(x, a)
    for (i, a_i) in pairs(a)
        x > a_i && return i
    end
    return nothing
end

