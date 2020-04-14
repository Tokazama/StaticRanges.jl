
"""
    find_firsteq(val, collection)

Return the first index of `collection` where the element is equal to `val`.
If no element of `collection` is equal to `val`, `nothing` is returned.
"""
function find_firsteq(x, r::AbstractRange)
    if !in(x, r)
        return nothing
    else
        return unsafe_findvalue(x, r)
    end
end

find_firsteq(x, r::OneToUnion) = _find_firsteq_oneto(x, r)

function _find_firsteq_oneto(x::Integer, r)
    if (x < 1) | (x > last(r))
        return nothing
    else
        return x
    end
end

function _find_firsteq_oneto(x, r)
    idx = round(Integer, x)
    if idx == x
        return _find_firsteq_oneto(idx, r)
    else
        return nothing
    end
end

function find_firsteq(x, a)
    for (i, a_i) in pairs(a)
        x == a_i && return i
    end
    return nothing
end
