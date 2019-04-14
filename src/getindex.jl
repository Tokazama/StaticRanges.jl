@inline function getindex(r::AbstractSRange, i::SVal)
    @boundscheck checkbounds(r, i)
    @inbounds get(unsafe_getindex(r, i))
end

@inline getindex(r::AbstractSRange, i::Integer) = r[SVal{i}()]

@inline getindex(r::AbstractSRange, i::AbstractRange) = r[srange(i)]

@inline function getindex(r::AbstractSRange, i::AbstractSRange)
    @boundscheck checkbounds(r, i)
    @inbounds unsafe_getindex(r, i)
end

@pure function unsafe_getindex(
    ::UnitSRange{T,SVal{B,T},SVal{E,T},SInt64{L}},
    i::SVal{I,<:Integer}) where {T,B,E,L,I}
    Base.@_inline_meta
    SVal{convert(T, B::T + (I::Int64 - 1::Int64))::T,T}()
end

const OverflowSafe = Union{Bool,Int8,Int16,Int32,Int64,Int128,
                           UInt8,UInt16,UInt32,UInt64,UInt128}

@pure function unsafe_getindex(
    ::UnitSRange{T,SVal{B,T},SVal{E,T},SVal{L,Ti}},
    i::SVal{I,<:Integer}) where {T<:OverflowSafe,B,E,L,Ti,I}
    Base.@_inline_meta
    SVal{T(B::T + (I - 1))::T % T,T}()
end

@inline function unsafe_getindex(
    r::UnitSRange{T1,SVal{B1,T1},SVal{E1,T1},SInt64{L1}},
    s::UnitSRange{T2,SVal{B2,T2},SVal{E2,T2},SInt64{L2}}
   ) where {T1,B1,E1,L1,T2<:Integer,B2,E2,L2}
    _sr(sfirst(r) + sfirst(s) - SOne, SNothing(), SNothing(), slength(s))
end

function unsafe_getindex(
    r::UnitSRange{T,SVal{B,T}},
    s::StepSRange{T2,SVal{B2,T}}) where {T2<:Integer,B2,T,B}
    _sr(SVal{T(B::T + B2::T2-1),T}(), sstep(s), SNothing(), slength(s))
end

function unsafe_getindex(
    r::LinSRange{T,SVal{B,T},SVal{E,T},SInt64{L},SInt64{D}},
    i::SInt64{I}) where {T,B,E,L,D,I}
    lerpi(i-SOne, SVal{D::Int64,Int64}(), SVal{B::T,T}(), SVal{E::T,T}())
end

function lerpi(j::SInteger{J}, d::SInteger{D}, a::SVal{A,T}, b::SVal{B,T}) where {J,D,A,B,T}
    Base.@_inline_meta
    t = J/D
    SVal{T((1-t)*a + t*B)::T,T}()
end


# StepSRangeLen
@pure @inline function unsafe_getindex(
    r::StepSRangeLen{T,SVal{B,Tb},SVal{S,Ts},SVal{E,T},SVal{L,Ti},SVal{F,Ti}},
    i::SInt64{I}) where {T,B,Tb,S,Ts,E,L,F,I,Ti<:Integer}
    return SVal{T(B::Tb + (I::Ti - F::Ti) * S::Ts)::T,T}()
end

@pure @inline function unsafe_getindex(
    r::StepSRangeLen{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F},
    i::SInt64{I}) where {T,Tb,Ts,Hb,Lb,Hs,Ls,E,L,F,I}
    u = i - F()
    shift_hi, shift_lo = u * Hs::Ts, u * Ls::Ts
    x_hi, x_lo = add12(SVal{Hb::Tb,Tb}(), shift_hi)
    return convert(SVal{Any,T}, (x_hi + (x_lo + (shift_lo + Lb::Tb))))
end

@inline function unsafe_getindex_hiprec(
    r::StepSRangeLen{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F},
    i::SInt64{I}) where {T,Tb,Ts,Hb,Lb,Hs,Ls,E,F,L,I}
    u = i - F()
    shift_hi, shift_lo = u*Hs::Ts, u*Ls::Ts
    x_hi, x_lo = add12(SVal{Hb::Tb,Tb}(), shift_hi)
    x_hi, x_lo = add12(x_hi, x_lo + (shift_lo + Lb::Tb))
    HPSVal{T,get(x_hi),get(x_lo)}()
end

@pure @inline function unsafe_getindex(
    r::StepSRangeLen{T},
    s::OrdinalSRange{<:Integer}) where T
    offset = max(min(SOne + round(Int, (soffset(r) - sfirst(s))/sstep(s)), slastindex(s)), sfirstindex(s))
    ref = unsafe_getindex_hiprec(r, sfirst(s) + (offset-SOne)*sstep(s))
    return StepSRangeLen{T}(ref, sstep(r)*sstep(s), slength(s), offset)
end

@pure @inline function unsafe_getindex(
    r::StepSRangeLen{T},
    s::AbstractUnitSRange{<:Integer}) where T
    offset = max(min(SOne + round(Int, soffset(r) - sfirst(s)), slastindex(s)), sfirstindex(s))
    ref = unsafe_getindex_hiprec(r, sfirst(s) + (offset-SOne))
    return StepSRangeLen(ref, sstep(r), slength(s), offset)
end

# StepSRange
@inline function unsafe_getindex(
    r::StepSRange{T},
    s::UnitSRange{<:Integer}) where T
    StepSRange{T}(unsafe_getindex(r, sfirst(s)), sstep(r), unsafe_getindex(r, slast(s)))
end

@inline function unsafe_getindex(r::StepSRange, s::AbstractSRange{<:Integer})
    _sr(unsafe_getindex(r, sfirst(s)), sstep(r)*sstep(s), SNothing(), slength(s))
end

@inline function unsafe_getindex(
    r::StepSRange{T,SVal{B,T},SVal{S,Ts},SVal{E,T},SVal{L,Ti}},
    i::SVal{I,<:Integer}) where {T,B,S,E,L,Ts,Ti,I}
    SVal{T(B::T + (I - 1) * S::Ts)::T,T}()
end

# unsafe_getindex(::StepSRange{Int64,SVal{1,Int64},SVal{2,Int64},SVal{13,Int64},SVal{7,Int64}},
#                 ::StepSRange{Int64,SVal{2,Int64},SVal{3,Int64},SVal{5,Int64},SVal{2,Int64}})


