(:)(a::SReal, b::SReal) = (:)(promote(a,b)...)

(:)(start::SVal{B,T}, stop::SVal{E,T}) where {B,E,T<:Real} = unitrange(T, start, stop)

(:)(start::SVal{B,T}, stop::SVal{E,T}) where {B,E,T} = (:)(start, oftype(stop-start, 1), stop)

# promote start and stop, leaving step alone
(:)(b::SVal{B,Tb}, step, e::SVal{E,Te}) where {B,E,Tb<:Real,Te<:Real} =
    (:)(SVal{convert(promote_type(Tb,Te), B)}(), step,
        SVal{convert(promote_type(Tb,Te), E)}())

# AbstractFloat specializations
(:)(b::SVal{B,T}, e::SVal{E,T}) where {B,E,T<:AbstractFloat} = (:)(b, SVal{T(1)}(), e)

(:)(b::SVal{B,T}, s::SFloat{S}, e::SVal{E,T}) where {B,S,E,T<:Real} = (:)(promote(b,s,e)...)
(:)(b::SVal{B,T}, s::SFloat{S}, e::SVal{E,T}) where {B,S,E,T<:AbstractFloat} = (:)(promote(b,s,e)...)
(:)(b::SVal{B,T}, s::SReal{S}, e::SVal{E,T}) where {B,S,E,T<:AbstractFloat} = (:)(promote(b,s,e)...)

(:)(b::SVal{B,T}, s::SVal{S,T}, e::SVal{E,T}) where {B,S,E,T<:AbstractFloat} =
    _scolon(Base.OrderStyle(T), Base.ArithmeticStyle(T), b, s, e)
(:)(b::SVal{B,T}, s::SVal{S,T}, e::SVal{E,T}) where {B,S,E,T<:Real} =
    _scolon(Base.OrderStyle(T), Base.ArithmeticStyle(T), b, s, e)
_scolon(::Base.Ordered, ::Any, b::SVal{B,T}, s::SVal, e::SVal{B,E}) where {B,E,T} = steprange(b, s, e)
# for T<:Union{Float16,Float32,Float64} see twiceprecision.jl
_scolon(::Base.Ordered, ::Base.ArithmeticRounds, b::SVal{B,T}, s::SVal, e::SVal{E,T}) where {B,E,T} =
    steprangelen(b, s, floor(Int, (e-b)/s)+1)
_scolon(::Any, ::Any, b::SVal{B,T}, s::SVal, e::SVal{E,T}) where {B,E,T} =
    steprangelen(b, s, floor(Int, (e-b)/s)+1)


(:)(b::SVal{B,T}, s, e::SVal{E,T}) where {B,E,T} = _scolon(b, s, e)
(:)(b::SVal{B,T}, s, e::SVal{E,T}) where {B,E,T<:Real} = _scolon(b, s, e)
# without the second method above, the first method above is ambiguous with
# (:)(start::A, step, stop::C) where {A<:Real,C<:Real}
function _scolon(b::SVal{B,T}, s, e::SVal{E,T}) where {B,E,T}
    T′ = typeof(b+zero(s))
    steprange(convert(T′,b), s, convert(T′,e))
end

function (:)(b::SVal{B,T}, s::SVal{S,T}, e::SVal{E,T}) where {T<:Union{Float16,Float32,Float64},B,S,E}
    S == 0 && throw(ArgumentError("range step cannot be zero"))
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
                len = max(0, div(den*stop_n - stop_d*start_n + step_n*stop_d, step_n*stop_d))
                # Integer ops could overflow, so check that this makes sense
                if Base.isbetween(B, B + (get(len)-1)*S, E + S/2) && !Base.isbetween(B, B + get(len)*S, E)
                    # Return a 2x precision range
                    return floatrange(T, SVal{start_n}(), SVal{step_n}(), SVal{len}(), SVal{den}())
                end
            end
        end
    end
    # Fallback, taking start and step literally
    lf = (E-B)/S
    if lf < 0
        len = 0
    elseif lf == 0
        len = 1
    else
        len = round(Int, lf) + 1
        stop′ = B + (len-1)*S
        # if we've overshot the end, subtract one:
        len -= (B < E < stop′) + (B > E > stop′)
    end
    srangehp(T, b, s, SVal{0}(), SVal{len}(), SVal{1}())
end
