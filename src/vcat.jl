
maybe_flip(::O, ::O, x) where {O<:Ordering} = x
maybe_flip(::Ordering, ::Ordering, x) = reverse(x)
function _first_segment(cmin, cmax, x, xo, y, yo)
    xidx, yidx = _first_segment_index(cmin, cmax, x, xo, y, yo)
    if xo isa ReverseOrdering
        return sort(vcat(@inbounds(x[xidx]), @inbounds(y[yidx])), rev=true)
    else
        return sort(vcat(@inbounds(x[xidx]), @inbounds(y[yidx])), rev=false)
    end
end

function _first_segment_index(cmin, cmax, x, xo::ForwardOrdering, y, yo)
    return find_all(<(cmin), x), maybe_flip(xo, yo, find_all(<(cmin), y))
end

function _first_segment_index(cmin, cmax, x, xo::ReverseOrdering, y, yo)
    return find_all(>(cmax), x), maybe_flip(xo, yo, find_all(>(cmax), y))
end

function _first_segment_index(cmin, cmax, x, xo, y, yo)
    xidx = find_all(<(cmin), x)
    yidx = find_all(<(cmin), y)
    if !isempty(xidx)
        return sortperm(x[xidx]), yidx
    elseif !isempty(yidx)
        return x[xidx], sortperm(y[yidx])
    else
        return xidx, yidx
    end
end

function _middle_segment(cmin, cmax, x, xo, y, yo)
    xidx = _middle_segment_index(cmin, cmax, x, xo)
    yidx = _middle_segment_index(cmin, cmax, y, yo)
    if xo isa ReverseOrdering
        return sort(vcat(@inbounds(x[xidx]), @inbounds(y[yidx])), rev=true)
    else
        return sort(vcat(@inbounds(x[xidx]), @inbounds(y[yidx])), rev=false)
    end
end

_middle_segment_index(cmin, cmax, x, xo) = find_all(and(>=(cmin), <=(cmax)), x)

function _last_segment(cmin, cmax, x, xo, y, yo)
    xidx, yidx = _last_segment_index(cmin, cmax, x, xo, y, yo)
    if xo isa ReverseOrdering
        return sort(vcat(@inbounds(x[xidx]), @inbounds(y[yidx])), rev=true)
    else
        return sort(vcat(@inbounds(x[xidx]), @inbounds(y[yidx])), rev=false)
    end
end

function _last_segment_index(cmin, cmax, x, xo::ReverseOrdering, y, yo)
    return find_all(<(cmin), x), maybe_flip(xo, yo, find_all(<(cmin), y))
end

function _last_segment_index(cmin, cmax, x, xo::ForwardOrdering, y, yo)
    return find_all(>(cmax), x), maybe_flip(xo, yo, find_all(>(cmax), y))
end

"""
    vcat_sort(x, y)

Returns a sorted concatenation of `x` and `y`.

## Examples
```jldoctest
julia> using StaticRanges

julia> StaticRanges.vcat_sort(1:10)  # it's already sorted, nothing happens
1:10

julia> StaticRanges.vcat_sort([3, 1, 2, 5])  # sort unordered collection
4-element Array{Int64,1}:
 1
 2
 3
 5


julia> StaticRanges.vcat_sort([3, 4, 5], [1, 2, 5])
6-element Array{Int64,1}:
 1
 2
 3
 4
 5
 5

```
"""
vcat_sort(x::AbstractVector) = _vcat_sort_one(order(x), x)
_vcat_sort_one(::UnorderedOrdering, x) = sort(x)
_vcat_sort_one(::Ordering, x) = x

function vcat_sort(x::AbstractVector, y::AbstractVector)
    xo = order(x)
    yo = order(y)
    if xo isa UnorderedOrdering && isempty(x)
        if yo isa UnorderedOrdering
            return sort(y)
        else
            return y
        end
    elseif yo isa UnorderedOrdering && isempty(y)
        if xo isa UnorderedOrdering
            return sort(x)
        else
            return x
        end
    else
        return _vcat_sort(x, xo, y, yo)
    end
end
function _vcat_sort(x, xo, y, yo)
    if is_before(x, xo, y, yo)
        return _vcat_before(x, xo, y, yo)
    elseif is_after(x, xo, y, yo)
        return _vcat_after(x, xo, y, yo)
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

function _vcat_before(x, xo, y, yo)
    if is_forward(xo)
        if is_forward(yo)
            return vcat(x, y)
        elseif is_reverse(yo)
            return vcat(x, reverse(y))
        else
            return vcat(x, sort(y))
        end
    elseif is_reverse(xo)
        if is_forward(yo)
            return vcat(reverse(y), x)
        elseif is_reverse(yo)
            return vcat(y, x)
        else
            return vcat(sort(y, rev=true), x)
        end
    else
        if is_forward(yo)
            return vcat(sort(x), y)
        elseif is_reverse(yo)
            return vcat(y, sort(x, rev=true))
        else
            return vcat(sort(x), sort(y))
        end
    end
end

function _vcat_after(x, xo, y, yo)
    if is_forward(xo)
        if is_forward(yo)
            return vcat(y, x)
        elseif is_reverse(yo)
            return vcat(reverse(y), x)
        else
            return vcat(sort(y), x)
        end
    elseif is_reverse(xo)
        if is_forward(yo)
            return vcat(x, reverse(y))
        elseif is_reverse(yo)
            return vcat(x, y)
        else
            return vcat(x, sort(y, rev=true))
        end
    else
        if is_forward(yo)
            return vcat(y, sort(x))
        elseif is_reverse(yo)
            return vcat(sort(x, rev=true), y)
        else
            return vcat(sort(y), sort(x))
        end
    end
end

