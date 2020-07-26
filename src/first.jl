
# TODO move this first(x)
Base.first(::OneToRange{T}) where {T} = one(T)

Base.first(::UnitSRange{T,F,L}) where {T,F,L} = F

Base.first(r::UnitMRange) = getfield(r, :start)

Base.first(r::StepSRange{T,Ts,F,S,L}) where {T,Ts,F,S,L} = F

Base.first(r::StepMRange) = getfield(r, :start)

Base.first(::LinSRange{T,B,E,L,D}) where {T,B,E,L,D} = B

Base.first(r::LinMRange) = getfield(r, :start)

Base.first(r::AbstractStepRangeLen) = unsafe_getindex(r, 1)

has_ref(x) = has_ref(typeof(x))
has_ref(::Type{T}) where {T} = false
has_ref(::Type{StepRangeLen{T,R,S}}) where {T,R,S} = true
has_ref(::Type{StepMRangeLen{T,R,S}}) where {T,R,S} = true
has_ref(::Type{<:StepSRangeLen{T,R,S}}) where {T,R,S} = true

ref_type(x) = ref_type(typeof(x))
ref_type(::Type{StepRangeLen{T,R,S}}) where {T,R,S} = R
ref_type(::Type{StepMRangeLen{T,R,S}}) where {T,R,S} = R
ref_type(::Type{<:StepSRangeLen{T,R,S}}) where {T,R,S} = R

"""
    refhi(x::AbstractStepRangeLen)

Returns the `hi` component of a twice precision ref.
"""
refhi(::StepSRangeLen{T,Tr,Ts,R,S,L,F}) where {T,Tr<:TwicePrecision,Ts,R,S,L,F} = gethi(R)
refhi(r::StepMRangeLen{T,R,S}) where {T,R<:TwicePrecision,S} = r.ref.hi
refhi(r::StepRangeLen{T,R,S}) where {T,R<:TwicePrecision,S} = r.ref.hi

"""
    reflo(x::AbstractStepRangeLen)

Returns the `lo` component of a twice precision ref.
"""
reflo(::StepSRangeLen{T,Tr,Ts,R,S,L,F}) where {T,Tr<:TwicePrecision,Ts,R,S,L,F} = getlo(R)
reflo(r::StepMRangeLen{T,R,S}) where {T,R<:TwicePrecision,S} = r.ref.lo
reflo(r::StepRangeLen{T,R,S}) where {T,R<:TwicePrecision,S} = r.ref.lo

"""
    can_set_first(x) -> Bool

Returns `true` if the first element of `x` can be set. If `x` is a range then
changing the first element will also change the length of `x`.
"""
can_set_first(x) = can_set_first(typeof(x))
can_set_first(::Type{T}) where {T} = can_setindex(T)
can_set_first(::Type{T}) where {T<:AbstractRange} = is_dynamic(T)
function can_set_first(::Type{T}) where {T<:AbstractUnitRange}
    return is_dynamic(T) && known_first(T) === nothing
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

function set_first!(x::AbstractRange{T}, val) where {T}
    if has_ref(x)
        setfield!(x, :ref, ref_type(x)(val) - (1 - x.offset) * step_hp(x))
    else
        setfield!(x, :start, T(val))
    end
    return x
end

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
        return pushfirst(x, val)
    elseif length(x) == 1
        return similar_type(x)([val])
    else
        return pushfirst(@inbounds(x[2:end]), val)
    end
end

set_first(x::OrdinalRange, val) = typeof(x)(val, step(x), last(x))

set_first(x::AbstractUnitRange{T}, val) where {T} = typeof(x)(T(val), last(x))

function set_first(x::AbstractRange, val)
    if has_ref(x)
        return typeof(x)(val, step(x), x.len, x.offset)
    else
        return typeof(x)(val, last(x), x.len)
    end
end
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

