abstract type StaticIndices{S,T,N,L,I} <: StaticArray{S,T,N} end

#Base.length(si::StaticIndices{S,T,N,L,I}) where {S,T,N,L,I} = L

Base.axes(si::StaticIndices{S,T,N,Dynamic,I}) where {S,T,N,I} =
    error("axes is not implemented for type $(typeof(si))")

@pure length(li::StaticIndices{S,T,N,L,I}) where {S,T,N,L<:SInteger,I} = L()
@pure length(li::Type{<:StaticIndices{S,T,N,L,I}}) where {S,T,N,L<:SInteger,I} = L()

Base.length(si::StaticIndices{S,T,N,Dynamic,I}) where {S,T,N,I} = prod(size(si))

abstract type StaticLinearIndices{S,T,N,L,I} <: StaticIndices{S,T,N,L,I} end

abstract type StaticCartesianIndices{S,T,N,L,I} <: StaticIndices{S,T,N,L,I} end

static_or_dynamic(x::T) where T<:SVal = values(x)
static_or_dynamic(x::T) where T<:BaseNumber = Dynamic


_indices_sizes(inds::Tuple) = Tuple{static_or_dynamic(length(first(inds))), _indices_sizes(Base.tail(inds))...}
_indices_sizes(inds::Tuple{}) = ()


struct LinearSIndices{S,T,N,L,I} <: StaticLinearIndices{S,T,N,L,I} end

LinearSIndices(indices::Tuple{Vararg{<:SRange{T},N}}) where {T,N} =
    LinearSIndices{Tuple{map(i->values(length(i)), indicies)...},T,N,values(prod(length.(indices))),typeof(indices)}()

Base.axes(li::LinearSIndices{S,T,N,L,I}, i::Integer) where {S,T,N,L,I} = fieldtype(I, values(i))
Base.axes(li::LinearSIndices{S,T,N,L,I}) where {S,T,N,L,I} = ntuple(i -> axes(li, i), N)::I


mutable struct LinearMIndices{S,T,N,I} <: StaticLinearIndices{S,T,N,Dynamic,I}
    indices::I
end

LinearMIndices(indices::Tuple{Vararg{<:AbstractRange{T},N}}) where {T,N} =
    LinearMIndices{_indices_sizes(indices),T,N,Dynamic,typeof(indices)}(indices)

Base.axes(li::LinearMIndices{S,T,N,I}) where {S,T,N,I} = li.indices::I
Base.axes(li::LinearMIndices, i::Integer) = li.indices[i]
Base.size(li::LinearMIndices, i::Integer) = length(li.indices[i])
Base.size(li::LinearMIndices) = length.(li.indices)




struct CartesianSIndices{S,T,N,L,I} <: StaticCartesianIndices{S,T,N,L,I} end

function CartesianSIndices(indices::Tuple{Vararg{<:SRange,N}}) where {N}
    CartesianSIndices{Tuple{map(i->values(length(i)), indicies)...},
                      Tuple{eltype.(indices)...},N,
                      values(prod(length.(indices))),typeof(indices)}()
end

Base.axes(li::CartesianSIndices{S,T,N,L,I}, i::Integer) where {S,T,N,L,I} = fieldtype(I, values(i))
Base.axes(li::CartesianSIndices{S,T,N,L,I}) where {S,T,N,L,I} = ntuple(i -> axes(li, i), N)::I
Base.length(li::CartesianSIndices{S,T,N,L,I}) where {S,T,N,L,I} = L

mutable struct CartesianMIndices{S,T,N,I} <: StaticCartesianIndices{S,T,N,Dynamic,I}
    indices::I
end

Base.axes(ci::CartesianMIndices{S,T,N,I}) where {S,T,N,I} = ci.indices::I
Base.axes(ci::CartesianMIndices, i::Integer) = ci.indices[i]

function CartesianMIndices(indices::Tuple{Vararg{<:AbstractRange{T},N}}) where {T,N}
    CartesianMIndices{_indices_sizes(indices),
                      Tuple{eltype.(indices)...},N,Dynamic,typeof(indices)}(indices)
end

first(si::StaticIndices, i::Integer) = first(axes(si, i))

last(si::StaticIndices, i::Integer) = last(axes(si, i))

step(si::StaticIndices, i::Integer) = step(axes(si, i))

firstindex(si::StaticIndices, i::Integer) = firstindex(axes(si, i))

lastindex(si::StaticIndices, i::Integer) = lastindex(axes(si, i))


Base.show(io::IO, si::StaticIndices) = showindices(io, si)
Base.show(io::IO, ::MIME"text/plain", si::StaticIndices) = showindices(io, si)

function showindices(io::IO, si::StaticIndices{S,T,N}) where {S,T,N}
    for i in 1:N
        print(io, "$(axes(si, i))\n")
    end
end


@inline function getindex(inds::StaticLinearIndices{S,N,L}, i::Int, ii::Int...) where {S,N,L}
    Base.@_propagate_inbounds_meta
    @boundscheck checkbounds(inds, i, ii...)
    stride = 1
    s2i = i
    for D in 2:N
        stride *= size(inds, D-1)
        s2i +=  stride * (ii[D-1] - 1)
    end
    s2i
end

