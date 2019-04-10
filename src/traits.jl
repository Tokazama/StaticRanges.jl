@pure first(::StaticRange{T,SVal{B,Tb},SVal{S,Ts},E,L,F}) where {T,B,Tb,S,Ts,E,L,F} = T(B)::T
@pure first(::Type{<:StaticRange{T,SVal{B,Tb},SVal{S,Ts},E,L,F}}) where {T,B,Tb,S,Ts,E,L,F} = T(B)::T

@pure first(::StaticRange{T,SVal{B,T},SVal{S,Ts},E,L,F}) where {T,B,S,Ts,E,L,F} = B::T
@pure first(::Type{<:StaticRange{T,SVal{B,T},SVal{S,Ts},E,L,F}}) where {T,B,S,Ts,E,L,F} = B::T


@pure static_first(::StaticRange{T,SVal{B,Tb},SVal{S,Ts},E,L,F}) where {T,B,Tb,S,Ts,E,L,F} = SVal{B,Tb}()
@pure static_first(::Type{<:StaticRange{T,SVal{B,Tb},SVal{S,Ts},E,L,F}}) where {T,B,Tb,S,Ts,E,L,F} = SVal{B,Tb}()

@pure static_first(::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F}) where {T,Tb,Hb,Lb,Ts,Hs,Ls,E,L,F} = HPSVal{Tb,Hb,Lb}()
@pure static_first(::Type{<:StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F}}) where {T,Tb,Hb,Lb,Ts,Hs,Ls,E,L,F} = HPSVal{Tb,Hb,Lb}()

@pure function first(::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F}) where {T,Tb,Hb,Lb,Ts,Hs,Ls,E,L,F}
    x_hi, x_lo = add12(SVal{Hb}(), SVal{Tb(0)}())
    return T(x_hi + (x_lo + Lb))
end
@pure function first(::Type{<:StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F}}) where {T,Tb,Hb,Lb,Ts,Hs,Ls,E,L,F}
    x_hi, x_lo = add12(SVal{Hb}(), SVal{Tb(0)}())
    return T(x_hi + (x_lo + Lb))
end


@pure step(::StaticRange{T,SVal{B,Tb},SVal{S,Ts},E,L,F}) where {T,B,Tb,S,Ts,E,L,F} = T(S)::T
@pure step(::Type{<:StaticRange{T,SVal{B,Tb},SVal{S,Ts},E,L,F}}) where {T,B,Tb,S,Ts,E,L,F} = T(S)::T

@pure step(::StaticRange{T,SVal{B,Tb},SVal{S,T},E,L,F}) where {T,B,Tb,S,E,L,F} = S::T
@pure step(::Type{<:StaticRange{T,SVal{B,Tb},SVal{S,T},E,L,F}}) where {T,B,Tb,S,E,L,F} = S::T

@pure step(::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F}) where {T,Tb,Hb,Lb,Ts,Hs,Ls,E,L,F} = T(Hs + Ls)::T
@pure step(::Type{<:StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F}}) where {T,Tb,Hb,Lb,Ts,Hs,Ls,E,L,F} = T(Hs + Ls)::T

@pure static_step(::StaticRange{T,SVal{B,Tb},SVal{S,Ts},E,L,F}) where {T,B,Tb,S,Ts,E,L,F} = SVal{S,Ts}()
@pure static_step(::Type{StaticRange{T,SVal{B,Tb},SVal{S,Ts},E,L,F}}) where {T,B,Tb,S,Ts,E,L,F} = SVal{S,Ts}()

@pure static_step(::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F}) where {T,Tb,Hb,Lb,Ts,Hs,Ls,E,L,F} = HPSVal{Ts,Hs,Ls}()
@pure static_step(::Type{<:StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F}}) where {T,Tb,Hb,Lb,Ts,Hs,Ls,E,L,F} = HPSVal{Ts,Hs,Ls}()

@pure last(::StaticRange{T,B,S,E,L,F}) where {T,B,S,E,L,F} = E::T
@pure last(::Type{StaticRange{T,B,S,E,L,F}}) where {T,B,S,E,L,F} = E::T

@pure static_last(::StaticRange{T,B,S,E,L,F}) where {T,B,S,E,L,F} = SVal{E,T}()
@pure static_last(::Type{<:StaticRange{T,B,S,E,L,F}}) where {T,B,S,E,L,F} = SVal{E,T}()

#@pure last(::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F}) where {T,Tb,Hb,Lb,Ts,Hs,Ls,E,L,F} = E::T

@pure firstindex(r::StaticRange{T,B,S,E,L,E}) where {T,B,S,E,L,F} = 1::Int
@pure firstindex(r::Type{<:StaticRange{T,B,S,E,L,E}}) where {T,B,S,E,L,F} = 1::Int

@pure static_firstindex(r::StaticRange{T,B,S,E,L,E}) where {T,B,S,E,L,F} = SVal{1::Int,Int}()
@pure static_firstindex(r::Type{<:StaticRange{T,B,S,E,L,E}}) where {T,B,S,E,L,F} = SVal{1::Int,Int}()

@pure lastindex(r::StaticRange{T,B,S,E,L,E}) where {T,B,S,E,L,F} = (L)::Int
@pure lastindex(r::Type{<:StaticRange{T,B,S,E,L,E}}) where {T,B,S,E,L,F} = (L)::Int

@pure static_lastindex(r::StaticRange{T,B,S,E,L,E}) where {T,B,S,E,L,F} = SVal{L::Int,Int}()
@pure static_lastindex(r::Type{<:StaticRange{T,B,S,E,L,E}}) where {T,B,S,E,L,F} = SVal{L::Int,Int}()

@pure length(r::StaticRange{T,B,S,E,L,F}) where {T,B,S,E,L,F} = L::Int
@pure length(r::Type{<:StaticRange{T,B,S,E,L,F}}) where {T,B,S,E,L,F} = L::Int

@pure static_length(r::StaticRange{T,B,S,E,L,F}) where {T,B,S,E,L,F} = SVal{L::Int,Int}()
@pure static_length(r::Type{<:StaticRange{T,B,S,E,L,F}}) where {T,B,S,E,L,F} = SVal{L::Int,Int}()


# compatability with other range types for indexing
# overloading provides way for other packages to easily integrate with static indexing
static_last(r::AbstractRange{T}) where T = SVal{last(r),T}()
static_first(r::AbstractRange{T}) where T = SVal{first(r),T}()
static_step(r::AbstractRange{T}) where T = SVal{step(r)}()
static_lastindex(r::AbstractRange{T}) where T = SVal{lastindex(r)}()
static_firstindex(r::AbstractRange{T}) where T = SVal{firstindex(r)}()




Base.minimum(r::StaticRange{T,B,S,E,0,F}) where {T,B,S,E,F} = throw(ArgumentError("range must be non-empty"))
Base.maximum(r::StaticRange{T,B,S,E,0,F}) where {T,B,S,E,F} = throw(ArgumentError("range must be non-empty"))

Base.minimum(r::StaticRange{T,B,S,E,L,F}) where {T,B,S,E,L,F} = min(first(r), last(r)) 
Base.maximum(r::StaticRange{T,B,S,E,L,F}) where {T,B,S,E,L,F} = max(first(r), last(r)) 

Base.extrema(r::StaticRange) = (minimum(r), maximum(r))

@pure function Base.isequal(
    ::StaticRange{T1,B1,E1,S1,F1,L1},
    ::StaticRange{T2,B2,E2,S2,F2,L2}) where {T1,B1,E1,S1,F1,L1,T2,B2,E2,S2,F2,L2}
    false
end
@pure function Base.isequal(::StaticRange{T,B,E,S,F,L},
    ::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L}
    true
end
==(sr1::StaticRange, sr2::StaticRange) = isequal(sr1, sr2)

@pure Base.isempty(::StaticRange{T,B,S,E,0,F}) where {T,B,E,S,F} = true
@inline Base.isempty(::StaticRange{T,SVal{B},SVal{S},E,L,F}) where {T,B,S,E,L,F} =
    (B != E) & ((S > zero(S)) != (E > B))



#=
@pure Base.minimum(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = B::T
@pure Base.minimum(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = B::T

@pure Base.maximum(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = E::T
@pure Base.maximum(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = E::T

@pure Base.extrema(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = (B, E)::Tuple{T,T}
@pure Base.extrema(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = (B, E)::Tuple{T,T}
=#

