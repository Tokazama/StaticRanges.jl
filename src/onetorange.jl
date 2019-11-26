"""
    OneToRange

Supertype for `OneToSRange` and `OneToMRange`. It's subtypes should behave
identically to `Base.OneTo`.
"""
abstract type OneToRange{T<:Integer} <: AbstractUnitRange{T} end

Base.firstindex(::OneToRange) = 1

Base.lastindex(r::OneToRange) = Int(last(r))

Base.issubset(r::OneToRange, s::OneTo) = last(r) <= last(s)
Base.issubset(r::OneToRange, s::OneToRange) = last(r) <= last(s)
Base.issubset(r::OneTo, s::OneToRange) = last(r) <= last(s)

Base.mod(i::Integer, r::OneToRange) = Base.mod1(i, last(r))

"""
    OneToSRange

A static range that parallels `OneTo` in behavior.
"""
struct OneToSRange{T<:Integer,E} <: OneToRange{T}
    OneToSRange{T}(stop::T) where {T} = new{T,max(zero(T), stop)}()
    OneToSRange{T}(stop::Number) where {T} = new{T,max(zero(T),T(stop))}()
end

function OneToSRange{T}(r::AbstractRange) where {T<:Integer}
    first(r) == 1 || (Base.@_noinline_meta; throw(ArgumentError("first element must be 1, got $(first(r))")))
    step(r)  == 1 || (Base.@_noinline_meta; throw(ArgumentError("step must be 1, got $(step(r))")))
    return OneToSRange(last(r))
end
OneToSRange{T,<:Any}(r::OneToSRange{T}) where {T<:Integer} = r
OneToSRange{T}(r::OneToRange) where {T<:Integer} = OneToSRange{T}(last(r))
OneToSRange(stop::T) where {T<:Integer} = OneToSRange{T}(stop)
OneToSRange(r::AbstractRange{T}) where {T<:Integer} = OneToSRange{T}(r)
(::Type{<:OneToSRange{T,<:Any}})(r::AbstractRange) where {T<:Integer} = OneToSRange{T}(r)

function Base.getproperty(r::OneToSRange, s::Symbol)
    if s === :stop
        return last(r)
    else
        error("type $(typeof(r)) has no property $s")
    end
end

"""
    OneToMRange

A mutable range that parallels `OneTo` in behavior.
"""
mutable struct OneToMRange{T<:Integer} <: OneToRange{T}
    stop::T

    OneToMRange{T}(stop) where {T<:Integer} = new(max(zero(T), stop))
end

function OneToMRange{T}(r::AbstractRange) where {T<:Integer}
    first(r) == 1 || (Base.@_noinline_meta; throw(ArgumentError("first element must be 1, got $(first(r))")))
    step(r)  == 1 || (Base.@_noinline_meta; throw(ArgumentError("step must be 1, got $(step(r))")))
    return OneToMRange(last(r))
end
OneToMRange{T}(r::OneToMRange{T}) where {T<:Integer} = r
OneToMRange{T}(r::OneToRange) where {T<:Integer} = OneToMRange{T}(last(r))
OneToMRange(stop::T) where {T<:Integer} = OneToMRange{T}(stop)
OneToMRange(r::AbstractRange{T}) where {T<:Integer} = OneToMRange{T}(r)
#OneToMRange{T}(r::OneTo) where {T} = OneToMRange{T}(T(last(r)))

Base.AbstractUnitRange{T}(r::OneToSRange) where {T} = OneToSRange{T}(r)
Base.AbstractUnitRange{T}(r::OneToMRange) where {T} = OneToMRange{T}(r)
