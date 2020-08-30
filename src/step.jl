
Base.step_hp(::StepSRangeLen{T,Tr,Ts,R,S}) where {T,Tr,Ts,R,S} = S
Base.step_hp(r::StepMRangeLen) = getfield(r, :step)

ArrayInterface.known_step(::Type{<:StepSRange{<:Any,<:Any,<:Any,S}}) where {S} = S
ArrayInterface.known_step(::Type{<:LinSRange{T,B,E,L,D}}) where {T,B,E,L,D} = (L - B) / D
ArrayInterface.known_step(::Type{<:StepSRangeLen{T,<:Any,<:Any,<:Any,S}}) where {T,S} = T(S)

Base.step(r::StepSRange) = known_step(r)
Base.step(r::StepMRange) = getfield(r, :step)
Base.step(r::AbstractLinRange) = (last(r) - first(r)) / r.lendiv
Base.step(r::AbstractStepRangeLen{T}) where {T} = T(step_hp(r))

"""
    can_set_step(x) -> Bool

Returns `true` if type of `x` has `step` field that can be set.
"""
can_set_step(x) = can_set_step(typeof(x))
function can_set_step(::Type{T}) where {T}
    return can_change_size(T) && !(step_is_known_one(T))
end
# it's not clear what changing the step size for a linear range would do
# - does stop or length change?
can_set_step(::Type{T}) where {T<:LinMRange} = false

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
function set_step!(x::StepMRangeLen{T,R,S}, st) where {T,R,S}
    setfield!(x, :step, S(st))
    return x
end

function set_step!(x::StepMRange{T,S}, st) where {T,S}
    setfield!(x, :step, S(st))
    setfield!(x, :stop, Base.steprange_last(first(x), st, last(x)))
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
set_step(x::AbstractUnitRange) = throw(ArgumentError("cannot set step for type $x"))
function set_step(x::OrdinalRange, st)
    return typeof(x)(first(x), st, Base.steprange_last(first(x), st, last(x)))
end

function set_step(x::AbstractStepRangeLen{T,R,S}, st) where {T,R,S}
    return typeof(x)(x.ref, S(st), x.len, x.offset)
end
function set_step(x::StepRangeLen{T,R,S}, st) where {T,R,S}
    return typeof(x)(x.ref, S(st), x.len, x.offset)
end

