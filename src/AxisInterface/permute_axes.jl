
"""
    permute_axes(x::AbstractArray, p::Tuple) = permute_axes(axes(x), p)
    permute_axes(x::NTuple{N}, p::NTuple{N}) -> NTuple{N}

Returns axes of `x` in the order of `p`.

## Examples
```jldoctest
julia> using StaticRanges

julia> permute_axes(rand(2, 4, 6), (1, 3, 2))
(Base.OneTo(2), Base.OneTo(6), Base.OneTo(4))

julia> permute_axes((Axis(1:2), Axis(1:4), Axis(1:6)), (1, 3, 2))
(Axis(1:2 => Base.OneTo(2)), Axis(1:6 => Base.OneTo(6)), Axis(1:4 => Base.OneTo(4)))
```
"""
permute_axes(x::AbstractArray{T,N}, p) where {T,N} = permute_axes(axes(x), p)
permute_axes(x::NTuple{N,Any}, p::AbstractVector{<:Integer}) where {N} = Tuple(map(i -> getindex(x, i), p))
permute_axes(x::NTuple{N,Any}, p::NTuple{N,<:Integer}) where {N} = map(i -> getfield(x, i), p)

"""
    permute_axes(x::AbstractVector)

Returns the permuted axes of `x` as axes of size 1 × length(x)

## Examples
```jldoctest
julia> using StaticRanges

julia> permute_axes(rand(4))
(Base.OneTo(1), Base.OneTo(4))

julia> permute_axes((Axis(1:4),))
(SimpleAxis(Base.OneTo(1)), Axis(1:4 => Base.OneTo(4)))
```
"""
permute_axes(x::AbstractVector) = permute_axes(axes(x))
function permute_axes(x::Tuple{Ax}) where {Ax<:AbstractUnitRange}
    if is_static(Ax)
        return (SimpleAxis(OneToSRange(1)), first(x))
    elseif is_fixed(Ax)
        return (SimpleAxis(Base.OneTo(1)), first(x))
    else  # is_dynamic(Ax)
        return (SimpleAxis(OneToMRange(1)), first(x))
    end
end

"""
    permute_axes(m::AbstractMatrix) -> NTuple{2}

Permute the axes of the matrix `m`, by flipping the elements across the diagonal
of the matrix. Differs from LinearAlgebra's transpose in that the operation is
not recursive.

## Examples
```jldoctest
julia> using StaticRanges

julia> permute_axes(rand(4, 2))
(Base.OneTo(2), Base.OneTo(4))

julia> permute_axes((Axis(1:4), Axis(1:2)))
(Axis(1:2 => Base.OneTo(2)), Axis(1:4 => Base.OneTo(4)))
```
"""
permute_axes(x::AbstractMatrix) = permute_axes(axes(x))
permute_axes(x::NTuple{2,Any}) = (last(x), first(x))

