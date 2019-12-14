@propagate_inbounds find_all(f, x) = find_all(f, x, order(x))
find_all(f, x, xo) = findall(f, x)

find_all(f::Fix2{typeof(in)}, y, yo) = _findin(f.x, order(f.x), y, yo)

_fallback_find_all(f, a) = collect(first(p) for p in pairs(a) if f(last(p)))

# <, <=
@propagate_inbounds function find_all(f::F2Lt, r, ro::ForwardOrdering)
    return _find_all(keytype(r), firstindex(r), find_last(f, r, ro))
end
@propagate_inbounds function find_all(f::F2Lt, r, ro::ReverseOrdering)
    return _find_all(keytype(r), find_first(f, r, ro), lastindex(r))
end
find_all(f::F2Lt, r::AbstractRange, ::UnorderedOrdering) = _empty_ur(keytype(r))
find_all(f::F2Lt, r::AbstractArray, ::UnorderedOrdering) = _fallback_find_all(f, a)

# >, >=
@propagate_inbounds function find_all(f::F2Gt, r, ro::ForwardOrdering)
    return _find_all(keytype(r), find_first(f, r, ro), lastindex(r))
end
@propagate_inbounds function find_all(f::F2Gt, r, ro::ReverseOrdering)
    return _find_all(keytype(r), firstindex(r), find_last(f, r, ro))
end
find_all(f::F2Gt, r::AbstractRange, ::UnorderedOrdering) = _empty_ur(keytype(r))
find_all(f::F2Gt, r::AbstractArray, ::UnorderedOrdering) = _fallback_find_all(f, a)

# find_all(==(x), r)
find_all(f::F2Eq, r::AbstractRange, ::UnorderedOrdering) = _empty_ur(keytype(r))
function find_all(f::F2Eq, r, ro::Ordering)
    return _find_all(keytype(r), find_first(f, r, ro), find_last(f, r, ro))
end

# only really applies to ordered vectors
_find_all(::Type{T},        fi,        li) where {T} = fi:li
_find_all(::Type{T}, ::Nothing,        li) where {T} = _empty_ur(T)
_find_all(::Type{T},        fi, ::Nothing) where {T} = _empty_ur(T)
_find_all(::Type{T}, ::Nothing, ::Nothing) where {T} = _empty_ur(T)

_empty_ur(::Type{T}) where {T} = one(T):zero(T)

@propagate_inbounds function find_all(f::BitAnd, r, ro)
    return _bit_and(r, ro, find_all(f.f1, r, ro), find_all(f.f2, r, ro))
end
@propagate_inbounds function find_all(f::BitOr, r, ro)
    return _bit_or(r, ro, find_all(f.f1, r, ro), find_all(f.f2, r, ro))
end

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

@propagate_inbounds function find_all(f::Fix2{typeof(!=)}, r, ro::ForwardOrdering)
    return find_all(<(f.x) | >(f.x), r, ro)
end
@propagate_inbounds function find_all(f::Fix2{typeof(!=)}, r, ro::ReverseOrdering)
    return find_all(>(f.x) | <(f.x), r, ro)
end

find_all(f::Fix2{typeof(!=)}, r::AbstractRange, ::UnorderedOrdering) = _empty_ur(keytype(r))
function find_all(f::Fix2{typeof(!=)}, r::AbstractVector, ::UnorderedOrdering)
    return findall(f, r)
end


