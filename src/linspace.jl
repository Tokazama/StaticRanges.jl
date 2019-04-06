function linspace(::Type{T}, b::SInteger{B}, e::SInteger{E}, l::SInteger{L}) where {T,B,E,L}
    snew = (E-B)/max(L-1, 1)
    if isa(snew, Integer)
        SRange{typeof(snew),SVal{oftype(snew, B)}(), SVal{oftype(snew, B)}(), SVal{snew}(), SVal{1}(),L}()
    else
        linspace(typeof(snew), b, e, l)
    end
end

linspace(::Type{T}, b::SInteger{B}, e::SInteger{E}, l::SInteger{L}) where {B,E,L,T<:Union{Float16, Float32, Float64}} = linspace(T, b, e, l, SVal{1}())


@inline function linspace(
    b::SVal{B,T},
    e::SVal{E,T},
    f::SInteger{F},
    l::SInteger{L}) where {B,E,F,L,T<:Union{Float16, Float32, Float64}}
    (isfinite(B) && isfinite(E)) || throw(ArgumentError("start and stop must be finite, got $start and $stop"))
    # Find the index that returns the smallest-magnitude element
    Δ, Δfac = E-B, 1
    if !isfinite(Δ)   # handle overflow for large endpoints
        Δ, Δfac = E/L - B/L, Int(L)
    end
    tmin = -(B/Δ)/Δfac            # t such that (1-t)*start + t*stop == 0
    imin = round(Int, tmin*(L-1)+1) # index approximately corresponding to t
    if 1 < imin < L
        # The smallest-magnitude element is in the interior
        t = (imin-1)/(L-1)
        ref = T((1-t)*B + t*E)
        step = imin-1 < L-imin ? (ref-B)/(imin-1) : (E-ref)/(L-imin)
    elseif imin <= 1
        imin = 1
        ref = B
        step = (Δ/(L-1))*Δfac
    else
        imin = Int(L)
        ref = E
        step = (Δ/(L-1))*Δfac
    end
    if L == 2 && !isfinite(step)
        # For very large endpoints where step overflows, exploit the
        # split-representation to handle the overflow
        return srangehp(T, b, (-b, e), SVal{0}(), SVal{2}())
    end
    # 2x calculations to get high precision endpoint matching while also
    # preventing overflow in ref_hi+(i-offset)*step_hi
    m, k = prevfloat(floatmax(T)), max(imin-1, L-imin)
    step_hi_pre = clamp(step, max(-(m+ref)/k, (-m+ref)/k), min((m-ref)/k, (m+ref)/k))
    nb = Base.nbitslen(T, L, imin)
    step_hi = Base.truncbits(step_hi_pre, nb)
    x1_hi, x1_lo = Base.add12((1-imin)*step_hi, ref)
    x2_hi, x2_lo = Base.add12((L-imin)*step_hi, ref)
    a, c = (start - x1_hi) - x1_lo, (stop - x2_hi) - x2_lo
    step_lo = (c - a)/(L - 1)
    ref_lo = a - (1 - imin)*step_lo
    srangehp(t, (SVal{ref}(), SVal{ref_lo}()), (SVal{step_hi}(), SVal{step_lo}()), SVal{0}(), SVal{l}(), SVal{imin}())
end

# range for rational numbers, start = start_n/den, stop = stop_n/den
# Note this returns a StepRangeLen
function linspace(::Type{T}, b::SInteger{B}, e::SInteger{E}, l::SInteger{L}, d::SInteger{D}) where {B,E,F,L,D,T<:Union{Float16, Float32, Float64}}
    L < 2 && return linspace1(T, SVal{B/D}(), SVal{E/D}(), l)
    B == E && return srangehp(T, (b, d), (zero(b), d), SVal{0}(), f, l)
    tmin = -b/(float(e) - float(b))
    imin = round(Int, tmin*(l-1)+1)
    imin = clamp(imin, SVal{1}(), SInt64(l))
    ref_num = SInt128(l-imin) * B + SInt128(imin-1) * e
    ref_denom = SInt128(l-1) * d
    ref = (ref_num, ref_denom)
    step_full = (SInt128(e) - SInt128(b), ref_denom)
    srangehp(T, ref, step_full,  nbitslen(T, l, imin), SInt64(l), imin)
end

#=
function linspace(::Type{T}, b::SInteger{B}, e::SInteger{E}, l::SInteger{L}, d::SInteger{D}) where {B,E,F,L,D,T<:Union{Float16, Float32, Float64}}
    L < 2 && return linspace1(T, SVal{B/D}(), SVal{E/D}(), l)
    B == E && return srangehp(T, (b, d), (zero(b), d), SVal{0}(), f, l)
    tmin = -b/(e - b)
    imin = round(Int, tmin*(l-1)+1)
    imin = clamp(imin, SVal{1}(), SVal{Int(L)}())
    ref_num = SInt128(L-imin) * b + SInt128(imin-1) * e
    ref_denom = SInt128(l-1) * d
    ref = (ref_num, ref_denom)
    step_full = (SInt128(e) - SInt128(b), ref_denom)
    nb = StaticRanges.nbitslen(T, l, imin)
    (T, ref, step_full,  nb,  SInt64(l), imin)
end

using StaticRanges
using StaticRanges: SNothing, SInt128, SInteger
  b = SVal(Int32(1))
  e = SVal(Int32(4))
  l = SVal(Int64(4))
  d = SVal(Int64(1))
  T = Float64
  B = Int32(1)
  E = Int32(4)
  L = 4
  D = 1
  b = SVal(Int32(1))
  e = SVal(Int32(4))
  l = SVal(Int64(4))
  d = SVal(Int64(1))
  T = Float64
  B = Int32(1)
  E = Int32(4)
  L = 4
  D = 1
   linspace(T, b, e, l, d)
=#

# For len < 2
function linspace1(::Type{T}, b::SVal{B}, e::SVal{E}, f::SInteger{F}, l::SInteger{L}) where {B,E,F,L,D,T<:Union{Float16, Float32, Float64}}
    L >= 0 || throw(ArgumentError("srange($B, stop=$E, length=$L): negative length"))
    if L <= 1
        L == 1 && (B == E || throw(ArgumentError("srange($B, stop=$E, length=$L): endpoints differ")))
        # Ensure that first(r)==start and last(r)==stop even for len==0
        # The output type must be consistent with steprangelen_hp
        if T<:Union{Float32,Float16}
            _sr(SFloat64(b), SNothing(),SFloat64(b - e), f, l)
        else
            _sr(HPSVal(b, SVal{zero(T),T}()), SNothing(), HPSVal(b, -e), f, l)
        end
    end
    throw(ArgumentError("should only be called for len < 2, got $L"))
end


