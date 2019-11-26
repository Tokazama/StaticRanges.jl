### intersect
for R in (:StepMRange,:LinMRange,:StepMRangeLen)
    @eval begin
        Base.intersect(r::$(R){T}, i::T) where {T} = intersect(i, r)
        Base.intersect(r::$(R){<:Real}, i::Real) = intersect(eltype(r)(i), r)
        Base.intersect(i::Real, r::$(R){Real}) = intersect(eltype(r)(i), r)
        function Base.intersect(i::T, r::$(R){T}) where {T}
            return i in r ? mrange(i, stop=i, length=1) : mrange(i, stop=i, length=0)
        end
    end
end

for R in (:StepSRange,:LinSRange,:StepSRangeLen)
    @eval begin
        Base.intersect(r::$(R){T}, i::T) where {T} = intersect(i, r)
        Base.intersect(r::$(R){<:Real}, i::Real) = intersect(eltype(r)(i), r)
        Base.intersect(i::Real, r::$(R){Real}) = intersect(eltype(r)(i), r)
        function Base.intersect(i::T, r::$(R){T}) where {T}
            return i in r ? srange(i, stop=i, length=1) : srange(i, stop=i, length=0)
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

Base.intersect(r::AbstractStepRange, s::StepRange) = _intersect(r, s)
Base.intersect(r::StepRange,         s::AbstractStepRange) = _intersect(r, s)
Base.intersect(r::AbstractStepRange, s::AbstractStepRange) = _intersect(r, s)

function _intersect(r, s)
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

###
### findin
###
function _find_first_in(x, xo::O, y, yo::O) where {O<:Ordering}
    for x_i in x
        out = find_first(==(x_i), y, yo)
        isnothing(out) || return out
    end
    return nothing
end

function _find_first_in(x, xo::Ordering, y, yo::Ordering)
    for x_i in x
        out = find_last(==(x_i), y, yo)
        isnothing(out) || return out
    end
    return nothing
end

function _find_last_in(x, xo::O, y, yo::O) where {O<:Ordering}
    for x_i in reverse(x)
        out = find_first(==(x_i), y, yo)
        isnothing(out) || return out
    end
    return nothing
end

function _find_last_in(x, xo::Ordering, y, yo::Ordering)
    for x_i in reverse(x)
        out = find_last(==(x_i), y, yo)
        isnothing(out) || return out
    end
    return nothing
end

# finds the step of indices in y given x 
_find_step_in(sx::T, xo::O, sy::T, yo::O) where {T<:Integer,O<:Ordering} = sx * gcd(sx, sy)
_find_step_in(sx::T, xo::Ordering, sy::T, yo::Ordering) where {T<:Integer} = -sx * gcd(sx, sy)

function _find_step_in(sx::T, xo, sy::T, yo) where {T<:AbstractFloat}
    return _find_step_in(rationalize(sx), rationalize(sy))
end

function _find_step_in(sx::T, xo::Ordering, sy::T, yo::Ordering) where {T<:Rational}
    if denominator(sx) != denominator(sy)
        return _find_step_in(denominator(sy) * sx, xo, denominator(sx) * sy, yo)
    else
        return -Rational(numerator(sx) * gcd(numerator(sx), numerator(sy)), denominator(sx))
    end
end

function _find_step_in(sx::T, xo::O, sy::T, yo::O) where {T<:Rational,O<:Ordering}
    if denominator(sx) != denominator(sy)
        return _find_step_in(denominator(sy) * sx, xo, denominator(sx) * sy, yo)
    else
        return Rational(numerator(sx) * gcd(numerator(sx), numerator(sy)), denominator(sx))
    end
end

###
### findin
###
function _findin(x, xo, y, yo)
    xnew, ynew = promote(x, y)
    return _findin(xnew, xo, ynew, yo)
end

function _findin(x::OneToMRange, xo, y::OneToMRange, yo)
    return OneToMRange(_find_last_in(x, xo, y, yo))
end
function _findin(x::OneTo, xo, y::OneTo, yo)
    return OneTo(_find_last_in(x, xo, y, yo))
end
function _findin(x::OneToSRange, xo, y::OneToSRange, yo)
    return OneToSRange(_find_last_in(x, xo, y, yo))
end

function _findin(x::UnitRange{<:Integer}, xo, y::UnitRange{<:Integer}, yo)
    return UnitRange(_find_first_in(x, xo, y, yo), _find_last_in(x, xo, y, yo))
end
function _findin(x::UnitMRange{<:Integer}, xo, y::UnitMRange{<:Integer}, yo)
    return UnitMRange(_find_first_in(x, xo, y, yo), _find_last_in(x, xo, y, yo))
end
function _findin(x::UnitSRange{<:Integer}, xo, y::UnitSRange{<:Integer}, yo)
    return UnitSRange(_find_first_in(x, xo, y, yo), _find_last_in(x, xo, y, yo))
end

function _findin(x::UnitRange, xo, y::UnitRange, yo)
    iszero(rem(first(x) - first(y), 1)) || return similar_type(x)(fi, li)
    return UnitRange(_find_first_in(x, xo, y, yo), _find_last_in(x, xo, y, yo))
end
function _findin(x::UnitMRange, xo, y::UnitMRange, yo)
    iszero(rem(first(x) - first(y), 1)) || return similar_type(x)(fi, li)
    return UnitMRange(_find_first_in(x, xo, y, yo), _find_last_in(x, xo, y, yo))
end
function _findin(x::UnitSRange, xo, y::UnitSRange, yo)
    iszero(rem(first(x) - first(y), 1)) || return similar_type(x)(fi, li)
    return UnitSRange(_find_first_in(x, xo, y, yo), _find_last_in(x, xo, y, yo))
end

function _findin(x::StepMRange, xo, y::StepMRange, yo)
    fi = _find_first_in(x, xo, y, yo)
    li = _find_last_in(x, xo, y, yo)
    sxy = _find_step_in(step(x), xo, step(y), yo)
    if !iszero(rem(ordmin(x, xo) - ordmin(y, yo), div(sxy, step(x))))
        # Unaligned, no overlap possible.
        return mrange(fi, step=sxy, length=0)
    else
        return mrange(fi, step=sxy, stop=li)
    end
end

function _findin(x::StepSRange, xo, y::StepSRange, yo)
    fi = _find_first_in(x, xo, y, yo)
    li = _find_last_in(x, xo, y, yo)
    sxy = _find_step_in(step(x), xo, step(y), yo)

    if !iszero(rem(ordmin(x, xo) - ordmin(y, yo), div(sxy, step(x))))
        # Unaligned, no overlap possible.
        return srange(fi, step=sxy, length=0)
    else
        return srange(fi, step=sxy, stop=li)
    end
end

function _findin(x::AbstractRange, xo, y::AbstractRange, yo)
    fi = _find_first_in(x, xo, y, yo)
    li = _find_last_in(x, xo, y, yo)
    sxy = _find_step_in(step(x), xo, step(y), yo)
    if !iszero(rem(ordmin(x, xo) - ordmin(y, yo), div(sxy, step(x))))
        # Unaligned, no overlap possible.
        return range(fi, step=sxy, length=0)
    else
        return range(fi, step=sxy, stop=li)
    end
end

