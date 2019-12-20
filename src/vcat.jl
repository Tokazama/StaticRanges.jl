
maybe_flip(::O, ::O, x) where {O} = x
maybe_flip(::Ordering, ::Ordering, x) = reverse(x)

"""
    first_segment(x, y)

Given two collections `x` and `y`, returns the first non-overlapping segment.
"""
@inline first_segment(x, y) = first_segment(x, order(x), y, order(y))
function first_segment(x, xo, y, yo)
   return _first_segment(
        max_of_group_min(x, xo, y, yo),
        min_of_group_max(x, xo, y, yo),
        x, xo, y, yo
    )
end

function _first_segment(cmin, cmax, x, xo, y, yo)
    xidx, yidx = _first_segment_index(cmin, cmax, x, xo, y, yo)
    return vcat(@inbounds(x[xidx]), @inbounds(y[yidx]))
end

function _first_segment_index(cmin, cmax, x, xo::ForwardOrdering, y, yo)
    return find_all(<(cmin), x, xo), maybe_flip(xo, yo, find_all(<(cmin), y, yo))
end

function _first_segment_index(cmin, cmax, x, xo::ReverseOrdering, y, yo)
    return find_all(>(cmin), x, xo), maybe_flip(xo, yo, find_all(>(cmin), y, yo))
end

function _first_segment_index(cmin, cmax, x, xo, y, yo)
    xidx = find_all(<(cmin), x, xo)
    yidx = find_all(<(cmin), y, yo)
    if !isempty(xidx)
        return sortperm(x[xidx]), yidx
    elseif !isempty(yidx)
        return x[xidx], sortperm(y[yidx])
    else
        return xidx, yidx
    end
end

"""
    middle_segment(x, y)

Given two collections `x` and `y`, returns the first non-overlapping segment.
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
    return sort(vcat(@inbounds(x[xidx]), @inbounds(y[yidx])))
end

function _middle_segment_index(cmin, cmax, x, xo)
    return find_all(and(>=(cmin), <=(cmax)), x, xo)
end

"""
    last_segment(x, y)

Given two collections `x` and `y`, returns the last non-overlapping segment.
"""
last_segment(x, y) = last_segment(x, order(x), y, order(y))
function last_segment(x, xo, y, yo)
   return _last_segment(
        max_of_group_min(x, xo, y, yo),
        min_of_group_max(x, xo, y, yo),
        x, xo, y, yo
    )
end

function _last_segment(cmin, cmax, x, xo, y, yo)
    xidx, yidx = _last_segment_index(cmin, cmax, x, xo, y, yo)
    return vcat(@inbounds(x[xidx]), @inbounds(y[yidx]))
end

function _last_segment_index(cmin, cmax, x, xo::ReverseOrdering, y, yo)
    return find_all(<(cmin), x, xo), maybe_flip(xo, yo, find_all(<(cmin), y, yo))
end

function _last_segment_index(cmin, cmax, x, xo::ForwardOrdering, y, yo)
    return find_all(>(cmax), x, xo), maybe_flip(xo, yo, find_all(>(cmax), y, yo))
end

"""
    vcat_sort(x, y)

Returns a sorted concatenation of `x` and `y`.
"""
vcat_sort(x::AbstractVector) = _vcat_sort_one(order(x), x)
_vcat_sort_one(::UnorderedOrdering, x) = sort(x)
_vcat_sort_one(::Ordering, x) = x

vcat_sort(x::AbstractVector, y::AbstractVector) = _vcat_sort(x, order(x), y, order(y))
function _vcat_sort(x, xo, y, yo)
    if is_before(x, xo, y, yo)
        return _vcatbefore(x, xo, y, yo)
    elseif is_after(x, xo, y, yo)
        return _vcatafter(x, xo, y, yo)
    else
        return __vcat_sort(
            max_of_group_min(x, xo, y, yo),
            min_of_group_max(x, xo, y, yo),
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

function _vcatbefore(x, xo, y, yo)
    if is_forward(xo)
        return is_forward(yo) ? vcat(x, y) : vcat(x, reverse(y))
    else
        return is_forward(yo) ? vcat(reverse(y), x) : vcat(y, x)
    end
end

function _vcatafter(x, xo, y, yo)
    if is_forward(xo)
        return is_forward(yo) ? vcat(y, x) : vcat(reverse(y), x)
    else
        return is_forward(yo) ? vcat(x, reverse(y)) : vcat(x, y)
    end
end
