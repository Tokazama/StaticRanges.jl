
using StaticArrays

import Base: names, length, ndims, axes


abstract type NamedIndices{names,S,T,N,L} <: StaticArray{S,T,N} end

@pure length(a::NamedIndices{names,N,S,T,N,L}) where {names,N,S,T,N,L} = L::Int
@pure ndims(a::NamedIndices{names,N,S,T,N,L}) where {names,N,S,T,N,L} = N::Int
@pure names(a::NamedIndices{names,N,S,T,N,L}) where {names,N,S,T,N,L} = names

@inline axes(a::NamedIndices{names,N,S,T,N,L}, i::Int) where {names,N,S,T,N,L} =
    (names[i] = SOneTo{size(a, i)}(),)

@inline axes(a::NamedIndices{names,N,S,T,N,L}) where {names,N,S,T,N,L} =
    NamedTuple{names}()







@inline Base.getproperty(x::NamedIndices, s::Symbol) = __getindex(x, Val(s))
@inline getindex(x::NamedIndices, s::Symbol) = __getindex(x, Val(s))
@inline getindex(x::NamedIndices{names,N,Ax}, i::Int) where {names,N,Ax} = fieldtype(Ax,i)()

@inline @generated function __getindex(::NamedIndices{names,N,Ax}, ::Val{s}) where {names,Ax,s}
    idx = findfirst(y -> y == s, names)
    :(fieldtype(Ax, $idx))
end

struct NLinearIndices{names,N,Ax} <: NamedIndices{names,Int,N,Ax} end

struct NCartesianIndices{names,N,Ax} <: NamedIndices{names,CartesianIndex{N},N,Ax} end

