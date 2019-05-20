
const AllInt128 = Union{SInt128,Int128}
const AllInt64 = Union{SInt64,Int64}
const AllInt32 = Union{SInt32,Int32}
const AllInt16 = Union{SInt16,Int16}
const AllInt8 = Union{SInt8,Int8}

const AllUInt128 = Union{SUInt128,UInt128}
const AllUInt64 = Union{SUInt64,UInt64}
const AllUInt32 = Union{SUInt32,UInt32}
const AllUInt16 = Union{SUInt16,UInt16}
const AllUInt8 = Union{SUInt8,UInt8}

const AllFloat64 = Union{SFloat64,Float64}
const AllFloat32 = Union{SFloat32,Float32}
const AllFloat16 = Union{SFloat16,Float16}

maybe_sval(val::Val) = SVal(val)
maybe_sval(val::SVal) = val
maybe_sval(::Nothing) = nothing
maybe_sval(val) = val

"""
    srange
"""
function srange(start; length=nothing, stop=nothing, step=nothing)
    _sr(maybe_sval(start),
        maybe_sval(step),
        maybe_sval(stop),
        maybe_sval(length))
end

function srange(start, stop; length=nothing, step=nothing)
    _sr(maybe_sval(start),
        maybe_sval(step),
        maybe_sval(stop),
        maybe_sval(length))
end

#srange(r::AbstractRange{T}) where T = srange(SVal(first(r)), stop=SVal(last(r)), length=SVal(length(r)))

#srange(r::StepRange{T}) where T = StepSRange(SVal(first(r)), SVal(step(r)), SVal(last(r)))
#srange(r::StepRangeLen{T,R,S}) where {T,R<:Real,S<:Real} = StepSRangeLen{T}(SVal(first(r)), SVal(step(r)), SVal(length(r)), SVal(r.offset))
#srange(r::StepRangeLen{T,R,S}) where {T,R<:TwicePrecision,S<:TwicePrecision} = StepSRangeLen{T}(HPSVal(r.ref), HPSVal(r.step), SVal(r.len), SVal(r.offset))
#srange(r::AbstractUnitRange{T}) where T = UnitSRange{T}(SVal(first(r)), SVal(last(r)))

_sr(b::Real,          s::Nothing,       ::Nothing,  l::Integer) = StaticUnitRange{eltype(b)}(b, b + l - SOne)
_sr(b::AbstractFloat, s::Nothing,       ::Nothing,  l::Integer) = _sr(b, oftype(b, 1),   e, l)
_sr(b::AbstractFloat, s::AbstractFloat, ::Nothing,  l::Integer) = _sr(promote(b, s)..., e, l)
_sr(b::Real,          s::AbstractFloat, ::Nothing,  l::Integer) = _sr(float(b), s, e, l)
_sr(b::AbstractFloat, s::Real,          ::Nothing,  l::Integer) = _sr(b, float(s), e, l)
_sr(b::B,             s::Nothing,       ::Nothing,  l::Integer) where B = _sr(b, oftype(B-B, 1), e, l)
_sr(b::B,             s,                ::Nothing,  l::Integer) where B =
    _srangestyle(Base.OrderStyle(eltype(B)), Base.ArithmeticStyle(eltype(B)), b, s, l)

_sr(b::B, ::Nothing, e::E, ::Nothing) where {B,E} = (:)(b, e)
_sr(b::B, ::S,       e::E, ::Nothing) where {B,S,E} = (:)(b, s, e)

_sr(b::AllFloat16, s::AllFloat16, ::Nothing, l::Integer) = __sr(eltype(b), b, s, nothing, l)
_sr(b::AllFloat32, s::AllFloat32, ::Nothing, l::Integer) = __sr(eltype(b), b, s, nothing, l)
_sr(b::AllFloat64, s::AllFloat64, ::Nothing, l::Integer) = __sr(eltype(b), b, s, nothing, l)

function __sr(::Type{T}, b::AbstractFloat, s::AbstractFloat, ::Nothing, l::Integer) where T<:Union{Float16,Float32,Float64}
    start_n, start_d = rat(b)
    step_n, step_d = rat(s)
    if start_d != 0 && step_d != 0 && T(start_n/start_d) == b && T(step_n/step_d) == s
        den = lcm(start_d, step_d)
        m = maxintfloat(T, Int)
        if abs(den*b) <= m && abs(den*s) <= m && rem(den, start_d) == 0 && rem(den, step_d) == 0
            return floatrange(T, round(Int, den*b), round(Int, den*s), l, den)
        end
    end
    srangehp(T, b, s, SZero, l, SOne)
end


_sr(b::AllFloat16, ::Nothing, e::AllFloat16, l::Integer) = __sr(eltype(b), b, nothing, e, l)
_sr(b::AllFloat32, ::Nothing, e::AllFloat32, l::Integer) = __sr(eltype(b), b, nothing, e, l)
_sr(b::AllFloat64, ::Nothing, e::AllFloat64, l::Integer) = __sr(eltype(b), b, nothing, e, l)

function __sr(::Type{T}, b::AbstractFloat, ::Nothing, e::AbstractFloat, l::Integer) where {B,E,F,T<:Union{Float16, Float32, Float64}}
    l < 2 && return linspace1(T, b, e, l)
    if b == e
        return srangehp(T, b, SZero(T), SVal{0}(), l)
    end
    # Attempt to find exact rational approximations
    start_n, start_d = rat(b)
    stop_n, stop_d = rat(e)
    if start_d != 0 && stop_d != 0
        den = lcm(start_d, stop_d)
        m = maxintfloat(T, Int)
        if den != 0 && abs(den*B) <= m && abs(den*E) <= m
            if T(start_n/den) == b && T(stop_n/den) == e
                return linspace(T, round(Int, den*b), round(Int, den*e), l, den)
            end
        end
    end
    linspace(b, e, l)
end

_srangestyle(::Base.Ordered, ::Base.ArithmeticWraps,  b, s, l::Integer) =
    StaticStepRange(b, s, oftype(b, b + s * (l - one(l))))
_srangestyle(::Any,          ::Any,                   b, s, l::Integer) =
    steprangelen(typeof(b+zero(s)*s), b, s, l)
