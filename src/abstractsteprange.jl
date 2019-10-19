"""
    AbstractStepRange

Supertype for `StepSRange` and `StepMRange`. It's subtypes should behave
identically to `StepRange`.
"""
abstract type AbstractStepRange{T,S} <: OrdinalRange{T,S} end

function Base.isempty(r::AbstractStepRange)
    (first(r) != last(r)) & ((step(r) > zero(step(r))) != (last(r) > first(r)))
end

function start_step_stop_to_length(::Type{T}, start, step, stop) where {T}
    if (start != stop) & ((step > zero(step)) != (stop > start))
        return zero(T)
    else
        return Integer(div((stop - start) + step, step))
    end
end


function start_step_stop_to_length(::Type{T}, start, step, stop) where {T<:Union{Int,UInt,Int64,UInt64,Int128,UInt128}}
    if (start != stop) & ((step > zero(step)) != (stop > start))
        return zero(T)
    elseif step > 1
        return (convert(T, div(unsigned(stop - start), step)) + one(T))
    elseif step < -1
        return (convert(T, div(unsigned(start - stop), -step)) + one(T))
    elseif step > 0
        return (div(stop - start, step) + one(T))
    else
        return (div(start - stop, -step) + one(T))
    end
end

function Base.length(r::AbstractStepRange{T}) where {T}
    return start_step_stop_to_length(T, first(r), step(r), last(r))
end

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

Base.first(r::StepSRange{T,Ts,F,S,L}) where {T,Ts,F,S,L} = F

Base.step(r::StepSRange{T,Ts,F,S,L}) where {T,Ts,F,S,L} = S

Base.last(r::StepSRange{T,Ts,F,S,L}) where {T,Ts,F,S,L} = L

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
end

Base.first(r::StepMRange) = getfield(r, :start)

Base.step(r::StepMRange) = getfield(r, :step)

Base.last(r::StepMRange) = getfield(r, :stop)
function Base.intersect(r::AbstractUnitRange{<:Integer}, s::AbstractStepRange{<:Integer})
    if isempty(s)
        range(first(r), length=0)
    elseif step(s) == 0
        intersect(first(s), r)
    elseif step(s) < 0
        intersect(r, reverse(s))
    else
        sta = first(s)
        ste = step(s)
        sto = last(s)
        lo = first(r)
        hi = last(r)
        i0 = max(sta, lo + mod(sta - lo, ste))
        i1 = min(sto, hi - mod(hi - sta, ste))
        i0:ste:i1
    end
end

function Base.intersect(r::AbstractStepRange{<:Integer}, s::AbstractUnitRange{<:Integer})
    if step(r) < 0
        return reverse(intersect(s, reverse(r)))
    else
        return intersect(s, r)
    end
end

Base.intersect(r::AbstractStepRange, s::StepRange) = _intersect(r, s)
Base.intersect(r::StepRange, s::AbstractStepRange) = _intersect(r, s)
Base.intersect(r::AbstractStepRange, s::AbstractStepRange) = _intersect(r, s)

function _intersect(r, s)
    if isempty(r) || isempty(s)
        return range(first(r), step=step(r), length=0)
    elseif step(s) < zero(step(s))
        return intersect(r, reverse(s))
    elseif step(r) < zero(step(r))
        return reverse(intersect(reverse(r), s))
    end

    start1 = first(r)
    step1 = step(r)
    stop1 = last(r)
    start2 = first(s)
    step2 = step(s)
    stop2 = last(s)
    a = lcm(step1, step2)

    g, x, y = gcdx(step1, step2)

    if !iszero(rem(start1 - start2, g))
        # Unaligned, no overlap possible.
        return range(start1, step=a, length=0)
    end

    z = div(start1 - start2, g)
    b = start1 - x * z * step1
    # Possible points of the intersection of r and s are
    # ..., b-2a, b-a, b, b+a, b+2a, ...
    # Determine where in the sequence to start and stop.
    m = max(start1 + mod(b - start1, a), start2 + mod(b - start2, a))
    n = min(stop1 - mod(stop1 - b, a), stop2 - mod(stop2 - b, a))
    range(m, step=a, stop=n)
end

for (F,f) in ((:M,:m), (:S,:s))
    SR = Symbol(:Step, F, :Range)
    frange = Symbol(f, :range)
    @eval begin
        function Base.getindex(r::$(SR), s::AbstractRange{<:Integer})
            Base.@_inline_meta
            @boundscheck checkbounds(r, s)
            st = oftype(first(r), first(r) + (first(s)-1)*step(r))
            return $(frange)(st, step=step(r)*step(s), length=length(s))
        end

        $(SR)(r::AbstractUnitRange{T}) where {T} = $(SR){T,T}(first(r), step(r), last(r))

        $(SR)(start::T, step::S, stop::T) where {T,S} = $(SR){T,S}(start, step, stop)

        $(SR){T1,T2}(r::$(SR){T1,T2}) where {T1,T2} = r
        function $(SR){T1,T2}(r::AbstractRange) where {T1,T2}
            return $(SR){T1,T2}(
                convert(T1, first(r)),
                convert(T2, step(r)),
                convert(T1, last(r))
               )
        end

        function (::Type{<:$(SR){T1,T2} where T1})(r::AbstractRange) where {T2}
            return $(SR){eltype(r),T2}(r)
        end

        function Base.:(-)(r::$(SR))
            return $(frange)(-first(r), step=-step(r), length=length(r))
        end
    end
end

function Base.show(io::IO, r::StepMRange)
    print(io, "StepMRange(", first(r), ":", step(r), ":", last(r), ")")
end

function Base.show(io::IO, r::StepSRange)
    print(io, "StepSRange(", first(r), ":", step(r), ":", last(r), ")")
end
