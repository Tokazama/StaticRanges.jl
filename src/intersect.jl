#=
function Base.intersect(r::StaticRange{T1,B1,E1,S1,F1,0}, s::StaticRange{T2,B2,E2,S2,F1,L2}) where {T1,B1,E1,S1,F1,T2,B2,E2,S2,F2,L2}
    StaticRange{T1,B1,B1-1,S1,1,0}()
end

function Base.intersect(r::StaticRange{T1,B1,E1,S1,F1,L1}, s::StaticRange{T2,B2,E2,S2,F2,0}) where {T1,B1,E1,S1,F1,L1,T2,B2,E2,S2,F2}
    StaticRange{T1,B1,B1-1,S1,1,0}()
end
Base.intersect(r::StaticRange{T,B,S,E,0,F}, s::) where {T,B,S,E,F} = oftype(r, _sr(static_first(r), SNothing, SNothing, SZero))

=#
function Base.intersect(i::SInteger, r::StaticRange)
    if isa(r, UnitSRange)
        if i < static_first(r)
            return static_first(r):i
        else
            if i > static_last(r)
                return i:static_last(r)
            else
                return i:i
            end
        end
    else
        return r[i]
    end
end

function Base.intersect(r::StaticRange, i::SInteger)
    if isa(r, UnitSRange)
        if i < static_first(r)
            return static_first(r):i
        else
            if i > static_last(r)
                return i:static_last(r)
            else
                return i:i
            end
        end
    else
        return r[i]
    end
end

@inline function Base.intersect(
    r::StaticRange{T1,B1,S1,E1,L1,F1},
    s::StaticRange{T2,B2,S2,E2,L2,F2}
    ) where {T1,B1,E1,S1,F1,L1,T2,B2,E2,S2,F2,L2}
    s1 = static_step(r)
    s2 = static_step(s)
    b1 = static_first(r)
    b2 = static_first(s)
    e1 = static_last(r)
    e2 = static_last(s)
    if isa(r, UnitSRange)
        if isa(s, UnitSRange)
            return max(b1,b2):min(e1,e2)
        else
            if isempty(s)
                return srange(b1, length=SZero)
            elseif s2 == SZero
                return intersect(b2, r)
            elseif s2 < 0
                return intersect(r, reverse(s))
            else
                return max(b2, b1 + mod(b2 - b1, s2)):s2:min(e2, e1 - mod(e1 - b2, s2))
            end
        end
    elseif isa(s, UnitSRange)
        if s1 < SZero
            return reverse(intersect(s, reverse(r)))
        else
            return intersect(s, r)
        end
    elseif isempty(s) || isempty(r)
        return oftype(r, _sr(static_first(r), s1, SNothing(), SZero))
    elseif s2 < SZero 
        return intersect(r, reverse(s))
    elseif s1 < SZero
        return reverse(intersect(reverse(r), s))
    end

    a = lcm(s1, s2)
    g, x, y = gcdx(s1, s2)

    if rem(b1 - b2, g) != SZero
        return oftype(r, _sr(b1, a, SNothing(), SZero)) # start, step, stop, length
    end

    z = div(b1 - b2, g)
    b = b1 - x * z * s1
    # Possible points of the intersection of r and s are
    # ..., b-2a, b-a, b, b+a, b+2a, ...
    # Determine where in the sequence to start and stop.
    m = max(b1 + mod(b - b1, a), b2 + mod(b - b2, a))
    n = min(e1 - mod(e1 - b, a), e2 - mod(e2 - b, a))
    return oftype(r, _sr(m, a, n, SNothing()))
end
#=
@inline function unitintersect(r::R, s::S) where {R<:UnitSRange{<:Integer},S<:UnitSRange{<:Integer}}
    max(static_first(r),static_first(s)):min(static_last(r),static_last(s))
end


@inline function Base.intersect(
    r::StaticRange{T1,B1,S1,E1,L1,F1},
    s::StaticRange{T2,B2,S2,E2,L2,F2}
    ) where {T1,B1,E1,S1,F1,L1,T2,B2,E2,S2,F2,L2}
    s1 = static_step(r)
    s2 = static_step(s)
    b1 = static_first(r)
    b2 = static_first(s)
    e1 = static_last(r)
    e2 = static_last(s)
 
    if isempty(s) || isempty(r)
        return oftype(r, _sr(static_first(r), static_step(r), SNothing(), SZero))
    elseif s2 < SZero 
        return intersect(r, reverse(s))
    elseif s1 < SZero
        return reverse(intersect(reverse(r), s))
    elseif s1 === SOne(s1)
        if s2 === SOne(s2)
            return oftype(r, _sr(max(b1, b2), SNothing(), min(e1, e2), SNothing()))
        else
            if s2 == SZero
                return intersect(static_first(s), r)
            else
                return oftype(r, _sr(max(b2, b1 + mod(b2 - b1, s2)), s2, min(e2, e1 - mod(e1 - b2, s2)), SNothing()))
            end
        end
    elseif s2 === SOne(s2)
        return intersect(s, r)
    end
 
    a = lcm(s1, s2)
    g, x, y = gcdx(s1, s2)

    if rem(b1 - b2, g) != SZero
        return oftype(r, _sr(b1, a, SNothing(), SZero)) # start, step, stop, length
    end

    z = div(b1 - b2, g)
    b = b1 - x * z * s1
    # Possible points of the intersection of r and s are
    # ..., b-2a, b-a, b, b+a, b+2a, ...
    # Determine where in the sequence to start and stop.
    m = max(b1 + mod(b - b1, a), b2 + mod(b - b2, a))
    n = min(e1 - mod(e1 - b, a), e2 - mod(e2 - b, a))
    return oftype(r, _sr(m, a, n, SNothing()))
end
=#