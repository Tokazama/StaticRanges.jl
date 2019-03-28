struct HPStaticRange{T,B,E,S,F,L} <: AbstractStaticRange{T,B,E,S,F,L}
    HPStaticRange{T,B,E,S,F,L}() where {T,B,E,S,F,L} = new{T,B,E,S,F,L}()
end


# length is present here
function _srange_float(
    b::Val{B},       # <:AbstractFloat
    e::Val{nothing},
    s::Val{nothing},
    f::Val{F},       # Int
    len::Val{L}      # Int
   ) where {B,F,L}

    _srange_float(b, e, Val(oftype(b, 1)), f, len)
end

function _srange_float(
    b::Val{B},       # <:AbstractFloat
    e::Val{nothing},
    s::Val{S},       # <:AbstractFloat
    f::Val{F},       # Int
    len::Val{L}      # Int
   ) where {B,S,F,L}
    _srangestyle(Base.OrderStyle(B), Base.ArtithmeticStyle(B), Val(B), e, Val(S), f, len)
end

function _srange_float(
    ::Base.Ordered,
    ::Base.ArithmeticWraps,
    b::Val{B},       # <:AbstractFloat
    e::Val{nothing},
    s::Val{S},       # same AbstractFloat type as B
    f::Val{F},       # Int
    len::Val{L}      # Int
   ) where {B,S,F,L}
    StaticRange{typeof(B),B,oftype(B, B + S * (len - 1)),S,F,L}()
end

function _srange_float(
    ::Any,
    ::Any,
    b::Val{B},       # <:AbstractFloat
    e::Val{nothing},
    s::Val{S},       # same AbstractFloat type as B
    f::Val{F},       # Int
    len::Val{L}      # Int
   ) where {B,S,F,L}
    StaticRange{typeof(B+0*S),B,oftype(typeof(B+0*S), B + (L - F) * S),S,F,L}()
end

# TODO TwicePrecision
# nothing 
function _srange(
    b::Val{B},
    s::Val{S},
    e::Val{nothing},
    len::Val{L}
   ) where {B,S,L}

    start_n, start_d = Base.rat(B)
    step_n, step_d = Base.rat(st)
    if start_d != 0 && step_d != 0 &&
            oftype(B, start_n/start_d) == B && oftype(B, step_n/step_d) == st
        den = lcm(start_d, step_d)
        m = maxintfloat(T, Int)
        if abs(den*B) <= m && abs(den*S) <= m &&
                rem(den, start_d) == 0 && rem(den, step_d) == 0
            start_n = round(Int, den*B)
            step_n = round(Int, den*S)
            return floatrange(T, start_n, step_n, len, den)
        end
    end
    steprangelen_hp(T, B, S, 0, len, 1)
end

function _srange_hp
end

# Use TwicePrecision only for Float64; use Float64 for T<:Union{Float16,Float32}
# See also _linspace1
# Ratio-of-integers constructors
function steprangelen_hp(
    ::Type{Float64}, ref::Tuple{Integer,Integer},
    step::Tuple{Integer,Integer}, nb::Integer,
    len::Integer, offset::Integer)
    Base.TwicePrecision{typeof(B)}(
    StepRangeLen(TwicePrecision{Float64}(ref),
                 TwicePrecision{Float64}(step, nb), Int(len), offset)
end

function steprangelen_hp(::Type{T}, ref::Tuple{Integer,Integer},
                         step::Tuple{Integer,Integer}, nb::Integer,
                         len::Integer, offset::Integer) where {T<:IEEEFloat}
    StepRangeLen{T}(ref[1]/ref[2], step[1]/step[2], Int(len), offset)
end

# AbstractFloat constructors (can supply a single number or a 2-tuple
const F_or_FF = Union{AbstractFloat, Tuple{AbstractFloat,AbstractFloat}}
asF64(x::AbstractFloat) = Float64(x)
asF64(x::Tuple{AbstractFloat,AbstractFloat}) = Float64(x[1]) + Float64(x[2])

# Defined to prevent splatting in the function below which here has a performance impact
_TP(x) = TwicePrecision{Float64}(x)
_TP(x::Tuple{Any, Any}) = TwicePrecision{Float64}(x[1], x[2])
function steprangelen_hp(::Type{Float64}, ref::F_or_FF,
                         step::F_or_FF, nb::Integer,
                         len::Integer, offset::Integer)
    StepRangeLen(_TP(ref),
                 twiceprecision(_TP(step), nb), Int(len), offset)
end

function steprangelen_hp(::Type{T}, ref::F_or_FF,
                         step::F_or_FF, nb::Integer,
                         len::Integer, offset::Integer) where {T<:IEEEFloat}
    StepRangeLen{T}(asF64(ref),
                    asF64(step), Int(len), offset)
end
# Construct range for rational start=start_n/den, step=step_n/den
function floatrange(::Type{T}, start_n::Integer, step_n::Integer, len::Integer, den::Integer) where T
    if len < 2 || step_n == 0
        return steprangelen_hp(T, (start_n, den), (step_n, den), 0, Int(len), 1)
    end
    # index of smallest-magnitude value
    imin = clamp(round(Int, -start_n/step_n+1), 1, Int(len))
    # Compute smallest-magnitude element to 2x precision
    ref_n = start_n+(imin-1)*step_n  # this shouldn't overflow, so don't check
    nb = nbitslen(T, len, imin)
    steprangelen_hp(T, (ref_n, den), (step_n, den), nb, Int(len), imin)
end

function floatrange(a::AbstractFloat, st::AbstractFloat, len::Real, divisor::AbstractFloat)
    T = promote_type(typeof(a), typeof(st), typeof(divisor))
    m = maxintfloat(T, Int)
    if abs(a) <= m && abs(st) <= m && abs(divisor) <= m
        ia, ist, idivisor = round(Int, a), round(Int, st), round(Int, divisor)
        if ia == a && ist == st && idivisor == divisor
            # We can return the high-precision range
            return floatrange(T, ia, ist, Int(len), idivisor)
        end
    end
    # Fallback (misses the opportunity to set offset different from 1,
    # but otherwise this is still high-precision)
    steprangelen_hp(T, (a,divisor), (st,divisor), nbitslen(T, len, 1), Int(len), 1)
end
