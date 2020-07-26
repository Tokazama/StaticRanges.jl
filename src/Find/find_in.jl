# find x in y

# find all values of x in y
@inline function find_in(x::Interval{:closed,:closed,T}, y) where {T}
    return intersect(find_allgteq(x.left, y), find_alllteq(x.right, y))
end

@inline function find_in(x::Interval{:closed,:open,T}, y) where {T}
    return intersect(find_allgteq(x.left, y), find_alllt(x.right, y))
end
@inline function find_in(x::Interval{:open,:closed,T}, y) where {T}
    return intersect(find_allgt(x.left, y), find_alllteq(x.right, y))
end
@inline function find_in(x::Interval{:open,:open,T}, y) where {T}
    return intersect(find_allgt(x.left, y), find_alllt(x.right, y))
end

function find_in(x::AbstractArray, y)
    out = Vector{Int}()
    for x_i in x
        idx = find_firsteq(x_i, y)
        if !isa(idx, Nothing)
            push!(out, idx)
        end
    end
    return out
end

###
### AbstractRange
###
@inline function find_in(x::AbstractRange, y)
    if y isa AbstractRange
        if step_is_one(x)
            if step_is_one(y)
                return _find_in_ur_ur(x, y)
            else
                return _find_in(x, y)
            end
        else
            if step_is_one(x)
                return _find_in(x, y)
            else
                return _find_in(x, y)
            end
        end
    else
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
end

function _find_in_ur_ur(x::AbstractRange{<:Integer}, y::AbstractRange{<:Integer})
    if first_is_one(x) && first_is_one(y)
        return promote_type(typeof(x), typeof(y))(min(last(x), last(y)))
    else
        return promote_type(typeof(x), typeof(y))(_find_first_in(x, y), _find_last_in(x, y))
    end
end

function _find_in_ur_ur(x::AbstractRange, y::AbstractRange)
    R = similar_type(promote_type(typeof(x), typeof(y)), Int)
    if !iszero(rem(first(x) - first(y), 1))
        return R(1, 0)
    else
        return R(_find_first_in(x, y), _find_last_in(x, y))
    end
end

_find_in(x::AbstractUnitRange, y::AbstractUnitRange) = _find_in(promote(x, y)...)

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

function _to_step(x, sx, sy)
    if sign(sx) == sign(sy)
        return x
    else
        return -x
    end
end

function _find_in(x::AbstractRange{T1}, y::AbstractRange{T2}) where {T1,T2}
    return _find_in(promote(x, y)...)
end

function _find_in(x::AbstractRange{T}, y::AbstractRange{T}) where {T}
    sx = drop_unit(step(x))
    sy = drop_unit(step(y))
    sxy = div(sx, sy)
    if iszero(sxy)
        sxy = div(sy, sx)
        if !iszero(rem(drop_unit(minimum(x)) - drop_unit(minimum(y)), div(sxy, sx)))
            return 1:1:0
        else
            fi = _find_first_in(x, y)
            li = _find_last_in(x, y)
            return fi:_to_step(1, sx, sy):li
        end
    else
        if !iszero(rem(drop_unit(minimum(x)) - drop_unit(minimum(y)), div(sxy, sx)))
            return 1:1:0
        else
            fi = _find_first_in(x, y)
            li = _find_last_in(x, y)
            return fi:_to_step(Int(sxy), sx, sy):li
        end
    end
end
