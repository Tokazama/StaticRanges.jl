
to_axis(x) = Axis(x)
to_axis(x::AbstractAxis) = x

"""
    CartesianAxes

Alias for LinearIndices where indices are subtypes of `AbstractAxis`.

```jldoctest
julia> using StaticRanges

julia> cartaxes = CartesianAxes((Axis(2.0:5.0), Axis(1:4)));

julia> cartinds = CartesianIndices((1:4, 1:4));

julia> cartaxes[2, 2]
CartesianIndex(2, 2)

julia> cartinds[2, 2]
CartesianIndex(2, 2)
```
"""
const CartesianAxes{N,R<:Tuple{Vararg{<:AbstractAxis,N}}} = CartesianIndices{N,R}

CartesianAxes(ks::Tuple{Vararg{<:Any,N}}) where {N} = CartesianIndices(to_axis.(ks))
CartesianAxes(ks::Tuple{Vararg{<:AbstractAxis,N}}) where {N} = CartesianIndices(ks)


function Base.getindex(A::CartesianAxes{N}, inds::Vararg{Int,N}) where {N}
    Base.@_propagate_inbounds_meta
    return CartesianIndex(map(getindex, A.indices, inds))
end
function Base.getindex(A::CartesianAxes, inds...)
    Base.@_propagate_inbounds_meta
    return _getindex(A, to_indices(A, A.indices, Tuple(inds)))
end

function _getindex(A::CartesianAxes, inds::Tuple{Vararg{Int}})
    Base.@_propagate_inbounds_meta
    return CartesianIndex(map(getindex, A.indices, inds))
    #return CartesianIndex(map((a, i) -> @inbounds(getindex(a, i)), A.indices, inds))
end

function _getindex(A::CartesianAxes, inds::Tuple)
    Base.@_propagate_inbounds_meta
    return CartesianIndices(map(getindex, A.indices, inds))
end

"""
    LinearAxes

Alias for LinearIndices where indices are subtypes of `AbstractAxis`.

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
const LinearAxes{N,R<:Tuple{Vararg{<:AbstractAxis,N}}} = LinearIndices{N,R}

LinearAxes(ks::Tuple{Vararg{<:Any,N}}) where {N} = LinearIndices(to_axis.(ks))
LinearAxes(ks::Tuple{Vararg{<:AbstractAxis,N}}) where {N} = LinearIndices(ks)


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

@propagate_inbounds function Base.to_indices(A, inds::Tuple{<:AbstractAxis, Vararg{Any}}, I::Tuple{Any, Vararg{Any}})
    Base.@_inline_meta
    (to_index(first(inds), first(I)), to_indices(A, maybetail(inds), tail(I))...)
end

@propagate_inbounds function Base.to_indices(A, inds::Tuple{<:AbstractAxis, Vararg{Any}}, I::Tuple{Colon, Vararg{Any}})
    Base.@_inline_meta
    (values(first(inds)), to_indices(A, maybetail(inds), tail(I))...)
end

@propagate_inbounds function Base.to_indices(A, inds::Tuple{<:AbstractAxis, Vararg{Any}}, I::Tuple{CartesianIndex{1}, Vararg{Any}})
    Base.@_inline_meta
    (to_index(first(inds), first(I)), to_indices(A, maybetail(inds), tail(I))...)
end

maybetail(::Tuple{}) = ()
maybetail(t::Tuple) = tail(t)


# TODO if anything oher than a AbstractUnitRange{Int} is returned we can't return another 
