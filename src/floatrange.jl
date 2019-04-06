function floatrange(
    ::Type{T},
    b::SInteger{B},
    s::SInteger{S},
    l::SInteger{L},
    d::SInteger{D}
    ) where {T,B,S,L,D}
    if L < 2 || S == 0
        return srangehp(T, (b, d), (s, d), SVal{0}(), SVal{1}(), l)
    end
    # index of smallest-magnitude value
    imin = clamp(round(Int, -b/s+1), SVal{1}(), SInt64(l))
    # Compute smallest-magnitude element to 2x precision
    ref_n = b+(imin-1)*s  # this shouldn't overflow, so don't check
    nb = nbitslen(T, l, imin)
    srangehp(T, (ref_n, d), (s, d), nb, SInt64(l), imin)
end

function floatrange(
    b::StaticFloat{B},
    s::StaticFloat{S},
    l::SVal{L,<:Real},
    d::StaticFloat{D}
    ) where {B,S,L,D}
    T = promote_type(typeof(B), typeof(S), typeof(D))
    m = maxintfloat(T, Int)
    if abs(B) <= m && abs(S) <= m && abs(D) <= m
        ia, ist, idivisor = round(Int, B), round(Int, S), round(Int, D)
        if ia == B && ist == S && idivisor == D
            # We can return the high-precision range
            return floatrange(T, SVal{ia}(), SVal{ist}(), Int(l), SVal{idivisor}())
        end
    end
    # Fallback (misses the opportunity to set offset different from 1,
    # but otherwise this is still high-precision)
    srangehp(T, (b,SVal{divisor}()), (s,SVal{divisor}()), Base.nbitslen(T, l, 1), Int(l), SVal{1}())
end