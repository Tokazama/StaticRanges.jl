"""
    AbstractStepRangeLen
"""
abstract type AbstractStepRangeLen{T,R,S} <: AbstractRange{T} end

function StepRangeLen{T}(r::AbstractStepRangeLen) where {T}
    return StepRangeLen{T}(r.ref, r.step, length(r), r.offset)
end

function StepRangeLen{T,R,S}(r::AbstractStepRangeLen) where {T,R,S}
    return StepRangeLen{T,R,S}(convert(R, r.ref), convert(S, r.step), length(r), r.offset)
end
Base.:(-)(r1::AbstractStepRangeLen, r2::AbstractRange) = -(promote(r1, r2)...)
Base.:(-)(r1::AbstractRange, r2::AbstractStepRangeLen) = -(promote(r1, r2)...)
Base.:(-)(r1::AbstractStepRangeLen, r2::AbstractStepRangeLen) = -(promote(r1, r2)...)

Base.first(r::AbstractStepRangeLen) = unsafe_getindex(r, 1)
Base.last(r::AbstractStepRangeLen) = unsafe_getindex(r, length(r))

function _getindex_hiprec(r::AbstractStepRangeLen, i::Integer)  # without rounding by T
    u = i - _offset(r)
    return _ref(r) + u * step(r)
end

function _getindex_hiprec(
    r::AbstractStepRangeLen{<:Any,<:TwicePrecision,<:TwicePrecision},
    i::Integer
   )
    u = i - _offset(r)
    shift_hi, shift_lo = u * step_hp(r).hi, u * step_hp(r).lo
    x_hi, x_lo = add12(_ref(r).hi, shift_hi)
    x_hi, x_lo = add12(x_hi, x_lo + (shift_lo + _ref(r).lo))
    return TwicePrecision(x_hi, x_lo)
end

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

function Base.show(io::IO, r::AbstractStepRangeLen)
    print(io, typeof(r).name, "(", first(r), ":", step(r), ":", last(r), ")")
end


Base.nbitslen(r::AbstractStepRangeLen) = nbitslen(eltype(r), length(r), r.offset)


function Base.reverse(r::AbstractStepRangeLen)
    # If `r` is empty, `length(r) - r.offset + 1 will be nonpositive hence
    # invalid. As `reverse(r)` is also empty, any offset would work so we keep
    # `r.offset`
    offset = isempty(r) ? _offset(r) : length(r) - _offset(r) + 1
    return similar_type(r)(_ref(r), -step(r), length(r), offset)
end


"""
    StepSRangeLen
"""
struct StepSRangeLen{T,Tr,Ts,R,S,L,F} <: AbstractStepRangeLen{T,R,S} end

function StepSRangeLen{T,R,S}(ref::R, step::S, len::Integer, offset::Integer = 1) where {T,R,S}
    len >= 0 || throw(ArgumentError("length cannot be negative, got $len"))
    1 <= offset <= max(1,len) || throw(ArgumentError("StepSRangeLen: offset must be in [1,$len], got $offset"))
    return StepSRangeLen{T,R,S,tp2val(ref),tp2val(step),len,offset}()
end

function StepSRangeLen{T,R1,S1}(ref::R2, step::S2, len::Integer, offset::Integer) where {T,R1,S1,R2,S2}
    return StepSRangeLen{T,R1,S1}(R1(ref), S1(step), len, offset)
end

function (::Type{StepSRangeLen{Float64}})(r::AbstractRange)
    return _convertSSRL(StepSRangeLen{Float64,TwicePrecision{Float64},TwicePrecision{Float64}}, r)
end

function Base.getproperty(r::StepSRangeLen, s::Symbol)
    if s === :ref
        return _ref(r)
    elseif s === :step
        return step_hp(r)
    elseif s === :len
        return length(r)
    elseif s === :offset
        return _offset(r)
    else
        error("type $(typeof(r)) has no property $s")
    end
end

# convert TPVal to TwicePrecision
Base.step_hp(::StepSRangeLen{T,Tr,Ts,R,S}) where {T,Tr,Ts<:TwicePrecision,R,S} = convert(Ts, S)
_ref(::StepSRangeLen{T,Tr,Ts,R,S,L,F}) where {T,Tr<:TwicePrecision,Ts,R,S,L,F} = convert(Tr, R)

Base.step(::StepSRangeLen{T,Tr,Ts,R,S,L,F}) where {T,Tr,Ts,R,S,L,F} = convert(T, S)
Base.length(::StepSRangeLen{T,Tr,Ts,R,S,L,F}) where {T,Tr,Ts,R,S,L,F} = L
_offset(::StepSRangeLen{T,Tr,Ts,R,S,L,F}) where {T,Tr,Ts,R,S,L,F} = F
_ref(::StepSRangeLen{T,Tr,Ts,R,S,L,F}) where {T,Tr,Ts,R,S,L,F} = R

"""
    StepMRangeLen
"""
mutable struct StepMRangeLen{T,R,S} <: AbstractStepRangeLen{T,R,S}
    ref::R
    step::S
    len::Int
    offset::Int

    function StepMRangeLen{T,R,S}(ref::R, step::S, len::Integer, offset::Integer = 1) where {T,R,S}
        len >= 0 || throw(ArgumentError("length cannot be negative, got $len"))
        1 <= offset <= max(1,len) || throw(ArgumentError("StepMRangeLen: offset must be in [1,$len], got $offset"))
        return new(ref, step, len, offset)
    end
end

function (::Type{StepMRangeLen{Float64}})(r::AbstractRange)
    return _convertSMRL(StepMRangeLen{Float64,TwicePrecision{Float64},TwicePrecision{Float64}}, r)
end
function StepMRangeLen{T,R1,S1}(ref::R2, step::S2, len::Integer, offset::Integer) where {T,R1,S1,R2,S2}
    return StepMRangeLen{T,R1,S1}(R1(ref), S1(step), len, offset)
end

Base.step_hp(r::StepMRangeLen) = getfield(r, :step)
Base.step(r::StepMRangeLen{T}) where {T} = T(step_hp(r))
Base.length(r::StepMRangeLen) = getfield(r, :len)
_offset(r::StepMRangeLen) = getfield(r, :offset)
_ref(r::StepMRangeLen) = getfield(r, :ref)

Base.:(+)(r1::AbstractStepRangeLen, r2::AbstractRange) = _add(r1, r2)
Base.:(+)(r1::AbstractRange, r2::AbstractStepRangeLen) = _add(r1, r2)
Base.:(+)(r1::AbstractStepRangeLen, r2::AbstractStepRangeLen) = _add(r1, r2)

Base.:(*)(r::AbstractStepRangeLen{T,TwicePrecision{T}}, x::Real) where {T<:Real} = x*r
function Base.:(*)(x::Real, r::StepMRangeLen{T,TwicePrecision{T}}) where {T<:Real}
    return StepMRangeLen(x * _ref(r), Base.twiceprecision(x * step(r), nbitslen(r)), length(r), _offset(r))
end
function Base.:(*)(x::Real, r::StepSRangeLen{T,TwicePrecision{T}}) where {T<:Real}
    return StepSRangeLen(x * _ref(r), Base.twiceprecision(x * step(r), nbitslen(r)), length(r), _offset(r))
end

function Base.:(/)(r::StepMRangeLen{T,TwicePrecision{T}}, x::Real) where {T<:Real}
    return StepMRangeLen(_ref(r)/x, Base.twiceprecision(step(r)/x, Base.nbitslen(r)), length(r), _offset(r))
end
function Base.:(/)(r::StepSRangeLen{T,TwicePrecision{T}}, x::Real) where {T<:Real}
    return StepSRangeLen(_ref(r)/x, Base.twiceprecision(step(r)/x, Base.nbitslen(r)), length(r), _offset(r))
end

#=
function Base.:(+)(r1::StepMRangeLen, r2::StepMRangeLen)
    return StepMRangeLen(first(r1)+first(r2), step(r1)+step(r2), len)
end

  MethodError: no method matching StepMRangeLen{Float32,Float64,Float64}(::Float64, ::Float32, ::Int64, ::Int64)

function Base.:(+)(r1::StepMRangeLen, r2::StepMRangeLen)
    return StepMRangeLen(first(r1)+first(r2), step(r1)+step(r2), len)
end
=#


for (F,f) in ((:M,:m), (:S,:s))
    SR = Symbol(:Step, F, :RangeLen)
    frange = Symbol(f, :range)
    CSRL = Symbol(:_convert, :S, F, :RL)
    _CSRL = Symbol(:__convert, :S, F, :RL)
    floatfrange = Symbol(:float, f, :range)
    @eval begin
        function Base.:(-)(r::$(SR){T,R,S}) where {T,R,S}
            return $(SR){T,R,S}(-_ref(r), -step(r), length(r), _offset(r))
        end

        Base.:(-)(r1::$(SR){T,R,S}, r2::$(SR){T,R,S}) where {T,R,S} = +(r1, -r2)



        #=
r1 = StepSRangeLen{Float64,Base.TwicePrecision{Float64},Base.TwicePrecision{Float64},StaticRanges.TPVal{Float64,1.0,0.0}(),StaticRanges.TPVal{Float64,0.09999999999999964,3.552713678800501e-16}(),11,1}
r2 = StepSRange{Int64,Int64,1,2,21}
        =#

        $(SR){T,R,S}(r::$(SR){T,R,S}) where {T,R,S} = r
        function $(SR){T,R,S}(r::$(SR)) where {T,R,S}
            return $(SR){T,R,S}(
                convert(R, _ref(r)),
                convert(S, step(r)),
                length(r),
                _offset(r)
               )
        end
        function $(SR){T}(r::Union{StepRangeLen,AbstractStepRangeLen}) where {T}
            return $(SR)(
                convert(T, _ref(r)),
                convert(T, step(r)),
                length(r),
                _offset(r)
               )
        end

        $(SR){T,R,S}(r::AbstractRange) where {T,R,S} = $(SR){T,R,S}(R(first(r)), S(step(r)), length(r))
        $(SR){T}(r::AbstractRange) where {T} = $(SR)(T(first(r)), T(step(r)), length(r))
        $(SR)(r::AbstractRange) = $(SR){eltype(r)}(r)

        function $(SR)(
            ref::TwicePrecision{T},
            step::TwicePrecision{T},
            len::Integer,
            offset::Integer=1
           ) where {T}
            return $(SR){T,TwicePrecision{T},TwicePrecision{T}}(ref, step, len, offset)
        end

        $(SR){T,R,S}(r::$(SR){T,R,S}) where {T<:AbstractFloat,R<:TwicePrecision,S<:TwicePrecision} = r
        function $(SR)(ref::R, step::S, len::Integer, offset::Integer = 1) where {R,S}
            return $(SR){typeof(ref+0*step),R,S}(ref, step, len, offset)
        end
        function $(SR){T}(ref::R, step::S, len::Integer, offset::Integer = 1) where {T,R,S}
            return $(SR){T,R,S}(ref, step, len, offset)
        end

        function $(SR){T,R,S}(r::$(SR)) where {T<:AbstractFloat,R<:TwicePrecision,S<:TwicePrecision}
            return $(CSRL)($(SR){T,R,S}, r)
        end

        function (::Type{<:$(SR){Float64}})(r::$(SR))
            return $(CSRL)($(SR){Float64,TwicePrecision{Float64},TwicePrecision{Float64}}, r)
        end
        function $(SR){T}(r::$(SR)) where {T<:IEEEFloat}
            return $(CSRL)($(SR){T,Float64,Float64}, r)
        end


        function $(SR){T}(r::AbstractRange) where {T<:IEEEFloat}
            return $(CSRL)($(SR){T,Float64,Float64}, r)
        end

        function $(CSRL)(::Type{<:$(SR){T,R,S}}, r::$(SR){<:Integer}) where {T,R,S}
            return $(SR){T,R,S}(R(_ref(r)), S(step(r)), length(r), _offset(r))
        end

        function $(CSRL)(::Type{<:$(SR){T,R,S}}, r::AbstractRange{<:Integer}) where {T,R,S}
            return $(SR){T,R,S}(R(first(r)), S(step(r)), length(r))
        end

        function $(CSRL)(::Type{<:$(SR){T,R,S}}, r::AbstractRange{U}) where {T,R,S,U}
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
                    return $(floatfrange)(T, start_n, step_n, length(r), den)
                end
            end
            return $(_CSRL)($(SR){T,R,S}, r)
        end

        function $(_CSRL)(::Type{<:$(SR){T,R,S}}, r::$(SR){U}) where {T,R,S,U}
            return $(SR){T,R,S}(R(_ref(r)), S(step(r)), length(r), _offset(r))
        end
        function $(_CSRL)(::Type{<:$(SR){T,R,S}}, r::AbstractRange{U}) where {T,R,S,U}
            return $(SR){T,R,S}(R(first(r)), S(step(r)), length(r))
        end
   end
end

