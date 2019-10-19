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
Base.:(+)(r1::AbstractStepRangeLen, r2::AbstractRange) = _add(r1, r2)
Base.:(+)(r1::AbstractRange, r2::AbstractStepRangeLen) = _add(r1, r2)
Base.:(+)(r1::AbstractStepRangeLen, r2::AbstractStepRangeLen) = _add(r1, r2)

_add(r1, r2) = +(promote(r1, r2)...)

function _add(r1::StepMRangeLen{T,S}, r2::StepMRangeLen{T,S}) where {T,S}
    len = length(r1)
    (len == length(r2) ||
        throw(DimensionMismatch("argument dimensions must match")))
    return StepMRangeLen(first(r1)+first(r2), step(r1)+step(r2), len)
end


function _add(r1::StepMRangeLen{T,TwicePrecision{T}}, r2::StepMRangeLen{T,TwicePrecision{T}}) where {T}
    len = length(r1)
    (len == length(r2) || throw(DimensionMismatch("argument dimensions must match")))
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
    return StepMRangeLen{T,typeof(ref),typeof(step)}(ref, step, len, imid)
end

function _add(r1::StepSRangeLen{T,TwicePrecision{T}}, r2::StepSRangeLen{T,TwicePrecision{T}}) where {T}
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

_add(r1::StepSRangeLen{T,R,S}, r2::Union{OneToSRange,UnitSRange,StepSRange,LinSRange}) where {T,R,S} = +(r1, StepSRangeLen{T,R,S}(r2))
_add(r2::Union{OneToSRange,UnitSRange,StepSRange,LinSRange}, r1::StepSRangeLen{T,R,S}) where {T,R,S} = +(r1, StepSRangeLen{T,R,S}(r2))

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
Base.:(-)(r1::AbstractStepRangeLen, r2::AbstractRange) = -(promote(r1, r2)...)
Base.:(-)(r1::AbstractRange, r2::AbstractStepRangeLen) = -(promote(r1, r2)...)
Base.:(-)(r1::AbstractStepRangeLen, r2::AbstractStepRangeLen) = -(promote(r1, r2)...)

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
#=
        function $f(r1::LinRange{T}, r2::LinRange{T}) where T
            len = r1.len
            (len == r2.len ||
             throw(DimensionMismatch("argument dimensions must match")))
            LinRange{T}(convert(T, $f(first(r1), first(r2))),
                        convert(T, $f(last(r1), last(r2))), len)
        end
=#

#= TODO

==(r::T, s::T) where {T<:AbstractRange} =
    (first(r) == first(s)) & (step(r) == step(s)) & (last(r) == last(s))
==(r::OrdinalRange, s::OrdinalRange) =
    (first(r) == first(s)) & (step(r) == step(s)) & (last(r) == last(s))
==(r::T, s::T) where {T<:Union{StepRangeLen,LinRange}} =
    (first(r) == first(s)) & (length(r) == length(s)) & (last(r) == last(s))
==(r::Union{StepRange{T},StepRangeLen{T,T}}, s::Union{StepRange{T},StepRangeLen{T,T}}) where {T} =
    (first(r) == first(s)) & (last(r) == last(s)) & (step(r) == step(s))
=#

#=
$f(r1::Union{StepRangeLen, OrdinalRange, LinRange},
   r2::Union{StepRangeLen, OrdinalRange, LinRange}) =
       $f(promote(r1, r2)...)

Base.:(==)(r::T, s::T) where {T<:Union{StepRangeLen,LinRange}} =
    (first(r) == first(s)) & (length(r) == length(s)) & (last(r) == last(s))
=#

#=
function Base.convert(::Type{T}, r::AbstractRange) where {T<:StepMRangeLen}
    return r isa T ? r : T(r)
end
function Base.convert(::Type{T}, r::AbstractRange) where {T<:StepSRangeLen}
    return r isa T ? r : T(r)
end
=#
