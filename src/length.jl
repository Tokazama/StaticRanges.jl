###
### length
###
@inline function _unit_range_length(start::T, stop::T) where {T<:Union{Int,Int64,Int128}}
    if stop < start
        return zero(T)
    else
        return Int(Base.checked_add(stop - start, one(T)))
    end
end
@inline function _unit_range_length(start::T, stop::T) where {T<:Union{UInt,UInt64,UInt128}}
    if stop < start
        return 0
    else
        return Int(Base.checked_add(Base.checked_sub(stop, start), one(T)))
    end
end
@inline function _unit_range_length(start::T, stop::T) where {T}
    if stop < start
        return 0
    else
        return Int(stop - start + 1)
    end
end

@inline function _step_range_length(start::T, step, stop::T) where {T}
    if (start != stop) & ((step > zero(step)) != (stop > start))
        return 0
    else
        return Int(div((stop - start) + step, step))
    end
end
@inline function _step_range_length(start::T, step, stop::T) where {T<:Union{Int,UInt,Int64,UInt64,Int128,UInt128}}
    if (start != stop) & ((step > zero(step)) != (stop > start))
        return 0
    elseif step > 1
        return Int(Base.checked_add(convert(T, div(unsigned(stop - start), step)), one(T)))
    elseif step < -1
        return Int(Base.checked_add(convert(T, div(unsigned(start - stop), -step)), one(T)))
    elseif step > 0
        return Int(Base.checked_add(div(Base.checked_sub(stop, start), step), one(T)))
    else
        return Int(Base.checked_add(div(Base.checked_sub(start, stop), -step), one(T)))
    end
end

ArrayInterface.known_length(::Type{T}) where {T<:OneToSRange} = known_last(T)
function ArrayInterface.known_length(::Type{T}) where {T<:UnitSRange}
    return _unit_range_length(known_first(T), known_last(T))
end
function ArrayInterface.known_length(::Type{T}) where {T<:StepSRange}
    return _step_range_length(known_first(T), known_step(T), known_last(T))
end
ArrayInterface.known_length(::Type{<:LinSRange{<:Any,<:Any,<:Any,L}}) where {L} = L
ArrayInterface.known_length(::Type{<:StepSRangeLen{<:Any,<:Any,<:Any,<:Any,<:Any,L}}) where {L} = L

Base.length(x::OneToRange) = last(x)
Base.length(x::UnitSRange) = known_length(x)
Base.length(x::UnitMRange) = _unit_range_length(first(x), last(x))
Base.length(x::StepSRange) = known_length(x)
Base.length(x::StepMRange) = _step_range_length(first(x), step(x), last(x))
Base.length(x::LinSRange) = known_length(x)
Base.length(x::LinMRange) = getfield(x, :len)
Base.length(x::StepSRangeLen) = known_length(x)
Base.length(x::StepMRangeLen) = getfield(x, :len)


lendiv(::LinSRange{T,B,E,L,D}) where {T,B,E,L,D} = D

lendiv(r::LinMRange) = getfield(r, :lendiv)

# some special cases to favor default Int type


"""
    can_set_length(x) -> Bool

Returns `true` if type of `x` can have its length set independent of changing
its first or last position.
"""
can_set_length(::T) where {T} = can_set_length(T)
can_set_length(::Type{T}) where {T} = false
can_set_length(::Type{T}) where {T<:AbstractRange} = can_change_size(T)

"""
    set_length!(x, len)

Returns a similar type as `x` with a length equal to `len`.

## Examples
```jldoctest
julia> using StaticRanges

julia> mr = UnitMRange(1, 10);

julia> set_length!(mr, 20);

julia> length(mr)
20
```
"""
function set_length!(x::LinMRange{T}, len) where {T}
    len >= 0 || throw(ArgumentError("set_length!($x, $len): negative length"))
    if len == 1
        x.start == x.stop || throw(ArgumentError("set_length!($x, $len): endpoints differ"))
        setfield!(x, :len, 1)
        setfield!(x, :lendiv, 1)
    else
        setfield!(x, :len, Int(len))
        setfield!(x, :lendiv, Int(max(len - 1, 1)))
    end
    return x
end

function set_length!(x::StepMRangeLen, len)
    len >= 0 || throw(ArgumentError("length cannot be negative, got $len"))
    1 <= x.offset <= max(1,len) || throw(ArgumentError("StepMRangeLen: offset must be in [1,$len], got $offset"))
    setfield!(x, :len, Int(len))
    return x
end

function set_length!(x::OrdinalRange{T}, len) where {T}
    can_set_length(x) || throw(MethodError(set_length!, (x, len)))
    setfield!(x, :stop, convert(T, first(x) + step(x) * (len - 1)))
    return x
end

function set_length!(x::AbstractUnitRange{T}, len) where {T}
    can_set_length(x) || throw(MethodError(set_length!, (x, len)))
    if known_first(x) === one(T)
        set_last!(x, len)
    else
        set_last!(x, T(first(x)+len-1))
    end
    return x
end

"""
    set_length(x, len)

Change the length of `x` while maintaining it's first and last positions.

## Examples
```jldoctest
julia> using StaticRanges

julia> set_length(1:10, 20)
1:20
```
"""
set_length(x::AbstractStepRangeLen, len) = typeof(x)(x.ref, x.step, len, x.offset)
set_length(x::StepRangeLen, len) = typeof(x)(x.ref, x.step, len, x.offset)
set_length(x::LinRange, len) = typeof(x)(first(x), last(x), len)
set_length(x::AbstractLinRange, len) = typeof(x)(first(x), last(x), len)

function set_length(x::AbstractUnitRange{T}, len) where {T}
    if known_first(x) === oneunit(T)
        return set_last(x, len)
    else
        return set_last(x, T(first(x)+len-1))
    end
end

function set_length(x::OrdinalRange{T}, len) where {T}
    return set_last(x, convert(T, first(x) + step(x) * (len - 1)))
end

"""
    set_lendiv!(r, d)

Change the length of `x` while maintaining it's first and last positions.
"""
set_lendiv!(r::LinMRange, d) = set_lendiv!(r, Int(d))
function set_lendiv!(r::LinMRange, d::Int)
    d >= 0 || throw(ArgumentError("set_length!($r, $d): negative length"))
    #=
    we don't do this because on the off chance the user is intentionally
    setting lendiv we can't know if they want the length also set to 1 or 2
    if d == 1
        r.start == r.stop || throw(ArgumentError("set_length!($r, $len): endpoints differ"))
        setfield!(r, :len, 1)
        setfield!(r, :lendiv, 1)
        return r
    end
    =#
    setfield!(r, :len, d + 1)
    setfield!(r, :lendiv, d)
    return r
end

