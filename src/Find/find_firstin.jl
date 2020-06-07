
"""
    find_firstin(x, y)

Find the first value of `x` that is found in `y` and return it's index in `y`.
"""
function find_firstin(x, y)
    if isempty(x) || isempty(y)
        return nothing
    elseif _steps_overlap(x, y)
        return _find_firstin(x, y)
    else
        return nothing
    end
end

function unsafe_find_firstin(x, y)
    if is_forward(x)
        if is_forward(y)
        else
        end
    else
    end
end

function unsafe_find_firstin_ff(x, y)
    searchval = first(x)
    while true
        index = unsafe_find_firstgteq(searchval, y)
        if index isa Nothing
            return nothing
        else
            newval = @inbounds(getindex(y, index))
            if newval == searchval
                return index
            else
                index = find_firstgtteq(newval, x)
                if index isa Nothing
                    return nothing
                else
                    searchval = @inbounds(getindex(x, index))
                end
            end
        end
    end
end

function unsafe_find_firstin_fr(x, y)
    searchval = first(x)
    while true
        index = unsafe_find_lastgteq(searchval, y)
        if index isa Nothing
            return nothing
        else
            newval = @inbounds(getindex(y, index))
            if newval == searchval
                return index
            else
                index = find_firstgteq(newval, x)
                if index isa Nothing
                    return nothing
                else
                    searchval = @inbounds(getindex(x, index))
                end
            end
        end
    end
end

function unsafe_find_firstin_rr(x, y)
    searchval = first(x)
    while true
        index = unsafe_find_lastgteq(searchval, y)
        if index isa Nothing
            return nothing
        else
            newval = @inbounds(getindex(y, index))
            if newval == searchval
                return index
            else
                index = find_firstlteq(newval, x)
                if index isa Nothing
                    return nothing
                else
                    searchval = @inbounds(getindex(x, index))
                end
            end
        end
    end
end

function unsafe_find_firstin_rf(x, y)
    searchval = first(x)
    while true
        index = unsafe_find_lastlteq(searchval, y)
        if index isa Nothing
            return nothing
        else
            newval = @inbounds(getindex(y, index))
            if newval == searchval
                return index
            else
                index = find_firstlteq(newval, x)
                if index isa Nothing
                    return nothing
                else
                    searchval = @inbounds(getindex(x, index))
                end
            end
        end
    end
end


###
### OneToUnion
###
unsafe_find_firstin(x::OneToUnion, y::OneToUnion) = firstindex(y)

function find_firstin(x::OneToUnion{<:Integer}, y::AbstractUnitRange{T}) where {T}
    if
        return nothing
    elseif iszero(rem(first(x) - first(y), 1))
        # -> _find_firstin(::AbstractUnitRange, ::AbstractUnitRange)
        return _find_firstin(x, y)
    else
        return nothing
    end
end

function find_firstin(x::OneToUnion{<:Integer}, y::AbstractRange{<:Integer})
    if isempty(x) || isempty(y)
        return nothing
    else
        # -> _find_firstin(::AbstractUnitRange, ::AbstractUnitRange)
        # -> _find_firstin(::AbstractUnitRange, ::AbstractRange)
        return _find_firstin(x, y)
    end
end

###
### AbstractUnitRange
###
function find_firstin(x::OneToUnion{<:Integer}, y::OneToUnion{<:Integer})
    if isempty(x) || isempty(y)
        return nothing
    else
        return _find_firstin(x, y)
    end
end

###
### ranges
###
_find_first_in_isempty(x::AbstractRange, y::AbstractRange) = 1:0

function find_firstin(x::AbstractRange, y::AbstractRange)
    if isempty(x) || isempty(y)
        return _find_first_in_isempty(x, y)
    else
        return _find_first_notempty(x, y)
    end
end

function _find_firstin(x::AbstractRange{T1}, y::AbstractRange{T2}) where {T1,T2}
    return _find_firstin(promote(x, y)...)
end

_find_firstin_notempty(x::AbstractUnitRange, y::AbstractUnitRange) = firstindex(y)

###
### AbstractUnitRange
###
@inline function _find_firstin(x::AbstractUnitRange{<:Integer}, y::AbstractUnitRange{<:Integer})
    if isempty(x) || isempty(y)
        return nothing
    else
        return _find_firstin_notempty(x, y)
    end
end

@inline function _find_firstin(x::AbstractUnitRange{T}, y::AbstractUnitRange{T}) where {T}
    if iszero(rem(first(x) - first(y), 1))
        return _find_firstin_notempty(x, y)
    else
        return nothing
    end
end

function _find_firstin_notempty(x::AbstractUnitRange, y::AbstractUnitRange)
    fx = first(x)
    fy = first(y)
    if fx < fy
        lx = last(x)
        if lx >= fy
            return firstindex(y)
        else
            return nothing
        end
    elseif fx == fy
        return firstindex(y)
    else
        ly = last(y)
        if fx < ly
            return unsafe_findvalue(fx, y)
        elseif fx == ly
            return lastindex(y)
        else
            return nothing
        end
    end
end

###
### OrdinalRange
###
function _find_firstin(x::AbstractRange{T}, y::AbstractRange{T}) where {T}
    sx = step(x)
    sy = step(y)
    sxy = div(sx, sy)
    if iszero(sxy)
        if iszero(rem(minimum(x) - minimum(y), div(div(sy, sx), sx)))
            return __find_firstin(x, y)
        else
            return nothing
        end
    else
        if iszero(rem(minimum(x) - minimum(y), div(sxy, sx)))
            return __find_firstin(x, y)
        else
            return nothing
        end
    end
end

function _find_firstin_notempty(x::AbstractRange, y::AbstractRange)
    sx = step(x)
    sy = step(y)
    sxy = div(sx, sy)
    if iszero(sxy)
        if iszero(rem(minimum(x) - minimum(y), div(div(sy, sx), sx)))
            return __find_firstin(x, y, )
        else
            return nothing
        end
    else
        if iszero(rem(minimum(x) - minimum(y), div(sxy, sx)))
            return __find_firstin(x, y)
        else
            return nothing
        end
    end
end

#=
function fxn()
    out = 1
    if is_forward(x) && is_forward(y)
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
=#

# TODO
function _find_firstin(::AbstractUnitRange, ::OrdinalRange) end


###
### Neither range is empty and steps overlap in some way
###

unsafe_find_firstin(x::OneToUnion, y::OneToUnion) = firstindex(y)

function unsafe_find_firstin(x::AbstractUnitRange, y::AbstractRange)

    fx = first(x)
    fy = first(y)
    if fx < fy
        lx = last(x)
        if lx >= fy
            return firstindex(y)
        else
            return nothing
        end
    elseif fx == fy
        return firstindex(y)
    else
        ly = last(y)
        if fx < ly
            return unsafe_findvalue(fx, y)
        elseif fx == ly
            return lastindex(y)
        else
            return nothing
        end
    end
end

function unsafe_find_firstin(x::AbstractRange, y::AbstractUnitRange)
    fx = first(x)
    fy = first(y)
    if fx < fy
        lx = last(x)
        if lx >= fy
            return firstindex(y)
        else
            return nothing
        end
    elseif fx == fy
        return firstindex(y)
    else
        ly = last(y)
        if fx < ly
            return unsafe_findvalue(fx, y)
        elseif fx == ly
            return lastindex(y)
        else
            return nothing
        end
    end
end
