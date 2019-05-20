function floatrange(::Type{T}, b::Integer, s::Integer, l::Real, d::Integer) where T
    if l < 2 || S == 0
        return srangehp(T, (b, d), (s, d), SZero, SOne, l)
    end
    # index of smallest-magnitude value
    imin = clamp(round(Int, -b/s+SOne), SOne, int(l))
    # Compute smallest-magnitude element to 2x precision
    ref_n = b+(imin-SOne)*s  # this shouldn't overflow, so don't check
    nb = nbitslen(T, l, imin)
    srangehp(T, (ref_n, d), (s, d), nb, int(l), imin)
end

function floatrange(b::AbstractFloat, s::AbstractFloat, l::Integer, d::AbstractFloat)
    T = promote_type(typeof(b), typeof(s), typeof(d))
    m = maxintfloat(T, Int)
    if abs(b) <= m && abs(s) <= m && abs(d) <= m
        ia, ist, idivisor = round(Int, b), round(Int, s), round(Int, d)
        if ia == B && ist == S && idivisor == D
            # We can return the high-precision range
            return floatrange(T, ia, ist, int(l), idivisor)
        end
    end
    # Fallback (misses the opportunity to set offset different from 1,
    # but otherwise this is still high-precision)
    srangehp(T, (b, d), (s, d), nbitslen(T, l, SOne), int(l), SOne)
end
