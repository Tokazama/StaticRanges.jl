struct LinearSIndices{I,S,N,L} <: StaticIndices{I,S,Int,N,L}
    indices::I
end

function LinearSIndices(inds::NTuple{N,Int}) where N
    sinds = (map(i->srange(SVal(1),stop=SVal(i)), inds)...)
    LinearSIndices{typeof(sinds),Tuple{inds...},N,prod(inds)}(sinds)
end

LinearSIndices(inds::Tuple{<:Vararg{AbstractRange,N}}) =
    LinearSIndices((map(i -> srange(i), inds)...,))

#
LinearSIndices(inds::Tuple{<:Vararg{<:AbstractSRange,N}}) where N =
    LinearSIndices{typeof(inds),Tuple{length.(inds)...},N}(inds)

LinearSIndices{I,S,N}(inds::Tuple{<:Vararg{<:AbstractSRange,N}}) where {I,S,N} =
    LinearSIndices{I,S,N,prod(S.parameters)}(inds)




