import Base: TwicePrecision
import Base: ==, +, -, *, /, ^, <, ~, abs, abs2, isless, max, min, div

struct SVal{V,T}
    function SVal{V,T}() where {V,T}
        !(typeof(V) === T) && throw(ArgumentError("val must be of type T"))
        new{V,T}()
    end
end
SVal(val::T) where T = SVal{val,T}()

@pure Base.get(::SVal{V,T}) where {V,T} = V::T
@pure Base.eltype(::SVal{V,T}) where {V,T} = T
@inline Base.typeof(::SVal{V,T}, val) where {V,T} = typeof(T, val)

for f in (:+, :-, :*, :^, :\, :div)
    @eval begin
        @inline function ($f)(::SVal{V,T}, x::Real) where {V,T}
            vnew = $f(V, x)
            SVal{vnew,typeof(vnew)}()
        end
        @inline function ($f)(x::Real, ::SVal{V,T}) where {V,T}
            vnew = $f(x, V)
            SVal{vnew,typeof(vnew)}()
        end

        @inline function ($f)(::SVal{V1,T1}, ::SVal{V2,T,2}) where {V1,T1,V2,T2}
            vnew = $f(V1, V2)
            SVal{vnew,typeof(vnew)}()
        end
    end
end

# bool
for f in (:(==), :<, :isless, :max, :min)
    @eval function ($f)(A::AbstractArray, B::AbstractArray)
        @inline $f(::SVal{V,T}, x) where {V,T} = $f(V, x)
        @inline $f(x,  ::SVal{V,T}) where {V,T} = $f(x, V)
        @pure $f(::SVal{V1,T1}, ::SVal{V2,T2}) where {V1,T2,V2,T2} = $f(V1, V2)
    end
end

copy(::SVal{V,T}) where {V,T} = SVal{V,T}()

abs(::SValUnion{V,T}) where {V,T}= abs(I)
abs2(::SValUnion{V,T}) where {V,T} = abs2(I)


_sr(b::SVal{B,Tt}, e::SVal{E,Tt}, s::SVal{S,Tt}, f::SVal{F,Ti}, l::Val{L,Ti}) where {B,E,S,Tt,F,L,Ti}

_sr(b::SVal{B,Tt}, e::SVal{E,Tt}, s::SVal{S,Tt}, f::SVal{F,Ti}, l::Val{L,Ti}) where {B,E,S,Tt<:Integer,F,L,Ti}


# base/range.jl line 104
function _sr(b::SVal{B      ,T},
             e::SVal{nothing,  Nothing},
             s::SVal{nothing,  Nothing},
             f::SVal{      F,<:Integer},
             l::SVal{      L,<:Integer}) where {B,F,L,T<:Real}
    _srfinal(b,SVal(convert(T, B + len - 1)),SVal(convert(T, 1)),f,l)
end

# base/range.jl line 105
function _sr(b::SVal{B      ,        T},
             e::SVal{nothing,  Nothing},
             s::SVal{nothing,  Nothing},
             f::SVal{      F,<:Integer},
             l::SVal{      L,<:Integer}) where {B,F,L,T<:AbstractFloat}
    _sr(b, e, SVal(T(1)), f, l)
end

# base/range.jl line 106
function _sr(b::SVal{      B,        T},
             e::SVal{nothing,  Nothing},
             s::SVal{      S,        T},
             f::SVal{      F,<:Integer},
             l::SVal{      L,<:Integer}) where {B,F,L,T<:AbstractFloat}
    bnew, snew = promote(B, S)
    _sr(SVal(bnew), e, SVal(snew), f, l)
end

# base/range.jl line 107
function _sr(b::SVal{      B,   <:Real},
             e::SVal{nothing,  Nothing},
             s::SVal{      S,        T},
             f::SVal{      F,<:Integer},
             l::SVal{      L,<:Integer}) where {B,F,L,T<:AbstractFloat}
    _sr(SVal(float(B)), e, s, f, l)
end

# base/range.jl line 108
function _sr(b::SVal{      B,        T},
             e::SVal{nothing,  Nothing},
             s::SVal{      S,   <:Real},
             f::SVal{      F,<:Integer},
             l::SVal{      L,<:Integer}) where {B,F,L,T<:AbstractFloat}
    _sr(SVal(float(B)), e, s, f, l)
end

# base/range.jl line 109
function _sr(b::SVal{      B},
             e::SVal{nothing,  Nothing},
             s::SVal{nothing,  Nothing},
             f::SVal{      F,<:Integer},
             l::SVal{      L,<:Integer}) where {B,F,L}
    _sr(b, e, SVal(oftype(B-B, 1)), f, l)
end

# base/range.jl line 111
function _sr(b::SVal{      B,       T1},
             e::SVal{nothing,  Nothing},
             s::SVal{      S,       T2},
             f::SVal{      F,<:Integer},
             l::SVal{      L,<:Integer}) where {B,S,F,L,T1,T2}
    _sr_style(Base.OrderStyle(T1), Base.ArithmeticStyle(T1), b, s, f, l)
end

# base/twiceprecision.jl line 427
function _sr(b::SVal{      B,        T},
             e::SVal{nothing,  Nothing},
             s::SVal{      S,        T},
             f::SVal{      F,<:Integer},
             l::SVal{      L,<:Integer}) where {B,S,F,L,T<:Union{Float16,Float32,Float64}}
    start_n, start_d = Base.rat(B)
    step_n, step_d = Base.rat(S)
    if start_d != 0 && step_d != 0 &&
            T(start_n/start_d) == a && T(step_n/step_d) == S
        den = lcm(start_d, step_d)
        m = maxintfloat(T, Int)
        if abs(den*B) <= m && abs(den*S) <= m &&
                rem(den, start_d) == 0 && rem(den, step_d) == 0
            start_n = round(Int, den*B)
            step_n = round(Int, den*S)
            return floatsrange(T, start_n, step_n, L, den)
        end
    end
    _sr_hp(T, b, s, Val(0), f, l)
end



# base/range.jl line 113
function _sr_style(::Base.Ordered,
                   ::Base.ArithmeticWraps,
                   b::SVal{      B,       T1},
                   s::SVal{      S,       T2},
                   f::SVal{      F,<:Integer},
                   l::SVal{      L,<:Integer}) where {B,S,F,L,T1,T2}
    _srfinal(b, _sr_last(b,e,SVal(B+S*(l-1)),f,l), SVal(B+S*(l-1)), f, l)
end

# base/range.jl line 115
# TODO check this
function _sr_style(::Any,
                   ::Any,
                   b::SVal{      B,       T1},
                   s::SVal{      S,       T2},
                   f::SVal{      F,<:Integer},
                   l::SVal{      L,<:Integer}) where {B,S,F,L,T1,T2}
    # steprange stuff
    _sr(typeof(a+0*step), b, e, s, f, L)
end



# base/range.jl # 213 stop == start
function _sr_last(b::SVal{B,Tt},
                  e::SVal{B,Tt},
                  s::SVal{S,Tt},
                  f::SVal{F,Ti},
                  l::SVal{L,Ti}) where {B,S,Tt<:Integer,F,L,Ti}
    SVal{B,Tt}()
end



function _sr_last(b::SVal{B}, e::SVal{E}, s::SVal{S}, f::SVal{F}, len::SVal{L}) where {B,E,S,F,L}
    if (S > 0) != (E > B)
        last = srange_last_empty(b, e, s)
    else
        # Compute absolute value of difference between `B` and `E`
        # (to simplify handling both signed and unsigned T and checking for signed overflow):
        absdiff, absstep = E > B ? (E - B, S) : (B - E, -S)

        # Compute remainder as a nonnegative number:
        if typeof(B) <: Signed && absdiff < zero(absdiff)
            # handle signed overflow with unsigned rem
            remain = typeof(B, unsigned(absdiff) % absstep)
        else
            remain = absdiff % absstep
        end
        # Move `E` closer to `B` if there is a remainder:
        last = E > B ? SVal(E - remain) : SVal(E + remain)
    end
    return last
end

# base/range.jl # 236
function srange_last_empty(::SVal{B,T}, ::SVal{E}, ::SVal{S}) where {B,E,S,T<:Integer}
    # empty range has a special representation where stop = start-1
    # this is needed to avoid the wrap-around that can happen computing
    # start - step, which leads to a range that looks very large instead
    # of empty.
    if S > zero(S)
        SVal(B - oneunit(E-B))
    else
        SVal(last = B + oneunit(E-B))
    end
end
srange_last_empty(::SVal{B}, ::SVal{E}, ::SVal{S}) where {B,E,S} = SVal(B-S)

_srfinal(::Type{T}, b::B, e::E, s::S, f::F, l::L) where {T,B,E,S,F,L} = SRange{T,B,E,S,F,L}

function length()
    if S > 1
        return StaticRange{typeof(B),B,last,S,F,checked_add(convert(Int, div(unsigned(last - B), S)), one(B))}()
    elseif S < -1
        return StaticRange{typeof(B),B,last,S,F,checked_add(convert(Int, div(unsigned(B - last), -S)), one(B))}()
    elseif S > 0
        return StaticRange{typeof(B),B,last,S,F,checked_add(div(checked_sub(last, B), S), one(B))}()
    else
        return StaticRange{typeof(B),B,last,S,F,checked_add(div(checked_sub(B, last), -S), one(B))}()
    end
end

