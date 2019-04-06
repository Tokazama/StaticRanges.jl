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
_sr(b::StaticFloat{B}, s::SNothing,       e::SNothing,  l::SInteger{L}) where {B,L}   = _sr(b, SVal{oftype(B, 1)}(),   e, l)
_sr(b::StaticFloat{B}, s::StaticFloat{S}, e::SNothing,  l::SInteger{L}) where {B,S,L} = _sr(promote(b, s)..., e, l)
_sr(b::SReal{B},       s::StaticFloat{S}, e::SNothing,  l::SInteger{L}) where {B,S,L} = _sr(float(b), s, e, l)
_sr(b::StaticFloat{B}, s::SReal{S},       e::SNothing,  l::SInteger{L}) where {B,S,L} = _sr(b, float(s), e, l)
_sr(b::SVal{B},        s::SNothing,       e::SNothing,  l::SInteger{L}) where {L,B}   = _sr(b, oftype(B-B, 1), e, l)
_sr(b::SVal{B,T},      s,                 e::SNothing,  l::SInteger{L}) where {T,B,L} = _srangestyle(Base.OrderStyle(T), Base.ArithmeticStyle(T), b, s, e, l)

_sr(b::SVal{B,T},      s::SNothing,       e::SVal{E,T}, l::SInteger{L}) where {T<:Real,B,E,L} = linrange(T, b, e, l)
_sr(b::SVal{B,T},      s::SNothing,       e::SVal{E,T}, l::SInteger{L}) where {T,B,E,L} = linrange(T, b, e, l)
_sr(b::SVal{B,T},      s::SNothing,       e::SVal{E,T}, l::SInteger{L}) where {T<:Integer,B,E,L} = linspace(float(T), b, e, l)

# high precision
function _sr(b::SVal{B,T}, s::SVal{S,T}, e::SNothing, l::SInteger{L}) where {B,S,F,L,T<:Union{Float16,Float32,Float64}}
    start_n, start_d = Base.rat(B)
    step_n, step_d = Base.rat(S)
    if start_d != 0 && step_d != 0 && T(start_n/start_d) == B && T(step_n/step_d) == S
        den = lcm(start_d, step_d)
        m = maxintfloat(T, Int)
        if abs(den*B) <= m && abs(den*S) <= m && rem(den, start_d) == 0 && rem(den, step_d) == 0
            start_n = round(Int, den*B)
            step_n = round(Int, den*S)
            return floatrange(T, SVal{start_n}(), SVal{step_n}(), l, SVal{den}())
        end
    end
    srangehp(T, b, s, SVal{0}(), l, SVal{1}())
end

function _sr(b::SVal{B,T}, s::SNothing, e::SVal{E,T}, l::SInteger{L}) where {B,E,F,L,T<:Union{Float16, Float32, Float64}}
    L < 2 && return linspace1(T, b, e, f, l)
    if B == E
        return srangehp(T, b, SVal{zero(T)}(), SVal{0}(), f, l)
    end
    # Attempt to find exact rational approximations
    start_n, start_d = Base.rat(B)
    stop_n, stop_d = Base.rat(E)
    if start_d != 0 && stop_d != 0
        den = lcm(start_d, stop_d)
        m = maxintfloat(T, Int)
        if den != 0 && abs(den*B) <= m && abs(den*E) <= m
            start_n = round(Int, den*B)
            stop_n = round(Int, den*E)
            if T(start_n/den) == B && T(stop_n/den) == E
                return linspace(T, SVal{start_n}(), SVal{stop_n}(), l, SVal{den}())
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


#=
_sr(b::SVal{B,T}, e::SVal{E,T}, s::SNothing, l::SInteger{L}) where {T<:Real,B,E,F,L} = SRange{T,SVal{B,T},SVal{E,T},typeof(SVal{L / max(L - 1, 1)}()),F,L}() #LinRange{T}(b, e, l)
_sr(b::SVal{B,T}, e::SVal{E,T}, s::SNothing, l::SInteger{L}) where {T,B,E,F,L} = SRange{T,SVal{B,T},SVal{E,T},typeof(SVal{L / max(L - 1, 1)}()),F,L}() #LinRange{T}(b, e, l)
_sr(b::SVal{B,T}, e::SVal{E,T}, s::SNothing, l::SInteger{L}) where {T<:Integer,B,E,F,L} = linspace(float(T), b, e, f, l)


# length missing
_sr(b::SVal{B,T},   e::SVal{E,T},      s::StaticFloat{S}, f::SInteger{F}, l::SNothing) where {T<:Real,B,E,S,F} = _sr(promote(b, e, s)..., f, l)
_sr(b::SVal{B,T},   e::SVal{E,T},      s::StaticFloat{S}, f::SInteger{F}, l::SNothing) where {T<:AbstractFloat,B,E,S,F} = _sr(promote(b, e, s)..., f, l)
_sr(b::SVal{B,T},   e::SVal{E,<:Real}, s::StaticFloat{S}, f::SInteger{F}, l::SNothing) where {T<:AbstractFloat,B,E,S,F} = _sr(promote(b, e, s)..., f, l)
_sr(b::SVal{B,Tb},  e::SVal{E,Te},     s::SVal{S,Ts},     f::SInteger{F}, l::SNothing) where {B,Tb,E,Te,S,Ts,F} = _sr(promote(b, e, s)..., f, l)

_sr(b::SVal{B,T},   e::SVal{E,T},      s::SVal{S,T},      f::SInteger{F}, l::SNothing) where {T,B,E,S,F} = _srangestyle(Base.OrderStyle(T), Base.ArithmeticStyle(T), b, e, s, f, l)

_sr(b::SReal{B,Tb}, e::SVal{E,Te},     s::SNothing,       f::SInteger{F}, l::SNothing) where {B,Tb,E,Te,F} = _sr(promote(b, e)..., s, f, l)
_sr(b::SVal{B,T},   e::SVal{E,T},      s::SNothing,       f::SInteger{F}, l::SNothing) where {T,B,E,F} = _sr(b, e, oftype(b, 1), f, l)

## stop missing
_sr(b::SReal{B},       e::SNothing, s::SNothing,       f::SInteger{F}, l::SInteger{L}) where {B,F,L}     = _sr(b, b+l-1, SVal{oftype(B, 1)}(), f, l)
_sr(b::StaticFloat{B}, e::SNothing, s::SNothing,       f::SInteger{F}, l::SInteger{L}) where {B,F,L}     = _sr(b,     e, SVal{oftype(B, 1)}(), f, l)
_sr(b::SReal{B},       e::SNothing, s::StaticFloat{S}, f::SInteger{F}, l::SInteger{L}) where {B,S,F,L}   = _sr(SVal{float(b)}(), e, s, f, l)
_sr(b::StaticFloat{B}, e::SNothing, s::SReal{S},       f::SInteger{F}, l::SInteger{L}) where {B,S,F,L}   = _sr(b, e, SVal{float(S)}(), f, l)
_sr(b,                 e::SNothing, s::SNothing,       f::SInteger{F}, l::SInteger{L}) where {F,L}       = _sr(b, e, SVal{oftype(B-B, 1)}(), f, l)
_sr(b::StaticFloat{B}, e::SNothing, s::StaticFloat{S}, f::SInteger{F}, l::SInteger{L}) where {B,S,F,L}   = (x = promote(b, s); _sr(x[1], e, x[2], f, l))
_sr(b::SVal{B,T},      e::SNothing, s::SVal{E,T},      f::SInteger{F}, l::SInteger{L}) where {T,B,E,S,F,L} = _srangestyle(Base.OrderStyle(T), Base.ArtithmeticStyle(T), b, e, s, f, l)

_srangestyle(::Base.Ordered, ::Any,                   b::SVal{B,T},      s,                 e::SVal{E,T},  l::SNothing) where {T,B,E}    = step_sr(b, e, s, f, l)  #StepRange(start, step, stop)
_srangestyle(::Base.Ordered, ::Base.ArithmeticRounds, b::SVal{B,T},      s::SVal{S,Ts},     e::SVal{E,T},  l::SNothing) where {T,B,E,S,Ts}    = _sr(b, e, s, f, SVal{floor(Int, (E-B)/S)+1}())
_srangestyle(::Any,          ::Any,                   b::SVal{B,Tb},     s::SVal{S,Ts},     e::SVal{E,Te}, l::SNothing) where {B,Tb,E,Te,S,Ts}    = _sr(b, e, s, f, SVal{floor(Int, (E-B)/S)+1}())
_srangestyle(::Base.Ordered, ::Base.ArithmeticWraps,  b::StaticFloat{B}, s::StaticFloat{S}, e::SNothing,   l::SInteger{L}) where {B,S,L} = steprange(b, s, SVal{B(b + s * (l - 1))}())


# Construct range for rational start=start_n/den, step=step_n/den
function _sr(b::SFloat64{B}, e::SNothing, s::SFloat64{S}, l::SInteger{L}) where {B,S,L}
    u = L - F
    shift_hi, shift_lo = u * gethi(s), u * getlo(s)
    x_hi, x_lo = add12(SVal{gethi(b)}(), SVal{shift_hi}())
    _sr(b, SVal{T(x_hi + (x_lo + (shift_lo + getlo(B))))}(), s, f, l)
end

function _sr(b::HPSVal{T}, e::SNothing, s::HPSVal{T}, l::SInteger{L}) where {T,L}
    u = L - F
    shift_hi, shift_lo = u * gethi(s), u * getlo(s)
    x_hi, x_lo = add12(SVal{gethi(b)}(), SVal{shift_hi}())
    _sr(b, SVal{T(x_hi + (x_lo + (shift_lo + getlo(b))))}(), s, f, l)
end

=#

#_range(start, step,      stop, ::Nothing) = (:)(start, step, stop)
#_sr(b::SVal{B},   s::SVal{S},  e::SVal{E}, l::SNothing)

#_range(start, ::Nothing, stop, ::Nothing) = (:)(start, stop)
#_sr(b::SVal{B},   s::SNothing,  e::SVal{E}, l::SNothing)

_sr(b::SVal{B,Tb}, s::SNothing,   e::SVal{E,Te}, l::SNothing) where {B,Tb<:Real,E,Te<:Real} =
    (T = promote_type(Tb,Te); _sr(SVal{T(B)}(), s, SVal{T(E)}(), l))
_sr(b::SVal{B,T},  s::SNothing,   e::SVal{E,T},  l::SNothing) where {B,E,T<:Real} =
    unitrange(T, b, e)
_sr(b::SVal{B,Tb}, s::SNothing,   e::SVal{E,Te}, l::SNothing) where {B,Tb,E,Te} = 
    _sr(b, SVal{oftype(E-B, 1)}(), e, l)
#_sr(b::SVal{B,Tb}, s::SVal{S,Ts}, e::SVal{E,Te}, l::SNothing) where {B,Tb,S,Ts,E,Te} = _sr(SVal{convert(promote_type(Tb,Te), B)}(), s,  SVal{convert(promote_type(Tb,Te), E)}(), l)
_sr(b::SVal{B,T},  s::SNothing,   e::SVal{E,T},  l::SNothing) where {B,E,T<:AbstractFloat} =
    _sr(b, SVal{T(1)}(), e, l)
_sr(b::SVal{B,Tb}, s::SVal{S,Ts}, e::SVal{E,Te}, l::SNothing) where {B,Tb,S,Ts,E,Te} =
    _sr(promote(b, s, e)..., l)
_sr(b::SVal{B,T},  s::SVal{S,T},  e::SVal{E,T},  l::SNothing) where {B,S,E,T<:AbstractFloat} =
    _srangestyle(Base.OrderStyle(T), Base.ArithmeticStyle(T), b, s, e, l)
_sr(b::SVal{B,T},  s::SVal{S,T},  e::SVal{E,T},  l::SNothing) where {B,S,E,T<:Real} =
    _srangestyle(Base.OrderStyle(T), Base.ArithmeticStyle(T), b, s, e, l)

#_sr(b::SVal{B,T}, s::SVal{S,Ts}, e::SVal{E,T}, l::SNothing) where {B,S,Ts<:AbstractFloat,E,T<:AbstractFloat} = _sr(promote(b, s, e)..., l)
#_sr(b::SVal{B,T}, s::SVal{S,Ts},  e::SVal{E,T}, l::SNothing) where {B,S,Ts<:Real,E,T<:AbstractFloat} = _sr(promote(b, s, e)..., l)

# b = SVal(0.0)
# s = SVal(1.0)
# b = SVal(-0.5)
# StaticRanges._srangestyle(Base.OrderStyle(Float64), Base.ArithmeticStyle(Float64), b, s, e)
# _srangestyle(Base.OrderStyle(T), Base.ArithmeticStyle(T), b, s, e)
