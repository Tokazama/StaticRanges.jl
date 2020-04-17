
### OneToRange
Base.step(::OneToRange{T}) where {T} = one(T)

### AbstractStepRangeLen
Base.step(::StepSRangeLen{T,Tr,Ts,R,S,L,F}) where {T,Tr,Ts,R,S,L,F} = convert(T, S)
Base.step_hp(::StepSRangeLen{T,Tr,Ts,R,S}) where {T,Tr,Ts<:TwicePrecision,R,S} = convert(Ts, S)
Base.step_hp(::StepSRangeLen{T,Tr,Ts,R,S}) where {T,Tr,Ts,R,S} = S

Base.step_hp(r::StepMRangeLen) = getfield(r, :step)
Base.step(r::StepMRangeLen{T}) where {T} = T(step_hp(r))
Base.step(r::AbstractLinRange) = (last(r)-first(r)) / lendiv(r)

"""
    stephi(x::AbstractStepRangeLen)

Returns the `hi` component of a twice precision step.
"""
stephi(::StepSRangeLen{T,Tr,Ts,R,S}) where {T,Tr,Ts<:TwicePrecision,R,S} = gethi(S)
stephi(r::StepMRangeLen{T,R,S}) where {T,R,S<:TwicePrecision} = r.step.hi
stephi(r::StepRangeLen{T,R,S}) where {T,R,S<:TwicePrecision} = r.step.hi

"""
    steplo(x::AbstractStepRangeLen)

Returns the `lo` component of a twice precision step.
"""
steplo(::StepSRangeLen{T,Tr,Ts,R,S}) where {T,Tr,Ts<:TwicePrecision,R,S} = getlo(S)
steplo(r::StepMRangeLen{T,R,S}) where {T,R,S<:TwicePrecision} = r.step.lo
steplo(r::StepRangeLen{T,R,S}) where {T,R,S<:TwicePrecision} = r.step.lo

### AbstractStepRange
Base.step(r::StepSRange{T,Ts,F,S,L}) where {T,Ts,F,S,L} = S
Base.step(r::StepMRange) = getfield(r, :step)

"""
    has_step(x) -> Bool

Returns `true` if type of `x` has `step` method defined.
"""
has_step(::T) where {T} = has_step(T)
has_step(::Type{T}) where {T} = false
has_step(::Type{T}) where {T<:AbstractRange} = true

"""
    can_set_step(x) -> Bool

Returns `true` if type of `x` has `step` field that can be set.
"""
can_set_step(::T) where {T} = can_set_step(T)
can_set_step(::Type{T}) where {T} = false
can_set_step(::Type{T}) where {T<:StepMRange} = true
can_set_step(::Type{T}) where {T<:StepMRangeLen} = true

"""
    set_step!(x, st)

Sets the `step` of `x` to `val`.

## Examples
```jldoctest
julia> using StaticRanges

julia> mr = StepMRange(1, 1, 10);

julia> set_step!(mr, 2);

julia> step(mr)
2
```
"""
set_step!(x::UnitMRange, st) = error("Step size of UnitMRange type can only be 1.")
set_step!(x::OneToMRange, st) = error("Step size of OneToMRange type can only be 1.")
function set_step!(x::Union{StepMRange{T,S},StepMRangeLen{T,S}}, st) where {T,S}
    return set_step!(x, convert(S, st))
end
function set_step!(r::StepMRange{T,S}, st::S) where {T,S}
    setfield!(r, :step, st)
    setfield!(r, :stop, Base.steprange_last(first(r), st, last(r)))
    return r
end
function set_step!(r::StepMRangeLen{T,R,S}, st::S) where {T,R,S}
    setfield!(r, :step, st)
    return r
end

"""
    set_step(x, st)

Sets the `step` of `x` to `val`.

## Examples
```jldoctest
julia> using StaticRanges

julia> set_step(1:1:10, 2)
1:2:9
```
"""
function set_step(r::AbstractRange, st)
    if is_static(r)
        return srange(first(r), step=st, last(r))
    elseif is_fixed(r)
        return range(first(r), step=st, last(r))
    else
        return mrange(first(r), step=st, last(r))
    end
end

set_step(r::StepRangeLen, st) = StepRangeLen(r.ref, st, r.len, r.offset)
set_step(r::StepMRangeLen, st) = StepMRangeLen(r.ref, st, r.len, r.offset)
set_step(r::StepSRangeLen, st) = StepSRangeLen(r.ref, st, r.len, r.offset)

