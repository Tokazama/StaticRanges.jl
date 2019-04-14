indices(si::StaticIndices{I,S,T,N,L}, idx::SVal{i,Int}) where {I,S,T,N,L,i} =
    _indices(si, fieldtype(I, i), idx)

_indices(si::StaticIndices, ::I, idx::SVal{i,Int}) where {I<:DynamicSRange,i} = si.indices[i]
_indices(si::StaticIndices, ::I, idx::SVal{i,Int}) where {I<:AbstractSRange,i} = I()

first(si::StaticIndices, idx::SVal) = first(indices(si, idx))
sfirst(si::StaticIndices, idx::SVal) = sfirst(indices(si, idx))

last(si::StaticIndices, idx::SVal) = last(indices(si, idx))
slast(si::StaticIndices, idx::SVal) = slast(indices(si, idx))

step(si::StaticIndices, idx::SVal) = step(indices(si, idx))
sstep(si::StaticIndices, idx::SVal) = sstep(indices(si, idx))

firstindex(si::StaticIndices, idx::SVal) = firstindex(indices(si, idx))
sfirstindex(si::StaticIndices, idx::SVal) = sfirstindex(indices(si, idx))

lastindex(si::StaticIndices, idx::SVal) = lastindex(indices(si, idx))
slastindex(si::StaticIndices, idx::SVal) = slastindex(indices(si, idx))



