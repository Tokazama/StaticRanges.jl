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

for f in (:+, :-, :*, :^, :\, :div)
    @eval begin
        @pure @inline function ($f)(::SValUnion{V,T}, x::Real) where {V,T}
            vnew = $f(V, x)
            SVal{vnew,typeof(vnew)}()
        end
        @pure @inline function ($f)(x::Real, ::SValUnion{V,T}) where {V,T}
            vnew = $f(x, V)
            SVal{vnew,typeof(vnew)}()
        end

        @pure @inline function ($f)(::SValUnion{V1,T1}, ::SValUnion{V1,T1}) where {V1,T1,V2,T2}
            vnew = $f(V1, V2)
            SVal{vnew,typeof(vnew)}()
        end

        Base.@pure ($f)(::SValUnion{T,1,I1}, ::SValUnion{T,1,I2}) where {I1,I2,T} = SVal{T,1,T($f(I1, I2))}()
    end
end

# bool
for f in (:(==), :<, :isless, :max, :min)
    @eval function ($f)(A::AbstractArray, B::AbstractArray)
        @pure $f( ::SValUnion{T,1,T},          x::Real) where {I,T}       = $f(I, x)
        @pure $f(         x::Real,  ::SValUnion{T,1,I}) where {T,I}       = $f(x, I)
        @pure $f( ::SValUnion{T,N,I},     x::NTuple{N}) where {T,N,I}     = $f(I, x)
        @pure $f(    x::NTuple{N},  ::SValUnion{T,N,I}) where {T,N,I}     = $f(x, I)
        @pure $f(::SValUnion{T,N,I1}, ::SValUnion{T,N,I2}) where {I,N,I1,I2} = $f(I1, I2)
    end
end

Base.show(io::IO, r::SVal{I}) where I = print(io, "SVal($I)")
Base.show(io::IO, ::MIME"text/plain", r::SVal{I}) where I = print(io, "SVal($I)")

@pure unpack(::SValUnion{I}) where I = I

@pure Base.eltype(::SValUnion{I,N,T}) where {I,N,T} = T
@pure Base.ndims(::SValUnion{I,N}) where {I,N} = N
@pure Base.length(::SValUnion{I,N}) where {I,N} = N
@pure Base.length(::Type{SValUnion{I,N}}) where {I,N} = N

@pure StaticArrays.Length(::SValUnion{I,N}) where {I,N} = Length{N}()
@pure StaticArrays.Length(::Type{SValUnion{I,N}}) where {I,N} = Length{N}()

copy(::SVal{I,N,T}) where {I,N,T} = SVal{I,N,T}()

abs( ::SValUnion{I,1}) where I = abs(I)
abs2(::SValUnion{I,1}) where I = abs2(I)


