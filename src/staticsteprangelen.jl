"""
    StaticStepRangeLen
"""
abstract type StaticStepRangeLen{T,R,S} <: AbstractRange{T} end

Base.:(-)(r1::StaticStepRangeLen, r2::AbstractRange) = +(r1, -r2)
Base.:(-)(r1::AbstractRange, r2::StaticStepRangeLen) = +(r1, -r2)
Base.:(-)(r1::StaticStepRangeLen, r2::StaticStepRangeLen) = +(r1, -r2)

Base.first(r::StaticStepRangeLen) = unsafe_getindex(r, 1)

Base.last(r::StaticStepRangeLen) = unsafe_getindex(r, length(r))

function Base.unsafe_getindex(r::StaticStepRangeLen{T}, i::Integer) where T
    u = i - _offset(r)
    return T(_ref(r) + u * step(r))
end

function _getindex_hiprec(r::StaticStepRangeLen, i::Integer)  # without rounding by T
    u = i - _offset(r)
    return _ref(r) + u * step(r)
end

function Base.unsafe_getindex(
    r::StaticStepRangeLen{T,<:TwicePrecision,<:TwicePrecision},
    i::Integer
   ) where T
    # Very similar to _getindex_hiprec, but optimized to avoid a 2nd call to add12
    Base.@_inline_meta
    u = i - _offset(r)
    shift_hi, shift_lo = u * step_hp(r).hi, u * step_hp(r).lo
    x_hi, x_lo = add12(_ref(r).hi, shift_hi)
    return T(x_hi + (x_lo + (shift_lo + _ref(r).lo)))
end

function _getindex_hiprec(r::StaticStepRangeLen{<:Any,<:TwicePrecision,<:TwicePrecision}, i::Integer)
    u = i - _offset(r)
    shift_hi, shift_lo = u * step(r).hi, u * step_hp(r).lo
    x_hi, x_lo = add12(_ref(r).hi, shift_hi)
    x_hi, x_lo = add12(x_hi, x_lo + (shift_lo + _ref(r).lo))
    return TwicePrecision(x_hi, x_lo)
end

function Base.sum(r::StaticStepRangeLen)
    l = length(r)
    # Compute the contribution of step over all indices.
    # Indexes on opposite side of r.offset contribute with opposite sign,
    #    r.step * (sum(1:np) - sum(1:nn))
    np, nn = l - _offset(r), _offset(r) - 1  # positive, negative
    # To prevent overflow in sum(1:n), multiply its factors by the step
    sp, sn = sumpair(np), sumpair(nn)
    tp = Base._tp_prod(step_hp(r), sp[1], sp[2])
    tn = Base._tp_prod(step_hp(r), sn[1], sn[2])
    s_hi, s_lo = add12(tp.hi, -tn.hi)
    s_lo += tp.lo - tn.lo
    # Add in contributions of ref
    ref = _ref(r) * l
    sm_hi, sm_lo = add12(s_hi, ref.hi)
    return add12(sm_hi, sm_lo + ref.lo)[1]
end

function Base.show(io::IO, r::StaticStepRangeLen)
    print(io, typeof(r).name, "(", first(r), ":", step(r), ":", last(r), ")")
end


"""
    StepSRangeLen
"""
struct StepSRangeLen{T,Tr,Ts,R,S,L,F} <: StaticStepRangeLen{T,R,S} end

function StepSRangeLen{T,R,S}(ref::R, step::S, len::Integer, offset::Integer = 1) where {T,R,S}
    len >= 0 || throw(ArgumentError("length cannot be negative, got $len"))
    1 <= offset <= max(1,len) || throw(ArgumentError("StepRangeLen: offset must be in [1,$len], got $offset"))
    StepSRangeLen{T,R,S,tp2val(ref),tp2val(ref),len,offset}()
end

# convert TPVal to TwicePrecision
Base.step_hp(::StepSRangeLen{T,Tr,Ts,R,S}) where {T,Tr,Ts<:TwicePrecision,R,S} = convert(Ts, S)
_ref(::StepSRangeLen{T,Tr,Ts,R,S,L,F}) where {T,Tr<:TwicePrecision,Ts,R,S,L,F} = convert(Tr, R)

Base.step(::StepSRangeLen{T,Tr,Ts,R,S,L,F}) where {T,Tr,Ts,R,S,L,F} = convert(T, S)
Base.length(::StepSRangeLen{T,Tr,Ts,R,S,L,F}) where {T,Tr,Ts,R,S,L,F} = L
_offset(::StepSRangeLen{T,Tr,Ts,R,S,L,F}) where {T,Tr,Ts,R,S,L,F} = F
_ref(::StepSRangeLen{T,Tr,Ts,R,S,L,F}) where {T,Tr,Ts,R,S,L,F} = R

isstatic(::Type{X}) where {X<:StepSRangeLen} = true

"""
    StepMRangeLen
"""
mutable struct StepMRangeLen{T,R,S} <: StaticStepRangeLen{T,R,S}
    ref::R
    step::S
    len::Int
    offset::Int

    function StepMRangeLen{T,R,S}(ref::R, step::S, len::Integer, offset::Integer = 1) where {T,R,S}
        len >= 0 || throw(ArgumentError("length cannot be negative, got $len"))
        1 <= offset <= max(1,len) || throw(ArgumentError("StepRangeLen: offset must be in [1,$len], got $offset"))
        new(ref, step, len, offset)
    end
end

Base.step_hp(r::StepMRangeLen) = getfield(r, :step)
Base.step(r::StepMRangeLen{T}) where {T} = T(step_hp(r))
Base.length(r::StepMRangeLen) = getfield(r, :len)
_offset(r::StepMRangeLen) = getfield(r, :offset)
_ref(r::StepMRangeLen) = getfield(r, :ref)


for (F,f) in ((:M,:m), (:S,:s))
    SR = Symbol(:Step, F, :RangeLen)
    frange = Symbol(f, :range)

    @eval begin
        function Base.:(-)(r::$(SR){T,R,S}) where {T,R,S}
            return $(SR){T,R,S}(-_ref(r), -step(r), length(r), _offset(r))
        end

        function Base.:(+)(r1::$(SR){T,S}, r2::$(SR){T,S}) where {T,S}
            len = length(r1)
            (len == length(r2) ||
                throw(DimensionMismatch("argument dimensions must match")))
            $(SR)(first(r1)+first(r2), step(r1)+step(r2), len)
        end

        function Base.reverse(r::$(SR))
            # If `r` is empty, `length(r) - r.offset + 1 will be nonpositive hence
            # invalid. As `reverse(r)` is also empty, any offset would work so we keep
            # `r.offset`
            offset = isempty(r) ? _offset(r) : length(r) - _offset(r) + 1
            $(SR)(_ref(r), -step(r), length(r), offset)
        end

        function Base.promote_rule(
            ::Type{<:$(SR){T1,R1,S1}},
            ::Type{<:$(SR){T2,R2,S2}}
           ) where {T1,T2,R1,R2,S1,S2}
            return el_same(
                promote_type(T1,T2),
                $(SR){T1,promote_type(R1,R2),promote_type(S1,S2)},
                $(SR){T2,promote_type(R1,R2),promote_type(S1,S2)}
               )
        end

        $(SR){T,R,S}(r::$(SR){T,R,S}) where {T,R,S} = r
        function $(SR){T,R,S}(r::$(SR)) where {T,R,S}
            return $(SR){T,R,S}(
                convert(R, _ref(r)),
                convert(S, step(r)),
                length(r),
                _offset(r)
               )
        end
        function $(SR){T}(r::StepRangeLen) where {T}
            return $(SR)(
                convert(T, _ref(r)),
                convert(T, step(r)),
                length(r),
                _offset(r)
               )
        end

        function Base.promote_rule(
            a::Type{<:$(SR){T,R,S}},
            ::Type{OR}
           ) where {T,R,S,OR<:AbstractRange}
            return promote_rule(a, $(SR){eltype(OR), eltype(OR), eltype(OR)})
        end

        $(SR){T,R,S}(r::AbstractRange) where {T,R,S} =
            $(SR){T,R,S}(R(first(r)), S(step(r)), length(r))
        $(SR){T}(r::AbstractRange) where {T} =
            $(SR)(T(first(r)), T(step(r)), length(r))
        $(SR)(r::AbstractRange) = $(SR){eltype(r)}(r)

        function $(SR)(
            ref::TwicePrecision{T},
            step::TwicePrecision{T},
            len::Integer,
            offset::Integer=1
           ) where {T}
            return $(SR){T,TwicePrecision{T},TwicePrecision{T}}(ref, step, len, offset)
        end
        function Base.getindex(
            r::$(SR){T,<:TwicePrecision,<:TwicePrecision},
            s::OrdinalRange{<:Integer}
           ) where T
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
                return $(SR)(_ref(r), newstep, length(s), max(1,soffset))
            else
                return $(SR)(_ref(r) + (ioffset-_offset(r))*step_hp(r), newstep, length(s), max(1,soffset))
            end
        end

        function Base.:(*)(x::Real, r::$(SR){<:Real,<:TwicePrecision})
            return $(SR)(x * _ref(r), Base.twiceprecision(x * step(r), Base.nbitslen(r)), length(r), _offset(r))
        end
        Base.:(*)(r::$(SR){<:Real,<:TwicePrecision}, x::Real) = x*r
        function Base.:(/)(r::$(SR){<:Real,<:TwicePrecision}, x::Real)
            return $(SR)(_ref(r)/x, Base.twiceprecision(step(r)/x, Base.nbitslen(r)), length(r), _offset(r))
        end

        $(SR){T,R,S}(r::$(SR){T,R,S}) where {T<:AbstractFloat,R<:TwicePrecision,S<:TwicePrecision} = r
        function $(SR)(ref::R, step::S, len::Integer, offset::Integer = 1) where {R,S}
            return $(SR){typeof(ref+0*step),R,S}(ref, step, len, offset)
        end
        function $(SR){T}(ref::R, step::S, len::Integer, offset::Integer = 1) where {T,R,S}
            return $(SR){T,R,S}(ref, step, len, offset)
        end

        function $(SR){T,R,S}(r::$(SR)) where {T<:AbstractFloat,R<:TwicePrecision,S<:TwicePrecision}
            return _convertSRL($(SR){T,R,S}, r)
        end

        function (::Type{<:$(SR){Float64}})(r::$(SR))
            return _convertSRL($(SR){Float64,TwicePrecision{Float64},TwicePrecision{Float64}}, r)
        end
        function $(SR){T}(r::$(SR)) where {T<:IEEEFloat}
            return _convertSRL($(SR){T,Float64,Float64}, r)
        end

        function (::Type{<:$(SR){Float64}})(r::AbstractRange)
            return _convertSRL($(SR){Float64,TwicePrecision{Float64},TwicePrecision{Float64}}, r)
        end
        function $(SR){T}(r::AbstractRange) where {T<:IEEEFloat}
            return _convertSRL($(SR){T,Float64,Float64}, r)
        end

        function _convertSRL(::Type{<:$(SR){T,R,S}}, r::$(SR){<:Integer}) where {T,R,S}
            return $(SR){T,R,S}(R(_ref(r)), S(step(r)), length(r), _offset(r))
        end

        function _convertSRL(::Type{<:$(SR){T,R,S}}, r::AbstractRange{<:Integer}) where {T,R,S}
            return $(SR){T,R,S}(R(first(r)), S(step(r)), length(r))
        end

        function _convertSRL(::Type{<:$(SR){T,R,S}}, r::AbstractRange{U}) where {T,R,S,U}
            # if start and step have a rational approximation in the old type,
            # then we transfer that rational approximation to the new type
            f, s = first(r), step(r)
            start_n, start_d = rat(f)
            step_n, step_d = rat(s)
            if start_d != 0 && step_d != 0 &&
                    U(start_n/start_d) == f && U(step_n/step_d) == s
                den = lcm(start_d, step_d)
                m = maxintfloat(T, Int)
                if den != 0 && abs(f*den) <= m && abs(s*den) <= m &&
                        rem(den, start_d) == 0 && rem(den, step_d) == 0
                    start_n = round(Int, f*den)
                    step_n = round(Int, s*den)
                    return floatrange(T, start_n, step_n, length(r), den)
                end
            end
            __convertSRL($(SR){T,R,S}, r)
        end

        function __convertSRL(::Type{<:$(SR){T,R,S}}, r::$(SR){U}) where {T,R,S,U}
            return $(SR){T,R,S}(R(_ref(r)), S(step(r)), length(r), _offset(r))
        end
        function __convertSRL(::Type{<:$(SR){T,R,S}}, r::AbstractRange{U}) where {T,R,S,U}
            return $(SR){T,R,S}(R(first(r)), S(step(r)), length(r))
        end

        function Base.:(+)(r1::$(SR){T,R}, r2::$(SR){T,R}) where T where R<:TwicePrecision
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
            step = twiceprecision(step(r1) + step(r2), nbitslen(T, len, imid))
            return $(SR){T,typeof(ref),typeof(step)}(ref, step, len, imid)
        end
    end
end
