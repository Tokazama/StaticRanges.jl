
module StaticRanges

using LinearAlgebra
using SparseArrays
using SparseArrays: AbstractSparseMatrixCSC


using Dates
using ChainedFixes
using Reexport

using ArrayInterface
using ArrayInterface: can_change_size, can_setindex, parent_type
using ArrayInterface: known_first, known_step, known_last, known_length
using ArrayInterface: OptionallyStaticUnitRange

using IntervalSets
using Requires

using Base.Broadcast: DefaultArrayStyle
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
    as_dynamic,
    as_fixed,
    as_static,
    of_staticness,
    set_first!,
    set_first,
    set_step!,
    set_step,
    set_last!,
    set_last,
    set_length!,
    set_length

include("utils.jl")
include("./GapRange/GapRange.jl")
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

const OneToUnion{T} = Union{OneTo{T},OneToRange{T}}
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


# Notes on implementation:
# Currently Base Julia reutrns an empty vector on empty(::AbstractRange)
# We want the appropriate variant of the range that returns true when isempty(::AbstractRange)
# We index by OneToSRange(0) in order to force this.
# Using the static version also ensures that it doesn't accidently "promote down" the type


# FIXME specify Bit operator filters here to <,<=,>=,>,==,isequal,isless
# Currently will return incorrect order or repeated results otherwise
Base.filter(f::Function, r::UnionRange)  = r[find_all(f, r)]

Base.filter(f::ChainedFix, r::UnionRange) = r[findall(f, r)]

include("traits.jl")
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
include("show.jl")
include("vcat.jl")
include("resize.jl")
include("./Find/Find.jl")

end

