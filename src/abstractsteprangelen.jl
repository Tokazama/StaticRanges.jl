"""
    AbstractStepRangeLen

Supertype for `StepSRangeLen` and `StepMRangeLen`. It's subtypes should behave
identically to `StepRangeLen`.
"""
abstract type AbstractStepRangeLen{T,R,S} <: AbstractRange{T} end

function StepRangeLen{T}(r::AbstractStepRangeLen) where {T}
    return StepRangeLen{T}(r.ref, r.step, length(r), r.offset)
end

function StepRangeLen{T,R,S}(r::AbstractStepRangeLen) where {T,R,S}
    return StepRangeLen{T,R,S}(convert(R, r.ref), convert(S, r.step), length(r), r.offset)
end
Base.first(r::AbstractStepRangeLen) = unsafe_getindex(r, 1)
Base.last(r::AbstractStepRangeLen) = unsafe_getindex(r, length(r))


function Base.show(io::IO, r::AbstractStepRangeLen)
    print(io, typeof(r).name, "(", first(r), ":", step(r), ":", last(r), ")")
end

Base.nbitslen(r::AbstractStepRangeLen) = nbitslen(eltype(r), length(r), r.offset)

"""
    StepSRangeLen

A static range `r` where `r[i]` produces values of type `T` (in the second form,
`T` is deduced automatically), parameterized by a `ref`erence value, a `step`,
and the `len`gth. By default `ref` is the starting value `r[1]`, but
alternatively you can supply it as the value of `r[offset]` for some other
index `1 <= offset <= len`. In conjunction with `TwicePrecision` this can be
used to implement ranges that are free of roundoff error.
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
Base.step_hp(::StepSRangeLen{T,Tr,Ts,R,S}) where {T,Tr,Ts,R,S} = S
_ref(::StepSRangeLen{T,Tr,Ts,R,S,L,F}) where {T,Tr<:TwicePrecision,Ts,R,S,L,F} = convert(Tr, R)

Base.step(::StepSRangeLen{T,Tr,Ts,R,S,L,F}) where {T,Tr,Ts,R,S,L,F} = convert(T, S)
Base.length(::StepSRangeLen{T,Tr,Ts,R,S,L,F}) where {T,Tr,Ts,R,S,L,F} = L
_offset(::StepSRangeLen{T,Tr,Ts,R,S,L,F}) where {T,Tr,Ts,R,S,L,F} = F
_ref(::StepSRangeLen{T,Tr,Ts,R,S,L,F}) where {T,Tr,Ts,R,S,L,F} = R

"""
    StepMRangeLen

A mutable range `r` where `r[i]` produces values of type `T` (in the second form,
`T` is deduced automatically), parameterized by a `ref`erence value, a `step`,
and the `len`gth. By default `ref` is the starting value `r[1]`, but
alternatively you can supply it as the value of `r[offset]` for some other
index `1 <= offset <= len`. In conjunction with `TwicePrecision` this can be
used to implement ranges that are free of roundoff error.
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


"stephi(x::AbstractStepRangeLen) - Returns the `hi` component of a twice precision step"
stephi(::StepSRangeLen{T,Tr,Ts,R,S}) where {T,Tr,Ts<:TwicePrecision,R,S} = gethi(S)
stephi(r::StepMRangeLen{T,R,S}) where {T,R,S<:TwicePrecision} = r.step.hi
stephi(r::StepRangeLen{T,R,S}) where {T,R,S<:TwicePrecision} = r.step.hi

"steplo(x::AbstractStepRangeLen) - Returns the `lo` component of a twice precision step"
steplo(::StepSRangeLen{T,Tr,Ts,R,S}) where {T,Tr,Ts<:TwicePrecision,R,S} = getlo(S)
steplo(r::StepMRangeLen{T,R,S}) where {T,R,S<:TwicePrecision} = r.step.lo
steplo(r::StepRangeLen{T,R,S}) where {T,R,S<:TwicePrecision} = r.step.lo

"refhi(x::AbstractStepRangeLen) - Returns the `hi` component of a twice precision ref"
refhi(::StepSRangeLen{T,Tr,Ts,R,S,L,F}) where {T,Tr<:TwicePrecision,Ts,R,S,L,F} = gethi(R)
refhi(r::StepMRangeLen{T,R,S}) where {T,R<:TwicePrecision,S} = r.ref.hi
refhi(r::StepRangeLen{T,R,S}) where {T,R<:TwicePrecision,S} = r.ref.hi

"reflo(x::AbstractStepRangeLen) - Returns the `lo` component of a twice precision ref"
reflo(::StepSRangeLen{T,Tr,Ts,R,S,L,F}) where {T,Tr<:TwicePrecision,Ts,R,S,L,F} = getlo(R)
reflo(r::StepMRangeLen{T,R,S}) where {T,R<:TwicePrecision,S} = r.ref.lo
reflo(r::StepRangeLen{T,R,S}) where {T,R<:TwicePrecision,S} = r.ref.lo

for (F,f) in ((:M,:m), (:S,:s))
    SR = Symbol(:Step, F, :RangeLen)
    frange = Symbol(f, :range)
    CSRL = Symbol(:_convert, :S, F, :RL)
    _CSRL = Symbol(:__convert, :S, F, :RL)
    floatfrange = Symbol(:float, f, :range)
    @eval begin
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
        $(SR){T,R,S}(r::StepRangeLen) where {T,R,S} = $(SR){T,R,S}(R(r.ref), S(r.step), r.len, r.offset)
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
        $(SR){T}(r::$(SR)) where {T<:IEEEFloat} = $(CSRL)($(SR){T,Float64,Float64}, r)


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

