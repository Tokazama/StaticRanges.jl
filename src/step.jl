
# TODO better error messages for set_step

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
can_set_step(::Type{T}) where {T<:OrdinalRange} = is_dynamic(T)
can_set_step(::Type{T}) where {T<:AbstractRange} = is_dynamic(T) && is_steprangelen(T)
can_set_step(::Type{T}) where {T<:AbstractUnitRange} = false

step_type(x) = step_type(typeof(x))
step_type(::Type{<:AbstractRange{T}}) where {T} = T
step_type(::Type{<:OrdinalRange{T,S}}) where {T,S} = S
step_type(::Type{StepRangeLen{T,R,S}}) where {T,R,S} = S

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
function set_step!(x::AbstractRange, st)
    can_set_step(x) || throw(ArgumentError("cannot perform `set_step!` for type $x"))
    if has_ref(x)
        setfield!(x, :step, step_type(x)(st))
    else
        setfield!(x, :step, step_type(x)(st))
        setfield!(x, :stop, Base.steprange_last(first(x), st, last(x)))
    end
    return x
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
function set_step(x::AbstractRange, st)
    if x isa AbstractUnitRange || is_linrange(x)
        throw(ArgumentError("cannot set step for type $x"))
    else
        if has_ref(x)
            return typeof(x)(x.ref, step_type(x)(st), x.len, x.offset)
        else
            return typeof(x)(first(x), st, Base.steprange_last(first(x), st, last(x)))
        end
    end
end
