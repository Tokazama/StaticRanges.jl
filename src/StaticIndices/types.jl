abstract type StaticIndices{S,T,N,L} <: StaticArray{S,T,N} end

@inline StaticIndices(A::AbstractArray) = SubIndices(IndexStyle(A), A)
@inline StaticIndices(::IndexLinear, A) = LinearSIndices(A)
@inline StaticIndices(::IndexCartesian, A) = CartesianSIndices(A)

@pure length(::StaticIndices{S,T,N,L}) where {S,T,N,L} = L::Int
@pure length(::Type{<:StaticIndices{S,T,N,L}}) where {S,T,N,L} = L::Int

"""
    LinearSIndices

```jldoctest
julia> A = reshape([1:30...], (5,6));

julia> li = LinearIndices((5,4,3,2,2));

julia> sli = LinearSIndices((5,4,3,2,2));

julia> inds = (srange(2:3), srange(2:3), srange(1:3), srange(1:2), srange(1:2))

julia> subli = SubLinearIndices(sli, inds)

julia> subli[1] == sli[inds...][1] == li[inds...][1]

julia> subli[2] == sli[inds...][2] == li[inds...][2]

julia> subli[3] == sli[inds...][3] == li[inds...][3]

```
"""
struct LinearSIndices{S<:Tuple,N,L} <: StaticIndices{S,Int,N,L} end
@inline function LinearSIndices{S}() where S
    LinearSIndices{S,length(S.parameters),prod(S.parameters)}()
end

@inline LinearSIndices(A::StaticArray{S,T,N}) where {S<:Tuple,T,N} = LinearSIndices{S}()
@inline LinearSIndices(A::AbstractArray{T,N}) where {T,N} = LinearSIndices(size(A))
@inline LinearSIndices(inds::Tuple{Vararg{<:StaticRange{Int},N}}) where N = LinearSIndices(map(length. ax))
@inline LinearSIndices(ax::Vararg{<:StaticRange,N}) where N = LinearSIndices(map(length. ax))
@inline LinearSIndices(s::NTuple{N,Int}) where N = LinearSIndices{Tuple{s...}}()

function getindex(inds::LinearSIndices{S,N,L}, i::Int) where {S,N,L}
    @_propagate_inbounds_meta
    @boundscheck checkbounds(inds, i)
    return i
end

@pure @inline function getindex(inds::LinearSIndices{S,N,L}, i::Int, ii::Int...) where {S,N,L}
    @_propagate_inbounds_meta
    @boundscheck checkbounds(inds, i, ii...)
    stride = 1
    s2i = i
    for D in 2:N
        stride *= size(inds, D-1)
        s2i +=  stride * (ii[D-1] - 1)
    end
    s2i
end

"""
    CartesianSIndices
"""
struct CartesianSIndices{S,N,L} <: StaticIndices{S,CartesianIndex{N},N,L} end
@inline function CartesianSIndices{S}() where S
    CartesianSIndices{S,length(S.parameters),prod(S.parameters)}()
end

# tmpfunc(x) = @inbounds x[1,1]
@generated function getindex(inds::CartesianSIndices{S,N,L}, i::Int) where {S,N,L}
    i2s = Vector{Expr}(undef, N)
    ind = :(i - 1)
    indnext = :()
    for D in 1:N
        indnext = :(div($ind, size(inds, $D)))
        i2s[D] = :($ind - size(inds, $D) * $indnext + 1)
        ind = indnext
    end
    return quote
        @_propagate_inbounds_meta
        @boundscheck checkbounds(inds, i)
        CartesianIndex($(i2s...))
    end
end

function getindex(inds::CartesianSIndices{S,N,L}, i::Int, ii::Int...) where {S,N,L}
    @_propagate_inbounds_meta
    @boundscheck checkbounds(inds, (i, ii...))
    return CartesianIndex(i, ii...)
end
