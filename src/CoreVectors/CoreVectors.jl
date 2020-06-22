
"""
    CoreVectors

Implements subtypes of `CoreVector`, which are intended to provide the most simple data format for representing immutable and mutable vectors that may be dynamic, fixed, or static in size.
"""
module CoreVectors

using StaticRanges
using StaticRanges: OneToUnion, Length
using Base: @propagate_inbounds, OneTo

export
    DynamicImmutableVector,
    DynamicMutableVector,
    FixedImmutableVector,
    FixedMutableVector,
    StaticImmutableVector,
    StaticMutableVector

"""
    CoreVector{T,I,Inds}
"""
abstract type CoreVector{T,I<:Integer,Inds<:OneToUnion{I}} <: AbstractVector{T} end

Base.length(v::CoreVector) = length(getfield(v, :axis))

Base.axes(v::CoreVector) = (getfield(v, :axis),)

@generated function unsafe_getindex_tuple(data::NTuple{N,T}, inds::AbstractVector{<:Integer}, ::Length{L}) where {N,T,L}
    exprs = [:(getfield(data, inds[$i], false)) for i in 1:L]
    return quote
        Base.@_inline_meta
        (tuple($(exprs...)))
    end
end

@generated function unsafe_getindex_tuple(data::Vector{T}, inds::AbstractVector{<:Integer}, ::Length{L}) where {T,L}
    exprs = [:(getindex(data, inds[$i])) for i in 1:L]
    return quote
        Base.@_inline_meta
        @inbounds (tuple($(exprs...)))
    end
end

@propagate_inbounds function Base.getindex(v::CoreVector{T,I,Inds}, inds::AbstractVector{<:Integer}) where {T,I,Inds}
    @boundscheck checkbounds(v, inds)
    return unsafe_getindex(v, inds)
end

@propagate_inbounds function Base.getindex(v::CoreVector{T,I,Inds}, i::Integer) where {T,I,Inds}
    @boundscheck checkbounds(v, i)
    return unsafe_getindex(v, Int(i))
end

include("immutable_vectors.jl")
include("mutable_vectors.jl")

end
