function indices(si::StaticIndices{S,I,T,N,L}, ::SVal{i,Int}) where {S,I,T,N,L,i}
    fieldtype(I, i::Int)()
end

first(si::StaticIndices, idx::SVal) = first(indices(si, idx))
static_first(si::StaticIndices, idx::SVal) = static_first(indices(si, idx))

last(si::StaticIndices, idx::SVal) = last(indices(si, idx))
static_last(si::StaticIndices, idx::SVal) = static_last(indices(si, idx))

step(si::StaticIndices, idx::SVal) = step(indices(si, idx))
static_step(si::StaticIndices, idx::SVal) = static_step(indices(si, idx))

firstindex(si::StaticIndices, idx::SVal) = firstindex(indices(si, idx))
static_firstindex(si::StaticIndices, idx::SVal) = static_firstindex(indices(si, idx))

lastindex(si::StaticIndices, idx::SVal) = lastindex(indices(si, idx))
static_lastindex(si::StaticIndices, idx::SVal) = static_lastindex(indices(si, idx))

