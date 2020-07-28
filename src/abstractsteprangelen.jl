
"""
    gethi(x:: TwicePrecision{T}) -> T

Returns the `hi` component of a twice precision number.
"""
gethi(x::TwicePrecision) = getfield(x, :hi)

"""
    getlo(x::TwicePrecision{T}) -> T

Returns the `lo` component of a twice precision number.
"""
getlo(x::TwicePrecision) = getfield(x, :lo)

"""
    AbstractStepRangeLen

Supertype for `StepSRangeLen` and `StepMRangeLen`. It's subtypes should behave
identically to `StepRangeLen`.
"""
abstract type AbstractStepRangeLen{T,R,S} <: AbstractRange{T} end

function Base.StepRangeLen{T,R,S}(r::AbstractStepRangeLen) where {T,R,S}
    return StepRangeLen{T,R,S}(convert(R, r.ref), convert(S, r.step), length(r), r.offset)
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
struct StepSRangeLen{T,Tr,Ts,R,S,L,F} <: AbstractStepRangeLen{T,R,S}

    function StepSRangeLen{T,R,S}(ref::R, step::S, len::Integer, offset::Integer = 1) where {T,R,S}
        len >= 0 || throw(ArgumentError("length cannot be negative, got $len"))
        1 <= offset <= max(1,len) || throw(ArgumentError("StepSRangeLen: offset must be in [1,$len], got $offset"))
        return new{T,R,S,ref,step,len,offset}()
    end
    function StepSRangeLen{T,Tr,Ts,R,S,L,F}(ref, step, len::Integer, offset::Integer = 1) where {T,Tr,Ts,R,S,L,F}
        return StepSRangeLen{T,Tr,Ts}(ref, step, len, offset)
    end
end

function Base.getproperty(r::StepSRangeLen{T,Tr,Ts,R,S,L,F}, s::Symbol) where {T,Tr,Ts,R,S,L,F}
    if s === :ref
        return R
    elseif s === :step
        return S
    elseif s === :len
        return L
    elseif s === :offset
        return F
    else
        error("type $(typeof(r)) has no property $s")
    end
end

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

function Base.setproperty!(r::StepMRangeLen{T,R,S}, s::Symbol, val) where {T,R,S}
    if s === :ref
        return setfield!(r, s, val)  # TODO Get rid of this. no one should be changing this
    elseif s === :step
        return set_step!(r, val)
    elseif s === :len
        return set_length!(r, val)
    elseif s === :offset
        return set_offset!(r, val)
    else
        error("type $(typeof(r)) has no property $s")
    end
end

const StepRangeLenUnion{T,R,S} = Union{StepRangeLen{T,R,S},AbstractStepRangeLen{T,R,S}}


for (F,f) in ((:M,:m), (:S,:s))
    SR = Symbol(:Step, F, :RangeLen)
    frange = Symbol(f, :range)
    CSRL = Symbol(:_convert, :S, F, :RL)
    _CSRL = Symbol(:__convert, :S, F, :RL)
    floatfrange = Symbol(:float, f, :range)
    @eval begin

        function $(SR){T,R1,S1}(ref::R2, step::S2, len::Integer, offset::Integer) where {T,R1,S1,R2,S2}
            return $(SR){T,R1,S1}(R1(ref), S1(step), len, offset)
        end

        # This is one big function b/c it results in ambiguities otherwise
        @inline function $(SR){T}(r::AbstractRange) where {T}
            if T <: AbstractFloat
                if r isa StepRangeLenUnion && T <: Float64
                    return $(CSRL)($(SR){Float64,TwicePrecision{Float64},TwicePrecision{Float64}}, r)
                else
                    return $(CSRL)($(SR){T,Float64,Float64}, r)
                end
            else
                if r isa StepRangeLenUnion
                    return $(SR)(T(r.ref), T(r.step), r.len, r.offset)
                else
                    return $(SR)(T(first(r)), T(step(r)), length(r))
                end
            end
        end

        function $(SR){T,R,S}(r::AbstractRange{T2}) where {T,R,S,T2}
            if r isa StepRangeLenUnion
                if T2 <: T && (r.step isa R) && (r.ref isa R) && (r isa $SR)
                    return copy(r)
                elseif T2 <: AbstractFloat && R <: TwicePrecision && S <: TwicePrecision
                    return $(CSRL)($(SR){T,R,S}, r)
                else
                    return $(SR){T,R,S}(convert(R, r.ref), convert(S, r.step), length(r), r.offset)
                end
            else
                return $(SR){T,R,S}(R(first(r)), S(step(r)), length(r))
            end
        end

        $(SR)(r::AbstractRange) = $(SR){eltype(r)}(r)
        function $(SR)(ref::TwicePrecision{T}, step::TwicePrecision{T}, len::Integer, offset::Integer=1) where {T}
            return $(SR){T,TwicePrecision{T},TwicePrecision{T}}(ref, step, len, offset)
        end

        function $(SR)(ref::R, step::S, len::Integer, offset::Integer = 1) where {R,S}
            return $(SR){typeof(ref+0*step),R,S}(ref, step, len, offset)
        end
        function $(SR){T}(ref::R, step::S, len::Integer, offset::Integer = 1) where {T,R,S}
            return $(SR){T,R,S}(ref, step, len, offset)
        end

        function $(CSRL)(::Type{<:$(SR){T,R,S}}, r::$(SR){<:Integer}) where {T,R,S}
            return $(SR){T,R,S}(R(r.ref), S(step(r)), length(r), r.offset)
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
            return $(SR){T,R,S}(R(r.ref), S(step(r)), length(r), r.offset)
        end
        function $(_CSRL)(::Type{<:$(SR){T,R,S}}, r::AbstractRange{U}) where {T,R,S,U}
            return $(SR){T,R,S}(R(first(r)), S(step(r)), length(r))
        end
   end
end

#=
StepSRangeLen{Float16,R,S}(r::AbstractRange) = _convertSSRL(StepSRangeLen{Float16,Float64,Float64}, r)
StepSRangeLen{Float32,R,S}(r::AbstractRange) = _convertSSRL(StepSRangeLen{Float32,Float64,Float64}, r)
StepSRangeLen{Float64,R,S}(r::AbstractRange) = _convertSSRL(StepSRangeLen{Float64,TwicePrecision{Float64},TwicePrecision{Float64}}, r)
StepSRangeLen{Float64,R,S}(r::StepRangeLenUnion) = _convertSSRL(StepSRangeLen{Float64,TwicePrecision{Float64},TwicePrecision{Float64}}, r)

StepMRangeLen{Float16,R,S}(r::AbstractRange) = _convertSMRL(StepMRangeLen{Float16,Float64,Float64}, r)
StepMRangeLen{Float32,R,S}(r::AbstractRange) = _convertSMRL(StepMRangeLen{Float32,Float64,Float64}, r)
StepMRangeLen{Float64,R,S}(r::AbstractRange) = _convertSMRL(StepMRangeLen{Float64,TwicePrecision{Float64},TwicePrecision{Float64}}, r)
StepMRangeLen{Float64,R,S}(r::StepRangeLenUnion) = _convertSMRL(StepMRangeLen{Float64,TwicePrecision{Float64},TwicePrecision{Float64}}, r)
=#
###
### Constructors
###
#=
function StepMRangeLen{T,R,S}(r::StepRangeLenUnion{T,R,S}) where {T<:AbstractFloat,R<:TwicePrecision,S<:TwicePrecision}
    if is_dynamic()
    else
    end
end

function StepMRangeLen{T,R,S}(r::StepRangeLenUnion{T,R,S}) where {T,R,S}
    if is_dynamic(r)
        return r
    else
        return StepMRangeLen(r.ref, r.step, r.len, r.offset)
    end
end

function StepSRangeLen{T,R,S}(r::StepRangeLenUnion{T,R,S}) where {T,R,S}
    if is_static(r)
        return r
    else
        return StepSRangeLen(r.ref, r.step, r.len, r.offset)
    end
end

function StepMRangeLen{T,R,S}(r::StepRangeLenUnion) where {T,R,S}
    return StepMRangeLen{T,R,S}(R(r.ref), S(r.step), r.len, r.offset)
end

function StepSRangeLen{T,R,S}(r::StepRangeLenUnion) where {T,R,S}
    return StepSRangeLen{T,R,S}(R(r.ref), S(r.step), r.len, r.offset)
end


function StepMRangeLen{T,R,S}(r::AbstractRange) where {T,R,S}
end

StepRangeLen{T,R,S}(r::StepRangeLen{T,R,S}) where {T,R,S} = r
StepRangeLen{T,R,S}(r::StepRangeLen) where {T,R,S} = StepRangeLen{T,R,S}(convert(R, r.ref), convert(S, r.step), length(r), r.offset)

StepRangeLen{T,R,S}(r::StepRangeLen{T,R,S}) where {T<:AbstractFloat,R<:TwicePrecision,S<:TwicePrecision} = r
StepRangeLen{T,R,S}(r::StepRangeLen) where {T<:AbstractFloat,R<:TwicePrecision,S<:TwicePrecision} =
=#

RangeInterface.step_type(::Type{<:StepSRangeLen{T,R,S}}) where {T,R,S} = S
RangeInterface.step_type(::Type{StepMRangeLen{T,R,S}}) where {T,R,S} = S

RangeInterface.has_len_field(::Type{T}) where {T<:StepSRangeLen} = true
RangeInterface.has_len_field(::Type{T}) where {T<:StepMRangeLen} = true

RangeInterface.has_ref_field(::Type{T}) where {T<:StepSRangeLen} = true
RangeInterface.has_ref_field(::Type{T}) where {T<:StepMRangeLen} = true

RangeInterface.has_step_field(::Type{T}) where {T<:StepSRangeLen} = true
RangeInterface.has_step_field(::Type{T}) where {T<:StepMRangeLen} = true

RangeInterface.has_offset_field(::Type{T}) where {T<:StepSRangeLen} = true
RangeInterface.has_offset_field(::Type{T}) where {T<:StepMRangeLen} = true

RangeInterface.known_offset(::Type{StepSRangeLen{T,Tr,Ts,R,S,L,F}}) where {T,Tr,Ts,R,S,L,F} = F
RangeInterface.known_ref(::Type{StepSRangeLen{T,Tr,Ts,R,S,L,F}}) where {T,Tr,Ts,R,S,L,F} = R
RangeInterface.known_step(::Type{StepSRangeLen{T,Tr,Ts,R,S,L,F}}) where {T,Tr,Ts,R,S,L,F} = S
RangeInterface.known_len(::Type{StepSRangeLen{T,Tr,Ts,R,S,L,F}}) where {T,Tr,Ts,R,S,L,F} = L

Base.length(x::StepSRangeLen) = RangeInterface.get_length(x)
Base.length(x::StepMRangeLen) = RangeInterface.get_length(x)

