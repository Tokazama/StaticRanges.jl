Base.reverse(r::StepSRange) = srange(last(r), step=-step(r), stop=first(r))
Base.reverse(r::StepMRange) = mrange(last(r), step=-step(r), stop=first(r))

function Base.reverse(r::AbstractStepRangeLen)
    # If `r` is empty, `length(r) - r.offset + 1 will be nonpositive hence
    # invalid. As `reverse(r)` is also empty, any offset would work so we keep
    # `r.offset`
    offset = isempty(r) ? _offset(r) : length(r) - _offset(r) + 1
    return similar_type(r)(_ref(r), -step_hp(r), length(r), offset)
end

function Base.iterate(r::Union{AbstractLinRange,AbstractStepRangeLen}, i::Int=1)
    Base.@_inline_meta
    length(r) < i && return nothing
    unsafe_getindex(r, i), i + 1
end

Base.isempty(r::Union{AbstractLinRange,AbstractStepRangeLen}) = length(r) == 0

###
### ==(r1, r2)
###
function Base.:(==)(r::StepMRangeLen{T,R,S}, s::StepMRangeLen{T,R,S}) where {T,R,S}
    (first(r) == first(s)) & (length(r) == length(s)) & (last(r) == last(s))
end

function Base.:(==)(r::StepSRangeLen{T,R,S}, s::StepSRangeLen{T,R,S}) where {T,R,S}
    (first(r) == first(s)) & (length(r) == length(s)) & (last(r) == last(s))
end

function Base.:(==)(r::AbstractLinRange{T}, s::AbstractLinRange{T}) where {T}
    (first(r) == first(s)) & (length(r) == length(s)) & (last(r) == last(s))
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

function Base.:(+)(r1::StepSRangeLen{T,TwicePrecision{T}}, r2::StepSRangeLen{T,TwicePrecision{T}}) where {T}
    len = length(r1)
    (len == length(r2) ||
        throw(DimensionMismatch("argument dimensions must match")))
    if _offset(r1) == _offset(r2)
        imid = _offset(r1)
        ref = _ref(r1) + _ref(r2)
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
    return similar_type(r)(-_ref(r), -step(r), length(r), _offset(r))
end
Base.:(-)(r1::StepMRangeLen{T,R,S}, r2::StepMRangeLen{T,R,S}) where {T,R,S} = +(r1, -r2)
Base.:(-)(r1::StepSRangeLen{T,R,S}, r2::StepSRangeLen{T,R,S}) where {T,R,S} = +(r1, -r2)


###
### *(r1, r2)
###
Base.:(*)(r::AbstractStepRangeLen{T,TwicePrecision{T}}, x::Real) where {T<:Real} = x*r
function Base.:(*)(x::Real, r::StepMRangeLen{T,TwicePrecision{T}}) where {T<:Real}
    return StepMRangeLen(x * _ref(r), Base.twiceprecision(x * step(r), nbitslen(r)), length(r), _offset(r))
end
function Base.:(*)(x::Real, r::StepSRangeLen{T,TwicePrecision{T}}) where {T<:Real}
    return StepSRangeLen(x * _ref(r), Base.twiceprecision(x * step(r), nbitslen(r)), length(r), _offset(r))
end

###
### /(r1, r2)
###
function Base.:(/)(r::StepMRangeLen{T,TwicePrecision{T}}, x::Real) where {T<:Real}
    return StepMRangeLen(_ref(r)/x, Base.twiceprecision(step(r)/x, Base.nbitslen(r)), length(r), _offset(r))
end
function Base.:(/)(r::StepSRangeLen{T,TwicePrecision{T}}, x::Real) where {T<:Real}
    return StepSRangeLen(_ref(r)/x, Base.twiceprecision(step(r)/x, Base.nbitslen(r)), length(r), _offset(r))
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

