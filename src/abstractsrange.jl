abstract type AbstractSRange{T,L} <: AbstractRange{T} end

const DynamicSRange{T} = AbstractSRange{T,Dynamic}

length(r::DynamicSRange) = getfield(r, :len)

@pure length(::AbstractSRange{T,SVal{L,Ti}}) where {T,L,Ti<:Integer} = L::Ti
@pure length(::Type{<:AbstractSRange{T,SVal{L,Ti}}}) where {T,L,Ti<:Integer} = L::Ti
@pure slength(::AbstractSRange{T,SVal{L,Ti}}) where {T,L,Ti<:Integer} = SVal{L::Ti,Ti}()
@pure slength(::Type{<:AbstractSRange{T,SVal{L,Ti}}}) where {T,L,Ti<:Integer} = SVal{L::Ti,Ti}()

Base.copy(r::AbstractSRange) = r

Base.show(io::IO, r::AbstractSRange) = showrange(io, r)
Base.show(io::IO, ::MIME"text/plain", r::AbstractSRange) = showrange(io, r)

"""
    AbstractUnitSRange
"""
abstract type AbstractUnitSRange{T,B,E,L} <: AbstractSRange{T,L} end

@pure Base.first(::AbstractUnitSRange{T,SVal{B,T},SVal{E,T},SVal{L,Ti}}) where {T,B,E,L,Ti<:Integer} = B::T
@pure Base.first(::Type{<:AbstractUnitSRange{T,SVal{B,T},SVal{E,T},SVal{L,Ti}}}) where {T,B,E,L,Ti<:Integer} = B::T
@pure sfirst(::AbstractUnitSRange{T,SVal{B,T},SVal{E,T},SVal{L,Ti}}) where {T,B,E,L,Ti<:Integer} = SVal{B::T,T}()
@pure sfirst(::Type{<:AbstractUnitSRange{T,SVal{B,T},SVal{E,T},SVal{L,Ti}}}) where {T,B,E,L,Ti<:Integer} = SVal{B::T,T}()

@pure first(::AbstractUnitSRange{T,HPSVal{Tb,Hb,Lb},SVal{E,T},SVal{L,Ti}}) where {T,Tb,Hb,Lb,E,L,Ti<:Integer} = T(Hb::Tb + Lb::Tb)::T
@pure first(::Type{<:AbstractUnitSRange{T,HPSVal{Tb,Hb,Lb},SVal{E,T},SVal{L,Ti}}}) where {T,Tb,Hb,Lb,E,L,Ti<:Integer} = T(Hb::Tb + Lb::Tb)::T
@pure sfirst(::AbstractUnitSRange{T,HPSVal{Tb,Hb,Lb},SVal{E,T},SVal{L,Ti}}) where {T,Tb,Hb,Lb,E,L,Ti<:Integer} = HPSVal{Tb,Hb,Lb}()
@pure sfirst(::Type{<:AbstractUnitSRange{T,HPSVal{Tb,Hb,Lb},SVal{E,T},SVal{L,Ti}}}) where {T,Tb,Hb,Lb,E,L,Ti<:Integer} = HPSVal{Tb,Hb,Lb}()
@pure last(::AbstractUnitSRange{T,SVal{B,T},SVal{E,T},SVal{L,Ti}}) where {T,B,E,L,Ti<:Integer} = E::T
@pure last(::Type{<:AbstractUnitSRange{T,SVal{B,T},SVal{E,T},SVal{L,Ti}}}) where {T,B,E,L,Ti<:Integer} = E::T
@pure slast(::AbstractUnitSRange{T,SVal{B,T},SVal{E,T},SVal{L,Ti}}) where {T,B,E,L,Ti<:Integer} = SVal{E::T,T}()
@pure slast(::Type{<:AbstractUnitSRange{T,SVal{B,T},SVal{E,T},SVal{L,Ti}}}) where {T,B,E,L,Ti<:Integer} = SVal{E::T,T}()

@pure last(::AbstractUnitSRange{T,HPSVal{Tb,Hb,Lb},SVal{E,T},SVal{L,Ti}}) where {T,Tb,Hb,Lb,E,L,Ti<:Integer} = E::T
@pure last(::Type{<:AbstractUnitSRange{T,HPSVal{Tb,Hb,Lb},SVal{E,T},SVal{L,Ti}}}) where {T,Tb,Hb,Lb,E,L,Ti<:Integer} = E::T
@pure slast(::AbstractUnitSRange{T,HPSVal{Tb,Hb,Lb},SVal{E,T},SVal{L,Ti}}) where {T,Tb,Hb,Lb,E,L,Ti<:Integer} = SVal{E::T,T}()
@pure slast(::Type{<:AbstractUnitSRange{T,HPSVal{Tb,Hb,Lb},SVal{E,T},SVal{L,Ti}}}) where {T,Tb,Hb,Lb,E,L,Ti<:Integer} = SVal{E::T,T}()

showrange(io::IO, r::AbstractUnitSRange) = print(io, "$(first(r)):$(last(r)) \t (static)")

"""
    OrdinalSRange
"""
abstract type OrdinalSRange{T,B,S,E,L} <: AbstractUnitSRange{T,B,E,L} end

@pure step(::OrdinalSRange{T,SVal{B,Tb},SVal{S,Ts},SVal{E,T},SVal{L,Ti}}) where {T,B,Tb,S,Ts,E,L,Ti<:Integer} = S::Ts
@pure step(::Type{<:OrdinalSRange{T,SVal{B,Tb},SVal{S,Ts},SVal{E,T},SVal{L,Ti}}}) where {T,B,Tb,S,Ts,E,L,Ti<:Integer} = S::Ts
@pure sstep(::OrdinalSRange{T,SVal{B,Tb},SVal{S,Ts},SVal{E,T},SVal{L,Ti}}) where {T,B,Tb,S,Ts,E,L,Ti<:Integer} = SVal{S::Ts,Ts}()
@pure sstep(::Type{<:OrdinalSRange{T,SVal{B,Tb},SVal{S,Ts},SVal{E,T},SVal{L,Ti}}}) where {T,B,Tb,S,Ts,E,L,Ti<:Integer} = SVal{S::Ts,Ts}()

@pure step(::OrdinalSRange{T,B,HPSVal{Ts,Hs,Ls},E,L}) where {T,B,Ts,Hs,Ls,E,L} = T(Hs::Ts + Ls::Ts)::T
@pure step(::Type{<:OrdinalSRange{T,B,HPSVal{Ts,Hs,Ls},E,L}}) where {T,B,Ts,Hs,Ls,E,L} = T(Hs::Ts + Ls::Ts)::T
@pure sstep(::OrdinalSRange{T,B,HPSVal{Ts,Hs,Ls},E,L}) where {T,B,Ts,Hs,Ls,E,L} = HPSVal{Ts,Hs::Ts,Ls::Ts}()
@pure sstep(::Type{<:OrdinalSRange{T,B,HPSVal{Ts,Hs,Ls},E,L}}) where {T,B,Ts,Hs,Ls,E,L} = HPSVal{Ts,Hs::Ts,Ls::Ts}()



showrange(io::IO, r::OrdinalSRange) = print(io, "$(first(r)):$(step(r)):$(last(r)) \t (static)")


