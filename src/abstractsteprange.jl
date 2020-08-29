
"""
    AbstractStepRange

Supertype for `StepSRange` and `StepMRange`. It's subtypes should behave
identically to `StepRange`.
"""
abstract type AbstractStepRange{T,S} <: OrdinalRange{T,S} end

"""
    StepSRange

A static range with elements of type `T` with spacing of type `S`. The step
between each element is constant, and the range is defined in terms of a
`start` and `stop` of type `T` and a `step` of type `S`. Neither `T` nor `S`
should be floating point types.
"""
struct StepSRange{T,Ts,F,S,L} <: AbstractStepRange{T,Ts}

    function StepSRange{T,Ts}(start::T, step::Ts, stop::T) where {T,Ts}
        return new{T,Ts,start,step,Base.steprange_last(start, step, stop)}()
    end

    function StepSRange{T,Ts,F,S,L}(start::T, step::Ts, stop::T) where {T,Ts,F,S,L}
        return new{T,Ts,start,step,Base.steprange_last(start, step, stop)}()
    end

    StepSRange(start::T, step::S, stop::T) where {T,S} = StepSRange{T,S}(start, step, stop)

    function StepSRange{T1,T2}(r::AbstractRange) where {T1,T2}
        return StepSRange{T1,T2}(T1(first(r)), T2(step(r)), T1(last(r)))
    end

    StepSRange{T1,T2}(r::StepSRange{T1,T2}) where {T1,T2} = r

    function StepSRange(r::AbstractUnitRange{T}) where {T}
        return StepSRange{T,T}(first(r), step(r), last(r))
    end
end

function Base.getproperty(r::StepSRange, s::Symbol)
    if s === :start
        return first(r)
    elseif s === :step
        return step(r)
    elseif s === :stop
        return last(r)
    else
        error("type $(typeof(r)) has no property $s")
    end
end

"""
    StepMRange

A mutable range with elements of type `T` with spacing of type `S`. The step
between each element is constant, and the range is defined in terms of a
`start` and `stop` of type `T` and a `step` of type `S`. Neither `T` nor `S`
should be floating point types.
"""
mutable struct StepMRange{T,S} <: AbstractStepRange{T,S}
    start::T
    step::S
    stop::T

    function StepMRange{T,S}(start::T, step::S, stop::T) where {T,S}
        return new(start, step, Base.steprange_last(start,step,stop))
    end

    function StepMRange{T,S}(start, st, stop) where {T,S}
        return StepMRange{T,S}(T(start), S(st), T(stop))
    end

    StepMRange(start::T, step::S, stop::T) where {T,S} = StepMRange{T,S}(start, step, stop)

    function StepMRange{T1,T2}(r::AbstractRange) where {T1,T2}
        return StepMRange{T1,T2}(T1(first(r)), T2(step(r)), T1(last(r)))
    end

    function StepMRange{T1,T2}(r::StepMRange{T1,T2}) where {T1,T2}
        return StepMRange{T1,T2}(first(r), step(r), last(r))
    end

    function StepMRange(r::AbstractUnitRange{T}) where {T}
        return StepMRange{T,T}(first(r), step(r), last(r))
    end
end

function Base.setproperty!(r::StepMRange, s::Symbol, val)
    if s === :start
        return set_first!(r, val)
    elseif s === :step
        return set_step!(r, val)
    elseif s === :stop
        return set_last!(r, val)
    else
        error("type $(typeof(r)) has no property $s")
    end
end

for (F,f) in ((:M,:m), (:S,:s))
    SR = Symbol(:Step, F, :Range)
    frange = Symbol(f, :range)
    @eval begin
        @inline function Base.getindex(r::$(SR), s::AbstractRange{<:Integer})
            @boundscheck checkbounds(r, s)
            st = oftype(first(r), first(r) + (first(s)-1)*step(r))
            return $(frange)(st, step=step(r)*step(s), length=length(s))
        end
    end
end

