
"""
    ImmutableVector{T,I,Inds}

Supertype for core vectors  whose elements are immutable.
"""
abstract type ImmutableVector{T,I,Inds} <: CoreVector{T,I,Inds} end

Base.getindex(V::ImmutableVector{T,I}, ::Colon) where {T,I} = V

Base.setindex!(v::ImmutableVector{T,I,Inds}, i::Integer) where {T,I,Inds} = throw(MethodError(setindex!, (v, i)))

Base.setindex!(v::ImmutableVector{T,I,Inds}, i::AbstractVector{<:Integer}) where {T,I,Inds} = throw(MethodError(setindex!, (v, i)))

"""
    StaticImmutableVector{T,I}

A vector whose length is static and elements are immutable.
"""
struct StaticImmutableVector{T,I,L} <: ImmutableVector{T,Int,OneToSRange{I,L}}
    data::NTuple{L,T}
    axis::OneToSRange{I,L}

    # FixedImmutableVector{T,I}
    function StaticImmutableVector{T,I,L}(data::Tuple, axis::OneToSRange{T,L}) where {T,I,L}
        if eltype(data) <: T
            if eltype(axis) <: I
                return new{T,I,L}(data, axis)
            else
                return StaticImmutableVector{T,I}(data, OneToSRange{L}(axis.stop))
            end
        else
            if eltype(axis) <: I
                return StaticImmutableVector{T,I}(convert(Tuple{Vararg{T}}, data), axis)
            else
                return StaticImmutableVector{T,I}(convert(Tuple{Vararg{T}}, data), OneToSRange{I}(axis.stop))
            end
        end
    end
    function StaticImmutableVector{T,I}(data::Tuple) where {T,I}
        len = I(length(data))
        return StaticImmutableVector{T,I,len}(data, OneToSRange{I}(len))
    end

    function StaticImmutableVector{T,I}(data::AbstractVector) where {T,I}
        len = I(length(data))
        return StaticImmutableVector{T,I,len}(tuple(data...), OneToSRange{I}(len))
    end

    # FixedImmutableVector{T}
    StaticImmutableVector{T}(data::Tuple) where {T,I} = StaticImmutableVector{T,Int}(data)
    StaticImmutableVector{T}(args::Vararg) where {T} = StaticImmutableVector{T}(args)
    StaticImmutableVector{T}(data::AbstractVector) where {T} = StaticImmutableVector{T}(tuple(data...))

    # FixedImmutableVector
    StaticImmutableVector(data::Tuple) = StaticImmutableVector{eltype(data)}(data)
    StaticImmutableVector(args::Vararg) where {T} = StaticImmutableVector(args)
    StaticImmutableVector(data::AbstractVector)= StaticImmutableVector{eltype(data)}(tuple(data...))
end

function unsafe_getindex(V::StaticImmutableVector{T,I}, inds::AbstractVector{<:Integer}) where {T,I}
    if is_static(inds)
        return StaticImmutableVector{T,I}(unsafe_getindex_tuple(getfield(V, :data), inds), inds, Length(inds))
    else
        v = getfield(V, :data)
        return FixedImmutableVector{T,I}(tuple([getfield(v, i, false) for i in inds]...), OneTo{I}(length(inds)))
    end
end

function unsafe_getindex(V::StaticImmutableVector{T,I}, i::Integer) where {T,I}
    return getfield(getfield(V, :data), convert(Int, i), false)
end


"""
    FixedImmutableVector{T,I}

A vector whose length is fixed and elements are immutable.
"""
struct FixedImmutableVector{T,I} <: ImmutableVector{T,I,OneTo{I}}
    data::Tuple{Vararg{T}}
    axis::OneTo{I}

    # FixedImmutableVector{T,I}
    function FixedImmutableVector{T,I}(data::Tuple, axis::OneTo) where {T,I}
        if eltype(data) <: T
            if eltype(axis) <: I
                return new{T,I}(data, axis)
            else
                return FixedImmutableVector{T,I}(data, OneTo{I}(axis.stop))
            end
        else
            if eltype(axis) <: I
                return FixedImmutableVector{T,I}(convert(Tuple{Varar{T}}, data), axis)
            else
                return FixedImmutableVector{T,I}(convert(Tuple{Varar{T}}, data), OneTo{I}(axis.stop))
            end
        end
    end
    function FixedImmutableVector{T,I}(data::Tuple) where {T,I}
        return FixedImmutableVector{T,I}(data, OneTo{I}(length(data)))
    end

    function FixedImmutableVector{T,I}(data::AbstractVector) where {T,I}
        return FixedImmutableVector{T,I}(tuple(data...), OneTo{I}(length(data)))
    end

    # FixedImmutableVector{T}
    FixedImmutableVector{T}(data::Tuple) where {T,I} = FixedImmutableVector{T,Int}(data)
    FixedImmutableVector{T}(args::Vararg) where {T} = FixedImmutableVector{T}(args)
    FixedImmutableVector{T}(data::AbstractVector) where {T} = FixedImmutableVector{T}(tuple(data...))

    # FixedImmutableVector
    FixedImmutableVector(data::Tuple) = FixedImmutableVector{eltype(data)}(data)
    FixedImmutableVector(args::Vararg) where {T} = FixedImmutableVector(args)
    FixedImmutableVector(data::AbstractVector)= FixedImmutableVector{eltype(data)}(tuple(data...))
end

function unsafe_getindex(V::FixedImmutableVector{T,I}, inds::AbstractVector{<:Integer}) where {T,I}
    v = getfield(V, :data)
    return FixedImmutableVector{T,I}(tuple([getfield(v, i, false) for i in inds]...), OneTo{I}(length(inds)))
end

function unsafe_getindex(V::FixedImmutableVector{T,I}, i::Integer) where {T,I}
    return getfield(getfield(V, :data), convert(Int, i), false)
end
