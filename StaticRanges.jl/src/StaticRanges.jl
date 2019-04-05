module StaticRanges

using StaticArrays

import StaticArrays: tuple_length, tuple_prod, tuple_minimum

import Base: TwicePrecision, @pure, getindex, checkbounds
import Base: ==, +, -, *, /, ^, <, ~, abs, abs2, isless, max, min, div, eltype, tail
import Base: first, last, firstindex, lastindex, step, length

import Base.Checked: checked_sub, checked_add

export StaticRange, OneToSRange, srange, SVal, HPSVal

include("SVal.jl")
include("HPSVal.jl")

abstract type StaticRange{T,B,S,E,L,F} <: AbstractRange{T} end

struct SRange{T,B,S,E,L,F} <: StaticRange{T,B,S,E,L,F} end

include("traits.jl")

include("unitrange.jl")
include("steprange.jl")
include("floatrange.jl")
include("srangehp.jl")
include("linspace.jl")
include("steprangelen.jl")
include("srange.jl")
include("indexing.jl")


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
    StaticRange{t,start,stop,step,offset,length}()

==(sr1::StaticRange, sr2::StaticRange) = isequal(sr1, sr2)

@pure Base.isempty(::StaticRange{T,B,E,S,F,0}) where {T,B,E,S,F} = true
@pure Base.isempty(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = false

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



end