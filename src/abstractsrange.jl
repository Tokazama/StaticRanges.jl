"""
    StaticRange{T,L}
"""
abstract type StaticRange{T,L} <: AbstractRange{T} end


@inline length(::StaticRange{T,L}) where {T,L<:SInteger} = values(L)
@inline length(::Type{<:StaticRange{T,L}}) where {T,L<:SInteger} = values(L)
@inline slength(::StaticRange{T,L}) where {T,L<:SInteger} = L()
@inline slength(::Type{<:StaticRange{T,L}}) where {T,L<:SInteger} = L()


# this will facilitate indirect indexing through custom indices
firstindex(r::StaticRange) = firstindex(IndexStyle(s), r)
firstindex(r::Type{<:StaticRange}) = lastindex(IndexStyle(s), r)
sfirstindex(r::StaticRange) = sfirstindex(IndexStyle(s), r)
sfirstindex(r::Type{<:StaticRange}) = sfirstindex(IndexStyle(s), r)


firstindex(::IndexLinear, ::StaticRange) = SOne
firstindex(::IndexLinear, ::Type{<:StaticRange}) = SOne
sfirstindex(::IndexLinear, ::StaticRange) = SOne
sfirstindex(::IndexLinear, ::Type{<:StaticRange}) = SOne

lastindex(::IndexLinear, r::StaticRange) = slength(r)
lastindex(::IndexLinear, r::Type{<:StaticRange}) = slength(r)
slastindex(::IndexLinear, r::StaticRange) = slength(r)
slastindex(::IndexLinear, r::Type{<:StaticRange}) = slength(r)


Base.show(io::IO, r::StaticRange) = showrange(io, r)
Base.show(io::IO, ::MIME"text/plain", r::StaticRange) = showrange(io, r)

#@pure soffset(::StaticStepRangeLen{T,B,S,E,SVal{L},SVal{F}}) where {T,B,S,E,L,F} = SVal{F::Ti,Ti}()
#@pure soffset(::Type{<:StaticStepRangeLen{T,B,S,E,SVal{L},SVal{F}}}) where {T,B,S,E,L,F,Ti<:Integer} = SVal{F::Ti,Ti}()


"""
    StaticStartRange{T,B,E,L}

StaticRange subtype with parametric parameters for the first and last parts of a range.
"""
abstract type StaticStartRange{T,B,E,L} <: StaticRange{T,L} end

@inline first(::StaticStartRange{T,B}) where {T,B<:SVal} = values(B)
@inline first(::Type{<:StaticStartRange{T,B}}) where {T,B<:SVal} = values(B)
@inline sfirst(::StaticStartRange{T,B}) where {T,B<:SVal} = B()
@inline sfirst(::Type{<:StaticStartRange{T,B}}) where {T,B<:SVal} = B()

@inline last(::StaticStartRange{T,B,E}) where {T,B,E<:SVal} = E::T
@inline last(::Type{<:StaticStartRange{T,B,E}}) where {T,B,E<:SVal} = E::T
@inline slast(::StaticStartRange{T,B,E}) where {T,B,E<:SVal} = E()
@inline slast(::Type{<:StaticStartRange{T,B,E}}) where {T,B,E<:SVal} = E()


"""
    StaticUnitRange{T,B,E,L}

Supertype for static ranges with a step size of oneunit(T) with elements of type T.
UnitRange and other types are subtypes of this

# Examples
```jldoctest
```
"""
abstract type StaticUnitRange{T,B,E,L} <: StaticStartRange{T,B,E,L} end

@inline step(::StaticUnitRange{T}) where T = one(T)::T
@inline step(::Type{<:StaticUnitRange{T}}) where T = one(T)::T
@inline sstep(::StaticUnitRange{T}) where T = sone(T)
@inline sstep(::Type{<:StaticUnitRange{T}}) where T = sone(T)


# if length is dynamic 
length(r::StaticUnitRange{T,B,E,Dynamic}) where {T,B,E,Dynamic} = Integer(last(r) - first(r) + step(r))
function length(r::StaticUnitRange{T,B,E,Dynamic}) where {T<:Union{Int,Int64,Int128},B,E}
    Base.@_inline_meta
    (last(r) - first(r)) - one(T)
end

length(r::StaticUnitRange{T,B,E,Dynamic}) where {T<:Union{UInt,UInt64,UInt128},B,E} =
    last(r) < first(r) ? zero(T) : (last(r) - first(r) + one(T))


"""
    StaticOrdinalRange

"""
abstract type StaticOrdinalRange{T,B,S,E,L} <: StaticStartRange{T,B,E,L} end

@inline step(::StaticOrdinalRange{T,B,S}) where {T,B,S<:SVal} = values(S)
@inline step(::Type{<:StaticOrdinalRange{T,B,S}}) where {T,B,S<:SVal} = values(S)
@inline sstep(::StaticOrdinalRange{T,B,S}) where {T,B,S<:SVal} = S()
@inline sstep(::Type{<:StaticOrdinalRange{T,B,S}}) where {T,B,S<:SVal} = S()

function length(r::StaticOrdinalRange{T,B,S,E,Dynamic}) where {T<:Union{Int,UInt,Int64,UInt64,Int128,UInt128},B,S,E}
    isempty(r) && return zero(T)
    if step(r) > 1
        return convert(T, div(unsigned(last(r) - first(r)), step(r))) + one(T)
    elseif step(r) < -1
        return convert(T, div(unsigned(first(r) - last(r)), -step(r))) + one(T)
    elseif step(r) > 0
        return div((last(r) - first(r)) - step(r)) + one(T)
    else
        return div(first(r) - last(r), -step(r)) + one(T)
    end
end

function length(r::StaticOrdinalRange{T,B,S,E,Dynamic}) where {T,B,S,E}
    n = Integer(div((last(r) - first(r)) + step(r), step(r)))
    isempty(r) ? zero(n) : n
end

"""
    StaticStepRange
"""
abstract type StaticStepRange{T,B,S,E,L} <: StaticOrdinalRange{T,B,S,E,L} end


"""
    StaticLinRange{T,B,E,L,D}
"""
abstract type StaticLinRange{T,B,S,E,L,D} <: StaticOrdinalRange{T,B,S,E,L} end

@inline lendiv(::StaticLinRange{T,B,E,L,D}) where {T,B,E,L,D} = one(T)::T
@inline lendiv(::Type{<:StaticLinRange{T,B,E,L}}) where {T,B,E,L} = one(T)::T
@inline slendiv(::StaticLinRange{T,B,E,L}) where {T,B,E,L} = SOne(T)
@inline slendiv(::Type{<:StaticLinRange{T,B,E,L}}) where {T,B,E,L} = SOne(T)


step(r::StaticLinRange{T,B,Dynamic,E,L,D}) where {T,B,E,L,D} = (last(r)-first(r))/lendiv(r)

#LinSRange(start::SVal{B,T}, stop::SVal{E,T}, len::SInteger{L}) where {T,B,E,L} =
#    LinSRange{eltype((stop-start)/len)}(start, stop, len)

"""
    StaticStepRangeLen{T,B,S,E,L,F}

"""
abstract type StaticStepRangeLen{T,B,S,E,L,F} <: StaticOrdinalRange{T,B,S,E,L} end

@inline offset(::StaticStepRangeLen{T,B,S,E,L,F}) where {T,B,S,E,L,F<:SInteger} = values(F)
@inline offset(::Type{<:StaticStepRangeLen{T,B,S,E,L,F}}) where {T,B,S,E,L,F<:SInteger} = values(F)
@inline soffset(::StaticStepRangeLen{T,B,S,E,L,F}) where {T,B,S,E,L,F<:SInteger} = F()
@inline soffset(::Type{<:StaticStepRangeLen{T,B,S,E,L,F}}) where {T,B,S,E,L,F<:SInteger} = F()
