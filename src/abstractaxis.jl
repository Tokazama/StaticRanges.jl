"""
    AbstractAxis

An `AbstractUnitRange` subtype optimized for indexing.
"""
abstract type AbstractAxis{name,K,V<:Integer,Ks,Vs} <: AbstractUnitRange{V} end

Base.valtype(::Type{<:AbstractAxis{name,K,V,Ks,Vs}}) where {name,K,V,Ks,Vs} = V

"""
    values_type(::AbstractAxis)
"""
values_type(::T) where {T} = values_type(T)
values_type(::Type{<:AbstractAxis{name,K,V,Ks,Vs}}) where {name,K,V,Ks,Vs} = Vs

Base.keytype(::Type{<:AbstractAxis{name,K}}) where {name,K} = K

"""
    keys_type(::AbstractAxis)
"""
keys_type(::T) where {T} = keys_type(T)
keys_type(::Type{<:AbstractAxis{name,K,V,Ks,Vs}}) where {name,K,V,Ks,Vs} = Ks

Base.size(a::AbstractAxis) = (length(a),)

Base.firstindex(a::AbstractAxis) = first(keys(a))

Base.lastindex(a::AbstractAxis) = last(keys(a))

Base.haskey(a::AbstractAxis{name,K}, key::K) where {name,K} = key in keys(a)

Base.allunique(a::AbstractAxis) = true

Base.isempty(a::AbstractAxis) = isempty(values(a))

Base.in(a, itr::AbstractAxis) = in(x, values(a))

Base.eachindex(a::AbstractAxis) = keys(a)
