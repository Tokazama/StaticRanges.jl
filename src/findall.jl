
@propagate_inbounds find_all(f, x) = find_all(f, x, order(x))
find_all(f, x, xo) = _fallback_find_all(f, x)

@propagate_inbounds function find_all(f::Fix2{typeof(in)}, y, yo)
    return _findin(f.x, order(f.x), y, yo)
end
for (L,LF) in ((:closed,>=),(:open,>))
    for (R,RF)  in ((:closed,<=),(:open,<))
        @eval begin
            @propagate_inbounds function find_all(f::Fix2{typeof(in),Interval{$(QuoteNode(L)),$(QuoteNode(R)),T}}, y, yo) where {T}
                return find_all(and($LF(f.x.left), $RF(f.x.right)), y, yo)
            end
        end
    end
end

_fallback_find_all(f, a) = collect(first(p) for p in pairs(a) if f(last(p)))

# <, <=
@propagate_inbounds function find_all(f::F2Lt, r, ro::ForwardOrdering)
    return _find_all(keytype(r), firstindex(r), find_last(f, r, ro))
end
@propagate_inbounds function find_all(f::F2Lt, r, ro::ReverseOrdering)
    return _find_all(keytype(r), find_first(f, r, ro), lastindex(r))
end
find_all(f::F2Lt, r::AbstractRange, ::UnorderedOrdering) = _empty_ur(keytype(r))
find_all(f::F2Lt, a::AbstractArray, ::UnorderedOrdering) = _fallback_find_all(f, a)

# >, >=
@propagate_inbounds function find_all(f::F2Gt, r, ro::ForwardOrdering)
    return _find_all(keytype(r), find_first(f, r, ro), lastindex(r))
end
@propagate_inbounds function find_all(f::F2Gt, r, ro::ReverseOrdering)
    return _find_all(keytype(r), firstindex(r), find_last(f, r, ro))
end
find_all(f::F2Gt, r::AbstractRange, ::UnorderedOrdering) = _empty_ur(keytype(r))
find_all(f::F2Gt, a::AbstractArray, ::UnorderedOrdering) = _fallback_find_all(f, a)

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

@propagate_inbounds function find_all(f::Fix2{typeof(!=)}, r, ro)
    return find_not_in(f, r, ro)
end

@propagate_inbounds function find_not_in(f, r, ro::ForwardOrdering)
    return find_all(or(>(f.x), <(f.x)), r, ro)
end

@propagate_inbounds function find_not_in(f, r, ro::ReverseOrdering)
    return find_all(or(>(f.x), <(f.x)), r, ro)
end

@propagate_inbounds function find_not_in(f, r, ::UnorderedOrdering)
    if r isa AbstractRange
        return GapRange(UnitRange(1, 0), UnitRange(1, 0))
    else
        return _fallback_find_all(f, x)
    end
end

###
### BitAnd
###
function find_all(bitop::BitAnd{<:F2Lt,<:F2Lt}, x, xo)
    return bitop.f1(bitop.f2.x) ? find_all(bitop.f2, x) : find_all(bitop.f1, x)
end
function find_all(bitop::BitAnd{<:F2Gt,<:F2Gt}, x, xo)
    return bitop.f1(bitop.f2.x) ? find_all(bitop.f2, x, xo) : find_all(bitop.f1, x, xo)
end
function find_all(bitop::BitAnd, x, xo)
    return intersect(find_all(bitop.f1, x, xo), find_all(bitop.f2, x, xo))
end

###
### BitOr
###
function find_all(bitop::BitOr{<:F2Lt,<:F2Lt}, x, xo)
    return !bitop.f1(bitop.f2.x) ? find_all(bitop.f2, x, xo) : find_all(bitop.f1, x, xo)
end
function find_all(bitop::BitOr{<:F2Gt,<:F2Gt}, x, xo)
    return !bitop.f1(bitop.f2.x) ? find_all(bitop.f2, x, xo) : find_all(bitop.f1, x, xo)
end
function find_all(bitop::BitOr, x, xo)
    return combine(find_all(bitop.f1, x, xo), find_all(bitop.f2, x, xo))
end

