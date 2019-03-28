"""
    IndirectRange

An `IndirectRange` provides one degree of indirection when accessing a parent range. This
may be used to access a subset of a parent range (similar to `SubArray`)
"""
struct IndirectRange{T,P<:AbstractVector{T},I<:AbstractVector} <: AbstractRange{T}
    parent::R
    index::I
end

struct NamedRange{T,names,I<:AbstractRange{T}} <: AbstractRange{T}
    index::I

    function NamedRange(names::NTuple{N,Symbol}, index::AbstractRange{T}) where {N,T}
        if N != length(index)
            throw()  # TODO
        end
        new{T,names,typeof(index)}(index)
    end
end
Base.propertynames(::NamedRange{T,names}) where {T,names} = names
@inline Base.getproperty(x::NamedRange, s::Symbol) = __getindex(x, Val(s))
@inline Base.getindex(x::NamedRange, s::Symbol) = __getindex(x, Val(s))

@inline function getindex(x::NamedRange, i::Int) where {T,names,Ax}
    @boundscheck checkbounds(x, i) # TODO: checkbounds for NamedRange
    @inbounds x.index[i]
end

@inline @generated function __getindex(x::NamedRange{T,names}, ::Val{s}) where {T,names,s}
    idx = findfirst(y -> y==s, names)
    # if idx does not throw error then it must be inbounds b/c it should be check at time
    # of construction
    :((@inbounds x[idx]))
end




function getindex()
end
