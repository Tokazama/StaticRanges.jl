
"""
    reindex(a::AbstractAxis, inds::AbstractVector{Integer}) -> AbstractAxis

Returns and index of the same type as `a` where the keys the new keys are
constructed by indexing into the keys of `a` with `inds` and the values have the
same starting value but a length matching `inds`.

## Examples
```jldoctest
julia> using StaticRanges

julia> x, y, z = Axis(1:10, 2:11), Axis(1:10), SimpleAxis(1:10);

julia>  reindex(x, collect(1:2:10))
Axis([1, 3, 5, 7, 9] => 2:6)

julia> reindex(y, collect(1:2:10))
Axis([1, 3, 5, 7, 9] => Base.OneTo(5))

julia> reindex(z, collect(1:2:10))
SimpleAxis(1:5)

```
"""
@propagate_inbounds reindex(a::AbstractAxis, inds) = unsafe_reindex(a, to_index(a, inds))

"""
    unsafe_reindex(a::AbstractAxis, inds::AbstractVector) -> AbstractAxis

Similar to `reindex` this function returns an index of the same type as `a` but
doesn't check that `inds` is inbounds. New subtypes of `AbstractAxis` must
implement a unique `unsafe_reindex` method.

See also: [`reindex`](@ref)

## Examples
```jldoctest
julia> using StaticRanges

julia> StaticRanges.unsafe_reindex(SimpleAxis(OneToMRange(10)), 1:5)
SimpleAxis(OneToMRange(5))

julia> StaticRanges.unsafe_reindex(SimpleAxis(OneToSRange(10)), 1:5)
SimpleAxis(OneToSRange(5))
```
"""
function unsafe_reindex(a::AbstractAxis, inds)
    error("New subtypes of `AbstractAxis` must implement a unique `unsafe_reindex` method.")
end
unsafe_reindex(a::Axis, inds) = Axis(@inbounds(keys(a)[inds]), _reindex(values(a), inds))
unsafe_reindex(a::SimpleAxis, inds) = SimpleAxis(_reindex(values(a), inds))

_reindex(a::OneTo{T}, inds) where {T} = OneTo{T}(length(inds))
_reindex(a::OneToMRange{T}, inds) where {T} = OneToMRange{T}(length(inds))
_reindex(a::OneToSRange{T}, inds) where {T} = OneToSRange{T}(length(inds))
_reindex(a::T, inds) where {T<:AbstractUnitRange} = T(first(a), first(a) + length(inds) - 1)

