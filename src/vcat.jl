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

vcat_sort(x, y) = _vcat_sort(x, order(x), y, order(y))
function _vcat_sort(x, xo, y, yo)
    if isbefore(x, xo, y, yo)
        return _vcatbefore(x, xo, y, yo)
    elseif isafter(x, xo, y, yo)
        return _vcatafter(x, xo, y, yo)
    else
        return __vcat_sort(
            max_of_groupmin(x, xo, y, yo),
            min_of_groupmax(x, xo, y, yo),
            x, xo, y, yo)
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
        return isforward(yo) ? vcat(x, y) : vcat(x, reverse(y))
    else
        return isforward(yo) ? vcat(reverse(y), x) : vcat(y, x)
    end
end

function _vcatafter(xo, yo, x, y)
    if isforward(xo)
        return isforward(yo) ? vcat(y, x) : vcat(reverse(y), x)
    else
        return isforward(yo) ? vcat(x, reverse(y)) : vcat(x, y)
    end
end
