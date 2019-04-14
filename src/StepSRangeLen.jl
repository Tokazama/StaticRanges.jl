struct StepSRangeLen{T,B,S,E,L,F} <: OrdinalSRange{T,B,S,E,L}
    # reference value (might be smallest-magnitude value in the range)
    # step value
    # length of the range
    # the index of ref

    function StepSRangeLen{T,SVal{B,Tb},SVal{S,Ts}}(len::SInteger{L}, offset::SInteger{F} = SOne) where {T,B,Tb,S,Ts,L,F}
        len >= SZero || throw(ArgumentError("length cannot be negative, got $L"))
        SOne <= offset <= max(SOne, len) || throw(ArgumentError("StepRangeLen: offset must be in [1,$L], got $F"))
        new{T,                              # eltype
            SVal{B,Tb},                     # ref
            SVal{S,Ts},                     # step
            SVal{T(B + (L-F) * S)::T,T},    # last
            SVal{Int(L),Int},               # length
            SVal{Int(F),Int}}()             # offset
    end

    function StepSRangeLen{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls}}(len::SInt64{L}, offset::SInt64{F} = SOne) where {T,Tb,Hb,Lb,Ts,Hs,Ls,L,F}
        len >= SZero || throw(ArgumentError("length cannot be negative, got $L"))
        SOne <= offset <= max(SOne, len) || throw(ArgumentError("StepRangeLen: offset must be in [1,$L], got $F"))
        u = L - F
        shift_hi, shift_lo = u*Hs, u*Ls
        x_hi, x_lo = Base.add12(Hb, shift_hi)
        new{T,                                              # eltype
            HPSVal{Tb,Hb,Lb},                               # ref
            HPSVal{Ts,Hs,Ls},                               # step
            SVal{T(x_hi + (x_lo + (shift_lo + Lb)))::T,T},  # last
            SInt64{L},                                      # length
            SInt64{F}}()                                    # offset
    end
end


StepSRangeLen(ref::SVal{B,Tb}, step::SVal{S,Ts}, len::SInteger{L}, offset::SInteger{F} = SOne) where {B,Tb,S,Ts,L,F} =
    StepSRangeLen{eltype(ref+SZero*step),SVal{B,Tb},SVal{S,Ts}}(len, offset)

StepSRangeLen(ref::HPSVal{Tb,Hb,Lb}, step::HPSVal{Ts,Hs,Ls}, len::SInteger{L}, offset::SInteger{F} = SOne) where {Tb,Hb,Lb,Ts,Hs,Ls,L,F} =
    StepSRangeLen{eltype(ref+0*step),HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls}}(len, offset)

StepSRangeLen{T}(ref::SVal{B,Tb}, step::SVal{S,Ts}, len::SInteger{L}, offset::SInteger{F} = SOne) where {T,B,Tb,S,Ts,L,F} =
    StepSRangeLen{T,SVal{B,Tb},SVal{S,Ts}}(len, offset)

StepSRangeLen{T}(ref::HPSVal{Tb,Hb,Lb}, step::HPSVal{Ts,Hs,Ls}, len::SInteger{L}, offset::SInteger{F} = SOne) where {T,Tb,Hb,Lb,Ts,Hs,Ls,L,F} =
    StepSRangeLen{eltype(ref+0*step),HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls}}(len, offset)

@pure firstindex(::StepSRangeLen{T,B,S,E,SVal{L,Ti},SVal{F,Ti}}) where {T,B,S,E,L,F,Ti<:Integer} = 1::Ti
@pure firstindex(::Type{<:StepSRangeLen{T,B,S,E,SVal{L,Ti},SVal{F,Ti}}}) where {T,B,S,E,L,F,Ti<:Integer} = 1::Ti
@pure sfirstindex(::StepSRangeLen{T,B,S,E,SVal{L,Ti},SVal{F,Ti}}) where {T,B,S,E,L,F,Ti<:Integer} = SVal{1::Ti,Ti}()
@pure sfirstindex(::Type{<:StepSRangeLen{T,B,S,E,SVal{L,Ti},SVal{F,Ti}}}) where {T,B,S,E,L,F,Ti<:Integer} = SVal{1::Ti,Ti}()

@pure lastindex(::StepSRangeLen{T,B,S,E,SVal{L,Ti},SVal{F,Ti}}) where {T,B,S,E,L,F,Ti<:Integer} = L::Ti
@pure lastindex(::Type{<:StepSRangeLen{T,B,S,E,SVal{L,Ti},SVal{F,Ti}}}) where {T,B,S,E,L,F,Ti<:Integer} = L::Ti
@pure slastindex(::StepSRangeLen{T,B,S,E,SVal{L,Ti},SVal{F,Ti}}) where {T,B,S,E,L,F,Ti<:Integer} = SVal{L::Ti,Ti}()
@pure slastindex(::Type{<:StepSRangeLen{T,B,S,E,SVal{L,Ti},SVal{F,Ti}}}) where {T,B,S,E,L,F,Ti<:Integer} = SVal{L::Ti,Ti}()

@pure offset(::StepSRangeLen{T,B,S,E,SVal{L,Ti},SVal{F,Ti}}) where {T,B,S,E,L,F,Ti<:Integer} = F::Ti
@pure offset(::Type{<:StepSRangeLen{T,B,S,E,SVal{L,Ti},SVal{F,Ti}}}) where {T,B,S,E,L,F,Ti<:Integer} = F::Ti
@pure soffset(::StepSRangeLen{T,B,S,E,SVal{L,Ti},SVal{F,Ti}}) where {T,B,S,E,L,F,Ti<:Integer} = SVal{F::Ti,Ti}()
@pure soffset(::Type{<:StepSRangeLen{T,B,S,E,SVal{L,Ti},SVal{F,Ti}}}) where {T,B,S,E,L,F,Ti<:Integer} = SVal{F::Ti,Ti}()

@pure @inline function Base.iterate(
    r::StepSRangeLen{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},SVal{E,T},SVal{F,Ti},SVal{L,Ti}},
    state::SInt64{I}) where {T,Tb,Ts,Hb,Lb,Hs,Ls,E,F,L,Ti<:Integer,I}
    I::Int64 == E::T && return SNothing()
    return (SVal{T(B::Tb + (I::Ti - F::Ti) * S::Ts)::T,T}(), state + SOne)
end

@pure @inline function Base.iterate(
    r::StepSRangeLen{T,SVal{B,Tb},SVal{S,Ts},SVal{E,T},SVal{F,Ti},SVal{L,Ti}},
    state::SInt64{I}) where {T,Tb,Ts,B,S,E,F,L,I,Ti<:Integer}
    I::Int64 == E::T && return SNothing()
    u = i - F()
    shift_hi, shift_lo = u * Hs::Ts, u * Ls::Ts
    x_hi, x_lo = add12(SVal{Hb::Tb,Tb}(), SVal{shift_hi}())
    return ((SVal{E,T})(T(x_hi + (x_lo + (shift_lo + Lb::Tb)))), state + SOne)
end
