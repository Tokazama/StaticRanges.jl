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

function findin(x::AbstractArray, y)
    out = Vector{Int}()
    for x_i in x
        idx = find_firsteq(x_i, y)
        if idx != nothing
            push!(out, idx)
        end
    end
    return out
end

###
### AbstractRange
###
findin(x::AbstractRange, y) = _findin(x, y)

function _findin(x::AbstractUnitRange{<:Integer}, y::AbstractUnitRange{<:Integer})
    return promote_type(typeof(x), typeof(y))(find_firstin(x, y), find_lastin(x, y))
end

function _findin(x::OneToUnion{<:Integer}, y::OneToUnion{<:Integer})
    return promote_type(typeof(x), typeof(y))(find_lastin(x, y))
end

function _findin(x::AbstractUnitRange{T}, y::AbstractUnitRange{T}) where {T}
    R = similar_type(promote_type(typeof(x), typeof(y)), Int)
    if !iszero(rem(first(x) - first(y), 1))
        return R(1, 0)
    else
        return R(find_firstin(x, y), find_lastin(x, y))
    end
end

_findin(x::AbstractUnitRange, y::AbstractUnitRange) = _findin(promote(x, y)...)

# TODO this needs to be optimized for ranges
function _findin(x, y)
    if (y isa AbstractRange) && (step(x) > 0) & (step(y) > 0)
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

function _findin(x::AbstractRange{T1}, y::AbstractRange{T2}) where {T1,T2}
    return _findin(promote(x, y)...)
end

function _findin(x::AbstractRange{T}, y::AbstractRange{T}) where {T<:Real}
    sx = step(x)
    sy = step(y)
    sxy = div(sx, sy)
    if iszero(sxy)
        sxy = div(sy, sx)
        if !iszero(rem(minimum(x) - minimum(y), div(sxy, sx)))
            return 1:1:0
        else
            fi = find_firstin(x, y)
            li = find_lastin(x, y)
            return fi:_to_step(1, sx, sy):li
        end
    else
        if !iszero(rem(minimum(x) - minimum(y), div(sxy, sx)))
            return 1:1:0
        else
            fi = find_firstin(x, y)
            li = find_lastin(x, y)
            return fi:_to_step(Int(sxy), sx, sy):li
        end
    end
end

# Ideally the previous _findin method could be used, but things like `div(::Second, ::Integer)`
# don't work. So this helps drop units by didingin by oneunit(::T) of the same type.
dropunit(x) = x / oneunit(x)

function _findin(x::AbstractRange{T}, y::AbstractRange{T}) where {T}
    sx = dropunit(step(x))
    sy = dropunit(step(y))
    sxy = div(sx, sy)
    minx = dropunit(minimum(x))
    miny = dropunit(minimum(y))
    if iszero(sxy)
        if !iszero(rem(minx - miny, div(sxy, sx)))
            return 1:1:0
        else
            fi = find_firstin(x, y)
            li = find_lastin(x, y)
            return fi:_to_step(1, sx, sy):li
        end
    else
        sxy = div(sy, sx)
        if !iszero(rem(minx - miny, div(sxy, sy)))
            return 1:1:0
        else
            fi = find_firstin(x, y)
            li = find_lastin(x, y)
            return fi:_to_step(Int(sxy), sx, sy):li
        end
    end
end
