module StaticRanges

import Base: OneTo, TwicePrecision, el_same, unsafe_getindex, nbitslen, rat,
             IEEEFloat, floatrange, sumpair, add12, twiceprecision, step_hp,
             truncbits, Fix1, Fix2, tail, front, to_index, unsafe_length

using Base.Order
using Base: @propagate_inbounds, @pure

using Base.Broadcast: DefaultArrayStyle

using Dates
using StaticArrays, ArrayInterface
using ArrayInterface: can_setindex
using StaticArrays: Dynamic

export
    # Types
    GapRange,
    AbstractLinRange,
    LinMRange,
    LinSRange,
    OneToRange,
    OneToMRange,
    OneToSRange,
    AbstractStepRangeLen,
    StepMRangeLen,
    StepSRangeLen,
    AbstractStepRange,
    StepMRange,
    StepSRange,
    UnitMRange,
    UnitSRange,
    # interface
    values_type,
    keys_type,
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

include("./GapRange/GapRange.jl")

include("chainedfix.jl")
include("continuity.jl")
include("order.jl")
include("findall.jl")
include("findlast.jl")
include("findfirst.jl")

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

"""
    srange(start[, stop]; length, stop, step=1)

Constructs static ranges within similar syntax and argument semantics as `range`.

## Examples
```jldoctest
julia> using StaticRanges

julia> srange(1, length=100)
UnitSRange(1:100)

julia> srange(1, stop=100)
UnitSRange(1:100)

julia> srange(1, step=5, length=100)
StepSRange(1:5:496)

julia> srange(1, step=5, stop=100)
StepSRange(1:5:96)

julia> srange(1, step=5, stop=100)
StepSRange(1:5:96)

julia> srange(1, 10, length=101)
StepSRangeLen(1.0:0.09:10.0)

julia> srange(1, 100, step=5)
StepSRange(1:5:96)

julia> srange(1, 10)
UnitSRange(1:10)

julia> srange(1.0, length=10)
StepSRangeLen(1.0:1.0:10.0)

```
"""
srange

"""
    mrange(start[, stop]; length, stop, step=1)

Constructs static ranges within similar syntax and argument semantics as `range`.

## Examples
```jldoctest
julia> using StaticRanges

julia> mrange(1, length=100)
UnitMRange(1:100)

julia> mrange(1, stop=100)
UnitMRange(1:100)

julia> mrange(1, step=5, length=100)
StepMRange(1:5:496)

julia> mrange(1, step=5, stop=100)
StepMRange(1:5:96)

julia> mrange(1, step=5, stop=100)
StepMRange(1:5:96)

julia> mrange(1, 10, length=101)
StepMRangeLen(1.0:0.09:10.0)

julia> mrange(1, 100, step=5)
StepMRange(1:5:96)

julia> mrange(1, 10)
UnitMRange(1:10)

julia> mrange(1.0, length=10)
StepMRangeLen(1.0:1.0:10.0)
```
"""
mrange

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

include("./AxisInterface/AxisInterface.jl")

end
