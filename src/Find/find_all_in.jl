# find x in y

# find all values of x in y
@inline function find_all_in(x::Interval{:closed,:closed,T}, y) where {T}
    return intersect(find_allgteq(x.left, y), find_alllteq(x.right, y))
end

@inline function find_all_in(x::Interval{:closed,:open,T}, y) where {T}
    return intersect(find_allgteq(x.left, y), find_alllt(x.right, y))
end
@inline function find_all_in(x::Interval{:open,:closed,T}, y) where {T}
    return intersect(find_allgt(x.left, y), find_alllteq(x.right, y))
end
@inline function find_all_in(x::Interval{:open,:open,T}, y) where {T}
    return intersect(find_allgt(x.left, y), find_alllt(x.right, y))
end

@inline function find_all_in(x::X, y::Y) where {X,Y}
    if isempty(x) || isempty(y)
        return _empty(x, y)
    else
        return unsafe_find_all_in(x, y)
    end
end

function unsafe_find_all_in(x, y)
    if is_range(x)
        if known_step(x) === nothing
            return _unsafe_find_all_in_range(x, y)
        else
            if first_is_known_one(x)
                return _unsafe_find_all_in_one_to(x, y)
            else
                return _unsafe_find_all_in_unit_range(x, y)
            end
        end
    else
        return unsafe_find_all_in_vector(x, y)
    end
end

function unsafe_find_all_in_vector(x, y)
    out = Vector{Int}()
    for x_i in x
        idx = find_firsteq(x_i, y)
        if !isa(idx, Nothing)
            push!(out, idx)
        end
    end
    return out
end

function _unsafe_find_all_in_range(x::AbstractRange, y)
    if is_forward(x) && is_forward(y)  # TODO get rid of this
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
#=
@inline function unsafe_find_all_in(x::X, y::Y) where {X,Y}
    if is_range(X)
        if is_range(Y)
            return _unsafe_find_all_in(x, y)
        else
        end
    else
    end
end
=#

###
### AbstractRange
###
@inline function _unsafe_find_all_in(x, y)
    if known_step(x) === nothing
        return _unsafe_find_all_in_range(x, y)
    else
        if first_is_known_one(x)
            return _unsafe_find_all_in_one_to(x, y)
        else
            return _unsafe_find_all_in_unit_range(x, y)
        end
    end
end

#=
@inline function _unsafe_find_all_in_one_to(x::X, y::Y) where {X,Y}
    if step_is_known_one(y)
        if first_is_known_one(x)
            if known_last(x) !== nothing && known_last(y) !== nothing
                return OneToSRange(min(last(x), last(y)))
            else
                return  OneTo{Int}(min(last(x), last(y)))
            end
        else
            return _unsafe_find_all_unit_range_in_unit_range(x, y)
        end
    else
        return _unsafe_find_all_in_range(x, y)
    end
end
=#

@inline function _unsafe_find_all_in_one_to(x, y)
    if known_step(x) === nothing
        return unsafe_find_all_range_in_range(x, y)
    else
        if first_is_known_one(y)
            if known_last(x) isa Nothing || known_last(y) isa Nothing
                return  static(1):(min(last(x), last(y)))
            else
                return static(1):static(min(last(x), last(y)))
            end
        else
            return _unsafe_find_all_unit_range_in_unit_range(x, y)
        end
    end
end

@inline function _unsafe_find_all_in_unit_range(x::X, y::Y) where {X,Y}
    if known_step(x) === nothing
        return _unsafe_find_all_in_range(x, y)
    else
        return _unsafe_find_all_unit_range_in_unit_range(x, y)
    end
end

function _unsafe_find_all_unit_range_in_unit_range(x::AbstractRange{<:Integer}, y::AbstractRange{<:Integer})
    fstx, fsty = first(x), first(y)
    lstx, lsty = last(x), last(y)
    if known_first(x) === nothing || known_last(x) === nothing ||
       known_first(y) === nothing || known_last(y) === nothing
       return UnitRange(_find_first_in(x, y), _find_last_in(x, y))
    else
        return static(_find_first_in(x, y)):static(_find_last_in(x, y))
    end
end

function _unsafe_find_all_unit_range_in_unit_range(x::AbstractRange, y::AbstractRange)
    if !iszero(rem(first(x) - first(y), 1))
        fst = 1
        lst = 0
    else
        fst, lst = _find_first_in(x, y), _find_last_in(x, y)
    end

    if known_first(x) === nothing || known_last(x) === nothing ||
       known_first(y) === nothing || known_last(y) === nothing
        return UnitRange(fst, lst)
    else
        return static(fst):static(lst)
    end
end

#function _unsafe_find_all_unit_range_in_unit_range(x::AbstractUnitRange, y::AbstractUnitRange)
#    _find_all_in(promote(x, y)...)
#end

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

function _unsafe_find_all_in_range(x::AbstractRange{T1}, y::AbstractRange{T2}) where {T1,T2}
    return _unsafe_find_all_in_range(promote(x, y)...)
end

function _unsafe_find_all_in_range(x::AbstractRange{T}, y::AbstractRange{T}) where {T}
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

