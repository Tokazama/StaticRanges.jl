# This file is a part of Julia. License is MIT: https://julialang.org/license

# Twice-precision arithmetic.

# Necessary for creating nicely-behaved ranges like r = 0.1:0.1:0.3
# that return r[3] == 0.3.  Otherwise, we have roundoff error due to
#     0.1 + 2*0.1 = 0.30000000000000004


## StepRangeLen

# Use TwicePrecision only for Float64; use Float64 for T<:Union{Float16,Float32}
# See also _linspace1
# Ratio-of-integers constructors
function floatsrange(::Type{T},
                     b::SVal{      B,<:Integer},
                     e::SVal{nothing,  Nothing},
                     s::SVal{      S,<:Integer},
                     f::SVal{      F,<:Integer},
                     l::SVal{      L,<:Integer}) where {B,F,L,T<:AbstractFloat}
    a::AbstractFloat, st::AbstractFloat, len::Real, divisor::AbstractFloat)
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


function floatsrange(::Type{T}, start_n::Integer, step_n::Integer, len::Integer, den::Integer) where T
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


function srange_hp(::Type{Float64}, ref::Tuple{Integer,Integer}, step::Tuple{Integer,Integer}, nb::Integer, len::Integer, offset::Integer)
    StepRangeLen(TwicePrecision{Float64}(ref),
                 TwicePrecision{Float64}(step, nb), Int(len), offset)
end

function srange_hp(::Type{T}, ref::Tuple{Integer,Integer},
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



StepRangeLen(ref::TwicePrecision{T}, step::TwicePrecision{T},
             len::Integer, offset::Integer=1) where {T} =
    StepRangeLen{T,TwicePrecision{T},TwicePrecision{T}}(ref, step, len, offset)

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

function (:)(start::T, step::T, stop::T) where T<:Union{Float16,Float32,Float64}
    step == 0 && throw(ArgumentError("range step cannot be zero"))
    # see if the inputs have exact rational approximations (and if so,
    # perform all computations in terms of the rationals)
    step_n, step_d = rat(step)
    if step_d != 0 && T(step_n/step_d) == step
        start_n, start_d = rat(start)
        stop_n, stop_d = rat(stop)
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
                if isbetween(start, start + (len-1)*step, stop + step/2) &&
                        !isbetween(start, start + len*step, stop)
                    # Return a 2x precision range
                    return floatrange(T, start_n, step_n, len, den)
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
    steprangelen_hp(T, start, step, 0, len, 1)
end

function _range(a::T, st::T, ::Nothing, len::Integer) where T<:Union{Float16,Float32,Float64}
    start_n, start_d = rat(a)
    step_n, step_d = rat(st)
    if start_d != 0 && step_d != 0 &&
            T(start_n/start_d) == a && T(step_n/step_d) == st
        den = lcm(start_d, step_d)
        m = maxintfloat(T, Int)
        if abs(den*a) <= m && abs(den*st) <= m &&
                rem(den, start_d) == 0 && rem(den, step_d) == 0
            start_n = round(Int, den*a)
            step_n = round(Int, den*st)
            return floatrange(T, start_n, step_n, len, den)
        end
    end
    steprangelen_hp(T, a, st, 0, len, 1)
end

# This assumes that r.step has already been split so that (0:len-1)*r.step.hi is exact
function unsafe_getindex(r::StepRangeLen{T,<:TwicePrecision,<:TwicePrecision}, i::Integer) where T
    # Very similar to _getindex_hiprec, but optimized to avoid a 2nd call to add12
    @_inline_meta
    u = i - r.offset
    shift_hi, shift_lo = u*r.step.hi, u*r.step.lo
    x_hi, x_lo = add12(r.ref.hi, shift_hi)
    T(x_hi + (x_lo + (shift_lo + r.ref.lo)))
end

function _getindex_hiprec(r::StepRangeLen{<:Any,<:TwicePrecision,<:TwicePrecision}, i::Integer)
    u = i - r.offset
    shift_hi, shift_lo = u*r.step.hi, u*r.step.lo
    x_hi, x_lo = add12(r.ref.hi, shift_hi)
    x_hi, x_lo = add12(x_hi, x_lo + (shift_lo + r.ref.lo))
    TwicePrecision(x_hi, x_lo)
end

function getindex(r::StepRangeLen{T,<:TwicePrecision,<:TwicePrecision}, s::OrdinalRange{<:Integer}) where T
    @boundscheck checkbounds(r, s)
    soffset = 1 + round(Int, (r.offset - first(s))/step(s))
    soffset = clamp(soffset, 1, length(s))
    ioffset = first(s) + (soffset-1)*step(s)
    if step(s) == 1 || length(s) < 2
        newstep = r.step
    else
        newstep = twiceprecision(r.step*step(s), nbitslen(T, length(s), soffset))
    end
    if ioffset == r.offset
        StepRangeLen(r.ref, newstep, length(s), max(1,soffset))
    else
        StepRangeLen(r.ref + (ioffset-r.offset)*r.step, newstep, length(s), max(1,soffset))
    end
end

*(x::Real, r::StepRangeLen{<:Real,<:TwicePrecision}) =
    StepRangeLen(x*r.ref, twiceprecision(x*r.step, nbitslen(r)), length(r), r.offset)
*(r::StepRangeLen{<:Real,<:TwicePrecision}, x::Real) = x*r
/(r::StepRangeLen{<:Real,<:TwicePrecision}, x::Real) =
    StepRangeLen(r.ref/x, twiceprecision(r.step/x, nbitslen(r)), length(r), r.offset)

StepRangeLen{T,R,S}(r::StepRangeLen{T,R,S}) where {T<:AbstractFloat,R<:TwicePrecision,S<:TwicePrecision} = r

StepRangeLen{T,R,S}(r::StepRangeLen) where {T<:AbstractFloat,R<:TwicePrecision,S<:TwicePrecision} =
    _convertSRL(StepRangeLen{T,R,S}, r)

(::Type{StepRangeLen{Float64}})(r::StepRangeLen) =
    _convertSRL(StepRangeLen{Float64,TwicePrecision{Float64},TwicePrecision{Float64}}, r)
StepRangeLen{T}(r::StepRangeLen) where {T<:IEEEFloat} =
    _convertSRL(StepRangeLen{T,Float64,Float64}, r)

(::Type{StepRangeLen{Float64}})(r::AbstractRange) =
    _convertSRL(StepRangeLen{Float64,TwicePrecision{Float64},TwicePrecision{Float64}}, r)
StepRangeLen{T}(r::AbstractRange) where {T<:IEEEFloat} =
    _convertSRL(StepRangeLen{T,Float64,Float64}, r)

function _convertSRL(::Type{StepRangeLen{T,R,S}}, r::StepRangeLen{<:Integer}) where {T,R,S}
    StepRangeLen{T,R,S}(R(r.ref), S(r.step), length(r), r.offset)
end

function _convertSRL(::Type{StepRangeLen{T,R,S}}, r::AbstractRange{<:Integer}) where {T,R,S}
    StepRangeLen{T,R,S}(R(first(r)), S(step(r)), length(r))
end

function _convertSRL(::Type{StepRangeLen{T,R,S}}, r::AbstractRange{U}) where {T,R,S,U}
    # if start and step have a rational approximation in the old type,
    # then we transfer that rational approximation to the new type
    f, s = first(r), step(r)
    start_n, start_d = rat(f)
    step_n, step_d = rat(s)
    if start_d != 0 && step_d != 0 &&
            U(start_n/start_d) == f && U(step_n/step_d) == s
        den = lcm(start_d, step_d)
        m = maxintfloat(T, Int)
        if den != 0 && abs(f*den) <= m && abs(s*den) <= m &&
                rem(den, start_d) == 0 && rem(den, step_d) == 0
            start_n = round(Int, f*den)
            step_n = round(Int, s*den)
            return floatrange(T, start_n, step_n, length(r), den)
        end
    end
    __convertSRL(StepRangeLen{T,R,S}, r)
end

function __convertSRL(::Type{StepRangeLen{T,R,S}}, r::StepRangeLen{U}) where {T,R,S,U}
    StepRangeLen{T,R,S}(R(r.ref), S(r.step), length(r), r.offset)
end
function __convertSRL(::Type{StepRangeLen{T,R,S}}, r::AbstractRange{U}) where {T,R,S,U}
    StepRangeLen{T,R,S}(R(first(r)), S(step(r)), length(r))
end

function sum(r::StepRangeLen)
    l = length(r)
    # Compute the contribution of step over all indices.
    # Indexes on opposite side of r.offset contribute with opposite sign,
    #    r.step * (sum(1:np) - sum(1:nn))
    np, nn = l - r.offset, r.offset - 1  # positive, negative
    # To prevent overflow in sum(1:n), multiply its factors by the step
    sp, sn = sumpair(np), sumpair(nn)
    tp = _tp_prod(r.step, sp[1], sp[2])
    tn = _tp_prod(r.step, sn[1], sn[2])
    s_hi, s_lo = add12(tp.hi, -tn.hi)
    s_lo += tp.lo - tn.lo
    # Add in contributions of ref
    ref = r.ref * l
    sm_hi, sm_lo = add12(s_hi, ref.hi)
    add12(sm_hi, sm_lo + ref.lo)[1]
end

# sum(1:n) as a product of two integers
sumpair(n::Integer) = iseven(n) ? (n+1, n>>1) : (n, (n+1)>>1)

function +(r1::StepRangeLen{T,R}, r2::StepRangeLen{T,R}) where T where R<:TwicePrecision
    len = length(r1)
    (len == length(r2) ||
        throw(DimensionMismatch("argument dimensions must match")))
    if r1.offset == r2.offset
        imid = r1.offset
        ref = r1.ref + r2.ref
    else
        imid = round(Int, (r1.offset+r2.offset)/2)
        ref1mid = _getindex_hiprec(r1, imid)
        ref2mid = _getindex_hiprec(r2, imid)
        ref = ref1mid + ref2mid
    end
    step = twiceprecision(r1.step + r2.step, nbitslen(T, len, imid))
    StepRangeLen{T,typeof(ref),typeof(step)}(ref, step, len, imid)
end

## LinRange

# For Float16, Float32, and Float64, this returns a StepRangeLen
function _range(start::T, ::Nothing, stop::T, len::Integer) where {T<:IEEEFloat}
    len < 2 && return _linspace1(T, start, stop, len)
    if start == stop
        return steprangelen_hp(T, start, zero(T), 0, len, 1)
    end
    # Attempt to find exact rational approximations
    start_n, start_d = rat(start)
    stop_n, stop_d = rat(stop)
    if start_d != 0 && stop_d != 0
        den = lcm(start_d, stop_d)
        m = maxintfloat(T, Int)
        if den != 0 && abs(den*start) <= m && abs(den*stop) <= m
            start_n = round(Int, den*start)
            stop_n = round(Int, den*stop)
            if T(start_n/den) == start && T(stop_n/den) == stop
                return _linspace(T, start_n, stop_n, len, den)
            end
        end
    end
    _linspace(start, stop, len)
end

function _linspace(start::T, stop::T, len::Integer) where {T<:IEEEFloat}
    (isfinite(start) && isfinite(stop)) || throw(ArgumentError("start and stop must be finite, got $start and $stop"))
    # Find the index that returns the smallest-magnitude element
    Δ, Δfac = stop-start, 1
    if !isfinite(Δ)   # handle overflow for large endpoints
        Δ, Δfac = stop/len - start/len, Int(len)
    end
    tmin = -(start/Δ)/Δfac            # t such that (1-t)*start + t*stop == 0
    imin = round(Int, tmin*(len-1)+1) # index approximately corresponding to t
    if 1 < imin < len
        # The smallest-magnitude element is in the interior
        t = (imin-1)/(len-1)
        ref = T((1-t)*start + t*stop)
        step = imin-1 < len-imin ? (ref-start)/(imin-1) : (stop-ref)/(len-imin)
    elseif imin <= 1
        imin = 1
        ref = start
        step = (Δ/(len-1))*Δfac
    else
        imin = Int(len)
        ref = stop
        step = (Δ/(len-1))*Δfac
    end
    if len == 2 && !isfinite(step)
        # For very large endpoints where step overflows, exploit the
        # split-representation to handle the overflow
        return steprangelen_hp(T, start, (-start, stop), 0, 2, 1)
    end
    # 2x calculations to get high precision endpoint matching while also
    # preventing overflow in ref_hi+(i-offset)*step_hi
    m, k = prevfloat(floatmax(T)), max(imin-1, len-imin)
    step_hi_pre = clamp(step, max(-(m+ref)/k, (-m+ref)/k), min((m-ref)/k, (m+ref)/k))
    nb = nbitslen(T, len, imin)
    step_hi = truncbits(step_hi_pre, nb)
    x1_hi, x1_lo = add12((1-imin)*step_hi, ref)
    x2_hi, x2_lo = add12((len-imin)*step_hi, ref)
    a, b = (start - x1_hi) - x1_lo, (stop - x2_hi) - x2_lo
    step_lo = (b - a)/(len - 1)
    ref_lo = a - (1 - imin)*step_lo
    steprangelen_hp(T, (ref, ref_lo), (step_hi, step_lo), 0, Int(len), imin)
end

# range for rational numbers, start = start_n/den, stop = stop_n/den
# Note this returns a StepRangeLen
_linspace(::Type{T}, start::Integer, stop::Integer, len::Integer) where {T<:IEEEFloat} = _linspace(T, start, stop, len, 1)
function _linspace(::Type{T}, start_n::Integer, stop_n::Integer, len::Integer, den::Integer) where T<:IEEEFloat
    len < 2 && return _linspace1(T, start_n/den, stop_n/den, len)
    start_n == stop_n && return steprangelen_hp(T, (start_n, den), (zero(start_n), den), 0, len, 1)
    tmin = -start_n/(Float64(stop_n) - Float64(start_n))
    imin = round(Int, tmin*(len-1)+1)
    imin = clamp(imin, 1, Int(len))
    ref_num = Int128(len-imin) * start_n + Int128(imin-1) * stop_n
    ref_denom = Int128(len-1) * den
    ref = (ref_num, ref_denom)
    step_full = (Int128(stop_n) - Int128(start_n), ref_denom)
    steprangelen_hp(T, ref, step_full,  nbitslen(T, len, imin), Int(len), imin)
end

# For len < 2
function _linspace1(::Type{T}, start, stop, len::Integer) where T<:IEEEFloat
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

### Numeric utilities

# Approximate x with a rational representation. Guaranteed to return,
# but not guaranteed to return a precise answer.
# https://en.wikipedia.org/wiki/Continued_fraction#Best_rational_approximations
function rat(x)
    y = x
    a = d = 1
    b = c = 0
    m = maxintfloat(narrow(typeof(x)), Int)
    while abs(y) <= m
        f = trunc(Int,y)
        y -= f
        a, c = f*a + c, a
        b, d = f*b + d, b
        max(abs(a), abs(b)) <= convert(Int,m) || return c, d
        oftype(x,a)/oftype(x,b) == x && break
        y = inv(y)
    end
    return a, b
end

narrow(::Type{T}) where {T<:AbstractFloat} = Float64
narrow(::Type{Float64}) = Float32
narrow(::Type{Float32}) = Float16
narrow(::Type{Float16}) = Float16

function _tp_prod(t::TwicePrecision, x, y...)
    @_inline_meta
    _tp_prod(t * x, y...)
end
_tp_prod(t::TwicePrecision) = t
<(x::TwicePrecision{T}, y::TwicePrecision{T}) where {T} =
    x.hi < y.hi || ((x.hi == y.hi) & (x.lo < y.lo))

isbetween(a, x, b) = a <= x <= b || b <= x <= a
