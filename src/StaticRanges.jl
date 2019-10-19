module StaticRanges

import Base: OneTo, TwicePrecision, el_same, unsafe_getindex, nbitslen, rat,
             IEEEFloat, floatrange, sumpair, add12, twiceprecision, step_hp,
             truncbits

using Base.Broadcast: DefaultArrayStyle

export
    StepSRangeLen,
    StepMRangeLen,
    StaticLinRange,
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
    setfirst!,
    setstep!,
    setlast!

include("twiceprecision.jl")
include("onetorange.jl")
include("staticunitrange.jl")
include("abstractsteprange.jl")
include("abstractlinrange.jl")
include("abstractsteprangelen.jl")

include("traits.jl")
const SRange{T} = Union{OneToSRange{T},UnitSRange{T},StepSRange{T},LinSRange{T},StepSRangeLen{T}}

isstatic(::Type{T}) where {T<:SRange} = true

const MRange{T} = Union{OneToMRange{T},UnitMRange{T},StepMRange{T},LinMRange{T},StepMRangeLen{T}}

include("promotion.jl")
include("range.jl")
#include("initialize.jl")

include("broadcast.jl")
include("operators.jl")
include("indexing.jl")

end

