module CoreArrays

using StaticRanges
using StaticRanges: OneToUnion, Length
using Base: @propagate_inbounds, OneTo

export
    ImmutableVector,
    StaticImmutableVector,
    FixedImmutableVector,
    MutableVector,
    StaticMutableVector,
    FixedMutableVector,
    DynamicMutableVector

include("CoreVectors.jl")
include("CoreArray.jl")

end
