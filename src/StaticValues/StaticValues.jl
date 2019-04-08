module StaticValues

import StaticArrays: tuple_length, tuple_prod, tuple_minimum

import Base: TwicePrecision, @pure
import Base: ==, +, -, *, /, ^, <, ~, abs, abs2, isless, max, min, div, eltype, tail

export SVal, HPSVal, div12, mul12, add12, splitprec, canonicalize2, rat, twiceprecision,
       SReal, SBigFloat, SFloat16, SFloat32, SFloat64, SBigInt, SInt128, SInt16,
       SInt32, SInt64, SInt8, SInteger, SUInt128, SUInt64, SUInt32, SUInt16, SUInt8,
       SFloat, SSigned, SUnsigned, SBool, SNothing, SZero, SOne, nbitslen

include("SVal.jl")
include("HPSVal.jl")

end
