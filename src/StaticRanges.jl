module StaticRanges

using StaticArrays

import StaticArrays: tuple_length, tuple_prod, tuple_minimum

import Base: TwicePrecision, @pure, getindex, checkbounds
import Base: ==, +, -, *, /, ^, <, ~, :, abs, abs2, isless, max, min, div, eltype, tail
import Base: first, last, firstindex, lastindex, step, length

import Base.Checked: checked_sub, checked_add
import StaticArrays: Dynamic

export StepSRange, UnitSRange, OneToSRange, StepSRangeLen, LinSRange,
       StaticIndices, LinearSIndices,
       srange, SVal, HPSVal, SOne, SZero,
       sfirst, sstep, slast, sfirstindex, slastindex


include("StaticValues/StaticValues.jl")
using .StaticValues

#Base.oftype(::SRange, r::StaticRange{T,B,S,E,L,F}) where {T,B,S,E,L,F} =
#    SRange{T,B,S,E,L,F}()
#Base.oftype(::SRange, r::SRange{T,B,S,E,L,F}) where {T,B,S,E,L,F} = r


include("abstractsrange.jl")
include("UnitSRange.jl")
include("LinSRange.jl")
include("StepSRangeLen.jl")
include("StepSRange.jl")
include("floatrange.jl")
include("srangehp.jl")
include("linspace.jl")
include("srange.jl")
include("colon.jl")
include("rangemath.jl")
include("abstractarray.jl")
include("checkbounds.jl")
include("getindex.jl")
#include("indexing.jl")
include("reverse.jl")
include("intersect.jl")
include("in.jl")
include("sorting.jl")
include("StaticIndices/StaticIndices.jl")

==(r::AbstractSRange, s::AbstractSRange) =
    (first(r) == first(s)) & (step(r) == step(s)) & (last(r) == last(s))
#=
==(r::OrdinalSRange, s::OrdinalSRange) =
    (first(r) == first(s)) & (step(r) == step(s)) & (last(r) == last(s))
==(r::T, s::T) where {T<:Union{StepSRangeLen,LinSRange}} =
    (first(r) == first(s)) & (length(r) == length(s)) & (last(r) == last(s))
==(r::Union{StepSRange{T},StepSRangeLen{T,T}}, s::Union{StepSRange{T},StepSRangeLen{T,T}}) where {T} =
    (first(r) == first(s)) & (last(r) == last(s)) & (step(r) == step(s))
=#

#=
function Base.similar(
    r::AbstractSRange{T,B,E,S,F,L}; t::Type=T, start::T=B, stop::T=E, step::T=S, offset::Int=F, length::Int=L) where {T,B,E,S,F,L}
    oftype(r, SRange{t,start,stop,step,offset,length}())
end
=#
end