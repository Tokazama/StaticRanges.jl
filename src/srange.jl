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

_sr(b::SReal{B},  s::SNothing,  e::SNothing,  l::SInteger{L}) where {B,L}   = unitrange(typeof(B), b, SVal{oftype(B, B+L-1)}())
_sr(b::SFloat{B}, s::SNothing,  e::SNothing,  l::SInteger{L}) where {B,L}   = _sr(b, SVal{oftype(B, 1)}(),   e, l)
_sr(b::SFloat{B}, s::SFloat{S}, e::SNothing,  l::SInteger{L}) where {B,S,L} = _sr(promote(b, s)..., e, l)
_sr(b::SReal{B},  s::SFloat{S}, e::SNothing,  l::SInteger{L}) where {B,S,L} = _sr(float(b), s, e, l)
_sr(b::SFloat{B}, s::SReal{S},  e::SNothing,  l::SInteger{L}) where {B,S,L} = _sr(b, float(s), e, l)
_sr(b::SVal{B},   s::SNothing,  e::SNothing,  l::SInteger{L}) where {L,B}   = _sr(b, oftype(B-B, 1), e, l)
_sr(b::SVal{B,T}, s,            e::SNothing,  l::SInteger{L}) where {T,B,L} = _srangestyle(Base.OrderStyle(T), Base.ArithmeticStyle(T), b, s, l)

_sr(b::SVal{B,T}, s::SNothing,  e::SVal{E,T}, l::SInteger{L}) where {T<:Real,B,E,L} = linrange(T, b, e, l)
_sr(b::SVal{B,T}, s::SNothing,  e::SVal{E,T}, l::SInteger{L}) where {T,B,E,L} = linrange(T, b, e, l)
_sr(b::SVal{B,T}, s::SNothing,  e::SVal{E,T}, l::SInteger{L}) where {T<:Integer,B,E,L} = linspace(float(T), b, e, l)



# start:stop
#_sr(b::SVal{B,Tb}, s::SNothing,   e::SVal{E,Te}, l::SNothing) where {B,Tb<:Real,E,Te<:Real} = (T = promote_type(Tb,Te); _sr(SVal{T(B)}(), s, SVal{T(E)}(), l))
#_sr(b::SVal{B,T},  s::SNothing,   e::SVal{E,T},  l::SNothing) where {B,E,T<:Real} = unitrange(T, b, e)
#_sr(b::SVal{B,Tb}, s::SNothing,   e::SVal{E,Te}, l::SNothing) where {B,Tb,E,Te} =  _sr(b, SVal{oftype(E-B, 1)}(), e, l)
#_sr(b::SVal{B,T},  s::SNothing,   e::SVal{E,T},  l::SNothing) where {B,E,T<:AbstractFloat} = _sr(b, SVal{T(1)}(), e, l)

_sr(b::SVal{B,Tb}, s::SNothing, e::SVal{E,Te}, l::SNothing) where {B,Tb,E,Te} = (:)(b, e)
# start:step:stop
#_sr(b::SVal{B,Tb}, s::SVal{S,Ts}, e::SVal{E,Te}, l::SNothing) where {B,Tb,S,Ts,E,Te} = _sr(SVal{convert(promote_type(Tb,Te), B)}(), s,  SVal{convert(promote_type(Tb,Te), E)}(), l)
_sr(b::SVal{B,Tb}, s::SVal{S,Ts}, e::SVal{E,Te}, l::SNothing) where {B,Tb,S,Ts,E,Te} = (:)(b, s, e)
#_sr(b::SVal{B,T},  s::SVal{S,T},  e::SVal{E,T},  l::SNothing) where {B,S,E,T<:AbstractFloat} = _srangestyle(Base.OrderStyle(T), Base.ArithmeticStyle(T), b, s, e, l)
#_sr(b::SVal{B,T},  s::SVal{S,T},  e::SVal{E,T},  l::SNothing) where {B,S,E,T<:Real} = _srangestyle(Base.OrderStyle(T), Base.ArithmeticStyle(T), b, s, e, l)
#_sr(b::SVal{B,T},  s::SVal{S},  e::SVal{E,T},  l::SNothing) where {B,S,E,T} = steprange(b, s, e)

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

#_srangestyle(::Base.Ordered, ::Any,                   b::SVal{B,T}, s::SVal{S}, e::SVal{E,T}, l::SNothing) where {T,B,S,E} = steprange(b, s, e)
#_srangestyle(::Base.Ordered, ::Base.ArithmeticRounds, b::SVal{B,T}, s::SVal{S}, e::SVal{E,T}, l::SNothing) where {T,B,S,E} = steprangelen(b, s, SVal{floor(Int, (E-B)/S)+1}())
#_srangestyle(::Any,          ::Any,                   b::SVal{B,T}, s::SVal{S}, e::SVal{E,T}, l::SNothing) where {T,B,S,E} = steprangelen(b, s, SVal{floor(Int, (E-B)/S)+1}())

_srangestyle(::Base.Ordered, ::Base.ArithmeticWraps,  b::SVal{B,T}, s::SVal{S}, l::SInteger{L}) where {T,B,S,L} = steprange(b, s, SVal{oftype(B, B+S*(L-1))}())
_srangestyle(::Any,          ::Any,                   b::SVal{B,T}, s::SVal{S}, l::SInteger{L}) where {T,B,S,L} = steprangelen(typeof(B+0*S), b, s, l)