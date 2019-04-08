function linspace(
    ::Type{T},
    b::SInteger{B},
    e::SInteger{E},
    l::SInteger{L}
    ) where {T,B,E,L}
    snew = (E-B)/max(L-1, 1)
    if isa(snew, Integer)
        SRange{typeof(snew),SVal{oftype(snew, B)}(), SVal{oftype(snew, B)}(), SVal{snew}(), SVal{1}(),L}()
    else
        linspace(typeof(snew), b, e, l)
    end
end

function linspace(
    ::Type{T},
    b::SInteger{B},
    e::SInteger{E},
    l::SInteger{L}
    ) where {B,E,L,T<:Union{Float16, Float32, Float64}}
    linspace(T, b, e, l, SVal{1}())
end

@inline function linspace(
    b::SVal{B,T},
    e::SVal{E,T},
    f::SVal{F,Tf},
    l::SVal{L,Tl}
    ) where {B,E,F,Tf<:Integer,L,Tl<:Integer,T<:Union{Float16, Float32, Float64}}
    (isfinite(b) && isfinite(e)) || throw(ArgumentError("start and stop must be finite, got $B and $E"))
    # Find the index that returns the smallest-magnitude element
    Δ, Δfac = l - b, SVal{1}()
    if !isfinite(Δ)   # handle overflow for large endpoints
        Δ, Δfac = e/l - b/l, SVal{Int(L),Int}()
    end
    tmin = -(b/Δ)/Δfac            # t such that (1-t)*start + t*stop == 0
    imin = round(Int, tmin*(l-SVal{Tl(1),Tl}()+SVal{Tl(1),Tl}()))# index approximately corresponding to t
    if SVal{Tl(1),Tl}() < imin < l
        # The smallest-magnitude element is in the interior
        t = (imin-SVal{1}())/(l-SVal{Tl(1),Tl}())
        ref = T((SVal{1}()-t)*B + t*E)
        step = imin-SVal{1}() < l-imin ? (ref-b)/(imin-SVal{1}()) : (e-ref)/(l-imin)
    elseif imin <= SVal{1}()
        imin = SVal{1,Int}()
        ref = b
        step = (Δ/(l-SVal{1}()))*Δfac
    else
        imin = SVal{Int(L),Int}()
        ref = e
        step = (Δ/(l-SVal{1}()))*Δfac
    end
    if L == 2 && !isfinite(step)
        # For very large endpoints where step overflows, exploit the
        # split-representation to handle the overflow
        return srangehp(T, b, (-b, e), SVal{0,Int}(), SVal{2,Int}())
    end
    # 2x calculations to get high precision endpoint matching while also
    # preventing overflow in ref_hi+(i-offset)*step_hi
    m, k = SVal{prevfloat(floatmax(T))}(), max(imin-1, l-imin)
    step_hi_pre = clamp(step, max(-(m+ref)/k, (-m+ref)/k), min((m-ref)/k, (m+ref)/k))
    nb = nbitslen(T, l, imin)
    step_hi = SVal{Base.truncbits(get(step_hi_pre), get(nb))}()
    x1_hi, x1_lo = add12((1-imin)*step_hi, ref)
    x2_hi, x2_lo = add12((L-imin)*step_hi, ref)
    a, c = (b - x1_hi) - x1_lo, (e - x2_hi) - x2_lo
    step_lo = (c - a)/(l - 1)
    ref_lo = a - (1 - imin)*step_lo
    srangehp(T, (ref, ref_lo), (step_hi, step_lo), SVal{0}(), l, imin)
end

# range for rational numbers, start = start_n/den, stop = stop_n/den
# Note this returns a StepRangeLen
function linspace(
    ::Type{T},
    b::SInteger{B},
    e::SInteger{E},
    l::SInteger{L},
    d::SInteger{D}
    ) where {B,E,F,L,D,T<:Union{Float16, Float32, Float64}}
    l < 2 && return linspace1(T, b/d, e/d, l)
    b == E && return srangehp(T, (b, d), (zero(b), d), SVal{0}(), l)
    tmin = -b/(float(e) - float(b))
    imin = round(Int, tmin*(l-1)+1)
    imin = clamp(imin, SVal{1}(), SInt64(l))
    ref_num = SInt128(l-imin) * B + SInt128(imin-1) * e
    ref_denom = SInt128(l-1) * d
    ref = (ref_num, ref_denom)
    step_full = (SInt128(e) - SInt128(b), ref_denom)
    srangehp(T, ref, step_full,  nbitslen(T, l, imin), SInt64(l), imin)
end

function linspace(
    b::SVal{B,T},
    e::SVal{E,T},
    l::SVal{L,<:Integer}
    ) where {B,E,L,T<:Union{Float16,Float32,Float64}}
    (isfinite(b) && isfinite(e)) || throw(ArgumentError("start and stop must be finite, got $b and $e"))
    # Find the index that returns the smallest-magnitude element
    Δ, Δfac = e-b, 1
    if !isfinite(Δ)   # handle overflow for large endpoints
        Δ, Δfac = e/l - b/l, Int(l)
    end
    tmin = -(b/Δ)/Δfac            # t such that (1-t)*start + t*e == 0
    imin = round(Int, tmin*(l-1)+1) # index approximately corresponding to t
    if 1 < imin < l
        # The smallest-magnitude element is in the interior
        t = (imin-1)/(l-1)
        ref = T((1-t)*b + t*e)
        step = imin-1 < l-imin ? (ref-b)/(imin-1) : (e-ref)/(l-imin)
    elseif imin <= 1
        imin = SVal{1}()
        ref = b
        step = (Δ/(l-1))*Δfac
    else
        imin = SVal{Int(l)}()
        ref = e
        step = (Δ/(l-1))*Δfac
    end
    if l == 2 && !isfinite(step)
        # For very large endpoints where step overflows, exploit the
        # split-representation to handle the overflow
        return srangehp(T, b, (-b, e), SVal{0}(), SVal{2}(), SVal{1}())
    end
    # 2x calculations to get high precision endpoint matching while also
    # preventing overflow in ref_hi+(i-offset)*step_hi
    m, k = SVal{prevfloat(floatmax(T))}(), max(imin-1, l-imin)
    step_hi_pre = clamp(step, max(-(m+ref)/k, (-m+ref)/k), min((m-ref)/k, (m+ref)/k))
    nb = nbitslen(T, l, imin)
    step_hi = SVal{Base.truncbits(get(step_hi_pre), get(nb))}()
    x1_hi, x1_lo = add12((1-imin)*step_hi, ref)
    x2_hi, x2_lo = add12((l-imin)*step_hi, ref)
    a, b = (b - x1_hi) - x1_lo, (e - x2_hi) - x2_lo
    step_lo = (b - a)/(l - 1)
    ref_lo = a - (1 - imin)*step_lo
    srangehp(T, (ref, ref_lo), (step_hi, step_lo), SVal{0}(), l, imin)
end

# For len < 2
function linspace1(
    ::Type{T},
    b::SVal{B,Tb},
    e::SVal{E,Te},
    l::SInteger{L}
    ) where {B,Tb,E,Te,L,T<:Union{Float16, Float32, Float64}}
    l >= SZero || throw(ArgumentError("srange($B, stop=$E, length=$L): negative length"))
    if l <= SOne
        l == SOne && (b == e || throw(ArgumentError("srange($B, stop=$E, length=$L): endpoints differ")))
        # Ensure that first(r)==start and last(r)==stop even for len==0
        # The output type must be consistent with steprangelen_hp
        if T<:Union{Float32,Float16}
            return steprangelen(T, SFloat64(b), SFloat64(b) - SFloat64(e), l, SOne)
        else
            return steprangelen(HPSVal(b, SVal{zero(T),T}()), HPSVal(b, -e), l, SOne)
        end
    end
    throw(ArgumentError("should only be called for len < 2, got $L"))
end

function linrange(
    ::Type{T},
    b::SVal{B,Tb},
    e::SVal{E,Te},
    l::SInteger{L}
    ) where {T,B,Tb,E,Te,L}
    SRange{T,SVal{B,Tb},typeof(SVal{(E-B)/max(L - 1, 1)}()),T(E),L,1}()
end

function linrange(
    b::SVal{B},
    e::SVal{E},
    l::SVal{L}
    ) where {B,E,L} 
    linrange(typeof((stop-start)/len), b, e, l)
end