abstract type AbstractStaticRange{T,L} <: AbstractRange{T} end

const AbstractStaticRangeUnion{T,L} = Union{AbstractStaticRange{T,L},Type{<:AbstractStaticRange{T,L}}}

@pure length(::AbstractStaticRangeUnion{T,L}) where {T,L} = L::Int
@pure lastindex(::AbstractStaticRangeUnion{T,L}) where {T,L} = L::Int
@pure size(::AbstractStaticRangeUnion{T,L}) where {T,L} = (L,)::NTuple{1,Int}

@pure Base.isempty(::AbstractStaticRangeUnion{T,0}) where {T,B,E,S} = true
@pure Base.isempty(::AbstractStaticRangeUnion{T,L}) where {T,L} = false
@pure offset(::AbstractStaticRange) = oftype(L, 1)


"""
    OneToSRange{T,N}

"""
struct OneToSRange{T,N} <: AbstractStaticRange{T,N} end

OneToSRange(N::Int) = OneToSRange{T,N}()

OneToSRangeUnion{T,N} = Union{OneToSRange{T,N},Type{<:OneToSRange{T,N}}}

@pure       last(::OneToSRangeUnion{T,N}) where {T,N} = N::T
@pure       step(::OneToSRangeUnion{T,N}) where {T,N} = T(1)
@pure firstindex(::OneToSRangeUnion{T,N}) where {T,N} = 1::Int
@pure  lastindex(::OneToSRangeUnion{T,N}) where {T,N} = N::Int

"""
    OrdinalSRange{T,B,E,L} <: AbstractStaticRange{T,L}
"""
abstract type OrdinalSRange{T,B,E,L} <: AbstractStaticRange{T,L} end

OrdinalSRangeUnion{T,B,E,L} = Union{OrdinalSRange{T,B,E,L},Type{<:OrdinalSRange{T,B,E,L}}}

@pure      first(::OrdinalSRangeUnion{T,B,E,L}) where {T,B,E,L} = B::T
@pure       last(::OrdinalSRangeUnion{T,B,E,L}) where {T,B,E,L} = E::T
@pure firstindex(::OrdinalSRangeUnion{T,B,E,L}) where {T,B,E,L} = 1::Int
@pure  lastindex(::OrdinalSRangeUnion{T,B,E,L}) where {T,B,E,L} = L::Int
@pure       step(::OrdinalSRangeUnion{T,B,E,L}) where {T,B,E,L} = T(1)

@pure Base.minimum(::OrdinalSRangeUnion{T,B}) where {T,B} = B::T
@pure Base.maximum(::OrdinalSRangeUnion{T,B,E}) where {T,B,E} = E::T
@pure Base.extrema(::OrdinalSRangeUnion{T,B,E}) where {T,B,E} = (B, E)::Tuple{T,T}




# len    lendiv  start   stop
#struct LinSRange{T,B,E,L} <: AbstractStaticRange{T,L} end
# const LinSRangeUnion{T,B,E,L} = Union{LinSRange{T,B,E,L},Type{<:LinSRange{T,B,E,L}}}


"""
    UnitSRange{T,B,E,L}

`OrdinalSRange` that assumes that step is T(1).
"""
struct UnitSRange{T,B,E,L} <: OrdinalSRange{T,B,E,L} end

"""
    AbstractStepSRange
Supertype for ordinal static ranges with elements of type `T` and spacing(s) of type `T`
(note: differs from `OrdinalRange` which allows spacing to have unique type from elements).
"""
abstract type AbstractStepSRange{T,B,E,S,L} <: OrdinalSRange{T,B,E,L} end

@pure step(::AbstractStepSRange{T,B,E,S,L}) where {T,B,E,S,L} = S::T
@pure step(::Type{<:AbstractStepSRange{T,B,E,S,L}}) where {T,B,E,S,L} = S::T


abstract type OffsetSRange{T,B,E,S,F,L} <: AbstractStepSRange{T,B,E,S,L} end

@pure firstindex(::OffsetSRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = F::Int
@pure firstindex(::Type{<:OffsetSRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = F::Int

@pure lastindex(::OffsetSRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = (L + F)::Int
@pure lastindex(::Type{<:OffsetSRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = (L + F)::Int


"""
    StaticRange

A StaticRange is fully statically typed in all of its traits.
* eltype
* first
* last
* step
* offset: affects indexing into range (doesn't affect actual range values, see examples)
* length
"""
struct StaticRange{T,B,E,S,F,L} <: OffsetSRange{T,B,E,S,F,L}
    function StaticRange{T,B,E,S,F,L}() where {T,B,E,S,F,L}
        (B*S) > E && error("StaticRange: the last index of a StaticRange cannot be less than the first index unless reverse indexing, got first = $B, and last = $E, step = $S.")
        new{T,B,E,S,F,L}()
    end
end
StaticRange{T,B,E,S,F}() where {T,B,E,S,F} = StaticRange{T,B,E,S,F,floor(Int, (E-B)/S)+1}()

const StaticRangeUnion{T,B,E,S,F,L} = Union{StaticRange{T,B,E,S,F,L},Type{<:StaticRange{T,B,E,S,F,L}}}


@pure ==(::StaticRangeUnion{T1,B1,E1,S1,F1,L1}, ::StaticRangeUnion{T2,B2,E2,S2,F2,L2}) where {T1,B1,E1,S1,F1,L1,T2,B2,E2,S2,F2,L2} = false
@pure ==(::StaticRangeUnion{T,B,E,S,F,L}, ::StaticRangeUnion{T,B,E,S,F,L}) where {T,B,E,S,F,L} = true

@pure (+)(::StaticRangeUnion{T,B,E,S,F,L}, i::T) where {T,B,E,S,F,L} = StaticRangeUnion{T,B+i,E+i,S,F,L}()
@pure (-)(::StaticRangeUnion{T,B,E,S,F,L}, i::T) where {T,B,E,S,F,L} = StaticRangeUnion{T,B-i,E-i,S,F,L}()

# Qs
# - Should offset be reset to one?
# - Should offset be required to be same in both ranges?
@pure (+)(::StaticRangeUnion{T,B1,E1,S,F,L}, ::StaticRangeUnion{T,B2,E2,S,F,L}) where {T,B1,B2,E1,E2,F,S,L} = StaticRange{T,B+i,E+i,S,1,L}()
@pure (-)(::StaticRangeUnion{T,B1,E1,S,F,L}, ::StaticRangeUnion{T,B2,E2,S,F,L}) where {T,B1,B2,E1,E2,F,S,L} = StaticRange{T,B-i,E-i,S,1,L}()

@pure Base.reverse(::StaticRangeUnion{T,B,E,S,F,L}) where {T,B,E,S,F,L} = StaticRange{T,E,B,-S,F,L}()
Base.similar(::StaticRangeUnion{T,B,E,S,F,L}, type=T, start=B, stop=E, step=S, offset=F, length=L) where {T,B,E,S,F,L,} =
    StaticRange{type,start,stop,step,offset,length}()

# enable base range like interactions
@inline function Base.getproperty(r::StaticRange{T,B,E,S,F,L}, sym::Symbol) where {T,B,E,S,F,L}
    if sym === :step
        return S::T
    elseif sym === :start
        return B::T
    elseif sym === :stop
        return E::T
    elseif sym === :len
        return L::Int
    elseif sym === :lendiv
        return (E - B) / S
    elseif sym === :ref  # for now this is just treated the same as start
        return B::T
    elseif sym === :offset
        return F::Int
    else
        error("type $(typeof(r)) has no field $sym")
    end
end

Base.show(io::IO, r::StaticRange) = showrange(io, r)
Base.show(io::IO, ::MIME"text/plain", r::StaticRange) = showrange(io, r)

function showrange(io::IO, r::StaticRange)
    print(io, "StaticRange(")
    show_mimic_range(io, r)
    print(io, ")")
end

#$(StaticRange)($(B):$(S):$(E))")
show_mimic_range(io::IO, ::StaticRange{T,B,E,S}) where {T,B,E,S} = print(io, "$(B):$(S):$(E)")
#show_mimic_range(io::IO, ::UnitSRange{T,B,E,S}) where {T,B,E,S} = print(io, "$(B):$(E)")
show_mimic_range(io::IO, ::OneToSRange{N}) where {N} = print(io, "OneTo($(N))")
