(:)(a::SReal, b::SReal) = (:)(promote(a,b)...)

(:)(start::SVal{B,T}, stop::SVal{E,T}) where {B,E,T<:Real} = unitrange{T}(start, stop)

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
    _scolon(OrderStyle(T), ArithmeticStyle(T), b, s, e)
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
function _scolon(b::SVal{B,T}, s, e::SVal{E,T}) where T
    T′ = typeof(b+zero(s))
    steprange(convert(T′,b), s, convert(T′,e))
end
