module StaticRanges

import Base: OneTo, TwicePrecision, el_same, unsafe_getindex, nbitslen, rat,
             IEEEFloat, floatrange, sumpair, add12, twiceprecision

export
    StaticStepRangeLen,
    StepSRangeLen,
    StepMRangeLen,
    StaticStepRange,
    StaticLinRange,
    LinSRange,
    LinMRange,
    StepSRange,
    StepMRange,
    StaticUnitRange,
    UnitSRange,
    UnitMRange,
    OneToRange,
    OneToSRange,
    OneToMRange,
    mrange,
    srange

include("traits.jl")
include("onetorange.jl")
include("staticunitrange.jl")
include("staticsteprange.jl")
include("staticlinrange.jl")
include("staticsteprangelen.jl")
include("range.jl")

end

