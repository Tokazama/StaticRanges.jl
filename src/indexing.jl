function Base.getindex(r::Union{AbstractStepRangeLen,AbstractLinRange}, i::Integer)
    Base.@_inline_meta
    @boundscheck checkbounds(r, i)
    unsafe_getindex(r, i)
end

function Base.getindex(
    r::AbstractStepRangeLen{T,TwicePrecision{T},TwicePrecision{T}},
    s::OrdinalRange{<:Integer}
   ) where {T}
    @boundscheck checkbounds(r, s)
    soffset = 1 + round(Int, (_offset(r) - first(s))/step(s))
    soffset = clamp(soffset, 1, length(s))
    ioffset = first(s) + (soffset-1)*step(s)
    if step(s) == 1 || length(s) < 2
        newstep = step_hp(r)
    else
        newstep = Base.twiceprecision(step_hp(r)*step(s), Base.nbitslen(T, length(s), soffset))
    end
    if ioffset == _offset(r)
        return similar_type(r)(_ref(r), newstep, length(s), max(1,soffset))
    else
        return similar_type(r)(_ref(r) + (ioffset-_offset(r))*step_hp(r), newstep, length(s), max(1,soffset))
    end
end


# although these should technically not need to be completely typed for
# each, dispatch ignores TwicePrecision on the static version and only
# uses the first otherwise
function Base.unsafe_getindex(
    r::StepSRangeLen{T,TwicePrecision{T},TwicePrecision{T}},
    i::Integer
   ) where {T}
    # Very similar to _getindex_hiprec, but optimized to avoid a 2nd call to add12
    Base.@_inline_meta
    u = i - _offset(r)
    shift_hi, shift_lo = u * step_hp(r).hi, u * step_hp(r).lo
    x_hi, x_lo = add12(_ref(r).hi, shift_hi)
    return T(x_hi + (x_lo + (shift_lo + _ref(r).lo)))
end

function Base.unsafe_getindex(
    r::StepMRangeLen{T,TwicePrecision{T},TwicePrecision{T}},
    i::Integer
   ) where {T}
    # Very similar to _getindex_hiprec, but optimized to avoid a 2nd call to add12
    Base.@_inline_meta
    u = i - _offset(r)
    shift_hi, shift_lo = u * step_hp(r).hi, u * step_hp(r).lo
    x_hi, x_lo = add12(_ref(r).hi, shift_hi)
    return T(x_hi + (x_lo + (shift_lo + _ref(r).lo)))
end

function Base.unsafe_getindex(r::StepSRangeLen{T,R,S}, i::Integer) where {T,R,S}
    return T(_ref(r) + (i - _offset(r)) * step_hp(r))
end
function Base.unsafe_getindex(r::StepMRangeLen{T,R,S}, i::Integer) where {T,R,S}
    return T(_ref(r) + (i - _offset(r)) * step_hp(r))
end
