# find x in y

# find all values of x in y
@inline function findin(x::Interval{:closed,:closed,T}, y) where {T}
    return intersect(find_allgteq(x.left, y), find_alllteq(x.right, y))
end

@inline function findin(x::Interval{:closed,:open,T}, y) where {T}
    return intersect(find_allgteq(x.left, y), find_alllt(x.right, y))
end
@inline function findin(x::Interval{:open,:closed,T}, y) where {T}
    return intersect(find_allgt(x.left, y), find_alllteq(x.right, y))
end
@inline function findin(x::Interval{:open,:open,T}, y) where {T}
    return intersect(find_allgt(x.left, y), find_alllt(x.right, y))
end

findin(x::AbstractRange, y) = _findin(x, y)

function _find_first_in(x, y)
    out = 1
    if is_forward(x) & is_forward(y)
        for x_i in x
            out = find_firsteq(x_i, y)
            out isa Nothing || return out
        end
    else
        for x_i in x
            out = find_lasteq(x_i, y)
            out isa Nothing || return out
        end
    end
    return 1
end

function _find_last_in(x, y)
    out = 0
    if is_forward(x) & is_forward(y)
        for x_i in reverse(x)
            out = find_firsteq(x_i, y)
            out isa Nothing || return out
        end
    else
        for x_i in reverse(x)
            out = find_lasteq(x_i, y)
            out isa Nothing || return out
        end
    end
    return out
end

function _findin(x::AbstractUnitRange{<:Integer}, y::AbstractUnitRange{<:Integer})
    return promote_type(typeof(x), typeof(y))(_find_first_in(x, y), _find_last_in(x, y))
end

function _findin(x::OneToUnion{<:Integer}, y::OneToUnion{<:Integer})
    return promote_type(typeof(x), typeof(y))(_find_last_in(x, y))
end

function _findin(x::AbstractUnitRange{T}, y::AbstractUnitRange{T}) where {T}
    R = similar_type(promote_type(typeof(x), typeof(y)), Int)
    if !iszero(rem(first(x) - first(y), 1))
        return R(1, 0)
    else
        return R(_find_first_in(x, y), _find_last_in(x, y))
    end
end

_findin(x::AbstractUnitRange, y::AbstractUnitRange) = _findin(promote(x, y)...)

# TODO this needs to be optimized for ranges
@propagate_inbounds function _findin(x, y)
    if is_forward(x) && is_forward(y)
        return Base._sortedfindin(y, x)
    else
        ind  = Vector{eltype(keys(y))}()
        xset = Set(x)
        @inbounds for x_i in x
            for (idx, y_i) in pairs(y)
                if x_i == y_i
                    push!(ind, idx)
                    break
                end
            end
        end
        return ind
    end
end

function _to_step(x, sx, sy)
    if sign(sx) == sign(sy)
        return x
    else
        return -x
    end
end

# TODO Does it matter what paramters are in the return empty range
@propagate_inbounds function _findin(x::AbstractRange, y::AbstractRange)
    sx = step(x)
    sy = step(y)
    sxy = div(sx, sy)
    if iszero(sxy)
        sxy = div(sy, sx)
        if !iszero(rem(minimum(x) - minimum(y), div(sxy, sx)))
            return 1:1:0
        else
            fi = _find_first_in(x, y)
            li = _find_last_in(x, y)
            return fi:_to_step(1, sx, sy):li
        end
    elseif !iszero(rem(minimum(x) - minimum(y), div(sxy, sx)))
        return 1:1:0
    else
        fi = _find_first_in(x, y)
        li = _find_last_in(x, y)
        return fi:_to_step(Int(sxy), sx, sy):li
    end
end
#=
How this is done without ambiguities:
* For each subtype of ranges creat an internal function `_findin_[subtypes]`
* For each `_findin_[subtypes]`


findin(x::OneToUnion,           y) = _findin_oneto(x, y)
findin(x::AbstractUnitRange,    y) = _findin_unit(x, y)
findin(x::AbstractRange,        y) = _findin_range(x, y)


# TODO OrdinalRange
function _findin_step(x, y::OrdinalRange{T,S}) where {T,S}
end

# TODO: I need to consolodate _find_[first/last]_in fxns to not account for order
# find x in y
@propagate_inbounds function _find_first_in_same(x, y)
    for x_i in x
        out = find_firsteq(x_i, y)
        out isa Nothing || return out
    end
    return 1
end

@propagate_inbounds function _find_first_in_different(x, y)
    for x_i in x
        out = find_lasteq(x_i, y)
        out isa Nothing || return out
    end
    return 1
end

function _find_first_in(x, y)
    if sign(step(x)) == sign(step(x))
        return _find_first_in_same(x, y)
    else
        return _find_first_in_different(x, y)
    end
end

@propagate_inbounds function _find_last_in_same(x, y)
    for x_i in reverse(x)
        out = find_firsteq(x_i, y)
        out isa Nothing || return out
    end
    return 0
end

@propagate_inbounds function _find_last_in_different(x, y)
    for x_i in reverse(x)
        out = find_lasteq(x_i, y)
        out isa Nothing || return out
    end
    return 0
end

function _find_last_in(x, y)
    if sign(step(x)) == sign(step(x))
        return _find_last_in_same(x, y)
    else
        return _find_last_in_different(x, y)
    end
end


@inline function _findin(x::AbstractUnitRange{<:Integer}, y::AbstractUnitRange{<:Integer})
    return promote_type(typeof(x), typeof(y))(_find_first_in(x, y), _find_last_in(x, y))
end

@propagate_inbounds function _findin(x::AbstractUnitRange{T}, y::AbstractUnitRange{T}) where {T}
    R = similar_type(promote_type(typeof(x), typeof(y)), Int)
    @boundscheck if !iszero(rem(first(x) - first(y), 1))
        return R(1, 0)
    end
    return R(_find_first_in(x, y), _find_last_in(x, y))
end

@propagate_inbounds function _findin(x::AbstractUnitRange, y::AbstractUnitRange)
    xnew, ynew = promote(x, y)
    return _findin(xnew, ynew)
end

# TODO this needs to be optimized for ranges
@propagate_inbounds function _findin(x, y)
    if is_forward(x) && is_forward(y)
        return Base._sortedfindin(y, x)
    else
        ind  = Vector{eltype(keys(y))}()
        xset = Set(x)
        @inbounds for x_i in x
            for (idx, y_i) in pairs(y)
                if x_i == y_i
                    push!(ind, idx)
                    break
                end
            end
        end
        return ind
    end
end

_to_step(x, ::O, ::O) where {O<:Ordering} = x
_to_step(x, ::Ordering, ::Ordering) = -x

# TODO Does it matter what paramters are in the return empty range


@propagate_inbounds function _findin_range(x, y::AbstractRange)
    range_generator = similar_range(x, y)
    if isempty(x) | isempty(y)
        return range_generator(1, step = 1, length=0)
    else
        sx = step(x)
        sy = step(y)
        sxy = div(sx, sy)
        if iszero(sxy)
            if iszero(rem(minimum(x) - minimum(y), div(sxy, sx)))
                start = _find_first_in(x, y)
                stop = _find_last_in(x, y)
                #return similar_range(x, y)(fi, step=_to_step(1, xo, yo), stop=li)
            else
                start = oneunit(sxy)
                sxy = oneunit(sxy)
                stop = start - sxy
            end
        elseif iszero(rem(minimum(x) - minimum(y), div(sxy, sx)))
            start = _find_first_in(x, y)
            stop = _find_last_in(x, y)
        else
            start = oneunit(sxy)
            sxy = oneunit(sxy)
            stop = start - sxy
        end
        return range_generator(start, step=sxy, stop=stop)
    end
end

# FIXME this has all sorts of potential problems
#=function _findin(x::AbstractUnitRange{T}, xo, y::AbstractRange{T}, yo) where {T}
    local ifirst
    local ilast
    fspan = first(x)
    lspan = last(x)
    fr = first(y)
    lr = last(y)
    sr = step(y)
    if sr > 0
        ifirst = fr >= fspan ? 1 : ceil(Integer,(fspan-fr)/sr)+1
        ilast = lr <= lspan ? length(y) : length(y) - ceil(Integer,(lr-lspan)/sr)
    elseif sr < 0
        ifirst = fr <= lspan ? 1 : ceil(Integer,(lspan-fr)/sr)+1
        ilast = lr >= fspan ? length(y) : length(y) - ceil(Integer,(lr-fspan)/sr)
    else
        ifirst = fr >= fspan ? 1 : length(y)+1
        ilast = fr <= lspan ? length(y) : 0
    end
    return ifirst:ilast
end
=#

# find all values of x in y
@inline function findin(x::Interval{:closed,:closed,T}, y) where {T}
    return intersect(find_allgteq(x.left, y), find_alllteq(x.right, y))
end

@inline function findin(x::Interval{:closed,:open,T}, y) where {T}
    return intersect(find_allgteq(x.left, y), find_alllt(x.right, y))
end
@inline function findin(x::Interval{:open,:closed,T}, y) where {T}
    return intersect(find_allgt(x.left, y), find_alllteq(x.right, y))
end
@inline function findin(x::Interval{:open,:open,T}, y) where {T}
    return intersect(find_allgt(x.left, y), find_alllt(x.right, y))
end

###
### OneToUnion
###
@inline function _findin_oneto(x, y::OneToUnion{<:Integer})
    return promote_type(typeof(x), typeof(y))(min(last(x), last(y)))
end
@inline function _findin_oneto(x, y::AbstractUnitRange{<:Integer})
    return promote_type(typeof(x), typeof(y))(max(1, first(y)), min(last(x), last(y)))
end
@inline function _findin_oneto(x, y::AbstractUnitRange{T}) where {T}
    if (first(y) - round(y)) == 0
        return promote_type(typeof(x), typeof(y))(max(1, first(y)), min(last(x), last(y)))
    else
        return promote_type(typeof(x), typeof(y))(1, 0)
    end
end
_findin_oneto(x, y::AbstractRange{T}) where {T} = findin(promot(x, y)...)

###
### AbstractUnitRange
###
@inline function _findin_unit(x::AbstractUnitRange{T1}, y::AbstractUnitRange{T2}) where {T1<:Integer,T2<:Integer}
    xstart = first(x)
    ystart = first(y)
    xstop = last(x)
    ystop = last(y)
    start = ystart > xstart ? firstindex(y) : find_firsteq(xstart, y)
    stop = ystop > xstop ? find_firsteq(xstop, y) : lastindex(y)
    return promote_type(typeof(x), typeof(y))(start, stop)
end
function _findin_unit(x::AbstractUnitRange{T1}, y::OrdinalRange{T2}) where {T1<:Integer,T2<:Integer}
    R = promote_type(typeof(x), typeof(y))
    if isempty(x) | isempty(y)
        return R(1, 1, 0)
    elseif step(y) > 0
        sta = first(y)
        ste = step(y)
        sto = last(y)
        lo = first(x)
        hi = last(x)
        start = max(sta, lo + mod(sta - lo, ste))
        stop = min(sto, hi - mod(hi - sta, ste))
        return R(find_firsteq(start, y), 1, find_firsteq(stop, y))
    else  # step(x) < 0
        sta = first(y)
        ste = step(y)
        sto = last(y)
        lo = first(x)
        hi = last(x)
        start = max(sta, lo + mod(sta - lo, ste))
        stop = min(sto, hi - mod(hi - sta, ste))
        return R(find_firsteq(stop, y), -1, find_firsteq(start, y))
    end
end
function _findin_unit(x::AbstractUnitRange{T1}, y::OrdinalRange{T2}) where {T1,T2}
    return findin(promot(x, y)...)
end

function _findin_unit(x::AbstractUnitRange{T}, y::AbstractUnitRange{T}) where {T}
    xstart = first(x)
    ystart = first(y)
    xstop = last(x)
    ystop = last(y)
    R = promote_type(typeof(x), typeof(y))
    if (xstart - 1) == (ystart - 1)
        start = ystart > xstart ? firstindex(y) : find_firsteq(xstart, y)
        stop = ystop > xstop ? find_firsteq(xstop, y) : lastindex(y)
        return R(start, stop)
    else
        return R(1, 0)
    end
end

_findin_unit(x::AbstractUnitRange{T}, y) where {T} = _findin_unit(promote(x, y)...)


###
### OrdinalRange
###
#=function _findin_step(x::OrdinalRange{T1}, y::AbstractUnitRange{T2}) where {T1<:Integer,T2<:Integer}
    R = promote_type(typeof(x), typeof(y))
    if isempty(x) | isempty(y)
        return R(1, 1, 0)
    elseif step(x) > 0
        sta = first(x)
        ste = step(x)
        sto = last(x)
        lo = first(y)
        hi = last(y)
        start = max(sta, lo + mod(sta - lo, ste))
        stop = min(sto, hi - mod(hi - sta, ste))
        return R(find_firsteq(start, y), ste, find_firsteq(stop, y))
    else  # step(x) < 0
        sta = first(x)
        ste = step(x)
        sto = last(x)
        lo = first(y)
        hi = last(y)
        start = max(sta, lo + mod(sta - lo, ste))
        stop = min(sto, hi - mod(hi - sta, ste))
        return R(find_firsteq(stop, y), ste, find_firsteq(start, y))
    end
end
_findin_step(x::OrdinalRange{T}, y::OrdinalRange{T}) where {T}
=#
#=
@inline function _findin(x::OneToUnion{<:Integer}, y::OneToUnion{<:Integer})
    R = 
    stop = 
    if is_static(R)
        return UnitSRange(1, stop)
    elseif is_fixed(R)
        return UnitRange(1, stop)
    else
        return UnitMRange(1, stop)
    end
end
=#

=#
