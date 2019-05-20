abstract type AbstractMRange{T,L} <: AbstractSRange{T,L} end

length(r::AbstractMRange{T,L}) where {T,L<:BaseInteger} = r.len::L
@pure length(r::AbstractMRange{T,SInteger{L,Tl}}) where {T,L,Tl<:BaseInteger} = L::Tl

"""
    AbstractUnitMRange
"""
abstract type AbstractUnitMRange{T,B,E,L} <: AbstractMRange{T,L} end

first(r::AbstractUnitMRange{T,B}) where {T,B<:BaseReal} = r.start::B
@pure first(r::AbstractUnitMRange{T,SReal{B,Tb}}) where {T,B,Tb<:BaseReal} = B::Tb

first(r::AbstractUnitMRange{T,B}) where {T,B<:TwicePrecision} = r.start::B
@pure first(r::AbstractUnitMRange{T,HPSVal{Tuple{Hb,Lb},Tb}}) where {T,Tb,Hb,Lb} =
    T(Hb::Tb + Lb::Tb)::T

last(r::AbstractUnitMRange{T,B,E,L}) where {T,B,E<:BaseReal,L} = r.stop::E
@pure last(r::AbstractUnitMRange{T,B,SReal{E,Te},L}) where {T,B,E,Te<:BaseReal,L} = E::Te

showrange(io::IO, r::AbstractUnitMRange) = print(io, "$(first(r)):$(last(r)) \t (static)")

mutable struct LinMRange{T,B,E,L,D} <: AbstractUnitMRange{T,B,E,L}
    start::B
    stop::E
    len::L
    lendiv::D
end

lastindex(r::LinMRange{T,B,E,L}) where {T,B,E,L<:Integer} = r.len::L
@pure lastindex(r::LinMRange{T,B,E,SInteger{L,Ti}}) where {T,B,E,L,Ti<:Integer} = L::Ti
@pure firstindex(r::LinMRange) = 1::Int64

lendiv(r::LinMRange{T,B,E,L,D}) where {T,B,E,L,D<:BaseInteger} = r.lendiv::D
@pure lendiv(r::LinMRange{T,B,E,L,SInteger{D,Td}}) where {T,B,E,L,D,Td<:BaseInteger} = D::Td

function show(io::IO, r::LinMRange)
    print(io, "mrange(")
    show(io, first(r))
    print(io, ", stop=")
    show(io, last(r))
    print(io, ", length=")
    show(io, length(r))
    print(io, ')')
end

"""
    OrdinalMRange
"""
abstract type OrdinalMRange{T,B,S,E,L} <: AbstractUnitMRange{T,B,E,L} end

step(r::OrdinalMRange{T,B,S}) where {T,B,S<:BaseReal} = r.step::S
@pure step(r::OrdinalMRange{T,B,SReal{S,Ts}}) where {T,B,S,Ts<:BaseReal} = S::Ts

step(r::AbstractUnitMRange{T,B,E,L}) where {T,B,E<:TwicePrecision,L} = r.step::E
@pure step(r::AbstractUnitMRange{T,B,HPSVal{Tuple{Hs,Ls},Ts}}) where {T,B,E,Hs,Ls,Ts,L} =
    T(Hs::Ts + Ls::Ts)::T

mutable struct StepMRangeLen{T,B,S,E,L,F} <: OrdinalMRange{T,B,S,E,L}
    start::B
    step::S
    stop::E
    len::L
    offset::F
end

offset(r::StepMRangeLen{T,B,S,E,L,F}) where {T,B,S,E,L,F<:BaseInteger} = r.offset::F
@pure offset(r::StepMRangeLen{T,B,S,E,L,SInteger{F,Tf}}) where {T,B,S,E,L,F,Tf<:BaseInteger} = F::Tf

@pure firstindex(r::StepMRangeLen) = 1::Int64
lastindex(r::StepMRangeLen) = length(r)

showrange(io::IO, r::OrdinalMRange) = print(io, "$(first(r)):$(step(r)):$(last(r)) \t (static)")
