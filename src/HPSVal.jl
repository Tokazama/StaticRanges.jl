
function splitprec(::Type{F}, ::SInteger{I}) where {F<:AbstractFloat,I}
    hi = Base.truncbits(F(I), cld(precision(F), 2))
    ihi = oftype(I, hi)
    SVal{hi}(), SVal{F(I - ihi),F}()
end

function canonicalize2(big::SVal{B}, little::SVal{L}) where {B,L}
    h = big+little
    h, (big - h) + little
end


"""
    zhi, zlo = add12(x, y)

A high-precision representation of `x + y` for floating-point
numbers. Mathematically, `zhi + zlo = x + y`, where `zhi` contains the
most significant bits and `zlo` the least significant.
Because of the way floating-point numbers are printed, `lo` may not
look the way you might expect from the standpoint of decimal
representation, even though it is exact from the standpoint of binary
representation.

# Example:
```jldoctest
julia> 1.0 + 1.0001e-15
1.000000000000001

julia> big(SVal(1.0)) + big(SVal(1.0001e-15))
1.000000000000001000100000000000020165767380775934141445417482375879192346701529

julia> hi, lo = Base.add12(SVal(1.0), SVal(1.0001e-15))
(1.000000000000001, -1.1012302462515652e-16)

julia> big(hi) + big(lo)
1.000000000000001000100000000000020165767380775934141445417482375879192346701529
```
`lo` differs from 1.0e-19 because `hi` is not exactly equal to
the first 16 decimal digits of the answer.

"""
function add12(x::SVal{X,T}, y::SVal{Y,T}) where {X,Y,T}
    x, y = ifelse(abs(y) > abs(x), (y, x), (x, y))
    canonicalize2(x, y)
end
add12(x, y) = add12(promote(x, y)...)


"""
    zhi, zlo = mul12(x, y)
A high-precision representation of `x * y` for floating-point
numbers. Mathematically, `zhi + zlo = x * y`, where `zhi` contains the
most significant bits and `zlo` the least significant.
Example:

```jldoctest
julia> x = Float32(π)
3.1415927f0

julia> x * x
9.869605f0

julia> Float64(x) * Float64(x)
9.869604950382893

julia> hi, lo = Base.mul12(SVal(x), SVal(x))
(9.869605f0, -1.140092f-7)

julia> Float64(hi) + Float64(lo)
9.869604950382893
```
"""
function mul12(x::SVal{X,T}, y::SVal{Y,T}) where {X,Y,T<:AbstractFloat}
    h = x * y
    ifelse(iszero(h) | !isfinite(h), (h, h), canonicalize2(h, SVal{fma(X, Y, -get(h))}()))
end
mul12(x::SVal{X,T}, y::SVal{Y,T}) where {T,X,Y} = (p = x * y; (p, zero(p)))
mul12(x, y) = mul12(promote(x, y)...)


"""
    zhi, zlo = div12(x, y)
A high-precision representation of `x / y` for floating-point
numbers. Mathematically, `zhi + zlo ≈ x / y`, where `zhi` contains the
most significant bits and `zlo` the least significant.
Example:
```julia
julia> x, y = Float32(π), 3.1f0
(3.1415927f0, 3.1f0)

julia> x / y
1.013417f0

julia> Float64(x) / Float64(y)
1.0134170444063078

julia> hi, lo = Base.div12(SVal(x), SVal(y))
(1.013417f0, 3.8867366f-8)

julia> Float64(hi) + Float64(lo)
1.0134170444063066
"""
function div12(x::SVal{X,T}, y::SVal{Y,T}) where {X,Y,T<:AbstractFloat}
    # We lose precision if any intermediate calculation results in a subnormal.
    # To prevent this from happening, standardize the values.
    xs, xe = frexp(X)
    ys, ye = frexp(Y)
    r = xs / ys
    rh, rl = canonicalize2(Val{r}(), Val{-fma(r, ys, -xs)/ys}())
    ifelse(iszero(r) | !isfinite(r), (SVal{r}(), SVal{r}()), (SVal{ldexp(get(rh), xe-ye)}(), SVal{ldexp(get(rl), xe-ye)}()))
end
div12(x::SVal{X,T}, y::SVal{Y,T}) where {X,Y,T} = (p = x / y; (p, zero(p)))
div12(x, y) = div12(promote(x, y)...)

"""
    HPSVal
"""
struct HPSVal{H,L,T} end

@pure gethi(::HPSVal{T,H,L}) where {T,H,L} = H::T
@pure gethi(::Type{<:HPSVal{T,H,L}}) where {T,H,L} = H::T

@pure getlo(::HPSVal{T,H,L}) where {T,H,L} = L::T
@pure getlo(::Type{<:HPSVal{T,H,L}}) where {T,H,L} = L::T

Base.eltype(::HPSVal{T,H,L}) where {T,H,L} = T
Base.eltype(::Type{<:HPSVal{T,H,L}}) where {T,H,L} = T

Base.get(::HPSVal{T,H,L}) where {T,H,L} = TwicePrecision{T}(H,L)
Base.get(::Type{<:HPSVal{T,H,L}}) where {T,H,L} = TwicePrecision{T}(H,L)


HPSVal{T}(::SVal{X,T}) where {X,T} = HPSVal{T,X,zero(T)}()
HPSVal{T}(::SVal{X,T}, ::SVal{Y,T}) where {X,Y,T} = HPSVal{T,X,Y}()
HPSVal(::SVal{X,T}, ::SVal{Y,T}) where {X,Y,T} = HPSVal{T,X,Y}()
HPSVal(x::TwicePrecision{T}) where T = HPSVal{T,x.hi,x.lo}()
HPSVal(x::Tuple{SVal{V1,T1},SVal{V2,V2}}) where {V1,T1,V2,T2} = HPSVal(SVal{V1,T1}(), SVal{V2,V2}())

(::Type{SVal{<:Any,T}})(x::HPSVal{Th,H,L}) where {T,Th,H,L} = SVal{T(H + L),T}()


function HPSVal{T}(::SVal{X}) where {X,T}
    xT = convert(T, X)
    Δx = X - xT
    HPSVal{T, xT, T(Δx)}()
end

function HPSVal{T}(i::SInteger{X}) where {X,T<:AbstractFloat}
    HPSVal{T}(canonicalize2(splitprec(T, i)...)...)
end

HPSVal(x::SVal{X,T}) where {X,T} = HPSVal{T}(x)

#---
# Numerator/Denominator constructors
HPSVal{T}(::Tuple{SVal{N,<:Integer},SVal{D,<:Integer}}) where {N,D,T<:Union{Float16,Float32}} = HPSVal{T}(SVal{N/D}())
HPSVal{T}(::Tuple{SVal{N,<:Any},SVal{D,<:Any}}) where {N,D,T} = HPSVal{T}(SVal{N}()) / D

function HPSVal{T}(nd::Tuple{SVal{X,I},SVal{Y,I}}, nb::SVal{N,<:Integer}) where {T,X,Y,I,N}
    twiceprecision(HPSVal{T}(nd), nb)
end

# Truncating constructors. Useful for generating values that can be
# exactly multiplied by small integers.
function twiceprecision(::SVal{V,T}, nb::SVal{N,<:Integer}) where {V,T<:Union{Float16, Float32, Float64},N}
    hi = Base.truncbits(V, N)
    HPSVal{T,T(hi), T(V-hi)}()
end

function twiceprecision(val::HPSVal{T,H,L}, nb::SVal{N,<:Integer}) where {T<:Union{Float16, Float32, Float64},H,L,N}
    hi = Base.truncbits(H, N)
    HPSVal{T,T(hi), T((H - hi) + L)}()
end

#---conversion
(::Type{T})(x::HPSVal{T2,H,L}) where {T<:Number,T2,H,L} = T(H + L)::T
HPSVal{T}(x::SVal{X,<:Number}) where {T,X} = HPSVal{T,T(X),zero(T)}()

convert(::Type{HPSVal{T}}, x::HPSVal{T}) where {T} = x
function convert(::Type{HPSVal{T1}}, x::HPSVal{T2,H,L}) where {T1,T2,H,L}
    HPSVal{T1}(SVal{convert(T1, H)}(), SVal{convert(T1, L)}())
end

Base.convert(::Type{T}, x::HPSVal) where {T<:Number} = T(x)
Base.convert(::Type{HPSVal{T}}, x::Number) where {T} = HPSVal{T}(x)
Base.convert(::Type{HPSVal{T}}, x::SVal) where {T} = HPSVal{T}(x)


Base.float(x::HPSVal{<:AbstractFloat,H,L}) where {H,L} = x
Base.float(x::HPSVal{T,H,L}) where {T,H,L} = HPSVal(SVal{float(H)}(), SVal{float(L)}())

Base.big(::HPSVal{T,H,L}) where {T,H,L} = big(H) + big(L)

-(::HPSVal{T,H,L}) where {T,H,L} = HPSVal{T,-H,-L}()

Base.zero(::Type{HPSVal{T}}) where {T} = HPSVal{T,T(0),T(0)}()

# Arithmetic

@inline function +(::HPSVal{T,H,L}, y::Number) where {H,L,T}
    s_hi, s_lo = add12(SVal{H,T}(), y)
    hnew, hlow = canonicalize2(s_hi, s_lo+L)
    HPSVal(hnew, hlow)
end
+(x::Number, y::HPSVal) = y+x

@inline function +(x::HPSVal{T,Hx,Lx}, y::HPSVal{T,Hy,Ly}) where {Hx,Lx,Hy,Ly,T}
    r = Hx + Hy
    s = abs(Hx) > abs(Hy) ? (((x.hi - r) + Hy) + Ly) + Lx : (((Hy - r) + Hx) + Lx) + Ly
    hnew, lnew = canonicalize2(r, s)
    HPSVal(SVal{hnew}(),SVal{lnew}())
end
+(x::HPSVal{Tx,Hx,Lx}, y::HPSVal{Ty,Hy,Ly}) where {Hx,Lx,Tx,Hy,Ly,Ty} = +(promote(x, y)...)

-(x::HPSVal{Tx,Hx,Lx}, y::HPSVal{Ty,Hy,Ly}) where {Hx,Lx,Tx,Hy,Ly,Ty} = x + (-y)
-(x::Number, y::HPSVal{T,H,L}) where {H,L,T} = x + (-y)
-(x::HPSVal{T,H,L}, y::Number) where {H,L,T} = x + (-y)

function *(x::HPSVal{T,H,L}, v::Number) where {T,H,L}
    v == 0 && return HPSVal{H*v, L*v}()
    x * HPSVal{oftype(H*v, v)}()
end

function *(x::HPSVal{<:Union{Float16, Float32, Float64},H,L,}, v::Integer) where {H,L}
    v == 0 && return HPSVal(SVal{H*v}(), SVal{L*v}())
    nb = ceil(Int, log2(abs(v)))
    u = Base.truncbits(H, nb)
    HPSVal(canonicalize2(SVal{u*v}(), SVal{((H-u) + L)*v}())...)
end

function *(x::HPSVal{<:Union{Float16, Float32, Float64},H,L}, s::SInteger{V}) where {H,L,V}
    V == 0 && return HPSVal(SVal{H*V}(), SVal{L*V}())
    nb = ceil(Int, log2(abs(V)))
    u = Base.truncbits(H, nb)
    HPSVal(canonicalize2(SVal{u*V}(), SVal{((H-u) + L)*V}())...)
end

*(v::Number, x::HPSVal) = x*v

@inline function *(x::HPSVal{T,Hx,Lx}, y::HPSVal{T,Hy,Ly}) where {Hx,Lx,Hy,Ly,T}
    zh, zl = mul12(SVal{Hx}(), SVal{Hy}())
    hnew, lnew = canonicalize2(SVal{zh}(), SVal{(Hx * Ly + Lx * Hy) + zl}())
    ret = HPSVal{T,T(hnew),T(lnew)}()
    ifelse(iszero(zh) | !isfinite(zh), HPSVal{T,T(zh),T(zh)}(), ret)
end

*(x::HPSVal, y::HPSVal) = *(promote(x, y)...)

/(x::HPSVal{T,H,L}, v::Number) where {H,L,T} = x / HPSVal(SVal{oftype(H/v, v)}())

function /(x::HPSVal{T,Hx,Lx}, y::HPSVal{T,Hy,Ly}) where {Hx,Lx,Hy,Ly,T}
    hi = SVal{Hx / Hy}()
    uh, ul = mul12(hi, SVal{Hy}())
    lo = ((((Hx - uh) - ul) + Lx) - hi*Ly)/Hy
    ret = HPSVal(canonicalize2(hi, lo)...)
    ifelse(iszero(hi) | !isfinite(hi), HPSVal(hi,hi), ret)
end

#nbitslen(r::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = nbitslen(T, L, F)
#@inline ($f)(x::Float64) = nan_dom_err(ccall(($(string(f)), libm), Float64, (Float64,), x), x) 

function nbitslen(::Type{T}, l::SVal{L,Tl}, f::SVal{F,Tf}) where {L,F,T<:Union{Float16, Float32, Float64},Tl,Tf}
    min(SVal{cld(precision(T), 2)}(), nbitslen(l, f))
end
# The +1 here is for safety, because the precision of the significand
# is 1 bit higher than the number that are explicitly stored.
function nbitslen(l::SVal{L}, f::SVal{F}) where {L,F}
    l < 2 ? SVal{0}() : ceil(Int, log2(max(f-1, l-f))) + 1
end

#=
function rat(::SVal{x,T}) where {x,T}
    y = x
    a = d = 1
    b = c = 0
    m = maxintfloat(Base.narrow(T), Int)
    while abs(y) <= m
        f = trunc(Int, y)
        y -= f
        a, c = f*a + c, a
        b, d = f*b + d, b
        max(abs(a), abs(b)) <= Base.convert(Int,m) || return SVal{c}(), SVal{d}()
        y = inv(y)
    end
    return SVal{a}(), SVal{b}()
end
=#

function _rat(x::Val{X}, ::Val{y}, ::Val{m}, ::Val{a}, ::Val{b}, ::Val{c}, ::Val{d}) where {X,y,m,a,b,c,d}
    f = trunc(Int, y)
    ynew = y
    ynew -= f
    anew = f*a + c
    cnew = a
    bnew = f*b + d
    dnew = b
    if max(abs(anew), abs(bnew)) <= Base.convert(Int,m)
        return SVal{cnew}(), SVal{dnew}()
    elseif oftype(X,anew)/oftype(X,bnew) == X
        return SVal{anew}(), SVal{bnew}()
    elseif abs(ynew) <= m
        ynew = inv(ynew)
        _rat(x, Val{ynew}(), Val{m}(), Val{anew}(), Val{bnew}(), Val{cnew}(), Val{dnew}())
    else
        return SVal{anew}(), SVal{bnew}()
    end
end

function rat(::SVal{V,T}) where {V,T}
    y = V
    a = d = 1
    b = c = 0
    m = maxintfloat(Base.narrow(T), Int)
    _rat(Val{V}(), Val{V}(), Val{m}(), Val{a}(), Val{b}(), Val{c}(), Val{d}())
end

Base.show(io::IO, r::HPSVal) = showsval(io, r)
Base.show(io::IO, ::MIME"text/plain", r::HPSVal) = showsval(io, r)

showsval(io::IO, r::HPSVal{T,H,L}) where {T,H,L} = print(io, "HPSVal{$T}($H, $L)")
