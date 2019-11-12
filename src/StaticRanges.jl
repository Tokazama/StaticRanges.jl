module StaticRanges

import Base: OneTo, TwicePrecision, el_same, unsafe_getindex, nbitslen, rat,
             IEEEFloat, floatrange, sumpair, add12, twiceprecision, step_hp,
             truncbits, Fix1, Fix2, tail, front

using Base.Order
using Base: @propagate_inbounds

using Base.Broadcast: DefaultArrayStyle

using StaticArrays, ArrayInterface
using ArrayInterface: can_setindex

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
    # methods
    mrange,
    srange,
    set_first!,
    set_step!,
    set_last!,
    set_length!,
    find_first,
    find_last,
    find_all,
    find_max,
    find_min,
    cmpmax,
    cmpmin,
    # Traits
    is_static,
    is_within,
    is_before,
    is_after,
    is_forward,
    is_reverse,
    is_ordered,
    is_contiguous,
    order

include("twiceprecision.jl")
include("onetorange.jl")
include("staticunitrange.jl")
include("abstractsteprange.jl")
include("abstractlinrange.jl")
include("abstractsteprangelen.jl")

const SRange{T} = Union{OneToSRange{T},UnitSRange{T},StepSRange{T},LinSRange{T},StepSRangeLen{T}}
const MRange{T} = Union{OneToMRange{T},UnitMRange{T},StepMRange{T},LinMRange{T},StepMRangeLen{T}}

include("traits.jl")
include("order.jl")
include("promotion.jl")
include("range.jl")
include("intersect.jl")
include("broadcast.jl")
include("operators.jl")
include("indexing.jl")
include("findvalue.jl")
include("findfirst.jl")
include("findlast.jl")
include("findall.jl")

end
