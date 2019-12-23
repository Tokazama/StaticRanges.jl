"""
    reindex(a::AbstractIndices, inds::AbstractVector{Integer}) -> AbstractIndices

Returns and index of the same type as `a` where the keys the new keys are
constructed by indexing into the keys of `a` with `inds` and the values have the
same starting value but a length matching `inds`.

## Examples
```jldoctest
julia> x, y, z = Indices(1:10, 2:11), Indices(1:10), SimpleIndices(1:10);

julia> reindex(x, collect(1:2:10))
Indices([1, 3, 5, 7, 9] => 2:6)

julia> reindex(y, collect(1:2:10))
Indices([1, 3, 5, 7, 9] => Base.OneTo(5))

julia> reindex(z, collect(1:2:10))
SimpleIndices(1:5)
```
"""
function reindex(a::AbstractIndices, inds::AbstractVector{T}) where {T<:Integer}
    @boundscheck checkbounds(a, inds)
    return unsafe_reindex(a, inds)
end

"""
    unsafe_reindex(a::AbstractIndices, inds::AbstractVector) -> AbstractIndices

Similar to `reindex` this function returns an index of the same type as `a` but
doesn't check that `inds` is inbounds. New subtypes of `AbstractIndices` must
implement a unique `unsafe_reindex` method.

See also: [`reindex`](@ref)
"""
function unsafe_reindex(a::AbstractIndices, inds)
    error("New subtypes of `AbstractIndices` must implement a unique `unsafe_reindex` method.")
end
function unsafe_reindex(a::Indices{name}, inds) where {name}
    return Indices{name}(
        @inbounds(keys(a)[inds]),
        _reindex(values(a), inds),
        AllUnique,
        LengthChecked
       )
end
function unsafe_reindex(a::SimpleIndices{name}, inds) where {name}
    return SimpleIndices{name}(_reindex(values(a), inds))
end

_reindex(a::OneTo{T}, inds) where {T} = OneTo{T}(length(inds))
_reindex(a::OneToMRange{T}, inds) where {T} = OneToMRange{T}(length(inds))
_reindex(a::OneToSRange{T}, inds) where {T} = OneToSRange{T}(length(inds))
_reindex(a::T, inds) where {T<:AbstractUnitRange} = T(first(a), first(a) + length(inds) - 1)
