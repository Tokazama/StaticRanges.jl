

"""
    StepSRangeLen{T,B,S,E,L,F}
"""
struct StepSRangeLen{T,B,S,E,L,F} <: StaticStepRangeLen{T,B,S,E,L,F}
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


"""
    StepMRangeLen{T,B,S,E,F}
"""

struct StepMRangeLen{T,B,S,E,F} <: StaticStepRangeLen{T,B,S,E,Dynamic,F}
    start::B       # reference value (might be smallest-magnitude value in the range)
    step::S      # step value
    stop::E     # length of the range
    offset::F  # the index of ref
end
"""
    StepSRangeLen{T,B,S,E,L,F}
"""
struct StepSRangeLen{T,B,S,E,L,F} <: StaticStepRangeLen{T,B,S,E,L,F}
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


"""
    StepMRangeLen{T,B,S,E,F}
"""

struct StepMRangeLen{T,B,S,E,F} <: StaticStepRangeLen{T,B,S,E,Dynamic,F}
    start::B       # reference value (might be smallest-magnitude value in the range)
    step::S      # step value
    stop::E     # length of the range
    offset::F  # the index of ref
end
