"""
    reindex(a::AbstractAxis, inds::AbstractVector{Integer}) -> AbstractAxis

Returns and index of the same type as `a` where the keys the new keys are
constructed by indexing into the keys of `a` with `inds` and the values have the
same starting value but a length matching `inds`.

## Examples
```jldoctest
julia> x, y, z = Axis(1:10, 2:11), Axis(1:10), SimpleAxis(1:10);

julia> reindex(x, collect(1:2:10))
Axis([1, 3, 5, 7, 9] => 2:6)

julia> reindex(y, collect(1:2:10))
Axis([1, 3, 5, 7, 9] => Base.OneTo(5))

julia> reindex(z, collect(1:2:10))
SimpleAxis(1:5)
```
"""
@propagate_inbounds function reindex(a::AbstractAxis, inds)
    return unsafe_reindex(a, to_index(a, inds))
end

"""
    unsafe_reindex(a::AbstractAxis, inds::AbstractVector) -> AbstractAxis

Similar to `reindex` this function returns an index of the same type as `a` but
doesn't check that `inds` is inbounds. New subtypes of `AbstractAxis` must
implement a unique `unsafe_reindex` method.

See also: [`reindex`](@ref)
"""
function unsafe_reindex(a::AbstractAxis, inds)
    error("New subtypes of `AbstractAxis` must implement a unique `unsafe_reindex` method.")
end
function unsafe_reindex(a::Axis{name}, inds) where {name}
    return Axis{name}(
        @inbounds(keys(a)[inds]),
        _reindex(values(a), inds),
        AllUnique,
        LengthChecked
       )
end
function unsafe_reindex(a::SimpleAxis{name}, inds) where {name}
    return SimpleAxis{name}(_reindex(values(a), inds))
end

_reindex(a::OneTo{T}, inds) where {T} = OneTo{T}(length(inds))
_reindex(a::OneToMRange{T}, inds) where {T} = OneToMRange{T}(length(inds))
_reindex(a::OneToSRange{T}, inds) where {T} = OneToSRange{T}(length(inds))
_reindex(a::T, inds) where {T<:AbstractUnitRange} = T(first(a), first(a) + length(inds) - 1)
