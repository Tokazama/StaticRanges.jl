module StaticRanges

using StaticArrays

import StaticArrays: tuple_length, tuple_prod, tuple_minimum

import Base: TwicePrecision, @pure, getindex, checkbounds
import Base: ==, +, -, *, /, ^, <, ~, :, abs, abs2, isless, max, min, div, eltype, tail
import Base: first, last, firstindex, lastindex, step, length

import Base.Checked: checked_sub, checked_add

export StaticRange, UnitSRange, OneToSRange, srange, SVal, HPSVal, SOne, SZero

include("StaticValues/StaticValues.jl")
using .StaticValues

abstract type StaticRange{T,B,S,E,L,F} <: AbstractRange{T} end

struct SRange{T,B,S,E,L,F} <: StaticRange{T,B,S,E,L,F} end

Base.oftype(::SRange, r::StaticRange{T,B,S,E,L,F}) where {T,B,S,E,L,F} =
    SRange{T,B,S,E,L,F}()
Base.oftype(::SRange, r::SRange{T,B,S,E,L,F}) where {T,B,S,E,L,F} = r


include("traits.jl")
include("unitrange.jl")
include("steprange.jl")
include("floatrange.jl")
include("srangehp.jl")
include("linspace.jl")
include("steprangelen.jl")
include("srange.jl")
include("colon.jl")
include("rangemath.jl")
include("abstractarray.jl")
include("indexing.jl")
include("intersect.jl")

function Base.reverse(r::StaticRange{T,SVal{B,Tb},SVal{S,Ts},E,L,F}) where {T,B,Tb,S,Ts,E,L,F}
    oftype(r, _sr(SVal{Tb(E),Tb}(), SVal{-S,Ts}(), SVal{B,Tb}(), SNothing()))
end

function Base.reverse(r::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F}) where {T,Tb,Hb,Lb,Ts,Hs,Ls,E,L,F}
    offset = isempty(r) ? SVal{F::Int,Int}() : SVal{L-F+1,Int}()
    oftype(r, steprangelen(HPSVal{Tb,Hb,Lb}(), HPSVal{Ts,-Hs,-Ls}(), HPSVal{E::Int,Int}(), offset))
end


function Base.similar(
    r::StaticRange{T,B,E,S,F,L}; t::Type=T, start::T=B, stop::T=E, step::T=S, offset::Int=F, length::Int=L) where {T,B,E,S,F,L}
    oftype(r, SRange{t,start,stop,step,offset,length}())
end

Base.copy(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = StaticRange{T,B,E,S,F,L}()

# Idea: would it be inappropriate for sortperm to return a StaticRange given a StaticRange?


Base.show(io::IO, r::StaticRange) = showrange(io, r)
Base.show(io::IO, ::MIME"text/plain", r::StaticRange) = showrange(io, r)

function showrange(io::IO, r::StaticRange)
    print(io, "StaticRange($(first(r))")
    if step(r) != 1
        print(io, ":$(step(r))")
    end
    print(io, ":$(last(r)))")
end

Base.in(x, ::StaticRange{T,B,E,0,F,L}) where {T,B,E,F,L} = L == 0 && B == x
Base.in(x::Integer, ::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} =
    x >= B && x <= E && (mod(convert(T, x), S) - mod(B, S) == 0)
Base.in(x::AbstractChar, ::StaticRange{<:AbstractChar,B,E,S,F,L}) where {B,E,S,F,L} =
    x >= B && x <= E && (mod(Int(x) - Int(B), S) == 0)

Base.issorted(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = L <= 1 || S >= zero(S)

function Base.sortperm(r::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L}
    issorted(r) ? StaticRange{Int,F,L-F+1,1,1,L}() : StaticRange{Int,L-F+1,F,-1,1,L}()
end

Base.sum(r::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} =
    L * B + (iseven(L) ? (S * (L-1)) * (L>>1) : (S * L) * ((L-1)>>1))
end