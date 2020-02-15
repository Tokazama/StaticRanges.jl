Base.reverse(r::StepSRange) = srange(last(r), step=-step(r), stop=first(r))
Base.reverse(r::StepMRange) = mrange(last(r), step=-step(r), stop=first(r))
Base.reverse(r::AbstractLinRange) = similar_type(r)(last(r), first(r), length(r))

function Base.reverse(r::AbstractStepRangeLen)
    # If `r` is empty, `length(r) - r.offset + 1 will be nonpositive hence
    # invalid. As `reverse(r)` is also empty, any offset would work so we keep
    # `r.offset`
    offset = isempty(r) ? r.offset : length(r) - r.offset + 1
    return similar_type(r)(r.ref, -step_hp(r), length(r), offset)
end

function Base.reverse!(r::StepMRange)
    setfield!(r, :step, -step(r))
    f = first(r)
    l = last(r)
    setfield!(r, :stop, f)
    setfield!(r, :start, l)
    return r
end

function Base.reverse!(r::StepMRangeLen)
    # If `r` is empty, `length(r) - r.offset + 1 will be nonpositive hence
    # invalid. As `reverse(r)` is also empty, any offset would work so we keep
    # `r.offset`
    setfield!(r, :offset, isempty(r) ? r.offset : length(r) - r.offset + 1)
    setfield!(r, :step, -step_hp(r))
    return r
end

function Base.reverse!(r::LinMRange)
    f = first(r)
    l = last(r)
    setfield!(r, :stop, f)
    setfield!(r, :start, l)
    return r
end

Base.isempty(r::Union{AbstractLinRange,AbstractStepRangeLen}) = length(r) == 0

###
### ==(r1, r2)
###
Base.:(==)(r::OneToRange, s::OneToRange) = last(r) == last(s)
function Base.:(==)(r::StepMRangeLen{T,R,S}, s::StepMRangeLen{T,R,S}) where {T,R,S}
    return (first(r) == first(s)) & (length(r) == length(s)) & (last(r) == last(s))
end
function Base.:(==)(r::StepSRangeLen{T,R,S}, s::StepSRangeLen{T,R,S}) where {T,R,S}
    return (first(r) == first(s)) & (length(r) == length(s)) & (last(r) == last(s))
end
function Base.:(==)(r::AbstractLinRange{T}, s::AbstractLinRange{T}) where {T}
    return (first(r) == first(s)) & (length(r) == length(s)) & (last(r) == last(s))
end

###
### +(r1, r2)
###
Base.:(+)(r1::Union{AbstractStepRangeLen,AbstractLinRange}, r2::AbstractRange) = +(promote(r1, r2)...)
Base.:(+)(r1::AbstractRange, r2::Union{AbstractStepRangeLen,AbstractLinRange}) =  +(promote(r1, r2)...)
Base.:(+)(r1::Union{AbstractStepRangeLen,AbstractLinRange}, r2::Union{AbstractStepRangeLen,AbstractLinRange}) = +(promote(r1, r2)...)
function Base.:(+)(r1::StepMRangeLen{T,S}, r2::StepMRangeLen{T,S}) where {T,S}
    len = length(r1)
    (len == length(r2) ||
        throw(DimensionMismatch("argument dimensions must match")))
    return StepMRangeLen(first(r1)+first(r2), step(r1)+step(r2), len)
end
function Base.:(+)(r1::StepSRangeLen{T,S}, r2::StepSRangeLen{T,S}) where {T,S}
    len = length(r1)
    (len == length(r2) ||
        throw(DimensionMismatch("argument dimensions must match")))
    return StepSRangeLen(first(r1)+first(r2), step(r1)+step(r2), len)
end
function Base.:(+)(r1::StepMRangeLen{T,TwicePrecision{T}}, r2::StepMRangeLen{T,TwicePrecision{T}}) where {T}
    len = length(r1)
    (len == length(r2) || throw(DimensionMismatch("argument dimensions must match")))
    if r1.offset == r2.offset
        imid = r1.offset
        ref = r1.ref + r2.ref
    else
        imid = round(Int, (r1.offset + r2.offset)/2)
        ref1mid = _getindex_hiprec(r1, imid)
        ref2mid = _getindex_hiprec(r2, imid)
        ref = ref1mid + ref2mid
    end
    step = twiceprecision(r1.step + r2.step, nbitslen(T, len, imid))
    return StepMRangeLen{T,typeof(ref),typeof(step)}(ref, step, len, imid)
end

function Base.:(+)(r1::StepSRangeLen{T,TwicePrecision{T},<:Any,<:Any,<:Any,<:Any,<:Any},
                   r2::StepSRangeLen{T,TwicePrecision{T},<:Any,<:Any,<:Any,<:Any,<:Any}) where {T}
    len = length(r1)
    (len == length(r2) ||
        throw(DimensionMismatch("argument dimensions must match")))
    if _offset(r1) == _offset(r2)
        imid = _offset(r1)
        ref = r1.ref + r2.ref
    else
        imid = round(Int, (_offset(r1)+_offset(r2))/2)
        ref1mid = _getindex_hiprec(r1, imid)
        ref2mid = _getindex_hiprec(r2, imid)
        ref = ref1mid + ref2mid
    end
    step = twiceprecision(r1.step + r2.step, nbitslen(T, len, imid))
    return StepSRangeLen{T,typeof(ref),typeof(step)}(ref, step, len, imid)
end

#_add(r1::StepSRangeLen{T,R,S}, r2::Union{OneToSRange,UnitSRange,StepSRange,LinSRange}) where {T,R,S} = +(r1, StepSRangeLen{T,R,S}(r2))
#_add(r2::Union{OneToSRange,UnitSRange,StepSRange,LinSRange}, r1::StepSRangeLen{T,R,S}) where {T,R,S} = +(r1, StepSRangeLen{T,R,S}(r2))

###
### sum
###
function Base.sum(r::AbstractStepRangeLen)
    l = length(r)
    # Compute the contribution of step over all indices.
    # Indexes on opposite side of r.offset contribute with opposite sign,
    #    r.step * (sum(1:np) - sum(1:nn))
    np, nn = l - r.offset, r.offset - 1  # positive, negative
    # To prevent overflow in sum(1:n), multiply its factors by the step
    sp, sn = sumpair(np), sumpair(nn)
    tp = Base._tp_prod(r.step, sp[1], sp[2])
    tn = Base._tp_prod(r.step, sn[1], sn[2])
    s_hi, s_lo = add12(tp.hi, -tn.hi)
    s_lo += tp.lo - tn.lo
    # Add in contributions of ref
    ref = r.ref * l
    sm_hi, sm_lo = add12(s_hi, ref.hi)
    return add12(sm_hi, sm_lo + ref.lo)[1]
end

###
### -(r1, r2)
###
Base.:(-)(r1::Union{AbstractStepRangeLen,AbstractLinRange}, r2::AbstractRange) = -(promote(r1, r2)...)
Base.:(-)(r1::AbstractRange, r2::Union{AbstractStepRangeLen,AbstractLinRange}) =  -(promote(r1, r2)...)
Base.:(-)(r1::Union{AbstractStepRangeLen,AbstractLinRange}, r2::Union{AbstractStepRangeLen,AbstractLinRange}) = -(promote(r1, r2)...)

function Base.:(-)(r::AbstractStepRangeLen)
    return similar_type(r)(-r.ref, -step(r), length(r), r.offset)
end
Base.:(-)(r1::StepMRangeLen{T,R,S}, r2::StepMRangeLen{T,R,S}) where {T,R,S} = +(r1, -r2)
Base.:(-)(r1::StepSRangeLen{T,R,S}, r2::StepSRangeLen{T,R,S}) where {T,R,S} = +(r1, -r2)


###
### *(r1, r2)
###
Base.:(*)(r::AbstractStepRangeLen{T,TwicePrecision{T}}, x::Real) where {T<:Real} = x*r
function Base.:(*)(x::Real, r::StepMRangeLen{T,TwicePrecision{T}}) where {T<:Real}
    return StepMRangeLen(x * r.ref, Base.twiceprecision(x * step(r), nbitslen(r)), length(r), r.offset)
end
function Base.:(*)(x::Real, r::StepSRangeLen{T,TwicePrecision{T}}) where {T<:Real}
    return StepSRangeLen(x * r.ref, Base.twiceprecision(x * step(r), nbitslen(r)), length(r), r.offset)
end

###
### /(r1, r2)
###
function Base.:(/)(r::StepMRangeLen{T,TwicePrecision{T}}, x::Real) where {T<:Real}
    return StepMRangeLen(r.ref/x, Base.twiceprecision(step(r)/x, Base.nbitslen(r)), length(r), r.offset)
end
function Base.:(/)(r::StepSRangeLen{T,TwicePrecision{T}}, x::Real) where {T<:Real}
    return StepSRangeLen(r.ref/x, Base.twiceprecision(step(r)/x, Base.nbitslen(r)), length(r), r.offset)
end

for (frange,R) in ((mrange, :StepMRange), (srange, :StepSRange))
    for f in (:+, :-)
        @eval begin
            Base.$(f)(r1::$R, r2::OrdinalRange) = $(f)(promote(r1, r2)...)
            Base.$(f)(r1::OrdinalRange, r2::$R) =  $(f)(promote(r1, r2)...)
            function Base.$(f)(r1::$R, r2::$R)
                r1l = length(r1)
                (r1l == length(r2) ||
                 throw(DimensionMismatch("argument dimensions must match: length of r1 is $r1l, length of r2 is $(length(r2))")))
                $(frange)($f(first(r1), first(r2)), step=$f(step(r1), step(r2)), length=r1l)
            end

        end
    end
end

#= TODO
float(r::StepRange) = float(r.start):float(r.step):float(last(r))
float(r::UnitRange) = float(r.start):float(last(r))
float(r::StepRangeLen{T}) where {T} =
    StepRangeLen{typeof(float(T(r.ref)))}(float(r.ref), float(r.step), length(r), r.offset)
function float(r::LinRange)
    LinRange(float(r.start), float(r.stop), length(r))
end
=#

Base.empty!(r::LinMRange{T}) where {T} = (setfield!(r, :len, 0); r)
Base.empty!(r::StepMRangeLen{T}) where {T} = (setfield!(r, :len, 0); r)
function Base.empty!(r::StepMRange{T}) where {T}
    setfield!(r, :stop, first(r) - step(r))
    return r
end
Base.empty!(r::UnitMRange{T}) where {T} = (setfield!(r, :stop, first(r) - one(T)); r)
Base.empty!(r::OneToMRange{T}) where {T} = (setfield!(r, :stop, zero(T)); r)

Base.empty(r::LinSRange) = LinSRange(first(r), last(r), 0)
Base.empty(r::LinMRange) = LinMRange(first(r), last(r), 0)
Base.empty(r::StepSRangeLen) = StepSRangeLen(r.ref, r.step, 0, r.offset)
Base.empty(r::StepMRangeLen) = StepMRangeLen(r.ref, r.step, 0, r.offset)
Base.empty(r::StepSRange)  = StepSRange(r.start, r.step, r.start - step(r))
Base.empty(r::StepMRange)  = StepMRange(r.start, r.step, r.start - step(r))
Base.empty(r::UnitSRange{T}) where {T} = UnitSRange(first(r), first(r) - one(T))
Base.empty(r::UnitMRange{T}) where {T} = UnitMRange(first(r), first(r) - one(T))
Base.empty(r::OneToSRange{T}) where {T} = OneToSRange(zero(T))
Base.empty(r::OneToMRange{T}) where {T} = OneToMRange(zero(T))
