struct CartesianSIndices{I,S,N,L} <: StaticIndices{I,S,Int,N,L}
    indices::I
end

function CartesianSIndices(inds::NTuple{N,Int}) where N
    sinds = (map(i->srange(SVal(1),stop=SVal(i)), inds)...)
    CartesianSIndices{typeof(sinds),Tuple{inds...},N,prod(inds)}(sinds)
end

CartesianSIndices(inds::Tuple{<:Vararg{AbstractRange,N}}) =
    CartesianSIndices((map(i -> srange(i), inds)...,))

#
CartesianSIndices(inds::Tuple{<:Vararg{<:AbstractSRange,N}}) where N =
    CartesianSIndices{typeof(inds),Tuple{length.(inds)...},N}(inds)

CartesianSIndices{I,S,N}(inds::Tuple{<:Vararg{<:AbstractSRange,N}}) where {I,S,N} =
    CartesianSIndices{I,S,N,prod(S.parameters)}(inds)



