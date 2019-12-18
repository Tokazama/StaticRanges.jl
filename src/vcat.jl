first_segment(x, y) = first_segment(x, order(x), y, order(y))
function first_segment(x, xo, y, yo)
    return _first_segment(
        max_of_group_min(x, xo, y, yo),
        min_of_group_max(x, xo, y, yo),
        x, xo, y, yo
    )
end
function _first_segment(cmin, cmax, x, xo::ForwardOrdering, y, yo)
    xidx = find_all(<(cmin), x, xo)
    yidx = maybe_flip(xo, yo, find_all(<(cmin), y, yo))
    return vcat(@inbounds(x[xidx]), @inbounds(y[yidx]))
end

function _first_segment(cmin, cmax, x, xo::ReverseOrdering, y, yo)
    xidx = find_all(>(cmin), x, xo)
    yidx = maybe_flip(xo, yo, find_all(>(cmin), y, yo))
    return vcat(@inbounds(x[xidx]), @inbounds(y[yidx]))
end

"""
    middle_segment
"""
middle_segment(x, y) = middle_segment(x, order(x), x, order(y))
function middle_segment(x, xo, y, yo)
    return _middle_segment(
        max_of_group_min(x, xo, y, yo),
        min_of_group_max(x, xo, y, yo),
        x, xo, y, yo
    )
end
function _middle_segment(cmin, cmax, x, xo, y, yo)
    xidx = _middle_segment_index(cmin, cmax, x, xo)
    yidx = _middle_segment_index(cmin, cmax, y, yo)
    return vcat(@inbounds(x[xidx]), @inbounds(y[yidx]))
end

function _middle_segment_index(cmin, cmax, x, xo)
    return find_all(and(>=(cmin), <=(cmax)), x, xo)
end

"""
    last_segment
"""
last_segment(x, y) = last_segment(x, order(x), y, order(y))
function last_segment(x, xo, y, yo)
   return _last_segment(
        max_of_group_min(x, xo, y, yo),
        min_of_group_max(x, xo, y, yo),
        x, xo, y, yo
    )
end

function _last_segment(cmin, cmax, x, xo::ReverseOrdering, y, yo)
    xidx = find_all(<(cmin), x, xo)
    yidx = maybe_flip(xo, yo, find_all(<(cmin), y, yo))
    return vcat(@inbounds(x[xidx]), @inbounds(y[yidx]))
end

function _last_segment(cmin, cmax, x, xo::ForwardOrdering, y, yo)
    xidx = find_all(>(cmax), x, xo)
    yidx = maybe_flip(xo, yo, find_all(>(cmax), y, yo))
    return vcat(@inbounds(x[xidx]), @inbounds(y[yidx]))
end

"""
    vcat_sort(x, y)

Returns a sorted concatenation of `x` and `y`.
"""
vcat_sort(x) = _vcat_sort_one(order(x), x)
_vcat_sort_one(::UnorderedOrdering, x) = sort(x)
_vcat_sort_one(::Ordering, x) = x

vcat_sort(x, y) = _vcat_sort(order(x), order(y), x, y)
function _vcat_sort(xo, yo, x, y)
    if isbefore(xo, yo, x, y)
        return _vcatbefore(xo, yo, x, y)
    elseif isafter(xo, yo, x, y)
        return _vcatafter(xo, yo, x, y)
    else
        return __vcat_sort(
            max_of_groupmin(xo, yo, x, y),
            min_of_groupmax(xo, yo, x, y),
            xo, yo, x, y)
    end
end

function __vcat_sort(cmin, cmax, x, xo, y, yo)
    return vcat(
        _first_segment(cmin, cmax, x, xo, y, yo),
        _middle_segment(cmin, cmax, x, xo, y, yo),
        _last_segment(cmin, cmax, x, xo, y, yo)
    )
end

function _vcatbefore(xo, yo, x, y)
    if isforward(xo)
        return SortedVector(isforward(yo) ? vcat(x, y) : vcat(x, reverse(y)), xo, IsOrdered)
    else
        return SortedVector(isforward(yo) ? vcat(reverse(y), x) : vcat(y, x), xo, IsOrdered)
    end
end

function _vcatafter(xo, yo, x, y)
    if isforward(xo)
        return SortedVector(isforward(yo) ? vcat(y, x) : vcat(reverse(y), x), xo, IsOrdered)
    else
        return SortedVector(isforward(yo) ? vcat(x, reverse(y)) : vcat(x, y), xo, IsOrdered)
    end
end
