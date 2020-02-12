
to_axis(x) = Axis(x)
to_axis(x::AbstractAxis) = x

abstract type AxisIndices{T,N,Ax<:Tuple{Vararg{<:AbstractAxis,N}}} <: AbstractArray{T,N} end

@propagate_inbounds function Base.getindex(A::AxisIndices{T,N}, inds::Vararg{<:Any,N}) where {T,N}
    return Base.getindex(A, to_indices(A, axes(A), Tuple(inds))...)
end

@propagate_inbounds function Base.getindex(
    A::AxisIndices{T,N},
    inds::Vararg{Union{Integer,AbstractVector{Integer}},N}
   ) where {T,N}
    @boundscheck checkbounds(A, inds)
    @inbounds Base._getindex(A, inds...)
end

Base.axes(A::AxisIndices, i) = axes(A)[i]

Base.size(A::AxisIndices) = map(length, axes(A))
Base.size(A::AxisIndices, i) = length(axes(A, i))

Base.length(A::AxisIndices) = prod(size(A))

# AxisIndices _are_ the keys
Base.keys(A::AxisIndices) = A

"""
    CartesianAxes

## Examples
```jldoctest
julia> using StaticRanges

julia> cartaxes = CartesianAxes((Axis(2.0:5.0), Axis(1:4)));

julia> cartinds = CartesianIndices((1:4, 1:4));

julia> cartaxes[2, 2]
(2, 2)

julia> cartinds[2, 2]
CartesianIndex(2, 2)
```
"""
struct CartesianAxes{T<:Tuple,N,Ax} <: AxisIndices{T,N,Ax}
    axes::Ax
end

Base.axes(A::CartesianAxes) = getfield(A, :axes)

function CartesianAxes(a::Tuple{Vararg{<:AbstractAxis,N}}) where {N}
    return CartesianAxes{Tuple{eltype.(a)...},N,typeof(a)}(a)
end

function CartesianAxes(ks::Tuple{Vararg{<:Any,N}}) where {N}
    return CartesianAxes(map(to_axis, ks))
end

@propagate_inbounds function Base.getindex(A::CartesianAxes{T,N}, inds::Vararg{<:Integer,N}) where {T,N}
    return map(getindex, axes(A), inds)
end

"""
    LinearAxes

## Examples
```jldoctest
julia> using StaticRanges

julia> linaxes = LinearAxes((Axis(2.0:5.0), Axis(1:4)));

julia> lininds = LinearIndices((1:4, 1:4));

julia> linaxes[2, 2]
6

julia> lininds[2, 2]
6
```
"""
struct LinearAxes{T<:Integer,N,Ax} <: AxisIndices{T,N,Ax}
    axes::Ax
end

Base.axes(A::LinearAxes) = getfield(A, :axes)

function LinearAxes(a::Tuple{Vararg{<:AbstractAxis,N}}) where {N}
    return LinearAxes{promote_type(eltype.(a)...),N,typeof(a)}(a)
end

function LinearAxes(ks::Tuple{Vararg{<:Any,N}}) where {N}
    return LinearAxes(map(to_axis, ks))
end

@propagate_inbounds function Base.getindex(A::LinearAxes{T,N}, inds::Vararg{<:Integer,N}) where {T,N}
    return to_linear(A, axes(A), inds) # map(getindex, axes(A), inds)
end

#=
function _getindex(A::CartesianAxes, inds::Tuple{Vararg{Int}})
    Base.@_propagate_inbounds_meta
    return CartesianIndex(map(getindex, A.indices, inds))
    #return CartesianIndex(map((a, i) -> @inbounds(getindex(a, i)), A.indices, inds))
end

function _getindex(A::CartesianAxes, inds::Tuple)
    Base.@_propagate_inbounds_meta
    return CartesianIndices(map(getindex, A.indices, inds))
end

function Base.getindex(A::LinearAxes{N}, I::Vararg{Int,N}) where {N}
    Base.@_propagate_inbounds_meta
    return Base._getindex(IndexStyle(A), A, I...)
end
function Base.getindex(iter::LinearAxes, i::Int)
    Base.@_inline_meta
    @boundscheck checkbounds(iter, i)
    return i
end
 
function Base.getindex(A::LinearAxes, inds...)
    Base.@_propagate_inbounds_meta
    return _getindex(A, to_indices(A, A.indices, Tuple(inds)))
end

function _getindex(A::LinearAxes, inds::Tuple{Vararg{Int}})
    Base.@_propagate_inbounds_meta
    return getindex(A, inds...)
end

function _getindex(A::LinearAxes, inds::Tuple)
    Base.@_propagate_inbounds_meta
    return LinearIndices(map(getindex, A.indices, inds))
end
"""
    AxisIndices

Subtype of `AbstractArray` similar to CartesianIndices where indices are subtypes of `AbstractAxis`.

## Examples
```jldoctest
julia> using StaticRanges

julia> cartaxes = AxesIndices((Axis(2.0:5.0), Axis(1:4)));

julia> cartinds = CartesianIndices((1:4, 1:4));

julia> cartaxes[2, 2]
(2, 2)

julia> cartaxes[==(3.0), 2]
(2, 2)

julia> cartinds[2, 2]
CartesianIndex(2, 2)
```
"""
struct AxesIndices{T<:Tuple,N,Ax<:Tuple{Vararg{<:AbstractAxis,N}}} <: AbstractArray{T,N}
    axes::Ax
end

AxesIndices(a::Tuple) = AxesIndices(map(to_axis, a))
function AxesIndices(a::Tuple{Vararg{<:AbstractAxis,N}}) where {N}
    return AxesIndices{Tuple{eltype.(a)...},N,typeof(a)}(a)
end

Base.axes(A::AxesIndices) = getfield(A, :axes)
Base.axes(A::AxesIndices, i) = axes(A)[1]

Base.size(A::AxesIndices, i) = length(axes(A)[1])
Base.size(A::AxesIndices) = map(length, axes(A))

Base.IndexStyle(::Type{<:AxesIndices}) = IndexCartesian()

#=
@propagate_inbounds function Base.getindex(A::LinearAxes{T,N}, inds::Vararg{<:Any,N}) where {T,N}
    return _getindex(A, to_indices(A, axes(A), Tuple(inds)))
end
@propagate_inbounds function _getindex(A::LinearAxes, inds::Tuple{Vararg{Int}})
    return to_linear(A, axes(A), inds) # map(getindex, axes(A), inds)
end
@propagate_inbounds function _getindex(A::LinearAxes, inds::Tuple) where {N}
    return LinearAxes(map(getindex, axes(A), inds))
end
=#
# TODO if anything oher than a AbstractUnitRange{Int} is returned we can't return another 
=#
