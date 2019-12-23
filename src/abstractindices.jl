"""
    AbstractIndices

An `AbstractVector` subtype optimized for indexing.
"""
abstract type AbstractIndices{name,K,V<:Integer,Ks<:AbstractVector{K},Vs<:AbstractUnitRange{V}} <: AbstractUnitRange{V} end

Base.valtype(::Type{<:AbstractIndices{name,K,V,Ks,Vs}}) where {name,K,V,Ks,Vs} = V

"""
    values_type(::AbstractIndices)
"""
values_type(::T) where {T} = values_type(T)
values_type(::Type{<:AbstractIndices{name,K,V,Ks,Vs}}) where {name,K,V,Ks,Vs} = Vs

Base.keytype(::Type{<:AbstractIndices{name,K}}) where {name,K} = K

"""
    keys_type(::AbstractIndices)
"""
keys_type(::T) where {T} = keys_type(T)
keys_type(::Type{<:AbstractIndices{name,K,V,Ks,Vs}}) where {name,K,V,Ks,Vs} = Ks

Base.size(a::AbstractIndices) = (length(a),)

Base.firstindex(a::AbstractIndices) = first(keys(a))

Base.lastindex(a::AbstractIndices) = last(keys(a))

Base.haskey(a::AbstractIndices{name,K}, key::K) where {name,K} = key in keys(a)

Base.allunique(a::AbstractIndices) = true

Base.isempty(a::AbstractIndices) = isempty(values(a))

Base.in(a, itr::AbstractIndices) = in(x, values(a))

Base.eachindex(a::AbstractIndices) = keys(a)

Base.pairs(a::AbstractIndices) = Base.Iterators.Pairs(a, keys(a))

# FIXME
#Base.Slice(a::AbstractIndices) = x

for (f) in (:(==), :isequal)
    @eval begin
        Base.$(f)(a::AbstractIndices, b::AbstractIndices) = $(f)(values(a), values(b))
        Base.$(f)(a::AbstractIndices, b::AbstractVector) = $(f)(values(a), b)
        Base.$(f)(a::AbstractVector, b::AbstractIndices) = $(f)(a, values(b))
        Base.$(f)(a::AbstractIndices, b::OrdinalRange) = $(f)(values(a), b)
        Base.$(f)(a::OrdinalRange, b::AbstractIndices) = $(f)(a, values(b))
    end
end

for f in (:+, :-)
    @eval begin
        function Base.$(f)(x::AbstractIndices, y::AbstractIndices)
            if same_type(x, y)
                return similar_type(x)(combine_keys(x, y), +(values(x), values(y)))
            else
                return $(f)(promote(x, y)...)
            end
        end

        Base.$(f)(x::AbstractIndices, y::AbstractVector) = $(f)(promote(x, y)...)

        Base.$(f)(x::AbstractVector, y::AbstractIndices) = $(f)(promote(x, y)...)

        Base.$(f)(x::AbstractIndices, y::AbstractUnitRange) = $(f)(promote(x, y)...)

        Base.$(f)(x::AbstractUnitRange, y::AbstractIndices) = $(f)(promote(x, y)...)
    end
end

"""
    AbstractIndex
"""
abstract type AbstractIndex{name,K,V<:Integer} <: Integer end

Base.valtype(::Type{<:AbstractIndex{name,K,V}}) where {name,K,V} = V

Base.keytype(::Type{<:AbstractIndex{name,K,V}}) where {name,K,V} = K


for T in (:Bool, :Int8, :UInt8, :Int16, :UInt16, :Int32, :UInt32, :Int64, :UInt64, :Int128, :BigInt, :Unsigned, :Integer)
    @eval Base.$T(i::AbstractIndex) = $T(values(i))
end
