"""
    merge_sort(x, y)

Merge's and sorts collections `x`, and `y`.
"""
merge_sort(x, y) = _merge_sort(x, order(x), y, order(y))

function _merge_sort(x, xo, y, yo)
    if isempt(x)
        return _catch_sort(y, yo)
    elseif isempty(y)
        return _catch_sort(x, xo)
    end

    if is_after(x, xo, y, yo)
        return _stack_sort(y, yo, x, xo)
    elseif is_before(x, xo, y, yo)
        return _stack_sort(x, xo, y, yo)
    else
        return _weave_sort(x, xo, y, yo)
    end
end

_catch_sort(x, ::ForwardOrdering) = x
_catch_sort(x, ::ReverseOrdering) = x
_catch_sort(x, ::UnorderedOrdering) = sort(x)

_stack_sort(x, ::O, y, ::O) where {O} = vcat(x, y)
_stack_sort(x, xo, y, yo) = vcat(x, sort(y, order=yo))

function _weave_sort(x::AbstractUnitRange{<:Integer}, xo, y::AbstractUnitRange{<:Integer}, yo)
    return similar_type(x)(_group_min(x, xo, y, yo), _group_max(x, xo, y, yo))
end

function _weave_sort(x::AbstractRange, xo, y::AbstractRange, yo)
    sx = step(x)
    sy = step(y)
    sxy = _find_step_in(sx, xo, sy, yo)
    if !iszero(rem(ordmin(x, xo) - ordmin(y, yo), div(sxy, step(x))))
        return sort(vcat(x, y), order=xo)
    end
    return _group_min(x, xo, y, yo):min(sx, sy):_group_max(x, xo, y, yo)
end

