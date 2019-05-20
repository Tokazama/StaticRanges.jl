linspace(::Type{T}, start::Integer, stop::Integer, len::Integer) where {T<:Union{Float16, Float32, Float64}} =
    linspace(T, start, stop, len, SOne)


@inline function linspace(b::IEEESFloat, e::IEEESFloat, l::Integer) where {T<:Union{Float16, Float32, Float64}}
    (isfinite(b) && isfinite(e)) || throw(ArgumentError("start and stop must be finite, got $B and $E"))
    # Find the index that returns the smallest-magnitude element
    Δ, Δfac = l - b, one(l)
    if !isfinite(Δ)   # handle overflow for large endpoints
        Δ, Δfac = e/l - b/l, int(l)
    end
    tmin = -(b/Δ)/Δfac            # t such that (1-t)*start + t*stop == 0
    imin = round(Int, tmin*(l-one(l))+one(l))  # index approximately corresponding to t
    if 1 < imin < l
        # The smallest-magnitude element is in the interior
        t = (imin-one(l)/(l-one(l)))
        # TODO
        ref = T((one(T)-t)*b + t*e)
        step = imin-one(imin) < l-imin ? (ref-b)/(imin-one(imin)) : (e-ref)/(l-imin)
    elseif imin <= 1
        imin = SOne
        ref = b
        step = (Δ/(l-one(l)))*Δfac
    else
        imin = int(l)
        ref = e
        step = (Δ/(l-one(l)))*Δfac
    end
    if l == 2 && !isfinite(step)
        # For very large endpoints where step overflows, exploit the
        # split-representation to handle the overflow
        return srangehp(T, b, (-b, e), SZero, SInt(2))
    end
    # 2x calculations to get high precision endpoint matching while also
    # preventing overflow in ref_hi+(i-offset)*step_hi
    m, k = prevfloat(floatmax(T)), max(imin-1, l-imin)
    step_hi_pre = clamp(step, max(-(m+ref)/k, (-m+ref)/k), min((m-ref)/k, (m+ref)/k))
    nb = nbitslen(T, l, imin)
    step_hi = truncbits(step_hi_pre, nb)
    x1_hi, x1_lo = add12((1-imin)*step_hi, ref)
    x2_hi, x2_lo = add12((L-imin)*step_hi, ref)
    a, c = (b - x1_hi) - x1_lo, (e - x2_hi) - x2_lo
    step_lo = (c - a)/(l - one(l))
    ref_lo = a - (one(imin) - imin)*step_lo
    srangehp(T, (ref, ref_lo), (step_hi, step_lo), SZero, l, imin)
end

# range for rational numbers, start = start_n/den, stop = stop_n/den
# Note this returns a StepRangeLen
function linspace(::Type{T}, b::Integer, e::Integer, l::Integer, d::Integer
                 ) where {T<:Union{Float16, Float32, Float64}}
    l < 2 && return linspace1(T, b/d, e/d, l)
    b == e && return srangehp(T, (b, d), (zero(b), d), SZero, l)
    tmin = -b/(float(e) - float(b))
    imin = round(Int, tmin*(l-one(l))+one(l))
    imin = clamp(imin, SOne, int(l))
    ref_num = int128(l-imin) * b + int128(imin-1) * e
    ref_denom = int128(l-one(l)) * d
    srangehp(T, (ref_num, ref_denom), (int128(e) - int128(b), (ref_num, ref_denom)),
             nbitslen(T, l, imin), int(l), imin)
end

# For len < 2
function linspace1(::Type{T}, b::B, e::E, l::Integer) where {B,E,T<:Union{Float16, Float32, Float64}}
    l >= SZero || throw(ArgumentError("srange($(values(b)), stop=$(values(e)), length=$(values(l))): negative length"))
    if l <= 1
        l == 1 && (b == e || throw(ArgumentError("srange($(values(b)), stop=$(values(e)), length=$(values(l))): endpoints differ")))
        # Ensure that first(r)==start and last(r)==stop even for len==0
        # The output type must be consistent with steprangelen_hp
        if T<:Union{Float32,Float16}
            return StaticStepRangeLen{T}(f64(b), f64(b) - f64(e), l, SOne)
        else
            return StaticStepRangeLen(TPVal(b, SZero(T)), TPVal(b, -e), l, SOne)
        end
    end
    throw(ArgumentError("should only be called for len < 2, got $L"))
end
