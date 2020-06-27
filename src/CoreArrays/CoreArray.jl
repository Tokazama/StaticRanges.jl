
struct CoreArray{T,N,Axs<:NTuple{N,<:Any},D<:CoreVector{T}} <: AbstractArray{T,N}
    data::D
    axes::Axs

    function CoreArray(data::CoreVector{T}, axs::Tuple{Vararg{<:OneToUnion,N}}) where {T,N}
        if length(data) == prod(map(length, axs))
            return new{T,N,typeof(axs),typeof(data)}(data, axs)
        else
            error("The provided data has a length of $(length(data)) and the product of the axes sizes is $(prod(map(length, axs)))")
        end
    end
end

lininds(A::CoreArray) = getfield(A, :axes)

Base.axes(A::CoreArray) = axes(getfield(A, :axes))
Base.axes(A::CoreArray, i) = getfield(axes(A), i)

get_data(A) = getfield(A, :data)


function Base.getindex(A::CoreArray, i::Union{AbstractVector{Integer},Integer}, ii::Union{AbstractVector{Integer},Integer}...)
    @boundscheck checkbounds(A, ii...)
    return unsafe_getindex(A, to_indices(A, ii))
end

function unsafe_getindex(A::CoreArray, inds::Tuple{Vararg{<:Integer}})
    return unsafe_getindex(get_data(A), @inbounds(getindex(lininds(A), inds...)))
end

@propagate_inbounds function Base.getindex(A::CoreArray, i::Integer)
    @boundscheck if i < 1 || i > length(A)
        throw(BoundsError(A, i))
    end
    return unsafe_getindex(A, convert(Int, i))
end

@propagate_inbounds function Base.getindex(A::CoreArray, inds::AbstractVector{Integer})
    @boundscheck checkbounds(A, inds)
    return CoreArray(unsafe_getindex(A, inds))
end

@propagate_inbounds function Base.getindex(A::CoreArray, gr::GapRange{Integer})
    @boundscheck checkbounds(A, inds)
    return CoreArray(vcat(unsafe_getindex(x, first_range(gr)), unsafe_getindex(x, last_range(gr))))
end

unsafe_getindex(A::CoreArray, i::Int) = unsafe_getindex(get_data(A), i)
