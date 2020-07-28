
@inline find_all(f::Equal,              x) = find_alleq(f.x,   x)
@inline find_all(f::Less,               x) = find_alllt(f.x,   x)
@inline find_all(f::LessThanOrEqual,    x) = find_alllteq(f.x, x)
@inline find_all(f::Greater,            x) = find_allgt(f.x,   x)
@inline find_all(f::GreaterThanOrEqual, x) = find_allgteq(f.x, x)
@inline find_all(f::In,                 x) = find_all_in(f.x,       x)
@inline find_all(f::Not,                x) = find_not_in(f.x,  x)
@inline find_all(f::Or,                 x) = combine(find_all(f.f1, x), find_all(f.f2, x))
@inline find_all(f::And,                x) = intersect(find_all(f.f1, x), find_all(f.f2, x))
find_all(f, x) = _fallback_find_all(f, x)

#=
@inline function find_all(f::BitOr{<:F2LtAndLtEq,<:F2LtAndLtEq}, x)
    if !f.f1(f.f2.x)
        return find_all(f.f2, x)
    else
        return find_all(f.f1, x)
    end
end
@inline function find_all(f::BitOr{<:F2GtAndGtEq,<:F2GtAndGtEq}, x)
    if !f.f1(f.f2.x)
        return find_all(f.f2, x)
    else
        return find_all(f.f1, x)
    end
end
=#

###
### BitAnd
###
#=
@inline function find_all(bitop::BitAnd{<:F2LtAndLtEq,<:F2LtAndLtEq}, x)
    if bitop.f1(bitop.f2.x)
        return find_all(bitop.f2, x)
    else
        return find_all(bitop.f1, x)
    end
end

@inline function find_all(bitop::BitAnd{<:F2GtAndGtEq,<:F2GtAndGtEq}, x)
    if bitop.f1(bitop.f2.x)
        return find_all(bitop.f2, x)
    else
        return find_all(bitop.f1, x)
    end
end
=#

_fallback_find_all(f, a) = collect(first(p) for p in pairs(a) if f(last(p)))

# <
@inline function find_alllt(x, r::AbstractRange{T}) where {T}
    if step(r) > zero(T)
        return _find_all(keytype(r), firstindex(r), find_lastlt(x, r))
    elseif step(r) < zero(T)
        return _find_all(keytype(r), find_firstlt(x, r), lastindex(r))
    else
        return _find_all(keytype(r), nothing, nothing)
    end
end
find_alllt(x, a) = collect(first(p) for p in pairs(a) if (last(p) < x))

# <=
@inline function find_alllteq(x, r::AbstractRange{T}) where {T}
    if step(r) > zero(T)
        return _find_all(keytype(r), firstindex(r), find_lastlteq(x, r))
    elseif step(r) < zero(T)
        return _find_all(keytype(r), find_firstlteq(x, r), lastindex(r))
    else
        return _find_all(keytype(r), nothing, nothing)
    end
end
find_alllteq(x, a) = collect(first(p) for p in pairs(a) if (last(p) <= x))

# TODO
#find_all(f::F2Lt, a::AbstractArray, ::UnorderedOrdering) = _fallback_find_all(f, a)

# >
@inline function find_allgt(x, r::AbstractRange{T}) where {T}
    if step(r) > zero(T)
        return _find_all(keytype(r), find_firstgt(x, r), lastindex(r))
    elseif step(r) < zero(T)
        return _find_all(keytype(r), firstindex(r), find_lastgt(x, r))
    else
        return _empty_ur(keytype(r))
    end
end
find_allgt(x, a) = collect(first(p) for p in pairs(a) if (last(p) > x))

# >=
@inline function find_allgteq(x, r::AbstractRange{T}) where {T}
    if step(r) > zero(T)
        return _find_all(keytype(r), find_firstgteq(x, r), lastindex(r))
    elseif step(r) < zero(T)
        return _find_all(keytype(r), firstindex(r), find_lastgteq(x, r))
    else
        return _empty_ur(keytype(r))
    end
end
find_allgteq(x, a) = collect(first(p) for p in pairs(a) if (last(p) >= x))

# TODO
#find_all(f::F2Gt, a::AbstractArray, ::UnorderedOrdering) = _fallback_find_all(f, a)

# find_all(==(x), r)
@inline function find_alleq(x, r::AbstractRange{T}) where {T}
    if (step(r) > zero(T)) | (step(r) < zero(T))
        return _find_all(keytype(r), find_firsteq(x, r), find_lasteq(x, r))
    else
        return _empty_ur(keytype(r))
    end
end
find_alleq(x, a) = collect(first(p) for p in pairs(a) if (last(p) == x))

# !=
@inline function find_not_in(x, r::AbstractRange{T}) where {T}
    if (step(r) > zero(T)) | (step(r) < zero(T))
        return combine(find_allgt(x, r), find_alllt(x, r))
    else
        return GapRange(UnitRange(1, 0), UnitRange(1, 0))
    end
end
find_all_not_in(x, a) = collect(first(p) for p in pairs(a) if (last(p) != x))

