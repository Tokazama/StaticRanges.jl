
# TODO this might be completely unecessary
to_axis(x) = Axis(x)
to_axis(x::AbstractAxis) = x
to_axis(x::Integer) = SimpleAxis(OneTo(x))

abstract type AxisIndices{T,N,Ax<:Tuple{Vararg{<:AbstractAxis,N}}} <: AbstractArray{T,N} end

@propagate_inbounds function Base.getindex(A::AxisIndices{T,N}, inds::Vararg{<:Any,N}) where {T,N}
    return Base.getindex(A, to_indices(A, axes(A), Tuple(inds))...)
end

@propagate_inbounds function Base.getindex(
    A::AxisIndices{T,N},
    inds::Vararg{Union{Integer,<:AbstractVector{<:Integer}},N}
   ) where {T,N}
    @boundscheck checkbounds(A, inds...)
    @inbounds Base._getindex(IndexStyle(A), A, inds...)
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

function CartesianAxes(x::Tuple{Vararg{<:AbstractAxis,N}}) where {N}
    return CartesianAxes{Tuple{eltype.(x)...},N,typeof(x)}(x)
end

function CartesianAxes(x::Tuple{Vararg{<:Any,N}}) where {N}
    return CartesianAxes(map(to_axis, x))
end

@propagate_inbounds function Base.getindex(A::CartesianAxes{T,N}, inds::Vararg{<:Integer,N}) where {T,N}
    return map(getindex, axes(A), inds)
end

@inline Base.first(A::CartesianAxes) = map(first, axes(A))

@inline Base.last(A::CartesianAxes) = map(last, axes(A))

function Base.similar(A::CartesianAxes{T}, dims::Tuple{Vararg{<:Integer}}=size(A)) where {T}
    return Array{NTuple{length(dims),eltype(T)}}(undef, dims)
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
struct LinearAxes{T<:Integer,N,Ax<:Tuple{Vararg{<:AbstractAxisBaseOne,N}}} <: AxisIndices{T,N,Ax}
    axes::Ax
end

Base.axes(A::LinearAxes) = getfield(A, :axes)

function LinearAxes(x::Tuple{Vararg{<:AbstractAxis,N}}) where {N}
    return LinearAxes{promote_type(eltype.(x)...),N,typeof(x)}(x)
end

function LinearAxes(x::Tuple{Vararg{<:Any,N}}) where {N}
    return LinearAxes(map(to_axis, x))
end

@propagate_inbounds function Base.getindex(A::LinearAxes{T,N}, inds::Vararg{<:Integer,N}) where {T,N}
    return to_linear(A, axes(A), inds) # map(getindex, axes(A), inds)
end

@inline Base.first(A::LinearAxes) = to_linear(A, axes(A), map(first, axes(A)))

@inline Base.last(A::LinearAxes) = to_linear(A, axes(A), map(last, axes(A)))

function Base.similar(A::LinearAxes{T}, dims::Tuple{Vararg{<:Integer}}=size(A)) where {T}
    return Array{T}(undef, dims)
end

Base.eachindex(A::LinearAxes) = OneTo(length(A))

