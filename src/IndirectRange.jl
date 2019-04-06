"""
    IndirectRange

An `IndirectRange` provides one degree of indirection when accessing a parent range. This
may be used to access a subset of a parent range (similar to `SubArray`)
"""
struct IndirectRange{T,P<:StaticRange,I<:StaticRange} <: AbstractRange{T} end

function getindex(r::IndirectRange{T,P,I}, i) where {T,P,I}
    @boundscheck checkbounds(r, i)
    @inbounds P()[I()[i]]
end


