module StaticRanges

using StaticArrays
import Base.unsafe_getindex

export srange, StaticRange


struct StaticRange{B,E,S,F,L,T} <: StaticVector{L,T}
    function StaticRange{B,E,S,F,L,T}() where {B,E,S,F,L,T}
        L >= 0 || throw(ArgumentError("length cannot be negative, got $L"))
        1 <= F <= max(1,L) || throw(ArgumentError("StaticRange: step must be in [1,$L], got $S"))  # FIXME
        new{B,E,S,F,L,T}()
    end
end

function StaticRange(start::Real, step::Real, stop::Real, offset::Real)
    B, E, F = promote(start, stop, offset)
    StaticRange{B,E,step,F}()
end

StaticRange{B,E,S,F}() where {B,E,S,F} = StaticRange{B,E,S,F,floor(Int, (E-B)/S)+1}()
StaticRange{B,E,S,F,L}() where {B,E,S,F,L} = StaticRange{B,E,S,F,L,typeof(B+0*S)}()

SRBoth{B,E,S,F,L,T} = Union{StaticRange{B,E,S,F,L,T},Type{<:StaticRange{B,E,S,F,L,T}}}

# Indexing interface
Base.length(r::SRBoth{B,E,S,F,L}) where {B,E,S,F,L} = L
Base.step(r::SRBoth{B,E,S}) where {B,E,S} = S
Base.first(r::SRBoth{B}) where {B} = unsafe_getindex(r, 1)
Base.last(r::SRBoth{B,E}) where {B,E} = unsafe_getindex(r, length(r))
Base.firstindex(::SRBoth) = 1
Base.lastindex(::SRBoth{B,E,S,F,L}) where {B,E,S,F,L} = L
offset(::SRBoth{B,E,S,F}) where {B,E,S,F} = F

Base.iterate(r::SRBoth) = (r[1], 1)
function Base.iterate(r::SRBoth, state::Int)
    if state < lastindex(r)
        r[state+1], state+1
    else
        return nothing
    end
end

function showrange(io::IO, r::StaticRange)
    print(io, "StaticRange: $(first(r)):$(step(r)):$(last(r))")
end
Base.show(io::IO, r::StaticRange) = showrange(io, r)
Base.show(io::IO, ::MIME"text/plain", r::StaticRange) = showrange(io, r)

include("srange.jl")
include("indexing.jl")
#include("swindow.jl")

end
