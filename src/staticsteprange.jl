
abstract type StaticStepRange{T,S} <: OrdinalRange{T,S} end

function Base.unsafe_length(r::StaticStepRange)
    n = Integer(div((last(r0 - first(r)) + step(r), step(r))))
    return isempty(r) ? zero(n) : n
end

function Base.isempty(r::StaticStepRange)
    (first(r) != last(r)) & ((step(r) > zero(step(r))) != (last(r) > first(r)))
end

function Base.isempty(r::StaticStepRange)
    (first(r) != last(r)) & ((step(r) > zero(step(r))) != (last(r) > first(r)))
end

struct StepSRange{T,Ts,F,S,L} <: StaticStepRange{T,Ts}

    function StepSRange{T,Ts}(start::T, step::Ts, stop::T) where {T,Ts}
        return new{T,Ts,start,step,Base.steprange_last(start, step, stop)}()
    end
end


isstatic(::Type{X}) where {X<:StepSRange} = true

Base.first(r::StepSRange{T,Ts,F,S,L}) where {T,Ts,F,S,L} = F

Base.step(r::StepSRange{T,Ts,F,S,L}) where {T,Ts,F,S,L} = S

Base.last(r::StepSRange{T,Ts,F,S,L}) where {T,Ts,F,S,L} = L

"""
    StepMRange
"""
mutable struct StepMRange{T,S} <: StaticStepRange{T,S}
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

setfirst!(r::StepMRange, val) = setfield!(r, :start, val)

setlast!(r::StepMRange, val) = setfield!(r, :stop, val)

can_growfirst(::Type{T}) where {T<:StepMRange} = true
can_setstep(::Type{T}) where {T<:StepMRange} = true
can_growlast(::Type{T}) where {T<:StepMRange} = true

function Base.length(r::StaticStepRange{T}) where {T}
    return start_step_stop_to_length(T, first(r), step(r), last(r))
end

function Base.intersect(r::AbstractUnitRange{<:Integer}, s::StaticStepRange{<:Integer})
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

function Base.intersect(r::StaticStepRange{<:Integer}, s::AbstractUnitRange{<:Integer})
    if step(r) < 0
        return reverse(intersect(s, reverse(r)))
    else
        return intersect(s, r)
    end
end
for (F,f) in ((:M,:m), (:S,:s))
    SR = Symbol(:Step, F, :Range)
    frange = Symbol(f, :range)
    @eval begin
        function Base.getindex(r::$(SR), s::AbstractRange{<:Integer})
            Base.@_inline_meta
            @boundscheck checkbounds(r, s)
            st = oftype(first(r), first(r) + (first(s)-1)*step(r))
            $(frange)(st, step=step(r)*step(s), length=length(s))
        end

        function Base.intersect(r::$(SR), s::$(SR))
            if isempty(r) || isempty(s)
                return $(frange)(first(r), step=step(r), length=0)
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
                return $(frange)(start1, step=a, length=0)
            end

            z = div(start1 - start2, g)
            b = start1 - x * z * step1
            # Possible points of the intersection of r and s are
            # ..., b-2a, b-a, b, b+a, b+2a, ...
            # Determine where in the sequence to start and stop.
            m = max(start1 + mod(b - start1, a), start2 + mod(b - start2, a))
            n = min(stop1 - mod(stop1 - b, a), stop2 - mod(stop2 - b, a))
            $(frange)(m, step=a, stop=n)
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

        function Base.promote_rule(
            a::Type{<:$(SR){T1a,T1b}},
            ::Type{UR}
           ) where {T1a,T1b,UR<:AbstractUnitRange}
            return promote_rule(a, $(SR){eltype(UR), eltype(UR)})
        end

        function promote_rule(
            ::Type{<:$(SR){T1a,T1b}},
            ::Type{$(SR){T2a,T2b}}
           ) where {T1a,T1b,T2a,T2b}
            return Base.el_same(
                promote_type(T1a,T2a),
                # el_same only operates on array element type, so just promote
                # second type parameter
                $(SR){T1a, promote_type(T1b,T2b)},
                $(SR){T2a, promote_type(T1b,T2b)}
               )
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
