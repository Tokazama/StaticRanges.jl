"""
    srange
"""
srange(start; length=SNothing(), stop=SNothing(), step=SNothing()) =
    _sr(SVal(start), SVal(step), SVal(stop), SVal(length))

srange(start, stop; length=SNothing(), step=SNothing()) =
    _sr(SVal(start), SVal(step), SVal(stop), SVal(length))

srange(start::SVal{B}; stop::SVal{E}=SNothing(), length::SVal{L}=SNothing(), step::SVal{S}=SNothing()) where {B,E,S,F,L} =
    _sr(start, step, stop, length)

srange(start::SVal{B}, stop::SVal{E}; length::SVal{L}=SNothing(), step::SVal{S}=SNothing()) where {B,E,S,F,L} =
    _sr(start, step, stop, length)

srange(r::AbstractRange{T}) where T = srange(SVal(first(r)), stop=SVal(last(r)), length=SVal(length(r)))

srange(r::StepRange{T}) where T = _sr(SVal(first(r)), SVal(step(r)), SVal(last(r)), SNothing())
srange(r::StepRangeLen{T,R,S}) where {T,R<:Real,S<:Real} = steprangelen(T, SVal(first(r)), SVal(step(r)), SVal(length(r)), SVal(r.offset))
srange(r::StepRangeLen{T,R,S}) where {T,R<:TwicePrecision,S<:TwicePrecision} = steprangelen(T, HPSVal(r.ref), HPSVal(r.step), SVal(r.len), SVal(r.offset))
srange(r::AbstractUnitRange{T}) where T = unitrange(T, SVal(first(r)), SVal(last(r)))

_sr(b::SReal{B},       s::SNothing,       e::SNothing,  l::SInteger{L}) where {B,L}   = unitrange(typeof(B), b, SVal{oftype(B, B+L-1)}())
_sr(b::SFloat{B}, s::SNothing,       e::SNothing,  l::SInteger{L}) where {B,L}   = _sr(b, SVal{oftype(B, 1)}(),   e, l)
_sr(b::SFloat{B}, s::SFloat{S}, e::SNothing,  l::SInteger{L}) where {B,S,L} = _sr(promote(b, s)..., e, l)
_sr(b::SReal{B},       s::SFloat{S}, e::SNothing,  l::SInteger{L}) where {B,S,L} = _sr(float(b), s, e, l)
_sr(b::SFloat{B}, s::SReal{S},       e::SNothing,  l::SInteger{L}) where {B,S,L} = _sr(b, float(s), e, l)
_sr(b::SVal{B},        s::SNothing,       e::SNothing,  l::SInteger{L}) where {L,B}   = _sr(b, oftype(B-B, 1), e, l)
_sr(b::SVal{B,T},      s,                 e::SNothing,  l::SInteger{L}) where {T,B,L} = _srangestyle(Base.OrderStyle(T), Base.ArithmeticStyle(T), b, s, e, l)

_sr(b::SVal{B,T},      s::SNothing,       e::SVal{E,T}, l::SInteger{L}) where {T<:Real,B,E,L} = linrange(T, b, e, l)
_sr(b::SVal{B,T},      s::SNothing,       e::SVal{E,T}, l::SInteger{L}) where {T,B,E,L} = linrange(T, b, e, l)
_sr(b::SVal{B,T},      s::SNothing,       e::SVal{E,T}, l::SInteger{L}) where {T<:Integer,B,E,L} = linspace(float(T), b, e, l)



# start:stop
_sr(b::SVal{B,Tb}, s::SNothing,   e::SVal{E,Te}, l::SNothing) where {B,Tb<:Real,E,Te<:Real} = (T = promote_type(Tb,Te); _sr(SVal{T(B)}(), s, SVal{T(E)}(), l))
_sr(b::SVal{B,T},  s::SNothing,   e::SVal{E,T},  l::SNothing) where {B,E,T<:Real} = unitrange(T, b, e)
_sr(b::SVal{B,Tb}, s::SNothing,   e::SVal{E,Te}, l::SNothing) where {B,Tb,E,Te} =  _sr(b, SVal{oftype(E-B, 1)}(), e, l)
_sr(b::SVal{B,T},  s::SNothing,   e::SVal{E,T},  l::SNothing) where {B,E,T<:AbstractFloat} = _sr(b, SVal{T(1)}(), e, l)

# start:step:stop
#_sr(b::SVal{B,Tb}, s::SVal{S,Ts}, e::SVal{E,Te}, l::SNothing) where {B,Tb,S,Ts,E,Te} = _sr(SVal{convert(promote_type(Tb,Te), B)}(), s,  SVal{convert(promote_type(Tb,Te), E)}(), l)
_sr(b::SVal{B,Tb}, s::SVal{S,Ts}, e::SVal{E,Te}, l::SNothing) where {B,Tb,S,Ts,E,Te} = _sr(promote(b, s, e)..., l)
_sr(b::SVal{B,T},  s::SVal{S,T},  e::SVal{E,T},  l::SNothing) where {B,S,E,T<:AbstractFloat} = _srangestyle(Base.OrderStyle(T), Base.ArithmeticStyle(T), b, s, e, l)
_sr(b::SVal{B,T},  s::SVal{S,T},  e::SVal{E,T},  l::SNothing) where {B,S,E,T<:Real} = _srangestyle(Base.OrderStyle(T), Base.ArithmeticStyle(T), b, s, e, l)


# high precision
# twiceprecision.jl line 386
function _sr(b::SVal{B,T}, s::SVal{S,T}, e::SVal{E,T}, l::SNothing) where {T<:Union{Float16,Float32,Float64},B,S,E}
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


function _sr(b::SVal{B,T}, s::SVal{S,T}, e::SNothing, l::SInteger{L}) where {B,S,F,L,T<:Union{Float16,Float32,Float64}}
    start_n, start_d = rat(b)
    step_n, step_d = rat(s)
    if start_d != 0 && step_d != 0 && T(start_n/start_d) == b && T(step_n/step_d) == s
        den = lcm(start_d, step_d)
        m = maxintfloat(T, Int)
        if abs(den*b) <= m && abs(den*s) <= m && rem(den, start_d) == 0 && rem(den, step_d) == 0
            start_n = round(Int, den*b)
            step_n = round(Int, den*s)
            return floatrange(T, SVal{start_n}(), SVal{step_n}(), l, SVal{den}())
        end
    end
    srangehp(T, b, s, SVal{0}(), l, SVal{1}())
end
#=

  b = SVal(1.0f0)
  s = SVal(nothing)
  e = SVal(Float32(2.0))
  l = SVal(2)
  B = 1.0f0
  E = 2.0f0
  L = 2
  T = Float32
  =#
function _sr(b::SVal{B,T}, s::SNothing, e::SVal{E,T}, l::SInteger{L}) where {B,E,F,L,T<:Union{Float16, Float32, Float64}}
    L < 2 && return linspace1(T, b, e, l)
    if b == e
        return srangehp(T, b, SVal{zero(T)}(), SVal{0}(), l)
    end
    # Attempt to find exact rational approximations
    start_n, start_d = rat(b)
    stop_n, stop_d = rat(e)
    if start_d != 0 && stop_d != 0
        den = lcm(start_d, stop_d)
        m = maxintfloat(T, Int)
        if den != 0 && abs(den*B) <= m && abs(den*E) <= m
            start_n = round(Int, den*b)
            stop_n = round(Int, den*e)
            if T(start_n/den) == b && T(stop_n/den) == e
                return linspace(T, start_n, stop_n, l, den)
            end
        end
    end
    linspace(b, e, l)
end

_srangestyle(::Base.Ordered, ::Base.ArithmeticWraps,  b::SVal{B,T}, s::SVal{S}, e::SNothing,  l::SInteger{L}) where {T,B,S,L} = steprange(b, s, SVal{oftype(B, B+S*(L-1))}())
_srangestyle(::Base.Ordered, ::Any,                   b::SVal{B,T}, s::SVal{S}, e::SVal{E,T}, l::SNothing) where {T,B,S,E} = steprange(b, s, e)
_srangestyle(::Any,          ::Any,                   b::SVal{B,T}, s::SVal{S}, e::SNothing,  l::SInteger{L}) where {T,B,S,L} = steprangelen(typeof(B+0*S), b, s, l)
_srangestyle(::Base.Ordered, ::Base.ArithmeticRounds, b::SVal{B,T}, s::SVal{S}, e::SVal{E,T}, l::SNothing) where {T,B,S,E} = steprangelen(b, s, SVal{floor(Int, (E-B)/S)+1}())
_srangestyle(::Any,          ::Any,                   b::SVal{B,T}, s::SVal{S}, e::SVal{E,T}, l::SNothing) where {T,B,S,E} = steprangelen(b, s, SVal{floor(Int, (E-B)/S)+1}())
