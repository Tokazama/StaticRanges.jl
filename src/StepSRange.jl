struct StepSRange{T,B,S,E,L} <: OrdinalSRange{T,B,S,E,L} end

@pure firstindex(::StepSRange) where {T,B,S,Ts,E,L} = 1::Int64
@pure firstindex(::Type{<:StepSRange}) where {T,B,S,Ts,E,L} = 1::Int64
@pure sfirstindex(::StepSRange) where {T,B,S,Ts,E,L} = SVal{1::Int,Int}()
@pure sfirstindex(::Type{StepSRange}) where {T,B,S,Ts,E,L} = SVal{1::Int,Int}()


@pure lastindex(::StepSRange{T,SVal{B,T},SVal{S,Ts},SVal{E,T},SVal{L,Ti}}) where {T,B,S,Ts,E,L,Ti<:Integer} = L::Ti
@pure lastindex(::Type{<:StepSRange{T,SVal{B,T},SVal{S,Ts},SVal{E,T},SVal{L,Ti}}}) where {T,B,S,Ts,E,L,Ti<:Integer} = L::Ti
@pure slastindex(::StepSRange{T,SVal{B,T},SVal{S,Ts},SVal{E,T},SVal{L,Ti}}) where {T,B,S,Ts,E,L,Ti<:Integer} = SVal{L::Ti,Ti}()
@pure slastindex(::Type{<:StepSRange{T,SVal{B,T},SVal{S,Ts},SVal{E,T},SVal{L,Ti}}}) where {T,B,S,Ts,E,L,Ti<:Integer} = SVal{L::Ti,Ti}()

StepSRange(start::SVal{B,T}, step::SVal{S,Ts}, stop::SVal{E,T}) where {T,Ts,B,S,E} =
    StepSRange{T}(start, step, stop)

StepSRange{T}(start::SVal{B,T}, step::SVal{S,Ts}, stop::SVal{B,T}) where {T,B,S,Ts} =
    StepSRange{T,SVal{B,T},SVal{S,Ts},SVal{B,T}}()

#=
@test !(1 in srange(Date(2017, 01, 01):Dates.Day(1):Date(2017, 01, 05)))

b = SVal(Date(2017, 01, 01))
s = SVal(Dates.Day(1))
e = SVal(Date(2017, 01, 05))
=#

function StepSRange{T}(b::SVal{B,T}, s::SVal{S,Ts}, e::SVal{E,T}) where {T,B,S,Ts,E}
    z = zero(s)
    s == z && throw(ArgumentError("step cannot be zero"))

    if (s > z) != (e > b)
        last = steprange_last_empty(b, s, e)
    else
        # Compute absolute value of difference between `B` and `E`
        # (to simplify handling both signed and unsigned T and checking for signed overflow):
        absdiff, absstep = e > b ? (e - b, s) : (b - e, -s)

        # Compute remainder as a nonnegative number:
        if T <: Signed && absdiff < SZero(absdiff)
            # handle signed overflow with unsigned rem
            remain = oftype(B, unsigned(absdiff) % absstep)
        else
            remain = absdiff % absstep
        end
        # Move `E` closer to `B` if there is a remainder:
        last = e > b ? e - remain : e + remain
    end
    return StepSRange{T,SVal{B,T},SVal{S,Ts},typeof(last)}()
end

function StepSRange{T,SVal{B,T},SVal{S,Ts},SVal{E,T}}() where {B,E,S,Ts,T<:Union{Int,UInt,Int64,UInt64,Int128,UInt128}}
    (B != E) & ((S > 0)) != (E > B) && return StepSRange{T,SVal{B,T},SVal{S,Ts},SVal{E,T},typeof(SZero)}()
    if S::Ts > 1
        return StepSRange{T,SVal{B,T},SVal{S,Ts},SVal{E,T},typeof(SVal{Base.Checked.checked_add(Int(div(unsigned(E - B), S)), one(B))}())}()
    elseif S::Ts < -1
        return StepSRange{T,SVal{B,T},SVal{S,Ts},SVal{E,T},typeof(SVal{Base.Checked.checked_add(Int(div(unsigned(B - E), -S)), one(B))}())}()
    elseif S::Ts > 0
        return StepSRange{T,SVal{B,T},SVal{S,Ts},SVal{E,T},typeof(SVal{Int(Base.Checked.checked_add(div(Base.Checked.checked_sub(E, B), S), one(B)))}())}()
    else
        return StepSRange{T,SVal{B,T},SVal{S,Ts},SVal{E,T},typeof(SVal{Int(Base.Checked.checked_add(div(Base.Checked.checked_sub(B, E), -S), one(B)))}())}()
    end
end

function StepSRange{T,SVal{B,T},SVal{S,Ts},SVal{E,T}}() where {B,E,S,Ts,T}
    n = Int(div((SVal{E::T,T}() - SVal{B::T,T}()) + SVal{S::Ts,Ts}(), SVal{S::Ts,Ts}()))
    (B::T != E::T) & ((S::Ts > zero(Ts))) != (E::T > B::T) ? StepSRange{T,SVal{B,T},SVal{S,Ts},SVal{E,T},typeof(SZero(n))}() :
                                                            StepSRange{T,SVal{B,T},SVal{S,Ts},SVal{E,T},typeof(SVal{n}())}()
end

function steprange_last_empty(b::SInteger{B}, s::SVal{S,Ts}, e::SVal{E}) where {B,E,S,Ts}
    # empty range has a special representation where stop = start-1
    # this is needed to avoid the wrap-around that can happen computing
    # start - step, which leads to a range that looks very large instead
    # of empty.
    if s > SZero(Ts)
        return b - oneunit(e - b)
    else
        return b + oneunit(e - b)
    end
end
steprange_last_empty(b::SVal{B}, s::SVal{S}, e::SVal{E}) where {B,E,S} = b - s
