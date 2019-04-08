function floatrange(
    ::Type{T},
    b::SInteger{B},
    s::SInteger{S},
    l::SInteger{L},
    d::SInteger{D}
    ) where {T,B,S,L,D}
    if L < 2 || S == 0
        return srangehp(T, (b, d), (s, d), SZero, SOne, l)
    end
    # index of smallest-magnitude value
    imin = clamp(round(Int, -b/s+1), SOne, SInt64(l))
    # Compute smallest-magnitude element to 2x precision
    ref_n = b+(imin-SOne)*s  # this shouldn't overflow, so don't check
    nb = nbitslen(T, l, imin)
    srangehp(T, (ref_n, d), (s, d), nb, SInt64(l), imin)
end

function floatrange(
    b::SFloat{B},
    s::SFloat{S},
    l::SVal{L,<:Real},
    d::SFloat{D}
    ) where {B,S,L,D}
    T = promote_type(typeof(B), typeof(S), typeof(D))
    m = SVal{maxintfloat(T, Int)}()
    if abs(B) <= m && abs(S) <= m && abs(D) <= m
        ia, ist, idivisor = round(Int, b), round(Int, s), round(Int, d)
        if ia == B && ist == S && idivisor == D
            # We can return the high-precision range
            return floatrange(T, ia, ist, SInt64(l), idivisor)
        end
    end
    # Fallback (misses the opportunity to set offset different from 1,
    # but otherwise this is still high-precision)
    srangehp(T, (b, d), (s, d), nbitslen(T, l, SOne), Int(l), SOne)
end
