# The goal is to create type stable merges that don't instantly result in an explosion
# of allocations because everything has to become an array.

###
### OneTo
###
combine(x::OneToUnion, y::OneToUnion) = promote_type(typeof(x), typeof(y))(max(x, y))

###
### AbstractUnitRange
###
function combine(x::AbstractUnitRange{<:Integer}, y::AbstractUnitRange{<:Integer})
    R = promote_type(typeof(x), typeof(y))
    if isempty(x)
        if isempty(y)
            return GapRange(R(1, 0), R(1, 0))
        else
            return GapRange(R(1, 0), R(first(y), last(y)))
        end
    elseif isempty(y)
        return GapRange(R(1, 0), R(first(x), last(x)))
    else
        xmax = last(x)
        xmin = first(x)
        ymax = last(y)
        ymin = first(y)
        if xmax < ymin  # all x below y
            return GapRange(R(xmin, xmax), R(ymin, ymax))
        elseif ymax < xmin  # all y below x
            return GapRange(R(ymin, ymax), R(xmin, xmax))
        else # x and y overlap so we just set the first range to length of one
            rmin = min(xmin, ymin)
            return GapRange(R(rmin, rmin), R(rmin + oneunit(eltype(R)), max(xmax, ymax)))
        end
    end
end

function combine(x, y)::Vector
    if is_after(x, y)
        return vcat(y, x)
    elseif is_before(x, y)
        return vcat(x, y)
    else
        return vcat_sort(x, y)
    end
end

"""
    merge_sort(x, y)

Merge's and collections `x`, and `y`, while accounting for their sorting.
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
    else
        return _group_min(x, xo, y, yo):min(sx, sy):_group_max(x, xo, y, yo)
    end
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

