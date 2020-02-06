module StaticRanges

import Base: OneTo, TwicePrecision, el_same, unsafe_getindex, nbitslen, rat,
             IEEEFloat, floatrange, sumpair, add12, twiceprecision, step_hp,
             truncbits, Fix1, Fix2, tail, front, to_index

using Base.Order
using Base: @propagate_inbounds, @pure

using Base.Broadcast: DefaultArrayStyle

using StaticArrays, ArrayInterface
using ArrayInterface: can_setindex
using StaticArrays: Dynamic

export
    # Types
    AbstractAxis,
    Axis,
    GapRange,
    LinMRange,
    LinSRange,
    OneToMRange,
    OneToSRange,
    SimpleAxis,
    StepMRangeLen,
    StepSRangeLen,
    StepMRange,
    StepSRange,
    UnitMRange,
    UnitSRange,
    # interface
    values_type,
    keys_type,
    # Swapping Axes
    drop_axes,
    permute_axes,
    reduce_axes,
    reduce_axis,
    reduce_axis!,
    # Matrix Multiplication and Axes
    matmul_axes,
    inverse_axes,
    covcor_axes,
    # Appending Axes
    append_axes,
    append_keys,
    append_values,
    append_axis,
    append_axis!,
    # Concatenating Axes
    hcat_axes,
    vcat_axes,
    cat_axis,
    cat_values,
    cat_keys,
    # Resizing Axes
    resize_first,
    resize_first!,
    resize_last,
    resize_last!,
    grow_first,
    grow_first!,
    grow_last,
    grow_last!,
    shrink_first,
    shrink_first!,
    shrink_last,
    shrink_last!,
    next_type,
    prev_type,
    reindex,
    # Combine Indices
    combine_indices,
    combine_index,
    combine_values,
    combine_keys,
    # Order functions
    is_forward,
    is_reverse,
    order,
    is_ordered,
    ordmax,
    ordmin,
    find_max,
    find_min,
    is_within,
    gtmax,
    ltmax,
    eqmax,
    gtmin,
    ltmin,
    eqmin,
    group_max,
    group_min,
    cmpmax,
    cmpmin,
    min_of_group_max,
    max_of_group_min,
    is_before,
    is_after,
    is_contiguous,
    # methods
    and,
    or,
    as_static,
    as_dynamic,
    as_fixed,
    mrange,
    srange,
    find_first,
    find_last,
    find_all,
    find_max,
    find_min,
    first_segment,
    last_segment,
    # Traits
    is_dynamic,
    is_fixed,
    is_forward,
    is_reverse,
    is_ordered,
    is_static,
    is_within,
    merge_sort,
    middle_segment,
    set_first!,
    set_first,
    set_step!,
    set_step,
    set_last!,
    set_last,
    set_length!,
    set_length,
    order,
    Continuity,
    Continuous,
    Discrete,
    # reexports
    similar_type,
    pop,
    popfirst,
    vcat_sort

include("gaprange.jl")
include("chainedfix.jl")
include("continuity.jl")
include("uniqueness.jl")
include("length_checks.jl")
include("order.jl")
include("findall.jl")
include("findlast.jl")
include("findfirst.jl")
include("nextval.jl")

include("twiceprecision.jl")
include("onetorange.jl")
include("unitrange.jl")
include("abstractsteprange.jl")
include("abstractlinrange.jl")
include("abstractsteprangelen.jl")

const LinRangeUnion{T} = Union{LinRange{T},AbstractLinRange{T}}
const StepRangeLenUnion{T,R,S} = Union{StepRangeLen{T,R,S},AbstractStepRangeLen{T,R,S}}
const StepRangeUnion{T,S} = Union{StepRange{T,S},AbstractStepRange{T,S}}
const UnitRangeUnion{T} = Union{UnitRange{T},UnitSRange{T},UnitMRange{T}}
const OneToUnion{T} = Union{OneTo{T},OneToRange{T}}

const SRange{T} = Union{OneToSRange{T},UnitSRange{T},StepSRange{T},LinSRange{T},StepSRangeLen{T}}
const MRange{T} = Union{OneToMRange{T},UnitMRange{T},StepMRange{T},LinMRange{T},StepMRangeLen{T}}
const UnionRange{T} = Union{SRange{T},MRange{T}}
const FRange{T} = Union{OneTo{T},UnitRange{T},StepRange{T},LinRange{T}, StepRangeLen{T}}

ArrayInterface.ismutable(::Type{X}) where {X<:MRange} = true

include("./AxisInterface/AxisInterface.jl")
include("iterate.jl")
include("staticness.jl")
include("checkindex.jl")
include("filter.jl")
include("first.jl")
include("last.jl")
include("step.jl")
include("length.jl")
include("size.jl")
include("promotion.jl")
include("range.jl")
include("merge.jl")
include("intersect.jl")
include("findin.jl")
include("broadcast.jl")
include("operators.jl")
include("getindex.jl")
include("findvalue.jl")
include("pop.jl")
include("push.jl")
include("show.jl")
include("vcat.jl")


end
