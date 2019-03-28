module StaticRanges

using StaticArrays

import StaticArrays: tuple_length, tuple_prod, tuple_minimum

import Base: unsafe_getindex, getindex, checkbounds, @pure, ==, +, -, tail, eltype

import Base.Checked: checked_sub, checked_add

export StaticRange, OneToSRange, srange

abstract type StaticRange{T,B,E,S,F,L} <: AbstractRange{T} end

@pure Base.first(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = B::T
@pure Base.first(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = B::T

@pure Base.last(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = E::T
@pure Base.last(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = E::T

@pure Base.step(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = S::T
@pure Base.step(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = S::T

@pure Base.firstindex(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = F
@pure Base.firstindex(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = F

@pure Base.lastindex(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = L - F + 1
@pure Base.lastindex(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = L - F + 1

@pure Base.length(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = L
@pure Base.length(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = L

@pure Base.size(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = (L,)
@pure Base.size(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = (L,)

@pure Base.minimum(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = B::T
@pure Base.minimum(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = B::T

@pure Base.maximum(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = E::T
@pure Base.maximum(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = E::T

@pure Base.extrema(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = (B, E)::Tuple{T,T}
@pure Base.extrema(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = (B, E)::Tuple{T,T}

include("srange.jl")
include("IntSRange.jl")
include("FloatSRange.jl")
include("NamedRange.jl")
include("IndirectRange.jl")



#=
    function StaticRange{T,B,E,S,F,L}() where {T,B,E,S,F,L}
        (B*S) > E && error("StaticRange: the last index of a StaticRange cannot be less than the first index unless reverse indexing, got first = $B, and last = $E, step = $S.")
        new{T,B,E,S,F,L}()
    end
=#

############
# Indexing #
############
Base.iterate(r::StaticRange{T,B,E,S,F,0}) where {T,B,E,S,F} = nothing
@inline function Base.iterate(::StaticRange{T,B,E,S,F,L}, state::Int) where {T,B,E,S,F,L}
    state === nothing && return nothing
    (B + (state - F) * S, state + 1)::Tuple{T,Int}
end

@inline function getindex(r::StaticRange, i::Int)
    @boundscheck checkbounds(r, i)
    @inbounds unsafe_getindex(r, i)
end

@inline function getindex(r::StaticRange, i::AbstractArray)
    @boundscheck checkbounds(r, i)
    @inbounds unsafe_getindex(r, i)
end

#@inline function getindex(r::AbstractArray{T,N}, i::StaticRange) where {T,N}
#    @boundscheck checkbounds(r, i)
#    @inbounds unsafe_getindex(r, i)
#end

@pure Base.to_index(A::Array, r::StaticRange) = r

@inline function unsafe_getindex(::StaticRange{T,B,E,S,F,L}, i::Int) where {T,B,E,S,F,L}
    B + (i - F) * S
end

@inline function checkbounds(r::AbstractArray, I::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L}
    (B < firstindex(r) || E > lastindex(r)) && throw(BoundsError(r, i))
end

@inline function checkbounds(r::StaticRange{T,B,E,S,F,L}, i::AbstractRange) where {T,B,E,S,F,L}
    (first(i) < F || last(i) > (L-F +1)) && throw(BoundsError(r, i))
end


@inline function unsafe_getindex(
    ::StaticRange{T1,B1,E1,S1,F1,L1}, ::StaticRange{T2,B2,E2,S2,F2,L2}) where {T1,B1,E1,S1,F2,L1,T2,B2,E2,S2,F1,L2}
    StaticRange{T1,B1 + (B2 - F1) * S1,(B1 + (B2 - F1) * S1) + (L2-1)*(S1*S2),S1*S2,L2}()
end

@inline function unsafe_getindex(::StaticRange{T,B,E,S,F,L}, i::AbstractRange) where {T,B,E,S,F,L}
    StaticRange{T,T(B + (first(i) - F) * S),T(B + (first(i) - F) * S) + (length(i)-F)*(S*step(i)),S*step(i),1,length(i)}()
end


#########
# Utils #
#########

@inline +(::StaticRange{T,B1,E1,S1,F,L}, ::StaticRange{T,B2,E2,S2,F,L}) where {T,B1,E1,S1,B2,E2,S2,F,L} =
    StaticRange{T,B1+B2,E1+E2,S1+S2,F,L}()

@inline -(::StaticRange{T,B1,E1,S1,F,L}, ::StaticRange{T,B2,E2,S2,F,L}) where {T,B1,E1,S1,B2,E2,S2,F,L} =
    StaticRange{T,B1-B2,E1-E2,S1-S2,F,L}()


@pure function Base.isequal(
    ::StaticRange{T1,B1,E1,S1,F1,L1}, ::StaticRange{T2,B2,E2,S2,F2,L2}) where {T1,B1,E1,S1,F1,L1,T2,B2,E2,S2,F2,L2}
    false
end
@pure function Base.isequal(::StaticRange{T,B,E,S,F,L}, ::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L}
    true
end

Base.reverse(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = StaticRange{T,E,B,-S,F,L}()


Base.similar(::StaticRange{T,B,E,S,F,L}; t::Type=T, start::T=B, stop::T=E, step::T=S, offset::Int=F, length::Int=L) where {T,B,E,S,F,L} =
    StaticRange{t,ts,ti,start,stop,step,offset,length}()

==(sr1::StaticRange, sr2::StaticRange) = isequal(sr1, sr2)

@pure Base.isempty(::StaticRange{T,B,E,S,F,0}) where {T,B,E,S,F} = true
@pure Base.isempty(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = false

Base.copy(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = StaticRange{T,B,E,S,F,L}()

# Idea: would it be inappropriate for sortperm to return a StaticRange given a StaticRange?


Base.show(io::IO, r::StaticRange) = showrange(io, r)
Base.show(io::IO, ::MIME"text/plain", r::StaticRange) = showrange(io, r)

function showrange(io::IO, r::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L}
    print(io, "StaticRange($B")
    if step(r) != 1
        print(io, ":$S")
    end
    print(io, ":$(E))")
end

function Base.intersect(r::StaticRange{T1,B1,E1,S1,F1,0}, s::StaticRange{T2,B2,E2,S2,F1,L2}) where {T1,B1,E1,S1,F1,T2,B2,E2,S2,F2,L2}
    StaticRange{T1,B1,B1-1,S1,1,0}()
end

function Base.intersect(r::StaticRange{T1,B1,E1,S1,F1,L1}, s::StaticRange{T2,B2,E2,S2,F2,0}) where {T1,B1,E1,S1,F1,L1,T2,B2,E2,S2,F2}
    StaticRange{T1,B1,B1-1,S1,1,0}()
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

@inline function Base.intersect(r::StaticRange{T1,B1,E1,S1,F1,L1}, s::StaticRange{T2,B2,E2,S2,F2,L2}
                       ) where {T1,B1,E1,S1,F1,L1,T2,B2,E2,S2,F2,L2}
    if S1 < 0
        return intersect(r, reverse(s))
    elseif S2 < 0
        return reverse(intersect(reverse(r), s))
    end

    a = lcm(S1, S2)
    g, x, y = gcdx(S1, S2)

    if rem(B1 - B2, g) != 0
        # Unaligned, no overlap possible.
        return srange(B1, step=a, length=0)
    end

    z = div(B1 - B2, g)
    b = S1 - x * z * 1
    # Possible points of the intersection of r and s are
    # ..., b-2a, b-a, b, b+a, b+2a, ...
    # Determine where in the sequence to start and stop.
    m = max(B1 + mod(b - B1, a), B2 + mod(b - B2, a))
    n = min(E1 - mod(E1 - b, a), E2 - mod(E2 - b, a))
    return srange(m, step=a, stop=n)
end

Base.sum(r::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} =
    L * B + (iseven(L) ? (S * (L-1)) * (L>>1) : (S * L) * ((L-1)>>1))

-(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = StaticRange{T,-B,-E,-S,F,L}()


@inline function Base.getproperty(r::StaticRange, sym::Symbol)
    if sym === :step
        return step(r)
    elseif sym === :start
        return first(r)
    elseif sym === :stop
        return last(r)
    elseif sym === :len
        return length(r)
    elseif sym === :lendiv
        return (last(r) - first(r)) / step(r)
    elseif sym === :ref  # for now this is just treated the same as start
        return first(r)
    elseif sym === :offset
        return firstindex(r)
    else
        error("type $(typeof(r)) has no field $sym")
    end
end


end
