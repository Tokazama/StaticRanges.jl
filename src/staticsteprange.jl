"""
    StepSRange

# Examples

```jldoctest
julia> StepSRange(SInt(1), SInt(2), SInt(10))
1:2:9  (static)
```
"""
struct StepSRange{T,B,S,E,L} <: StaticStepRange{T,B,S,E,L} end

StepSRange(start::B, step::S, stop::E) where {B,S,E} = StepSRange{eltype(start)}(start, step, stop)

StepSRange{T,B,S,E}(start::B, step::S, stop::E, len::L) where {T,B,S,E,L} =
    StepSRange{T,B,S,E,L}()

#StepSRange{T}(start::B, step::S, stop::E) where {T,B,S,E} = StepSRange{T,B}(start, step, stop)


function StepSRange{T}(b::SReal, s::SReal, e::SReal) where T
    z = zero(s)
    s == z && throw(ArgumentError("step cannot be zero"))

    if (s > z) != (e > b)
        if T<:Integer
            if S::Ts > zero(Ts)
                last = b - oneunit(e - b)
            else
                last = b + oneunit(e - b)
            end
        else
            last = b - s
        end
    else
        # Compute absolute value of difference between `B` and `E`
        # (to simplify handling both signed and unsigned T and checking for signed overflow):
        absdiff, absstep = e > b ? (e - b, s) : (b - e, -s)

        # Compute remainder as a nonnegative number:
        if T <: Signed && absdiff < szero(absdiff)
            # handle signed overflow with unsigned rem
            remain = oftype(b, unsigned(absdiff) % absstep)
        else
            remain = absdiff % absstep
        end
        # Move `E` closer to `B` if there is a remainder:
        last = e > b ? e - remain : e + remain
    end
    return StepSRange{T,typeof(b),typeof(s),typeof(last)}(b, s, last)
end

function StepSRange{T,B,S,E}(b::B, s::S, e::E) where {B,E,S,T<:Union{Int,UInt,Int64,UInt64,Int128,UInt128}}
    (b != e) & ((s > 0)) != (e > b) && return StepSRange{T,B,S,E,typeof(szero)}(b,s,e, szero)
    if s > 1
        return StepSRange{T,B,S,E}(b, s, e, int(div(Base.unsigned(e - b), s)) + one(b))
    elseif s < -1
        return StepSRange{T,B,S,E}(b, s, e, int(div(Base.unsigned(e - b), -s)) + one(b))
    elseif s > 0
        return StepSRange{T,B,S,E}(b, s, e, int(div(e - b, s) + one(b)))
    else
        return StepSRange{T,B,S,E}(b, s, e, int(div(b - e, -s) + one(b)))
    end
end

function StepSRange{T,B,S,E}(b::B, s::S, e::E) where {B,E,S,T}
    (b != e) &
    ((s > zero(s))) !=
    (e > b) ? StepSRange{T,B,S,E}(b, s, e, szero) :
              StepSRange{T,B,S,E}(b, s, e, int(div(e - b + s, s)))
end


"""
    StepMRange
"""
mutable struct StepMRange{T,B,S,E} <: StaticStepRange{T,B,S,E,Dynamic}
    start::B
    step::S
    stop::E
end

first(r::StepMRange{T,B,S,E}) where {T,B,S,E} = values(r.start::B)
step(r::StepMRange{T,B,S,E}) where {T,B,S,E} = values(r.step::S)
last(r::StepMRange{T,B,S,E}) where {T,B,S,E} = values(r.stop::E)


showrange(io::IO, r::StaticStepRange) = print(io, "$(first(r)):$(step(r)):$(last(r)) \t (static)")
