#=
function Base.intersect(r::StaticRange{T1,B1,E1,S1,F1,0}, s::StaticRange{T2,B2,E2,S2,F1,L2}) where {T1,B1,E1,S1,F1,T2,B2,E2,S2,F2,L2}
    StaticRange{T1,B1,B1-1,S1,1,0}()
end

function Base.intersect(r::StaticRange{T1,B1,E1,S1,F1,L1}, s::StaticRange{T2,B2,E2,S2,F2,0}) where {T1,B1,E1,S1,F1,L1,T2,B2,E2,S2,F2}
    StaticRange{T1,B1,B1-1,S1,1,0}()
end
Base.intersect(r::StaticRange{T,B,S,E,0,F}, s::) where {T,B,S,E,F} = oftype(r, _sr(static_first(r), SNothing, SNothing, SZero))

=#
function Base.intersect(
    r::AbstractUnitSRange{<:Integer},
    s::AbstractUnitSRange{<:Integer})
    max(sfirst(r),sfirst(s)):min(slast(r),slast(s))
end

@inline function Base.intersect(
    i::SVal{I,Ti},
    r::AbstractUnitSRange{T,SVal{B,T},SVal{E,T}}) where {I,Ti<:Integer,T<:Integer,B,E}
    I::Ti < B::T ? (SVal{B::T,T}():i) :
                    i > SVal{E::T,T}()  ? (i:SVal{E::T,T}()) : (i:i)
end

Base.intersect(r::AbstractUnitSRange{<:Integer}, i::SVal{I,<:Integer}) where I = intersect(i, r)

Base.intersect(i::Integer, r::AbstractUnitSRange) = intersect(SVal(i), r)
Base.intersect(r::AbstractUnitSRange, i::Integer) = intersect(SVal(i), r)

@inline function Base.intersect(
    r::AbstractUnitSRange{<:Integer,B1,E1,L1},
    s::StepSRange{<:Integer,B2,S2,E2,L2}) where {B1,E1,L1,B2,S2,E2,L2}
    if isempty(s)
        srange(sfirst(r), length=SZero)
    elseif sstep(s) == SZero
        intersect(sfirst(s), r)
    elseif sstep(s) < SZero
        intersect(r, reverse(s))
    else
        sta = sfirst(s)
        ste = sstep(s)
        sto = slast(s)
        lo = sfirst(r)
        hi = slast(r)
        i0 = max(sta, lo + mod(sta - lo, ste))
        i1 = min(sto, hi - mod(hi - sta, ste))
        i0:ste:i1
    end
end

function Base.intersect(
    r::StepSRange{<:Integer,B1,S,E1,L1},
    s::AbstractUnitSRange{<:Integer,B2,E2,L2}) where {B1,B2,E1,E2,S,L1,L2}
    if sstep(r) < SZero
        reverse(intersect(s, reverse(r)))
    else
        intersect(s, r)
    end
end

function Base.intersect(
    r::StepSRange{T1,B1,S1,E1,L1},
    s::StepSRange{T2,B2,S2,E2,L2}) where {T1<:Integer,B1,S1,E1,L1,T2<:Integer,B2,S2,E2,L2}
    if isempty(r) || isempty(s)
        return srange(sfirst(r), step=sstep(r), length=SZero)
    elseif sstep(s) < SZero
        return intersect(r, reverse(s))
    elseif sstep(r) < SZero
        return reverse(intersect(reverse(r), s))
    end

    start1 = sfirst(r)
    step1 = sstep(r)
    stop1 = slast(r)
    start2 = sfirst(s)
    step2 = sstep(s)
    stop2 = slast(s)
    a = lcm(step1, step2)

    g, x, y = gcdx(step1, step2)

    if rem(start1 - start2, g) != 0
        # Unaligned, no overlap possible.
        return srange(start1, step=a, length=SZero)
    end

    z = div(start1 - start2, g)
    b = start1 - x * z * step1
    # Possible points of the intersection of r and s are
    # ..., b-2a, b-a, b, b+a, b+2a, ...
    # Determine where in the sequence to start and stop.
    m = max(start1 + mod(b - start1, a), start2 + mod(b - start2, a))
    n = min(stop1 - mod(stop1 - b, a), stop2 - mod(stop2 - b, a))
    m:a:n
end

function Base.intersect(
    r::StepSRange{T1,B1,S1,E1,L1},
    s::StepSRange{T2,B2,S2,E2,L2}) where {T1<:Real,B1,S1,E1,L1,T2<:Real,B2,S2,E2,L2}
    if isempty(r) || isempty(s)
        return srange(sfirst(r), step=sstep(r), length=SZero)
    elseif sstep(s) < SZero
        return intersect(r, reverse(s))
    elseif sstep(r) < SZero
        return reverse(intersect(reverse(r), s))
    end

    start1 = sfirst(r)
    step1 = sstep(r)
    stop1 = slast(r)
    start2 = sfirst(s)
    step2 = sstep(s)
    stop2 = slast(s)
    a = lcm(step1, step2)

    g, x, y = gcdx(step1, step2)

    if rem(start1 - start2, g) != 0
        # Unaligned, no overlap possible.
        return srange(start1, step=a, length=SZero)
    end

    z = div(start1 - start2, g)
    b = start1 - x * z * step1
    # Possible points of the intersection of r and s are
    # ..., b-2a, b-a, b, b+a, b+2a, ...
    # Determine where in the sequence to start and stop.
    m = max(start1 + mod(b - start1, a), start2 + mod(b - start2, a))
    n = min(stop1 - mod(stop1 - b, a), stop2 - mod(stop2 - b, a))
    m:a:n
end

Base.intersect(r::StepSRangeLen, i::SVal) = r[i]
Base.intersect(i::SVal, r::StepSRangeLen) = r[i]



#=
function Base._findin(r::AbstractSRange{<:Integer}, span::AbstractUnitSRange{<:Integer})
    local ifirst
    local ilast
    fspan = sfirst(span)
    lspan = slast(span)
    fr = sfirst(r)
    lr = slast(r)
    sr = sstep(r)
    if sr > 0
        ifirst = fr >= fspan ? SOne : ceil(Integer,(fspan-fr)/sr)+SOne
        ilast = lr <= lspan ? length(r) : length(r) - ceil(Integer,(lr-lspan)/sr)
    elseif sr < 0
        ifirst = fr <= lspan ? SOne : ceil(Integer,(lspan-fr)/sr)+SOne
        ilast = lr >= fspan ? length(r) : length(r) - ceil(Integer,(lr-fspan)/sr)
    else
        ifirst = fr >= fspan ? SOne : length(r)+SOne
        ilast = fr <= lspan ? length(r) : 0
    end
    r isa AbstractUnitSRange ? (ifirst:ilast) : (ifirst:SOne:ilast)
end
=#