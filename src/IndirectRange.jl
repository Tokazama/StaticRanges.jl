"""
    IndirectRange

An `IndirectRange` provides one degree of indirection when accessing a parent range. This
may be used to access a subset of a parent range (similar to `SubArray`)
"""
struct IndirectRange{T,P<:AbstractVector{T},I<:AbstractVector} <: AbstractRange{T}
    parent::R
    index::I
end


