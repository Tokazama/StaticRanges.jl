abstract type AbstractStaticRange{T,L} <: AbstractRange{T} end

const AbstractStaticRangeUnion{T,L} = Union{AbstractStaticRange{T,L},Type{<:AbstractStaticRange{T,L}}}

@pure length(::AbstractStaticRangeUnion{T,L}) where {T,L} = L::Int
@pure lastindex(::AbstractStaticRangeUnion{T,L}) where {T,L} = L::Int
@pure size(::AbstractStaticRangeUnion{T,L}) where {T,L} = (L,)::NTuple{1,Int}
@pure firstindex(::AbstractStaticRangeUnion{T,L}) where {T,L} = 1::Int

@pure Base.isempty(::AbstractStaticRangeUnion{T,0}) where {T,B,E,S} = true
@pure Base.isempty(::AbstractStaticRangeUnion{T,L}) where {T,L} = false

# len    lendiv  start   stop
#struct LinSRange{T,B,E,L} <: AbstractStaticRange{T,L} end
# const LinSRangeUnion{T,B,E,L} = Union{LinSRange{T,B,E,L},Type{<:LinSRange{T,B,E,L}}}

# TODO: handle UnitSRange with multiple non-int types before implementing this
struct UnitSRange{T,B,E,L} <: AbstractStaticRange{T,L} end

@pure first(::UnitSRange{T,B,E,S,L}) where {T,B,E,S,L} = B::T
@pure first(::Type{<:UnitSRange{T,B,E,S,L}}) where {T,B,E,S,L} = B::T

@pure last(::UnitSRange{T,B,E,S,L}) where {T,B,E,S,L} = E::T
@pure last(::Type{<:UnitSRange{T,B,E,S,L}}) where {T,B,E,S,L} = E::T

@pure step(::UnitSRange{T,B,E,S,L}) where {T,B,E,S,L} = T(1)
@pure step(::Type{<:UnitSRange{T,B,E,S,L}}) where {T,B,E,S,L} = T(1)



abstract type OrdinalSRange{T,B,E,S,L} <: AbstractStaticRange{T,L} end

@pure first(::OrdinalSRange{T,B,E,S,L}) where {T,B,E,S,L} = B::T
@pure first(::Type{<:OrdinalSRange{T,B,E,S,L}}) where {T,B,E,S,L} = B::T

@pure last(::OrdinalSRange{T,B,E,S,L}) where {T,B,E,S,L} = E::T
@pure last(::Type{<:OrdinalSRange{T,B,E,S,L}}) where {T,B,E,S,L} = E::T

@pure step(::OrdinalSRange{T,B,E,S,L}) where {T,B,E,S,L} = S::T
@pure step(::Type{<:OrdinalSRange{T,B,E,S,L}}) where {T,B,E,S,L} = S::T

# TODO: StepSRange needs own non pure getindex
mutable struct StepSRange{T,B,E,S,L} <: OrdinalSRange{T,B,E,S,L}
    offset::Int
end

offset(r::StepSRange{T}) where T = r.offset::Int



"""
    StaticRange

A StaticRange is fully statically typed in all of its traits.
* eltype
* first
* last
* step
* offset
* length

"""
struct StaticRange{T,B,E,S,F,L} <: OrdinalSRange{T,B,E,S,F,L}
    function StaticRange{T,B,E,S,F,L}() where {T,B,E,S,F,L}
        (B*S) > E && error("StaticRange: the last index of a StaticRange cannot be less than the first index unless reverse indexing, got first = $B, and last = $E, step = $S.")
        new{T,B,E,S,F,L}()
    end
end

const StaticRangeUnion{T,B,E,S,F,L} = Union{StaticRange{T,B,E,S,F,L},Type{<:StaticRange{T,B,E,S,F,L}}}

offset(::StaticRangeUnion{T,B,E,S,F,L}) where {T,B,E,S,F,L} = F::Int
firstindex(::StaticRangeUnion{T,B,E,S,F,L}) where {T,B,E,S,F,L} = F::Int
lastindex(::StaticRangeUnion{T,B,E,S,F,L}) where {T,B,E,S,F,L} = (L + F)::Int


const OneToSRange{N} = StaticRange{Int,1,N,1,1,N}
OneToSRange(N::Int) = OneToSRange{N}()

StaticRange{B,E,S,F}() where {B,E,S,F} = StaticRange{B,E,S,F,floor(Int, (E-B)/S)+1}()
StaticRange{B,E,S,F,L}() where {B,E,S,F,L} = StaticRange{B,E,S,F,L,typeof(B+0*S)}()

srange(r::AbstractRange{T}) where T = StaticRange{T,first(r),last(r),step(r),T(1),length(r)}()

