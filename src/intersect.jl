
#= intersect
for R in (:StepMRange,:LinMRange,:StepMRangeLen)
    @eval begin
        Base.intersect(r::$(R){T}, i::T) where {T} = intersect(i, r)
        Base.intersect(r::$(R){<:Real}, i::Real) = intersect(eltype(r)(i), r)
        Base.intersect(i::Real, r::$(R){Real}) = intersect(eltype(r)(i), r)
        function Base.intersect(i::T, r::$(R){T}) where {T}
            if i in r
                return mrange(i, stop=i, length=1)
            else
                return mrange(i, stop=i, length=0)
            end
        end
    end
end
=#

Base.intersect(x::AbstractStepRange, y) = _step_intersect(x, y)
Base.intersect(x::AbstractLinRange, y) = _lin_intersect(x, y)
Base.intersect(x::AbstractStepRangeLen, y) = _steplen_intersect(x, y)
Base.intersect(r::StepRange, s::AbstractStepRange) = _step_intersect(r, s)

_step_intersect(x::AbstractRange{T}, y::Real) where {T} = _el_instersect(x, T(y))
_lin_intersect(x::AbstractRange{T}, y::Real) where {T} = _el_instersect(x, T(y))
_steplen_intersect(x::AbstractRange{T}, y::Real) where {T} = _el_instersect(x, T(y))

function _el_instersect(x::AbstractRange{T}, y::T) where {T}
    if is_static(x)
        if y in x
            return srange(y, stop=y, length=1)
        else
            return srange(y, stop=y, length=0)
        end
    else
        if y in x
            return mrange(y, stop=y, length=1)
        else
            return mrange(y, stop=y, length=0)
        end
    end
end

Base.intersect(r::OneToRange, s::OneToRange) = OneTo(min(last(r),last(s)))
Base.intersect(r::OneToRange, s::OneTo) = OneTo(min(last(r),last(s)))
Base.intersect(r::OneTo, s::OneToRange) = OneTo(min(last(r),last(s)))

function Base.intersect(r::AbstractUnitRange{<:Integer}, s::AbstractStepRange{<:Integer})
    if isempty(s)
        range(first(r), length=0)
    elseif step(s) < 0
        intersect(r, reverse(s))
    else
        sta = first(s)
        ste = step(s)
        sto = last(s)
        lo = first(r)
        hi = last(r)
        i0 = max(sta, lo + mod(sta - lo, ste))
        i1 = min(sto, hi - mod(hi - sta, ste))
        i0:ste:i1
    end
end

function Base.intersect(r::AbstractStepRange{<:Integer}, s::AbstractUnitRange{<:Integer})
    if step(r) < 0
        return reverse(intersect(s, reverse(r)))
    else
        return intersect(s, r)
    end
end


function _step_intersect(r, s::OrdinalRange)
    if isempty(r) || isempty(s)
        return range(first(r), step=step(r), length=0)
    elseif step(s) < zero(step(s))
        return intersect(r, reverse(s))
    elseif step(r) < zero(step(r))
        return reverse(intersect(reverse(r), s))
    end

    start1 = first(r)
    step1 = step(r)
    stop1 = last(r)
    start2 = first(s)
    step2 = step(s)
    stop2 = last(s)
    a = lcm(step1, step2)

    g, x, y = gcdx(step1, step2)

    if !iszero(rem(start1 - start2, g))
        # Unaligned, no overlap possible.
        return range(start1, step=a, length=0)
    end

    z = div(start1 - start2, g)
    b = start1 - x * z * step1
    # Possible points of the intersection of r and s are
    # ..., b-2a, b-a, b, b+a, b+2a, ...
    # Determine where in the sequence to start and stop.
    m = max(start1 + mod(b - start1, a), start2 + mod(b - start2, a))
    n = min(stop1 - mod(stop1 - b, a), stop2 - mod(stop2 - b, a))
    range(m, step=a, stop=n)
end
