module StaticValues

import Base: TwicePrecision, promote_rule
import Base: ==, +, -, *, /, ^, <, ~, :, abs, abs2, isless, max, min, div, rem
import Base: eltype, values, log10, isfinite, zero, iszero

export SInt128, SInt16, SInt32, SInt64, SInt, SInt8,
       SUInt128, SUInt64, SUInt, SUInt32, SUInt16, SUInt8,
       SFloat16, SFloat32, SFloat64,
       SSIgned, SUnsigned, SInteger, SFloat, SReal



struct SUInt128{V} <: Unsigned
    function SUInt128{V}() where V
        !(typeof(V) === UInt128) && throw(ArgumentError("SUInt128 only supports static UInt128 storage, got $(typeof(V))"))
        return new{V}()
    end
end
#SUInt128(val::SUInt128) = val

struct SUInt64{V} <: Unsigned
    function SUInt64{V}() where V
        !(typeof(V) === UInt64) && throw(ArgumentError("SUInt64 only supports static UInt64 storage, got $(typeof(V))"))
        new{V}()
    end
end
#SUInt64(val::SUInt64) = val

const SUInt{V} = SUInt64{V}

struct SUInt32{V} <: Unsigned
    function SUInt32{V}() where V
        !(typeof(V) === UInt32) && throw(ArgumentError("SUInt32 only supports static UInt32 storage, got $(typeof(V))"))
        new{V}()
    end
end
#SUInt32(val::SUInt32) = val

struct SUInt16{V} <: Unsigned
    function SUInt16{V}() where V
        !(typeof(V) === UInt16) && throw(ArgumentError("SUInt16 only supports static UInt16 storage, got $(typeof(V))"))
        new{V}()
    end
end
#SUInt16(val::SUInt16) = val

struct SUInt8{V} <: Unsigned
    function SUInt8{V}() where V
        !(typeof(V) === UInt8) && throw(ArgumentError("SUInt8 only supports static UInt8 storage, got $(typeof(V))"))
        new{V}()
    end
end
#SUInt8(val::SUInt8) = val

const SUnsigned{V} = Union{SUInt8{V},SUInt16{V},SUInt32{V},SUInt64{V},SUInt128{V}}

# Signed
struct SInt128{V} <: Signed
    function SInt128{V}() where V
        !(typeof(V) === Int128) && throw(ArgumentError("SInt128 only supports static Int128 storage, got $(typeof(V))"))
        new{V}()
    end
end
#SUInt128(val::SUInt128) = val

struct SInt64{V} <: Signed
    function SInt64{V}() where V
        !(typeof(V) === Int64) && throw(ArgumentError("SInt64 only supports static Int64 storage, got $(typeof(V))"))
        new{V}()
    end
end
#SInt64(val::SInt64) = val

const SInt{V} = SInt64{V}

struct SInt32{V} <: Signed
    function SInt32{V}() where V
        !(typeof(V) === Int32) && throw(ArgumentError("SInt32 only supports static Int32 storage, got $(typeof(V))"))
        new{V}()
    end
end
#SInt32(val::SInt32) = val

struct SInt16{V} <: Signed
    function SInt16{V}() where V
        !(typeof(V) === Int16) && throw(ArgumentError("SInt16 only supports static Int16 storage, got $(typeof(V))"))
        new{V}()
    end
end
#SInt16(val::SInt16) = val

struct SInt8{V} <: Signed
    function SInt8{V}() where V
        !(typeof(V) === Int8) && throw(ArgumentError("SInt8 only supports static Int8 storage, got $(typeof(V))"))
        new{V}()
    end
end
#SInt8(val::SInt8) = val

const SSigned{V} = Union{SInt8{V},SInt16{V},SInt32{V},SInt64{V},SInt128{V}}

const SInteger{V} = Union{SSigned{V},SUnsigned{V}}

Base.leading_zeros(::SInteger{V}) where V = leading_zeros(V)
Base.leading_ones(::SInteger{V}) where V = leading_ones(V)


# AbstractFloat
struct SFloat64{V} <: AbstractFloat
    function SFloat64{V}() where V
        !(typeof(V) === Float64) && throw(ArgumentError("SFloat64 only supports static Float64 storage, got $(typeof(V))"))
        new{V}()
    end
end
#SFloat64(val::SFloat64) = val

struct SFloat32{V} <: AbstractFloat
    function SFloat32{V}() where V
        !(typeof(V) === Float32) && throw(ArgumentError("SFloat32 only supports static Float32 storage, got $(typeof(V))"))
        new{V}()
    end
end
#SFloat32(val::SFloat32) = val

struct SFloat16{V} <: AbstractFloat
    function SFloat16{V}() where V
        !(typeof(V) === Float16) && throw(ArgumentError("SFloat16 only supports static Float16 storage, got $(typeof(V))"))
        new{V}()
    end
end
#SFloat16(val::SFloat16) = val


const SFloat{V} = Union{SFloat16{V}, SFloat32{V}, SFloat64{V}}

Base.show(io::IO, ::SFloat{V}) where V = print(io, V)

# BigFloat
#const IEEESFloat{V} = Union{SFloat16{V}, SFloat32{V}, SFloat64{V}}

const SReal{V} = Union{SFloat{V},SInteger{V}}

promote_rule(::Type{SInt16}, ::Union{Type{SInt8}, Type{SUInt8}}) = SInt16
promote_rule(::Type{SInt32}, ::Union{Type{SInt16}, Type{SInt8}, Type{SUInt16}, Type{SUInt8}}) = SInt32
promote_rule(::Type{SInt64}, ::Union{Type{SInt16}, Type{SInt32}, Type{SInt8}, Type{SUInt16}, Type{SUInt32}, Type{SUInt8}}) = SInt64
promote_rule(::Type{SInt128}, ::Union{Type{SInt16}, Type{SInt32}, Type{SInt64}, Type{SInt8}, Type{SUInt16}, Type{SUInt32}, Type{SUInt64}, Type{SUInt8}}) = SInt128
promote_rule(::Type{SUInt16}, ::Union{Type{SInt8}, Type{SUInt8}}) = SUInt16
promote_rule(::Type{SUInt32}, ::Union{Type{SInt16}, Type{SInt8}, Type{SUInt16}, Type{SUInt8}}) = SUInt32
promote_rule(::Type{SUInt64}, ::Union{Type{SInt16}, Type{SInt32}, Type{SInt8}, Type{SUInt16}, Type{SUInt32}, Type{SUInt8}}) = SUInt64
promote_rule(::Type{SUInt128}, ::Union{Type{SInt16}, Type{SInt32}, Type{SInt64}, Type{SInt8}, Type{SUInt16}, Type{SUInt32}, Type{SUInt64}, Type{SUInt8}}) = SUInt128

# with mixed signedness and same size, Unsigned wins
promote_rule(::Type{SUInt8},   ::Type{SInt8}  ) = SUInt8
promote_rule(::Type{SUInt16},  ::Type{SInt16} ) = SUInt16
promote_rule(::Type{SUInt32},  ::Type{SInt32} ) = SUInt32
promote_rule(::Type{SUInt64},  ::Type{SInt64} ) = SUInt64
promote_rule(::Type{SUInt128}, ::Type{SInt128}) = SUInt128

promote_rule(::Type{SFloat64}, ::Type{SUInt128}) = SFloat64
promote_rule(::Type{SFloat64}, ::Type{SInt128})  = SFloat64
promote_rule(::Type{SFloat32}, ::Type{SUInt128}) = SFloat32
promote_rule(::Type{SFloat32}, ::Type{SInt128})  = SFloat32
promote_rule(::Type{SFloat32}, ::Type{SFloat16}) = SFloat32
promote_rule(::Type{SFloat64}, ::Type{SFloat16}) = SFloat64
promote_rule(::Type{SFloat64}, ::Type{SFloat32}) = SFloat64

const BaseUnsigned = Union{UInt128,UInt16,UInt32, UInt64,UInt8}
const BaseSigned = Union{BigInt,Int128,Int16,Int32,Int64,Int8}
const BaseInteger = Union{UInt128,UInt16,UInt32,UInt64,UInt8,
                          BigInt,Int128,Int16,Int32,Int64,Int8,Bool}
const BaseFloat = Union{BigFloat,Float16,Float32,Float64}
const BaseReal = Union{UInt128,UInt16,UInt32,UInt64,UInt8,
                       BigInt,Int128,Int16,Int32,Int64,Int8,Bool,
                       BigFloat,Float16,Float32,Float64,
                       Rational,Irrational}
const BaseNumber = Union{UInt128,UInt16,UInt32,UInt64,UInt8,
                         BigInt,Int128,Int16,Int32,Int64,Int8,Bool,
                         BigFloat,Float16,Float32,Float64,
                         Rational,Irrational,Complex}

static_tuple = (SUInt128,SUInt16,SUInt32,SUInt64,SUInt8,
                SInt128,SInt16,SInt32,SInt64,SInt8,SFloat64,SFloat32,SFloat16)
base_tuple  = (UInt128,UInt16,UInt32,UInt64,UInt8,
                Int128,Int16,Int32,Int64,Int8,Float64,Float32,Float16)
notin_tuple = (Union{SSigned,SUInt64,SUInt32,SUInt16,SUInt8,SFloat},
               Union{SSigned,SUInt128,SUInt32,SUInt16,SUInt8,SFloat},
               Union{SSigned,SUInt128,SUInt64,SUInt16,SUInt8,SFloat},
               Union{SSigned,SUInt128,SUInt64,SUInt32,SUInt8,SFloat},
               Union{SSigned,SUInt128,SUInt64,SUInt32,SUInt16,SFloat},
               Union{SUnsigned,SInt64,SInt32,SInt16,SInt8,SFloat},
               Union{SUnsigned,SInt128,SInt32,SInt16,SInt8,SFloat},
               Union{SUnsigned,SInt128,SInt64,SInt16,SInt8,SFloat},
               Union{SUnsigned,SInt128,SInt64,SInt32,SInt8,SFloat},
               Union{SUnsigned,SInt128,SInt64,SInt32,SInt16,SFloat},
               Union{SInteger,SFloat32,SFloat64},
               Union{SInteger,SFloat32,SFloat16},
               Union{SInteger,SFloat16,SFloat64})

for (ST,BT) in zip(static_tuple, base_tuple)

    # f(static) --> val
    for f in (:eltype, :values, :log10, :isfinite, :zero, :iszero)
        @eval begin
            $f(::$ST) = $BT
        end
    end

    # f(static) --> Bool
    for f in (:(==), :<, :<=, :(!=), :isless)
        @eval begin
            $f(::$ST{V1}, ::$ST{V2}) where {V1,V2} = V1::$BT === V2::$BT
        end
    end

    # f(static, static) --> static
    for f in (:*, :^, :\, :div, :+, :-, :max, :min, :rem)
        @eval begin
            $f(::$ST{V1}, ::$ST{V2}) where {V1,V2} = $ST{$f(V1::$BT, V2::$BT)}()
        end
    end

    for (ST2,BT2) in zip(static_tuple, base_tuple)
        if BT == BT2
            @eval begin
                (::Type{<:$ST{<:Any}})(val::$ST2) = val
                (::Type{<:$ST{<:Any}})(val::$BT2) = $ST{val}()

                Base.promote_rule(::Type{<:$ST}, ::Type{$BT2}) = $BT
                Base.flipsign(::$ST{V1}, ::$ST2{V2}) where {V1,V2} = flipsign(V1::$BT,V2::$BT2)

                (::Type{$BT2})(::$ST{V}) where V = V::$BT
            end
        else
            @eval begin
                (::Type{<:$ST{<:Any}})(::$ST2{V}) where V = $ST{$BT(V::$BT2)}()
                (::Type{<:$ST{<:Any}})(val::$BT2) = $ST{$BT(val)}()

                Base.promote_rule(::Type{<:$ST}, ::Type{$BT2}) = promote_type($BT, $BT2)
                Base.flipsign(::$ST{V1}, ::$ST2{V2}) where {V1,V2} = flipsign(V1::$BT,V2::$BT2)


                (::Type{$BT2})(::$ST{V}) where V = $BT2(V::$BT)
            end
        end
    end

    # require special treatment for type inference
    @eval begin
        Base.log10(::$ST{V}) where V = $ST{log(V::$BT)/log(10)}()
    end

    for (ST2,BT2) in zip((SUInt128,SUInt16,SUInt32,SUInt64,SUInt8,SInt128,SInt16,SInt32,SInt64,SInt8),
                         (UInt128,  UInt16, UInt32, UInt64, UInt8, Int128, Int16, Int32, Int64, Int8))
        eval(:(Base.round(::Type{$BT2}, ::$ST{V}) where V = $ST2{round($BT2, V::$BT)}()))
    end

end

# with mixed staticness, non-static wins
#=
for (ST,BT,∉) in ()
    @eval begin
        #($ST)(val::$BT) = $ST{val}()
        #($ST)(val::T) where T = $ST($BT(val))
        #($ST)(::Val{V}) where V = $ST($BT(V))

#        (::Type{$ST{<:Any}})(val::$∉{V}) where V = $ST{$BT(V)}()
        (::Type{$ST{<:Any}})(val::$BT) = $ST{$BT}()
        (::Type{$ST{<:Any}})(::Val{V}) where V = $ST($BT(V))

        # with mixed static/non-static, non-static wins
    end
end

const BASE2 = log(2)
@generated function Base.log(::SVal{V,T}) where {V,T}
    x = log(V)
    :(SVal{$x}())
end

# version from base erros on @code_inference
@generated function Base.log2(::SVal{V,T}) where {V,T}
    x = log2(V)
    :(SVal{$x}())
end
Base.log1p(::SVal{V,T}) where {V,T} = SVal{logp(V)}()
function Base.clamp(::SVal{X}, ::SVal{L}, ::SVal{H}) where {x,X,lo,L,hi,H}
    if x > hi
        out  = Base.convert(promote_type(X,L,H), hi)
    elseif x < lo
        out = Base.convert(promote_type(X,L,H), lo)
    else
        out = Base.convert(promote_type(X,L,H), x)
    end
    SVal{out}()
end



=#




end
