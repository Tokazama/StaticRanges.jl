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
    StepSRangeLen,
    StepMRangeLen,
    LinSRange,
    LinMRange,
    StepSRange,
    StepMRange,
    UnitSRange,
    UnitMRange,
    OneToSRange,
    OneToMRange,
    GapRange,
    # methods
    and,
    or,
    as_static,
    as_dynamic,
    as_fixed,
    mrange,
    srange,
    set_first!,
    set_first,
    set_step!,
    set_step,
    set_last!,
    set_last,
    set_length!,
    set_length,
    vcat_sort,
    find_first,
    find_last,
    find_all,
    find_max,
    find_min,
    first_segment,
    middle_segment,
    last_segment,
    cmpmax,
    cmpmin,
    # Traits
    is_static,
    is_dynamic,
    is_fixed,
    is_within,
    is_before,
    is_after,
    is_forward,
    is_reverse,
    is_ordered,
    is_contiguous,
    order,
    Continuity,
    Continuous,
    Discrete,
    # reexports
    similar_type,
    pop,
    popfirst

include("gaprange.jl")
include("chainedfix.jl")
include("continuity.jl")
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
include("merge_sort.jl")
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
