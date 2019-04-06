
@inline first(::StaticRange{T,SVal{B,Tb},SVal{S,Ts},E,L,F}) where {T,B,Tb,S,Ts,E,L,F} = T(B)::T
@pure first(::StaticRange{T,SVal{B,T},SVal{S,Ts},E,L,F}) where {T,B,S,Ts,E,L,F} = B::T



@pure function first(::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F}) where {T,Tb,Hb,Lb,Ts,Hs,Ls,E,L,F}
    x_hi, x_lo = add12(SVal{Hb}(), SVal{Tb(0)}())
    return T(x_hi + (x_lo + Lb))
end

@inline step(::StaticRange{T,SVal{B,Tb},SVal{S,Ts},E,L,F}) where {T,B,Tb,S,Ts,E,L,F} = T(S)::T
@pure step(::StaticRange{T,SVal{B,Tb},SVal{S,T},E,L,F}) where {T,B,Tb,S,E,L,F} = S::T


@pure function step(::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F}) where {T,Tb,Hb,Lb,Ts,Hs,Ls,E,L,F}
    T(Hs + Ls)::T
end

@pure last(::StaticRange{T,SVal{B,Tb},SVal{S,Ts},E,L,F}) where {T,B,Tb,S,Ts,E,L,F} = E::T
#=
  u = i - r.offset
    shift_hi, shift_lo = u*r.step.hi, u*r.step.lo

    x_hi, x_lo = add12(r.ref.hi, shift_hi)
    T(x_hi + (x_lo + (shift_lo + r.ref.lo)))
=#
@pure last(::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F}) where {T,Tb,Hb,Lb,Ts,Hs,Ls,E,L,F} = E::T

@pure static_first(::StaticRange{T,B,S,E,L,F}) where {T,B,S,E,L,F}  = B
@pure static_step(::StaticRange{T,B,S,E,L,F}) where {T,B,S,E,L,F} = S


@pure firstindex(r::StaticRange{T,B,S,E,L,E}) where {T,B,S,E,L,F} = F::Int
@pure lastindex(r::StaticRange{T,B,S,E,L,E}) where {T,B,S,E,L,F} = (L - F + 1)::Int
@pure length(r::StaticRange{T,B,S,E,L,F}) where {T,B,S,E,L,F} = L::Int

Base.minimum(r::StaticRange{T,B,S,E,0,E}) where {T,B,S,E,F} = throw(ArgumentError("range must be non-empty"))
Base.maximum(r::StaticRange{T,B,S,E,0,E}) where {T,B,S,E,F} = throw(ArgumentError("range must be non-empty"))

Base.minimum(r::StaticRange{T,B,S,E,L,E}) where {T,B,S,E,L,F} = min(first(r), last(r)) 
Base.maximum(r::StaticRange{T,B,S,E,L,E}) where {T,B,S,E,L,F} = max(first(r), last(r)) 

Base.extrema(r::StaticRange) = (minimum(r), maximum(r))

#=
@pure Base.minimum(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = B::T
@pure Base.minimum(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = B::T

@pure Base.maximum(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = E::T
@pure Base.maximum(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = E::T

@pure Base.extrema(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = (B, E)::Tuple{T,T}
@pure Base.extrema(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = (B, E)::Tuple{T,T}
=#

