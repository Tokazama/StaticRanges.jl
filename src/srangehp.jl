const F_or_FF = Union{<:AbstractFloat, Tuple{<:AbstractFloat,<:AbstractFloat}}

f64(x::BaseFloat) = Float64(x)
f64(x::Tuple{<:BaseFloat,<:BaseFloat}) = Float64(x[1]) + Float64(x[2])
f64(x::SFloat) = SFloat64(x)
f64(x::Tuple{<:SFloat,<:SFloat}) = SFloat64(x[1]) + SFloat64(x[2])

tp64(x::BaseNumber) = TwicePrecision{Float64}(x)
tp64(x::Tuple{<:BaseNumber,<:BaseNumber}) = TwicePrecision{Float64}(x[1], x[2])
tp64(x::SReal) = TPVal(Float64, x)
tp64(x::Tuple{<:SReal,<:SReal}) = TPVal(Float64, x[1], x[2])

srangehp(::Type{Float64}, b::Tuple{Integer,Integer}, s::Tuple{Integer,Integer},
         nb::SInteger, l::Integer, f::Integer) =
    StaticStepRangeLen(TPVal(Float64, b), TPVal(Float64, s, nb), l, f)

srangehp(::Type{T}, b::Tuple{Integer,Integer}, s::Tuple{Integer,Integer},
         nb::Integer, l::Integer, f::Integer) where T =
    StaticStepRangeLen{T}(b[1]/b[2], s[1]/s[2], int(l), f)

srangehp(::Type{Float64}, b::F_or_FF, s::F_or_FF, nb::Integer, l::Integer, f::Integer) =
    StaticStepRangeLen(tp64(b), twiceprecision(tp64(s), nb), int(l), f)

srangehp(::Type{T}, b::F_or_FF, s::F_or_FF,
         nb::Integer, l::Integer, f::Integer) where {T<:Union{Float16,Float32}} =
    StaticStepRangeLen{T}(f64(b), f64(s), Int(l), f)
