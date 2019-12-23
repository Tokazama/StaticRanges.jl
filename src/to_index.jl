struct ByKeyTrait end
const ByKey = ByKeyTrait()

struct ByValueTrait end
const ByValue = ByValueTrait()

"""
    index_by(a::AbstractIndices, i)

Returns `ByKey` if the index of `i` should be identified by searching the keys
and returns `ByValue` if the index of `i` should be identified directly from the
values.
"""
index_by(a::AbstractIndices{name,K}, i::Function) where {name,K} = ByKey

index_by(a::AbstractIndices{name,K}, i::K) where {name,K} = ByKey
index_by(a::AbstractIndices{name,K}, i::AbstractVector{K}) where {name,K} = ByKey

index_by(a::AbstractIndices{name,K}, i::K) where {name,K<:Integer} = ByKey
index_by(a::AbstractIndices{name,K}, i::AbstractVector{K}) where {name,K<:Integer} = ByKey

index_by(a::AbstractIndices{name,K}, i::I) where {name,K,I<:Integer} = ByValue
index_by(a::AbstractIndices{name,K}, i::AbstractVector{I}) where {name,K,I<:Integer} = ByValue

@inline @propagate_inbounds function Base.to_index(a::AbstractIndices, i)
    return _to_index(index_by(a, i), a, i)
end

# _to_index
# TODO find_all should be filter where possible
@propagate_inbounds function _to_index(b::ByKeyTrait, a, i::Function)
    return __to_index(a, i, find_all(i, keys(a)))
end
@propagate_inbounds function _to_index(b::ByKeyTrait, a, i::AbstractVector)
    return __to_index(a, i, find_all(in(i), keys(a)))
end
@propagate_inbounds function _to_index(b::ByKeyTrait, a, i)
    return __to_index(a, i, find_first(==(i), keys(a)))
end
@propagate_inbounds function _to_index(b::ByValueTrait, a, i::Function)
    return __to_index(a, i, find_all(i, values(a)))
end
@propagate_inbounds function _to_index(b::ByValueTrait, a, i)
    @boundscheck if !checkindex(Bool, values(a), i)
        throw(BoundsError(a, i))
    end
    return @inbounds getindex(values(a), i)
end
@propagate_inbounds function _to_index(b::ByValueTrait, a, i::AbstractVector)
    @boundscheck if !checkindex(Bool, values(a), i)
        throw(BoundsError(a, i))
    end
    return @inbounds unsafe_reindex(a, i)
end

# __to_index
@propagate_inbounds function __to_index(a, i, idx::T) where {T<:Union{Integer,Nothing}}
    @boundscheck if T <: Nothing
        throw(BoundsError(a, i))
    end
    return @inbounds getindex(values(a), idx)
end
@propagate_inbounds function __to_index(a, i, idx::AbstractVector{T}) where {T<:Union{Integer,Nothing}}
    @boundscheck if !(T<:Integer)
        throw(BoundsError(a, i))
    end
    return unsafe_reindex(a, idx)
end
