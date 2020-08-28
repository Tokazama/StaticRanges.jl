
module StaticRanges

using LinearAlgebra
using SparseArrays
using SparseArrays: AbstractSparseMatrixCSC


using Base.Broadcast: DefaultArrayStyle

using Dates
using ChainedFixes
using Reexport

using StaticArrays
import StaticArrays: Length, pop, popfirst

using ArrayInterface
using ArrayInterface: can_change_size, can_setindex, parent_type
using ArrayInterface: known_first, known_step, known_last, known_length
using ArrayInterface: OptionallyStaticUnitRange

using IntervalSets
using Requires

import Base: OneTo, TwicePrecision, el_same, unsafe_getindex, nbitslen, rat,
             IEEEFloat, floatrange, sumpair, add12, twiceprecision, step_hp,
             truncbits, Fix1, Fix2, tail, front, to_index, unsafe_length

using Base.Order
using Base: @propagate_inbounds, @pure

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
    # methods
    mrange,
    srange,
    # interface
    order,
    # traits
    axes_type,
    as_dynamic,
    as_fixed,
    as_static,
    of_staticness,
    is_forward,
    is_reverse,
    is_ordered,
    is_within,
    # traits
    is_after,
    is_before,
    is_contiguous,
    # Traits
    is_forward,
    is_reverse,
    is_ordered,
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

    # reexports
    similar_type,
    pop,
    popfirst,
    vcat_sort

include("utils.jl")
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

###
### can_change_size
###
ArrayInterface.can_change_size(::Type{T}) where {T<:OneToMRange} = true
ArrayInterface.can_change_size(::Type{T}) where {T<:UnitMRange} = true
ArrayInterface.can_change_size(::Type{T}) where {T<:StepMRange} = true
ArrayInterface.can_change_size(::Type{T}) where {T<:LinMRange} = true
ArrayInterface.can_change_size(::Type{T}) where {T<:StepMRangeLen} = true

@defiterate OneToRange
@defiterate UnitSRange
@defiterate UnitMRange
@defiterate StepSRange
@defiterate StepMRange
@defiterate AbstractLinRange
@defiterate AbstractStepRangeLen

include("traits.jl")
include("filter.jl")
include("first.jl")
include("last.jl")
include("step.jl")
include("length.jl")
include("promotion.jl")
include("range.jl")
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
include("./Find/Find.jl")

end

