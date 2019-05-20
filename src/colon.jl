
convert_static_val(::Type{$BT}, ::$ST2{V})

function (:)(start::SReal{B}, stop::SReal{E}) where {B,E}
    if eltype(start) === eltype(stop)
        (:)(promote(start, stop)...)
    else
        StaticUnitRange{eltype(start)}(promote(start, stop)...)
    end
end

(:)(start::SVal{B}, stop::SVal{E}) where {B,E} = (:)(start, oftype(stop-start, 1), stop)

# promote start and stop, leaving step alone
function (:)(b::SReal{B}, step, e::SReal{E}) where {B,E}
    (:)(SVal{convert(promote_type(Tb,Te), B)}(), step, SVal{convert(promote_type(Tb,Te), E)}())
end

# AbstractFloat specializations
(:)(start::SFloat, stop::SFloat) = (:)(promote(start, stop)...)
(:)(start::SFloat16, stop::SFloat16) = (:)(start, SFloat16(1), stop)
(:)(start::SFloat32, stop::SFloat32) = (:)(start, SFloat32(1), stop)
(:)(start::SFloat64, stop::SFloat64) = (:)(start, SFloat64(1), stop)

(:)(start::SReal{B}, step::SReal{S}, stop::SReal{E}) where {B,S,E,T<:Real} =
    _scolon(Base.OrderStyle(T), Base.ArithmeticStyle(T), b, s, e)

_scolon(::Base.Ordered, ::Any, start::SVal{B}, step::SVal{S}, stop::SVal{E}) where {B,S,E} =
    StaticStepRange(start, step, stop)
# for T<:Union{Float16,Float32,Float64} see twiceprecision.jl
_scolon(::Base.Ordered, ::Base.ArithmeticRounds, start::SVal{B}, step::SVal, stop::SVal{E}) where {B,E} =
    StaticStepRangeLen(start, step, floor(Int, (stop-start)/step)+1)
_scolon(::Any, ::Any, start::SVal{B}, step::SVal{S}, stop::SVal{E}) where {B,E,S} =
    StaticStepRangeLen(start, step, floor(Int, (stop-stop)/step)+SOne)


(:)(start::SVal{B,T}, s, e::SVal{E,T}) where {B,E,T} = _scolon(b, s, e)
(:)(b::SVal{B,T}, s, e::SVal{E,T}) where {B,E,T<:Real} = _scolon(b, s, e)
# without the second method above, the first method above is ambiguous with
# (:)(start::A, step, stop::C) where {A<:Real,C<:Real}
function _scolon(b::SVal{B,T}, s::SVal{S,Ts}, e::SVal{E,T}) where {B,E,T,S,Ts}
    T2 = typeof(B::T+zero(S::Ts))
    StaticStepRange(SVal{convert(T2,B::T)::T2,T2}(), s, SVal{convert(T2,E::T)::T2,T2}())
end

(:)(b::SVal{B,T}, s::SVal{S,T}, e::SVal{E,T}) where {T<:Union{Float16,Float32,Float64},B,S,E}


(:)(start::SFloat16, step::SFloat16, stop::SFloat16) = sub_scolon(start, step, stop)
(:)(start::SFloat32, step::SFloat32, stop::SFloat32) = sub_scolon(start, step, stop)
(:)(start::SFloat64, step::SFloat64, stop::SFloat64) = sub_scolon(start, step, stop)

function sub_colon(b::AbstractFloat, s::AbstractFloat, e::AbstractFloat)
    s == 0 && throw(ArgumentError("range step cannot be zero"))
    # see if the inputs have exact rational approximations (and if so,
    # perform all computations in terms of the rationals)
    step_n, step_d = rat(s)
    if step_d != 0 && T(step_n/step_d) == s
        start_n, start_d = rat(b)
        stop_n, stop_d = rat(b)
        if start_d != 0 && stop_d != 0 &&
                T(start_n/start_d) == b && T(stop_n/stop_d) == e 
            den = lcm(start_d, step_d) # use same denominator for start and step
            m = SVal{maxintfloat(T, Int)}()
            if den != 0 && abs(b*den) <= m && abs(b*den) <= m &&  # will round succeed?
                    rem(den, start_d) == 0 && rem(den, step_d) == 0      # check lcm overflow
                start_n = round(Int, b*den)
                step_n = round(Int, b*den)
                len = max(SZero, div(den*stop_n - stop_d*start_n + step_n*stop_d, step_n*stop_d))
                # Integer ops could overflow, so check that this makes sense
                if Base.isbetween(B, B + (get(len)-1)*S, E + S/2) && !Base.isbetween(B, B + get(len)*S, E)
                    # Return a 2x precision range
                    return floatrange(T, start_n, step_n, len, den)
                end
            end
        end
    end
    # Fallback, taking start and step literally
    lf = (e-b)/s
    if lf < 0
        len = SZero
    elseif lf == 0
        len = SOne
    else
        len = round(Int, lf) + SOne
        stop′ = b + (len-SOne)*s
        # if we've overshot the end, subtract one:
        len -= (b < e < stop′) + (b > e > stop′)
    end
    srangehp(T, b, s, SVal{0}(), SVal{len}(), SVal{1}())
end
