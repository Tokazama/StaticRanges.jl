
# find x in y
@propagate_inbounds function _find_first_in(x, xo::O, y, yo::O) where {O<:Ordering}
    for x_i in x
        out = find_first(==(x_i), y, yo)
        out isa Nothing || return out
    end
    return 1
end

@propagate_inbounds function _find_first_in(x, xo::Ordering, y, yo::Ordering)
    for x_i in x
        out = find_last(==(x_i), y, yo)
        out isa Nothing || return out
    end
    return 1
end

@propagate_inbounds function _find_last_in(x, xo::O, y, yo::O) where {O<:Ordering}
    for x_i in reverse(x)
        out = find_first(==(x_i), y, yo)
        out isa Nothing || return out
    end
    return 0
end

@propagate_inbounds function _find_last_in(x, xo::Ordering, y, yo::Ordering)
    for x_i in reverse(x)
        out = find_last(==(x_i), y, yo)
        out isa Nothing || return out
    end
    return 0
end

@propagate_inbounds function _findin(x::AbstractUnitRange{<:Integer}, xo, y::AbstractUnitRange{<:Integer}, yo)
    return promote_type(typeof(x), typeof(y))(
        _find_first_in(x, xo, y, yo),
        _find_last_in(x, xo, y, yo)
    )
end

@propagate_inbounds function _findin(x::OneToUnion{<:Integer}, xo, y::OneToUnion{<:Integer}, yo)
    R = promote_type(typeof(x), typeof(y))
    stop = _find_last_in(x, xo, y, yo)
    if is_static(R)
        return UnitSRange(1, stop)
    elseif is_fixed(R)
        return UnitRange(1, stop)
    else
        return UnitMRange(1, stop)
    end
end

# TODO could place boundscheck for if operator here
@propagate_inbounds function _findin(x::AbstractUnitRange{T}, xo, y::AbstractUnitRange{T}, yo) where {T}
    R = similar_type(promote_type(typeof(x), typeof(y)), Int)
    if iszero(rem(first(x) - first(y), 1))
        return R(_find_first_in(x, xo, y, yo), _find_last_in(x, xo, y, yo))
    else
        return R(1, 0)
    end
end

@propagate_inbounds function _findin(x::AbstractUnitRange, xo, y::AbstractUnitRange, yo)
    xnew, ynew = promote(x, y)
    return _findin(xnew, xo, ynew, yo)
end

# TODO test to ensure every
@propagate_inbounds function _findin(x, xo, y, yo)
    if is_forward(xo) && is_forward(yo)
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
@propagate_inbounds function _findin(x::AbstractRange, xo, y::AbstractRange, yo)
    sx = step(x)
    sy = step(y)
    sxy = div(sx, sy)
    if iszero(sxy)
        sxy = div(sy, sx)
        if !iszero(rem(ordmin(x, xo) - ordmin(y, yo), div(sxy, sx)))
            return 1:1:0
        else
            fi = _find_first_in(x, xo, y, yo)
            li = _find_last_in(x, xo, y, yo)
            return similar_range(x, y)(fi, step=_to_step(1, xo, yo), stop=li)
        end
    elseif !iszero(rem(ordmin(x, xo) - ordmin(y, yo), div(sxy, sx)))
        return 1:1:0
    else
        fi = _find_first_in(x, xo, y, yo)
        li = _find_last_in(x, xo, y, yo)
        return similar_range(x, y)(fi, step=_to_step(Int(sxy), xo, yo), stop=li)
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

