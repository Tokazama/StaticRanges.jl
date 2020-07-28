
Base.last(::OneToSRange{T,E}) where {T,E} = E

Base.last(r::OneToMRange) = getfield(r, :stop)

Base.last(::UnitSRange{T,F,L}) where {T,F,L} = L

Base.last(r::UnitMRange) = getfield(r, :stop)

Base.last(r::StepSRange{T,Ts,F,S,L}) where {T,Ts,F,S,L} = L

Base.last(r::StepMRange) = getfield(r, :stop)

Base.last(r::AbstractStepRangeLen) = unsafe_getindex(r, length(r))

Base.last(::LinSRange{T,B,E,L,D}) where {T,B,E,L,D} = E

Base.last(r::LinMRange) = getfield(r, :stop)

"""
    can_set_last(x) -> Bool

Returns `true` if the last element of `x` can be set. If `x` is a range then
changing the first element will also change the length of `x`.
"""
can_set_last(x) = can_set_last(typeof(x))
can_set_last(::Type{T}) where {T} = can_setindex(T)
can_set_last(::Type{T}) where {T<:AbstractRange} = is_dynamic(T)

"""
    set_last!(x, val)

Set the last element of `x` to `val`.

## Examples
```julia
julia> using StaticRanges

julia> mr = UnitMRange(1, 10);

julia> set_last!(r, 5);

julia> last(mr)
5
```
"""
function set_last!(x::AbstractVector, val)
    can_set_last(x) || throw(MethodError(set_last!, (x, val)))
    setindex!(x, val, lastindex(x))
    return x
end
function set_last!(x::OrdinalRange{T}, val) where {T}
    can_set_last(x) || throw(MethodError(set_last!, (x, val)))
    setfield!(x, :stop, T(Base.steprange_last(first(x), step(x), val)))
    return x
end
function set_last!(x::AbstractUnitRange{T}, val) where {T}
    can_set_last(x) || throw(MethodError(set_last!, (x, val)))
    if known_first(x) === oneunit(T)
        setfield!(x, :stop, max(zero(T), T(val)))
    else
        setfield!(x, :stop, T(val))
    end
    return x
end

function set_last!(x::AbstractRange{T}, val) where {T}
    if has_ref(x)
        len = unsafe_findvalue(val, x) # FIXME should not use unsafe_findvalue at this point
        len >= 0 || throw(ArgumentError("length cannot be negative, got $len"))
        1 <= x.offset <= max(1, len) || throw(ArgumentError("StepSRangeLen: offset must be in [1,$len], got $(x.offset)"))
        setfield!(x, :len, len)
    else
        setfield!(x, :stop, T(val))
    end
    return x
end

"""
    set_last(x, val)

Returns a similar type as `x` with its last value equal to `val`.

## Examplse
```jldoctest
julia> using StaticRanges

julia> set_last(1:10, 5)
1:5
```
"""
function set_last(x::AbstractVector, val)
    if isempty(x)
        return push(x, val)
    elseif length(x) == 1
        return similar_type(x)([val])
    else
        return push(@inbounds(x[1:end-1]), val)
    end
end

set_last(x::OrdinalRange, val) = typeof(x)(first(x), step(x), val)
function set_last(x::AbstractUnitRange{T}, val) where {T}
    if RangeInterface.has_start_field(x)
        return typeof(x)(first(x), val)
    else
        return typeof(x)(val)
    end
    return x
end

function set_last(x::AbstractRange{T}, val) where {T}
    if has_ref(x)
        return typeof(x)(x.ref, x.step, unsafe_findvalue(val, x), x.offset)
    else
        return typeof(x)(first(x), val, x.len)
    end
end

