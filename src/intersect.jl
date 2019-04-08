#=
function Base.intersect(r::StaticRange{T1,B1,E1,S1,F1,0}, s::StaticRange{T2,B2,E2,S2,F1,L2}) where {T1,B1,E1,S1,F1,T2,B2,E2,S2,F2,L2}
    StaticRange{T1,B1,B1-1,S1,1,0}()
end

function Base.intersect(r::StaticRange{T1,B1,E1,S1,F1,L1}, s::StaticRange{T2,B2,E2,S2,F2,0}) where {T1,B1,E1,S1,F1,L1,T2,B2,E2,S2,F2}
    StaticRange{T1,B1,B1-1,S1,1,0}()
end
Base.intersect(r::StaticRange{T,B,S,E,0,F}, s::) where {T,B,S,E,F} = oftype(r, _sr(static_first(r), SNothing, SNothing, SZero))

=#

function Base.intersect(i::SVal{I,<:Integer}, r::StaticRange{<:Integer}) where I
    i < static_first(r) ? _sr(static_first(r), SNothing(), i, SNothing()) :
                          i > static_last(r)  ? _sr(i, SNothing(), static_last(r))  : _sr(i, SNothing(), i, SNothing())
end

Base.intersect(r::StaticRange{<:Integer}, i::SVal{I,<:Integer}) where I = intersect(i, r)

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
    b = s1 - x * z * SOne
    # Possible points of the intersection of r and s are
    # ..., b-2a, b-a, b, b+a, b+2a, ...
    # Determine where in the sequence to start and stop.
    m = max(b1 + mod(b - b1, a), b2 + mod(b - b2, a))
    n = min(e1 - mod(e1 - b, a), e2 - mod(e2 - b, a))
    return oftype(r, _sr(m, a, n, SNothing()))
end

#=
@inline function Base.intersect(
    r::StaticRange{T1,SVal{B1,Tb1},SVal{S1,Ts1},E1,L1,F1},
    s::StaticRange{T2,SVal{B2,Tb2},SVal{S2,Ts2},E2,L2,F2}
    ) where {T1,B1,Tb1,E1,S1,Ts1,F1,L1,T2,B2,Tb2,E2,S2,Ts2,F2,L2}
    s1 = static_step(r)
    s2 = static_step(s)
    if s2 < SZero
        return intersect(r, reverse(s))
    elseif s1 < SZero
        return reverse(intersect(reverse(r), s))
    elseif s1 == SOne(Ts1)
        _sr(max(static_first(s), static_first(r) + mod(static_first(s) - static_first(r), s2)), s2,
            min(static_last(s),  static_last(r)  - mod(static_last(r)  - static_first(s), s2)), SNothing())
    end
    b1 = static_first(r)
    b2 = static_first(s)
    e1 = static_last(r)
    e2 = static_last(s)
  
    a = lcm(s1, s2)
    g, x, y = gcdx(s1, s2)

    if rem(b1 - b2, g) != SZero
        return oftype(r, _sr(b1, a, SNothing(), SZero)) # start, step, stop, length
    end

    z = div(b1 - b2, g)
    b = s1 - x * z * SOne
    # Possible points of the intersection of r and s are
    # ..., b-2a, b-a, b, b+a, b+2a, ...
    # Determine where in the sequence to start and stop.
    m = max(b1 + mod(b - b1, a), b2 + mod(b - b2, a))
    n = min(e1 - mod(e1 - b, a), e2 - mod(e2 - b, a))
    return oftype(r, _sr(m, a, n, SNothing()))
end
=#