"""
    merge_sort(x, y)
Merge's and sorts collections `x`, and `y`.
"""
merge_sort(x, y) = _merge_sort(x, order(x), y, order(y))

function _merge_sort(x, xo, y, yo)
    if is_after(x, xo, y, yo)
        return _vcat_after(x, xo, y, yo)
    elseif is_before(x, xo, y, yo)
        return _vcat_before(x, xo, y, yo)
    else
        return _weave_sort(x, xo, y, yo)
    end
end

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

function _weave_sort(x, xo, y, yo)
    return __weave_sort(
        max_of_group_min(x, xo, y, yo),
        min_of_group_max(x, xo, y, yo),
        x, xo, y, yo)
end

function __weave_sort(cmin, cmax, x, xo, y, yo)
    return vcat(
        _first_segment(cmin, cmax, x, xo, y, yo),
        unique(_middle_segment(cmin, cmax, x, xo, y, yo)),
        _last_segment(cmin, cmax, x, xo, y, yo)
    )
end

