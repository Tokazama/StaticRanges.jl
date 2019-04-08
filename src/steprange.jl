function steprange(b::SVal{B,T}, s::SVal{S,Ts}, e::SVal{E,T}) where {T,Ts,B,S,E}
    steprange(T, b, s, steprange_last(b, s, e))
end


# srange(1:2:0)
function steprange(::Type{T}, b::SVal{B,Tb}, s::SVal{S,Ts}, e::SVal{E,Tb}) where {T,B,Tb,S,Ts,E}
    e = steprange_last(b, s, e)
    SRange{T,SVal{B,Tb},SVal{S,Ts},get(e),steprange_length(b,s,e),1}()
end

function steprange_length(b::SVal{B,T}, s::SVal{S}, e::SVal{E,T}) where {B,E,S,T<:Union{Int,UInt,Int64,UInt64,Int128,UInt128}}
    (B != E) & ((S > zero(S))) != (E > B) && return T(0)
    if S > 1
        return Base.Checked.checked_add(Int(div(unsigned(E - B), S)), one(B))
    elseif S < -1
        return Base.Checked.checked_add(Int(div(unsigned(B - E), -S)), one(B))
    elseif S > 0
        return Int(Base.Checked.checked_add(div(Base.Checked.checked_sub(E, B), S), one(B)))
    else
        return Int(Base.Checked.checked_add(div(Base.Checked.checked_sub(B, E), -S), one(B)))
    end
end

function steprange_length(b::SVal{B,T}, s::SVal{S}, e::SVal{E,T}) where {B,E,S,T}
    n = Int(div((E - B) + S, S))
    (B != E) & ((S > zero(S))) != (E > B) ? zero(n) : n
end

steprange_last(b::SVal{B,T}, s::SVal{S}, e::SVal{B,T}) where {B,S,T} = b
#steprange_length(::Type{Rational{UInt64}}, ::SVal{0xffffffffffffffff//0x0000000000000001,Rational{UInt64}}, ::SVal{1,Int64}, ::SVal{0xfffffffffffffffe//0x0000000000000001,Rational{UInt64}})
# stop == start
function steprange_last(b::SVal{B}, s::SVal{S}, e::SVal{E}) where {B,S,E}
    z = zero(s)
    s == z && throw(ArgumentError("step cannot be zero"))

    if (S > 0) != (E > B)
        last = steprange_last_empty(b, s, e)
    else
        # Compute absolute value of difference between `B` and `E`
        # (to simplify handling both signed and unsigned T and checking for signed overflow):
        absdiff, absstep = E > B ? (E - B, S) : (B - E, -S)

        # Compute remainder as a nonnegative number:
        if typeof(B) <: Signed && absdiff < zero(absdiff)
            # handle signed overflow with unsigned rem
            remain = typeof(B, unsigned(absdiff) % absstep)
        else
            remain = absdiff % absstep
        end
        # Move `E` closer to `B` if there is a remainder:
        last = E > B ? SVal{E - remain}() : SVal{E + remain}()
    end
    return last
end


function steprange_last_empty(::SInteger{B}, ::SVal{S}, ::SVal{E}) where {B,E,S}
    # empty range has a special representation where stop = start-1
    # this is needed to avoid the wrap-around that can happen computing
    # start - step, which leads to a range that looks very large instead
    # of empty.
    if S > zero(S)
        return SVal{B - oneunit(E-B)}()
    else
        return SVal{B + oneunit(E-B)}()
    end
end
steprange_last_empty(::SVal{B}, ::SVal{S}, ::SVal{E}) where {B,E,S} = SVal{B-S}()

function intersect(r::StaticRange, s::StepRange)
    if isempty(r) || isempty(s)
        return range(first(r), step=step(r), length=0)
    elseif step(s) < 0
        return intersect(r, reverse(s))
    elseif step(r) < 0
        return reverse(intersect(reverse(r), s))
    end

    start1 = first(r1)
    step1 = step(r1)
    stop1 = last(r1)
    start2 = first(r2)
    step2 = step(r2)
    stop2 = last(r2)
    a = lcm(step1, step2)

    # if a == 0
    #     # One or both ranges have step 0.
    #     if step1 == 0 && step2 == 0
    #         return start1 == start2 ? r : AbstractRange(start1, 0, 0)
    #     elseif step1 == 0
    #         return start2 <= start1 <= stop2 && rem(start1 - start2, step2) == 0 ? r : AbstractRange(start1, 0, 0)
    #     else
    #         return start1 <= start2 <= stop1 && rem(start2 - start1, step1) == 0 ? (start2:step1:start2) : AbstractRange(start1, step1, 0)
    #     end
    # end

    g, x, y = gcdx(step1, step2)

    if rem(start1 - start2, g) != 0
        # Unaligned, no overlap possible.
        return srange(start1, step=a, length=0)
    end

    z = div(start1 - start2, g)
    b = start1 - x * z * step1
    # Possible points of the intersection of r and s are
    # ..., b-2a, b-a, b, b+a, b+2a, ...
    # Determine where in the sequence to start and stop.
    m = max(start1 + mod(b - start1, a), start2 + mod(b - start2, a))
    n = min(stop1 - mod(stop1 - b, a), stop2 - mod(stop2 - b, a))
    srange(m, step=a, stop=n)
end

function Base.intersect(
    r1::StaticRange{T1,SVal{B1,T1},SVal{S1,T1},E1,L1,F1},
    r2::StaticRange{T2,SVal{B2,T2},SVal{S2,T2},E2,0,F2}
    ) where {T1,B1,E1,S1,F2,L1,T2,B2,E2,S2,F1}
   oftype(r1, _sr(SVal{T1(B1)}(), SVal{T1(S1)}(), SNothing(), SVal{0}()))
end

function Base.intersect(
    r1::StaticRange{T1,SVal{B1,T1},SVal{S1,T1},E1,0,F1},
    r2::StaticRange{T2,SVal{B2,T2},SVal{S2,T2},E2,0,F2}
    ) where {T1,B1,E1,S1,F2,T2,B2,E2,S2,F1}
   oftype(r1, _sr(SVal{T1(B1)}(), SVal{T1(S1)}(), SNothing(), SVal{0}()))
end

function Base.intersect(
    r1::StaticRange{T1,SVal{B1,T1},SVal{S1,T1},E1,0,F1},
    r2::StaticRange{T2,SVal{B2,T2},SVal{S2,T2},E2,L2,F2}
    ) where {T1,B1,E1,S1,F2,T2,B2,E2,S2,F1,L2}
   oftype(r1, _sr(SVal{T1(B1)}(), SVal{T1(S1)}(), SNothing(), SVal{0}()))
end

@inline function Base.intersect(
    r1::StaticRange{T1,SVal{B1,T1},SVal{S1,T1},E1,L1,F1},
    r2::StaticRange{T2,SVal{B2,T2},SVal{S2,T2},E2,L2,F2}
    ) where {T1,B1,E1,S1,F2,L1,T2,B2,E2,S2,F1,L2}
    if S2 < 0
        return intersect(r, reverse(s))
    elseif S1 < 0
        return reverse(intersect(reverse(r1), r2))
    end

    # TODO finish modifying intersect function from here
    b1 = SVal{B1,T1}()
    s1 = SVal{S1,T1}()
    e1 = SVal{E1}()
    b2 = SVal{B2,T2}()
    s2 = SVal{S2,T2}()
    e2 = SVal{E2}()

    a = lcm(s1, s2)

    g, x, y = gcdx(s1, s2)

    if rem(b1 - b2, g) != 0
        # Unaligned, no overlap possible.
        return range(B1, step=a, length=0)
    end

    z = div(b1 - b2, g)
    b = b1 - x * z * s1 
    # Possible points of the intersection of r and s are
    # ..., b-2a, b-a, b, b+a, b+2a, ...
    # Determine where in the sequence to start and stop.
    m = max(b1 + mod(b - b1, a), b2 + mod(b - b2, a))
    n = min(e1 - mod(E1 - b, a), e2 - mod(e2 - b, a))
    _sr(m, a, n, SNothing())
end
