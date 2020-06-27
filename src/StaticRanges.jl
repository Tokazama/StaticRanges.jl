module StaticRanges

using SparseArrays

import Base: OneTo, TwicePrecision, el_same, unsafe_getindex, nbitslen, rat,
             IEEEFloat, floatrange, sumpair, add12, twiceprecision, step_hp,
             truncbits, Fix1, Fix2, tail, front, to_index, unsafe_length

using Base.Order
using Base: @propagate_inbounds, @pure

using Base.Broadcast: DefaultArrayStyle

using Dates
using ChainedFixes

using StaticArrays
using StaticArrays: Length
import StaticArrays: Length, pop, popfirst

using ArrayInterface
using ArrayInterface: can_setindex, parent_type

using IntervalSets
using Requires

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
    ⩓,
    or,
    ⩔,
    as_static,
    as_dynamic,
    as_fixed,
    mrange,
    srange,
    # find
    find_first,
    find_firsteq,
    find_firstgt,
    find_firstlt,
    find_firstgteq,
    find_firstlteq,
    find_last,
    find_lasteq,
    find_lastgt,
    find_lastlt,
    find_lastgteq,
    find_lastlteq,
    findin,
    find_all,
    find_alleq,
    find_allgt,
    find_alllt,
    find_allgteq,
    find_alllteq,
    find_max,
    find_min,
    # Traits
    parent_type,
    axes_type,
    is_dynamic,
    is_fixed,
    is_forward,
    is_reverse,
    is_ordered,
    is_static,
    is_within,
    merge_sort,
    push,
    pushfirst,
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

include("continuity.jl")
include("order.jl")
include("onetorange.jl")
include("unitrange.jl")
include("abstractsteprange.jl")
include("abstractlinrange.jl")
include("abstractsteprangelen.jl")
const LinRangeUnion{T} = Union{LinRange{T},AbstractLinRange{T}}
const StepRangeUnion{T,S} = Union{StepRange{T,S},AbstractStepRange{T,S}}
const UnitRangeUnion{T} = Union{UnitRange{T},UnitSRange{T},UnitMRange{T}}

# Things I have to had to avoid ambiguities with base
RANGE_LIST = (LinSRange, LinMRange, StepSRange, StepMRange, UnitSRange, UnitMRange, OneToSRange, OneToMRange, StepSRangeLen, StepMRangeLen)

for R in RANGE_LIST
    @eval begin
        function Base.findfirst(f::Union{Base.Fix2{typeof(==),T}, Base.Fix2{typeof(isequal),T}}, r::$R) where T<:Integer
            return find_first(f, r)
        end
    end
end


const SRange{T} = Union{OneToSRange{T},UnitSRange{T},StepSRange{T},LinSRange{T},StepSRangeLen{T}}
const MRange{T} = Union{OneToMRange{T},UnitMRange{T},StepMRange{T},LinMRange{T},StepMRangeLen{T}}
const UnionRange{T} = Union{SRange{T},MRange{T}}
const FRange{T} = Union{OneTo{T},UnitRange{T},StepRange{T},LinRange{T}, StepRangeLen{T}}

ArrayInterface.ismutable(::Type{X}) where {X<:MRange} = true

include("iterate.jl")
include("traits.jl")
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
include("broadcast.jl")
include("operators.jl")
include("getindex.jl")
include("pop.jl")
include("push.jl")
include("show.jl")
include("vcat.jl")
include("resize.jl")
include("offset_range.jl")
include("./Find/Find.jl")

include("./CoreArrays/CoreArrays.jl")
using .CoreArrays

end
