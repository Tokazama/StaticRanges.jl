# TODO:
# - ensure axes works on all appropriate types
# - distributed StridedWindow (for each window) indexing creates more objects but is parallel
# - non-distributed can be optimized within one function
# - implement offset

module StaticRanges

using StaticArrays, Base.Cartesian

import StaticArrays: tuple_length, tuple_prod, tuple_minimum

import Base: # indexing
             unsafe_getindex, getindex, checkbounds, to_index, axes, size,
             @_inline_meta, @pure, @_propagate_inbounds_meta, @propagate_inbounds,
             ==, +, -,
             # range
             step, OneTo, first, last, firstindex, lastindex, tail, eltype, length
#             promote_op, , zero, trunc, floor, round, ceil,
#             mod, rem, atan, hypot

export StaticRange, SRange, OneToSRange, SubRange, srange
export StaticIndices, SubIndices,
       CartesianSIndices, SubCartesianIndices,
       LinearSIndices, SubLinearIndices, parentsize

# this is the default number of dimensions supported by default. Users can compile methods
# to support more dimensions by calling `create_nd_support(N)` where N is the max number of
# supported dimensions.
const NDSupport = 3::Int

# Notes on project organization
# - Abstract types and documentation are kept in this module file
# - Each subtype has it's own file
include("types.jl")
include("traits.jl")
include("checkbounds.jl")
include("indexing.jl")
include("multidimensional.jl")
include("utils.jl")

#include("SubIndices.jl")

#include("SlidingWindow.jl")



end
