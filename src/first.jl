
ArrayInterface.known_first(::Type{<:OneToRange{T}}) where {T} = one(T)
ArrayInterface.known_first(::Type{<:UnitSRange{<:Any,F}}) where {F} = F
ArrayInterface.known_first(::Type{<:StepSRange{<:Any,<:Any,F}}) where {F} = F
ArrayInterface.known_first(::Type{<:LinSRange{<:Any,B}}) where {B} = B

# TODO move this first(x)
Base.first(::OneToRange{T}) where {T} = one(T)
Base.first(r::UnitSRange) = known_first(r)
Base.first(r::UnitMRange) = getfield(r, :start)
Base.first(r::StepSRange) = known_first(r)
Base.first(r::StepMRange) = getfield(r, :start)
Base.first(r::LinSRange) = known_first(r)
Base.first(r::LinMRange) = getfield(r, :start)
Base.first(r::AbstractStepRangeLen) = unsafe_getindex(r, 1)

"""
    can_set_first(x) -> Bool

Returns `true` if the first element of `x` can be set. If `x` is a range then
changing the first element will also change the length of `x`.
"""
can_set_first(x) = can_set_first(typeof(x))
can_set_first(::Type{T}) where {T} = can_setindex(T)
function can_set_first(::Type{T}) where {T<:AbstractRange}
    return can_change_size(T) && known_first(T) === nothing
end

"""
    set_first!(x, val)

Set the first element of `x` to `val`.

## Examples
```jldoctest
julia> using StaticRanges

julia> mr = UnitMRange(1, 10);

julia> set_first!(mr, 2);

julia> first(mr)
2
```
"""
function set_first!(x::AbstractVector{T}, val) where {T}
    can_set_first(x) || throw(MethodError(set_first!, (x, val)))
    setindex!(x, T(val), firstindex(x))
    return x
end

function set_first!(x::AbstractUnitRange{T}, val) where {T}
    can_set_first(x) || throw(MethodError(set_first!, (x, val)))
    setfield!(x, :start, T(val))
    return x
end

function set_first!(x::OrdinalRange{T,S}, val) where {T,S}
    can_set_first(x) || throw(MethodError(set_first!, (x, val)))
    val2 = T(val)
    setfield!(x, :start, val2)
    setfield!(x, :stop, Base.steprange_last(val2, step(x), last(x)))
    return x
end

function set_first!(x::StepMRangeLen{T,R}, val) where {T,R}
    return setfield!(x, :ref, R(val) - (1 - x.offset) * step_hp(x))
end
set_first!(x::LinMRange{T}, val) where {T} = (setfield!(x, :start, T(val)); x)

"""
    set_first(x, val)

Returns similar type as `x` with first value set to `val`.

## Examples
```julia
julia> using StaticRanges

julia> r = set_first(1:10, 2)
2:10
```
"""
function set_first(x::AbstractVector, val)
    if isempty(x)
        return vcat(x, val)
    elseif length(x) == 1
        return vcat(empty(x), val)
    else
        return vcat(val, @inbounds(x[2:end]))
    end
end

set_first(x::OrdinalRange, val) = typeof(x)(val, step(x), last(x))

set_first(x::AbstractUnitRange{T}, val) where {T} = typeof(x)(T(val), last(x))

set_first(x::AbstractStepRangeLen, val) = typeof(x)(val, step(x), x.len, x.offset)
set_first(x::StepRangeLen, val) = typeof(x)(val, step(x), x.len, x.offset)

set_first(x::LinRange, val) = typeof(x)(val, last(x), x.len)
set_first(x::AbstractLinRange, val) = typeof(x)(val, last(x), x.len)

#= FIXME
  MethodError: no method matching StepSRangeLen{Int64,Int64,Int64,1,1,3,1}(::Int64, ::Int64, ::Int64, ::Int64)
  Stacktrace:
=#


"""
    set_offset!(x, val)

Set the offset field of an instance of `StepMRangeLen`.
"""
function set_offset!(r::StepMRangeLen, val::Int)
    if 1 > val > max(1, r.len)
        throw(ArgumentError("StepMRangeLen: offset must be in [1,$(r.len)], got $(r.offset)"))
    end
    setfield!(r, :offset, val)
    return r
end
set_offset!(r::StepMRangeLen, val) = set_offset!(r, Int(val))

