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

findin(x::AbstractRange, y) = _findin(x, y)

function _find_first_in(x, y)
    out = 1
    if is_forward(x) & is_forward(y)
        for x_i in x
            idx = find_firsteq(x_i, y)
            if !isa(idx, Nothing)
                out = idx
                break
            end
        end
    else
        for x_i in x
            idx = find_lasteq(x_i, y)
            if !isa(idx, Nothing)
                out = idx
                break
            end
        end
    end
    return out
end

function _find_last_in(x, y)
    out = 0
    if is_forward(x) & is_forward(y)
        for x_i in reverse(x)
            idx = find_firsteq(x_i, y)
            if !isa(idx, Nothing)
                out = idx
                break
            end
        end
    else
        for x_i in reverse(x)
            idx = find_lasteq(x_i, y)
            if !isa(idx, Nothing)
                out = idx
                break
            end
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

