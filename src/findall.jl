"""
# Examples

julia> findall(x -> >(x, 3) & <(x, 6), 1:10)
 4
 5

 findall(x -> >(x, 3) & <(x, 6), 1:10) == [4, 5]

 findall(>(3) & <(6), 1:10) == 4:5

"""
find_all(f, x) = find_all(f, x, order(x))
find_all(f, x, xo) = findall(f, x)

find_all(f::Fix2{typeof(in)}, y, yo) = _findin(f.x, order(f.x), y, yo)

# <, <=
find_all(f::F2Lt, r, ro::ForwardOrdering) = _find_all(r, firstindex(r), find_last(f, r, ro))
find_all(f::F2Lt, r, ro::ReverseOrdering) = _find_all(r, find_first(f, r, ro), lastindex(r))
find_all(f::F2Lt, r::AbstractRange, ::UnorderedOrdering) = _empty_ur(keytype(r))
# TODO find_all(f::Fix2{<:Union{typeof(<),typeof(<=)}}, r::AbstractArray, ::UnorderedOrdering)

# >, >=
find_all(f::F2Gt, r, ro::ForwardOrdering) = _find_all(r, find_first(f, r, ro), lastindex(r))
find_all(f::F2Gt, r, ro::ReverseOrdering) = _find_all(r, firstindex(r), find_last(f, r, ro))
find_all(f::F2Gt, r::AbstractRange, ::UnorderedOrdering) = _empty_ur(keytype(r))
# TODO find_all(f::Fix2{<:Union{typeof(>),typeof(>=)}}, r::AbstractArray, ::UnorderedOrdering)

# find_all(==(x), r)
find_all(f::F2Eq, r::AbstractRange, ::UnorderedOrdering) = _empty_ur(keytype(r))
find_all(f::F2Eq, r, ro::Ordering) = _find_all(r, find_first(f, r, ro), find_last(f, r, ro))

# only really applies to ordered vectors
_find_all(v, fi, li) = fi:li
_find_all(v, ::Nothing, li       ) = _empty_ur(keytype(v))
_find_all(v, fi,        ::Nothing) = _empty_ur(keytype(v))
_find_all(v, ::Nothing, ::Nothing) = _empty_ur(keytype(v))

_empty_ur(::Type{T}) where {T} = one(T):zero(T)

#= TODO inverted indices
function find_all(f::Fix2{typeof(!=)}, r, ::ForwardOrdering)
    f = find_first(<(f.x), r, Forward)
    Not()
end

=#

find_all(f::BitAnd, r, ro) = _bit_and(r, ro, find_all(f.f1, r, ro), find_all(f.f2, r, ro))
find_all(f::BitOr, r, ro) = _bit_or(r, ro, find_all(f.f1, r, ro), find_all(f.f2, r, ro))

function _bit_and(r, ro, inds1, inds2)
    if isempty(inds1)
        return isempty(inds2) ? inds2 : inds1
    else
        return isempty(inds2) ? inds2 : intersect(inds1, inds2)
    end
end

function _bit_or(r, ro, inds1, inds2)
    if isempty(inds1)
        return isempty(inds2) ? inds1 : inds2
    else
        return isempty(inds2) ? inds1 : _merge_bit_find(inds1, inds2)
    end
end

# we assume that neither of these are empty at this point
function _merge_bit_find(inds1::AbstractRange{T}, inds2::AbstractRange{T}) where {T}
    if is_after(inds1, inds2)
        return vcat(inds2, inds1)
    elseif is_before(inds1, inds2)
        return vcat(inds1, inds2)
    else
        return _group_min(inds1, Forward, inds2, Forward):_group_max(inds1, Forward, inds2, Forward)
    end
end

find_all(f::Fix2{typeof(!=)}, r, ro) = find_all(<(f.x) | >(f.x), r, ro)


