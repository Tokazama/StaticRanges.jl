struct SVal{V,T<:Union{Number,Nothing}}
    function SVal{V,T}() where {V,T}
        !(typeof(V) === T) && throw(ArgumentError("val must be of type T"))
        new{V,T}()
    end
end
SVal(val::T) where T = SVal{val,T}()
SVal{V}() where {V} = SVal{V,typeof(V)}()
SVal(::Val{V}) where {V} = SVal{V}()
SVal(::Type{SVal{V,T}}) where {V,T}  = SVal{V,T}()
SVal(::SVal{V}) where {V} = SVal{V}()


(::Type{T})(x::SVal{V,T2}) where {T<:Number,T2,V} = T(V)::T
(::Type{SVal{<:Any,T1}})(x::SVal{V,T2}) where {T1,V,T2} = SVal{T1(V),T1}()
(::Type{SVal{<:Any,T}})(x::SVal{V,T}) where {T,V} = x


const SReal{V} = SVal{V,<:Real}

const SBigFloat{V} = SVal{V,BigFloat}
 const SFloat16{V} = SVal{V,Float16}
 const SFloat32{V} = SVal{V,Float32}
 const SFloat64{V} = SVal{V,Float64}
const StaticFloat{V} = Union{SFloat16{V},SFloat32{V},SFloat64{V},SBigFloat{V}}

const SBigInt{V} = SVal{V,BigInt}
const SInt128{V} = SVal{V,Int128}
 const SInt16{V} = SVal{V,Int16}
 const SInt32{V} = SVal{V,Int32}
 const SInt64{V} = SVal{V,Int64}
  const SInt8{V} = SVal{V,Int8}
const StaticSigned{V} = Union{<:SInt8{V},<:SInt16{V},<:SInt32{V},<:SInt64{V},<:SInt128{V},<:SBigInt{V}}

const SUInt128{V} = SVal{V,UInt128}
 const SUInt64{V} = SVal{V,UInt64}
 const SUInt32{V} = SVal{V,UInt32}
 const SUInt16{V} = SVal{V,UInt16}
  const SUInt8{V} = SVal{V,UInt8}
const StaticUnsigned{V} = Union{<:SUInt8{V},<:SUInt16{V},<:SUInt32{V},<:SUInt64{V},<:SUInt128{V}}

const SBool{V} = SVal{V,Bool}

const SInteger{V} = Union{<:StaticUnsigned{V},<:StaticSigned{V},<:SBool{V}}

const SNothing = SVal{nothing,Nothing}

Base.big(::SVal{V,T}) where {V,T} = SVal{big(V)}()
Base.float(::SVal{V,T}) where {V,T} = SVal{float(V)}()


Base.oftype(x::T, ::SVal{V}) where {T,V} = SVal{T(V),T}()

function Base.promote(::SVal{V1,T1}, ::SVal{V2,T2}) where {V1,T1,V2,T2}
    T3 = promote_type(T1,T2)
    SVal{T3(V1),T3}(), SVal{T3(V2),T3}()
end

function Base.promote(::SVal{V1,T1}, ::SVal{V2,T2}, ::SVal{V3,T3}) where {V1,T1,V2,T2,V3,T3}
    T4 = promote_type(T1,T2,T3)
    SVal{T4(V1),T4}(), SVal{T4(V2),T4}(), SVal{T4(V3),T4}()
end


@pure Base.get(::SVal{V,T}) where {V,T} = V::T
@pure Base.get(::Type{<:SVal{V,T}}) where {V,T} = V::T

@pure Base.eltype(::SVal{V,T}) where {V,T} = T
@pure Base.eltype(::Type{<:SVal{V,T}}) where {V,T} = T

Base.convert(::Type{SVal{V,T}}, x) where {V,T} = SVal{oftype(V, x),T}()


#=
for f in (:*, :^, :\, :div)
    @eval begin
        @inline function ($f)(::SVal{V,T}, x::Real) where {V,T}
            vnew = $f(V, x)
            SVal{vnew,typeof(vnew)}()
        end
        @inline function ($f)(x::Real, ::SVal{V,T}) where {V,T}
            vnew = $f(x, V)
            SVal{vnew,typeof(vnew)}()
        end

        @inline function ($f)(::SVal{V1,T1}, ::SVal{V2,T2}) where {V1,T1,V2,T2}
            vnew = $f(V1, V2)
            SVal{vnew,typeof(vnew)}()
        end
    end
end
=#


# bool
for f in (:(==), :<, :isless, )
    @eval begin
        @inline function $f(::SVal{V,T}, x::Real) where {V,T}
            $(f)(V, x)
        end

        @inline function $f(x::Real, ::SVal{V,T}) where {V,T}
            $(f)(x, V)
        end

        @pure function $f(::SVal{V1,T1}, ::SVal{V2,T2}) where {V1,T1,V2,T2}
            $(f)(V1, V2)
        end
    end
end

max(r::SVal{V,T}, x::Real) where {V,T} = max(x, r)
max(x::Real, r::SVal{V,T}) where {V,T} = ifelse(x > V, x, r)
max(::SVal{V1,T1}, ::SVal{V2,T2}) where {V1,T1,V2,T2} = SVal{max(V1, V2)}()

min(r::SVal{V,T}, x::Real) where {V,T} = min(x, r)
min(x::Real, r::SVal{V,T}) where {V,T} = ifelse(x > V, x, r)
min(::SVal{V1,T1}, ::SVal{V2,T2}) where {V1,T1,V2,T2} = SVal{min(V1, V2)}()

+(::SVal{V,T}, y::Number) where {V,T} = SVal{V+y}()
+(x::Number, y::SVal) = y+x

+(x::SVal{V1,T}, y::SVal{V2,T}) where {V1,V2,T} = SVal{V1+V2}()
+(x::SVal{V1,T1}, y::SVal{V2,T2}) where {V1,V2,T1,T2} = +(promote(x, y)...)

-(x::SVal{V,T}) where {V,T} = SVal{-V,T}()

-(x::SVal, y::SVal) = x + (-y)
-(x::Number, y::SVal) = x + (-y)
-(x::SVal, y::Number) = x + (-y)

*(x::SVal{V,T}, v::Number) where {V,T} = SVal{V*v}()
*(v::Number, x::SVal) = x*v
*(x::SVal{V1,T1}, y::SVal{V2,T2}) where {V1,V2,T1,T2} = *(promote(x, y)...)
*(x::SVal{V1,T}, y::SVal{V2,T}) where {V1,V2,T} = SVal{V1*V2}()

/(x::SVal{V,T}, v::Number) where {V,T} = x / SVal(oftype(V/v, v))
/(v::Number, x::SVal{V,T}) where {V,T} = SVal(oftype(V/v, v)) / x
/(x::SVal{V1,T1}, y::SVal{V2,T2}) where {V1,T1,V2,T2} = /(promote(x, y)...)
/(x::SVal{V1,T}, y::SVal{V2,T}) where {V1,V2,T} = SVal{V1/V2}()

copy(::SVal{V,T}) where {V,T} = SVal{V,T}()

abs(::SVal{V,T}) where {V,T}= SVal{abs(V)}()
abs2(::SVal{V,T}) where {V,T} = SVal{abs2(V),T}()

Base.ceil(::SVal{V,T}) where {V,T} = SVal{ceil(V)}()
Base.ceil(::Type{T}, ::SVal{V}) where {V,T} = SVal{ceil(T, V)}()


const BASE2 = log(2)
const BASE10 = log(10)
Base.log(::SVal{V,T}) where {V,T} = SVal{log(V)}()
# version from base erros on @code_inference
Base.log2(::SVal{V,T}) where {V,T} = SVal{log(V) / BASE2}()
Base.log10(::SVal{V,T}) where {V,T} = SVal{log(V) / BASE10}()
Base.log1p(::SVal{V,T}) where {V,T} = SVal{logp(V)}()

Base.rem(::SVal{V1,T}, ::SVal{V2,<:Integer}) where {V1,V2,T} = SVal{rem(V1,V2)}()
Base.rem(::SVal{V,T}, x::Integer) where {V,T} = SVal{rem(V,x)}()
Base.rem(x::T, ::SVal{V,<:Integer}) where {V,T} = SVal{rem(x,V)}()

function Base.clamp(::SVal{x,X}, ::SVal{lo,L}, ::SVal{hi,H}) where {x,X,lo,L,hi,H}
    if x > hi
        out  = Base.convert(promote_type(X,L,H), hi)
    elseif x < lo
        out = Base.convert(promote_type(X,L,H), lo)
    else
        out = Base.convert(promote_type(X,L,H), x)
    end
    SVal{out}()
end

Base.round(::Type{T}, ::SVal{V}) where {T,V} = SVal{round(T, V)}()

Base.isfinite(::SVal{V,T}) where {V,T} = isfinite(V)
Base.zero(::SVal{V,T}) where {V,T} = SVal{zero(V)}()
Base.iszero(::SVal{V,T}) where {V,T} = iszero(V)


Base.show(io::IO, r::SVal) = showsval(io, r)
Base.show(io::IO, ::MIME"text/plain", r::SVal) = showsval(io, r)

showsval(io::IO, r::SVal{V,T}) where {V,T} = print(io, "SVal($(V)::$(T))")
showsval(io::IO, r::SNothing) where {V,T} = print(io, "SVal(nothing)")


Base.div(::SVal{A,T1}, ::SVal{B,T2}) where {A,T1,B,T2} = SVal{div(A,B)}()
Base.div(::SVal{A,T1}, b::T2) where {A,T1,T2} = SVal{div(A,b)}()
Base.div(a::T1, ::SVal{B,T2}) where {T1,B,T2} = SVal{div(a,B)}()

#Base.oneunit(::SVal{V,T}) where {V,T} = SVal{T(1)}()
Base.one(::SVal{V,T}) where {V,T} = SVal{T(1)}()

Base.one(::Type{SVal{V,T}}) where {V,T} = SVal{T(1)}()

Base.oneunit(::SVal{V,T}) where {V,T} = SVal{T(1)}()
Base.oneunit(::Type{SVal{V,T}}) where {V,T} = SVal{T(1)}()

Base.gcd(a::SVal{A,<:Integer}, b::SVal{B,<:Integer}) where {A,B} = gcd(promote(a,b)...)
function Base.gcd(a::SVal{A,T}, b::SVal{B,T}) where {A,B,T<:Integer}
    r = rem(a, b)
    if r == 0
        return b
    else
        return gcd(b, r)
    end
end

Base.lcm(a::SVal{A,<:Integer}, b::SVal{B,<:Integer}) where {A,B} = lcm(promote(a,b)...)
function Base.lcm(a::SVal{A,T}, b::SVal{B,T}) where {A,B,T<:Integer}
    # explicit a==0 test is to handle case of lcm(0,0) correctly
    if a == SVal{T(0),T}()
        return a
    else
        return abs(a * div(b, gcd(b,a)))
    end
end