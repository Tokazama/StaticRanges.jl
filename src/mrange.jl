
function mrange(start; length::Union{Integer,Nothing}=nothing, stop=nothing, step=nothing)
    return _mrange(start, step, stop, length)
end

mrange(start, stop; length::Union{Integer,Nothing}=nothing, step=nothing) =
    _mrange(start, step, stop, length)

_mrange2(start, step, stop, length) = _mrange(start, step, stop, length)

# Range from start to stop: range(a, [step=s,] stop=b), no length
_mrange(start, step,      stop, ::Nothing) = _mcolon(start, step, stop)
_mrange(start, ::Nothing, stop, ::Nothing) = _mcolon(start, stop)

_mcolon(a::Real, b::Real) = _mcolon(promote(a,b)...)

_mcolon(start::T, stop::T) where {T<:Real} = UnitMRange{T}(start, stop)

_mcolon(start::T, stop::T) where {T} = _mcolon(start, oftype(stop-start, 1), stop)

# promote start and stop, leaving step alone
_mcolon(start::A, step, stop::C) where {A<:Real,C<:Real} =
    _mcolon(convert(promote_type(A,C),start), step, convert(promote_type(A,C),stop))

function _mcolon(start::T, step::T, stop::T) where T<:Union{Float16,Float32,Float64}
    step == 0 && throw(ArgumentError("range step cannot be zero"))
    # see if the inputs have exact rational approximations (and if so,
    # perform all computations in terms of the rationals)
    step_n, step_d = Base.rat(step)
    if step_d != 0 && T(step_n/step_d) == step
        start_n, start_d = Base.rat(start)
        stop_n, stop_d = Base.rat(stop)
        if start_d != 0 && stop_d != 0 &&
                T(start_n/start_d) == start && T(stop_n/stop_d) == stop
            den = lcm(start_d, step_d) # use same denominator for start and step
            m = maxintfloat(T, Int)
            if den != 0 && abs(start*den) <= m && abs(step*den) <= m &&  # will round succeed?
                    rem(den, start_d) == 0 && rem(den, step_d) == 0      # check lcm overflow
                start_n = round(Int, start*den)
                step_n = round(Int, step*den)
                len = max(0, div(den*stop_n - stop_d*start_n + step_n*stop_d, step_n*stop_d))
                # Integer ops could overflow, so check that this makes sense
                if Base.isbetween(start, start + (len-1)*step, stop + step/2) &&
                        !Base.isbetween(start, start + len*step, stop)
                    # Return a 2x precision range
                    return floatmrange(T, start_n, step_n, len, den)
                end
            end
        end
    end
    # Fallback, taking start and step literally
    lf = (stop-start)/step
    if lf < 0
        len = 0
    elseif lf == 0
        len = 1
    else
        len = round(Int, lf) + 1
        stop′ = start + (len-1)*step
        # if we've overshot the end, subtract one:
        len -= (start < stop < stop′) + (start > stop > stop′)
    end
    stepmrangelen_hp(T, start, step, 0, len, 1)
end
# AbstractFloat specializations
_mcolon(a::T, b::T) where {T<:AbstractFloat} = _mcolon(a, T(1), b)

_mcolon(a::T, b::AbstractFloat, c::T) where {T<:Real} = _mcolon(promote(a,b,c)...)
_mcolon(a::T, b::AbstractFloat, c::T) where {T<:AbstractFloat} = _mcolon(promote(a,b,c)...)
_mcolon(a::T, b::Real, c::T) where {T<:AbstractFloat} = _mcolon(promote(a,b,c)...)

_mcolon(start::T, step::T, stop::T) where {T<:AbstractFloat} =
    _mcolon_colon(Base.OrderStyle(T), Base.ArithmeticStyle(T), start, step, stop)
_mcolon(start::T, step::T, stop::T) where {T<:Real} =
    _mcolon_colon(Base.OrderStyle(T), Base.ArithmeticStyle(T), start, step, stop)
_mcolon_colon(::Base.Ordered, ::Any, start::T, step, stop::T) where {T} = StepMRange(start, step, stop)
# for T<:Union{Float16,Float32,Float64} see twiceprecision.jl
_mcolon_colon(::Base.Ordered, ::Base.ArithmeticRounds, start::T, step, stop::T) where {T} =
    StepMRangeLen(start, step, floor(Int, (stop-start)/step)+1)
_mcolon_colon(::Any, ::Any, start::T, step, stop::T) where {T} =
    StepMRangeLen(start, step, floor(Int, (stop-start)/step)+1)
# mrange of a given length: mrange(a, [step=s,] length=l), no stop
_mrange(a::Real,          ::Nothing,         ::Nothing, len::Integer) = UnitMRange{typeof(a)}(a, oftype(a, a+len-1))
_mrange(a::AbstractFloat, ::Nothing,         ::Nothing, len::Integer) = _mrange(a, oftype(a, 1),   nothing, len)
_mrange(a::AbstractFloat, st::AbstractFloat, ::Nothing, len::Integer) = _mrange(promote(a, st)..., nothing, len)
_mrange(a::Real,          st::AbstractFloat, ::Nothing, len::Integer) = _mrange(float(a), st,      nothing, len)
_mrange(a::AbstractFloat, st::Real,          ::Nothing, len::Integer) = _mrange(a, float(st),      nothing, len)
_mrange(a,                ::Nothing,         ::Nothing, len::Integer) = _mrange(a, oftype(a-a, 1), nothing, len)

function _mrange(a::T, step::T, ::Nothing, len::Integer) where {T <: AbstractFloat}
    return _mrangestyle(Base.OrderStyle(T), Base.ArithmeticStyle(T), a, step, len)
end
function _mrange(a::T, step, ::Nothing, len::Integer) where {T}
    return _mrangestyle(Base.OrderStyle(T), Base.ArithmeticStyle(T), a, step, len)
end
function _mrangestyle(::Base.Ordered, ::Base.ArithmeticWraps, a::T, step::S, len::Integer) where {T,S}
    return StepMRange{T,S}(a, step, convert(T, a+step*(len-1)))
end
function _mrangestyle(::Any, ::Any, a::T, step::S, len::Integer) where {T,S}
    return StepMRangeLen{typeof(a+0*step),T,S}(a, step, len)
end

function _mrange(start::T, ::Nothing, stop::T, len::Integer) where {T<:Base.IEEEFloat}
    len < 2 && return _linspace1(T, start, stop, len)
    if start == stop
        return steprangelen_hp(T, start, zero(T), 0, len, 1)
    end
    # Attempt to find exact rational approximations
    start_n, start_d = Base.rat(start)
    stop_n, stop_d = Base.rat(stop)
    if start_d != 0 && stop_d != 0
        den = lcm(start_d, stop_d)
        m = Base.maxintfloat(T, Int)
        if den != 0 && abs(den*start) <= m && abs(den*stop) <= m
            start_n = round(Int, den*start)
            stop_n = round(Int, den*stop)
            if T(start_n/den) == start && T(stop_n/den) == stop
                return _mlinspace(T, start_n, stop_n, len, den)
            end
        end
    end
    _linspace(start, stop, len)
end

_mrange(start,     step,      ::Nothing, ::Nothing) = # range(a, step=s)
    throw(ArgumentError("At least one of `length` or `stop` must be specified"))
_mrange(start,     ::Nothing, ::Nothing, ::Nothing) = # range(a)
    throw(ArgumentError("At least one of `length` or `stop` must be specified"))
_mrange(::Nothing, ::Nothing, ::Nothing, ::Nothing) = # range(nothing)
    throw(ArgumentError("At least one of `length` or `stop` must be specified"))
_mrange(start::Real, step::Real, stop::Real, length::Integer) = # range(a, step=s, stop=b, length=l)
    throw(ArgumentError("Too many arguments specified; try passing only one of `stop` or `length`"))
_mrange(::Nothing, ::Nothing, ::Nothing, ::Integer) = # range(nothing, length=l)
    throw(ArgumentError("Can't start a range at `nothing`"))


function _mrange(start::T, ::Nothing, stop::S, len::Integer) where {T,S}
    a, b = promote(start, stop)
    _mrange(a, nothing, b, len)
end
_mrange(start::T, ::Nothing, stop::T, len::Integer) where {T<:Real} = LinMRange{T}(start, stop, len)
_mrange(start::T, ::Nothing, stop::T, len::Integer) where {T} = LinRange{T}(start, stop, len)
_mrange(start::T, ::Nothing, stop::T, len::Integer) where {T<:Integer} =
    _mlinspace(float(T), start, stop, len)
## for Float16, Float32, and Float64 we hit twiceprecision.jl to lift to higher precision StepRangeLen
# for all other types we fall back to a plain old LinRange
_mlinspace(::Type{T}, start::Integer, stop::Integer, len::Integer) where T = LinMRange{T}(start, stop, len)

_mlinspace(::Type{T}, start::Integer, stop::Integer, len::Integer) where {T<:Base.IEEEFloat} = _mlinspace(T, start, stop, len, 1)
function _mlinspace(::Type{T}, start_n::Integer, stop_n::Integer, len::Integer, den::Integer) where {T<:Base.IEEEFloat}
    len < 2 && return _mlinspace1(T, start_n/den, stop_n/den, len)
    start_n == stop_n && return steprangelen_hp(T, (start_n, den), (zero(start_n), den), 0, len, 1)
    tmin = -start_n/(Float64(stop_n) - Float64(start_n))
    imin = round(Int, tmin*(len-1)+1)
    imin = clamp(imin, 1, Int(len))
    ref_num = Int128(len-imin) * start_n + Int128(imin-1) * stop_n
    ref_denom = Int128(len-1) * den
    ref = (ref_num, ref_denom)
    step_full = (Int128(stop_n) - Int128(start_n), ref_denom)
    stepmrangelen_hp(T, ref, step_full,  nbitslen(T, len, imin), Int(len), imin)
end

function _mlinspace1(::Type{T}, start, stop, len::Integer) where {T<:Base.IEEEFloat}
    len >= 0 || throw(ArgumentError("range($start, stop=$stop, length=$len): negative length"))
    if len <= 1
        len == 1 && (start == stop || throw(ArgumentError("range($start, stop=$stop, length=$len): endpoints differ")))
        # Ensure that first(r)==start and last(r)==stop even for len==0
        # The output type must be consistent with steprangelen_hp
        if T<:Union{Float32,Float16}
            return StepRangeLen{T}(Float64(start), Float64(start) - Float64(stop), len, 1)
        else
            return StepRangeLen(TwicePrecision(start, zero(T)), TwicePrecision(start, -stop), len, 1)
        end
    end
    throw(ArgumentError("should only be called for len < 2, got $len"))
end
function _mrange(a::T, st::T, ::Nothing, len::Integer) where T<:Union{Float16,Float32,Float64}
    start_n, start_d = Base.rat(a)
    step_n, step_d = Base.rat(st)
    if start_d != 0 && step_d != 0 &&
            T(start_n/start_d) == a && T(step_n/step_d) == st
        den = lcm(start_d, step_d)
        m = Base.maxintfloat(T, Int)
        if abs(den*a) <= m && abs(den*st) <= m &&
                rem(den, start_d) == 0 && rem(den, step_d) == 0
            start_n = round(Int, den*a)
            step_n = round(Int, den*st)
            return floatmrange(T, start_n, step_n, len, den)
        end
    end
    stepmrangelen_hp(T, a, st, 0, len, 1)
end

function stepmrangelen_hp(::Type{Float64}, ref::Tuple{Integer,Integer},
                         step::Tuple{Integer,Integer}, nb::Integer,
                         len::Integer, offset::Integer)
    StepMRangeLen(TwicePrecision{Float64}(ref),
                 TwicePrecision{Float64}(step, nb), Int(len), offset)
end

function stepmrangelen_hp(::Type{T}, ref::Tuple{Integer,Integer},
                         step::Tuple{Integer,Integer}, nb::Integer,
                         len::Integer, offset::Integer) where {T<:Base.IEEEFloat}
    StepMRangeLen{T}(ref[1]/ref[2], step[1]/step[2], Int(len), offset)
end

function floatmrange(::Type{T}, start_n::Integer, step_n::Integer, len::Integer, den::Integer) where T
    if len < 2 || step_n == 0
        return stepmrangelen_hp(T, (start_n, den), (step_n, den), 0, Int(len), 1)
    end
    # index of smallest-magnitude value
    imin = clamp(round(Int, -start_n/step_n+1), 1, Int(len))
    # Compute smallest-magnitude element to 2x precision
    ref_n = start_n+(imin-1)*step_n  # this shouldn't overflow, so don't check
    nb = Base.nbitslen(T, len, imin)
    stepmrangelen_hp(T, (ref_n, den), (step_n, den), nb, Int(len), imin)
end

function floatmrange(a::AbstractFloat, st::AbstractFloat, len::Real, divisor::AbstractFloat)
    T = promote_type(typeof(a), typeof(st), typeof(divisor))
    m = maxintfloat(T, Int)
    if abs(a) <= m && abs(st) <= m && abs(divisor) <= m
        ia, ist, idivisor = round(Int, a), round(Int, st), round(Int, divisor)
        if ia == a && ist == st && idivisor == divisor
            # We can return the high-precision range
            return floatmrange(T, ia, ist, Int(len), idivisor)
        end
    end
    # Fallback (misses the opportunity to set offset different from 1,
    # but otherwise this is still high-precision)
    stepmrangelen_hp(T, (a,divisor), (st,divisor), Base.nbitslen(T, len, 1), Int(len), 1)
end
