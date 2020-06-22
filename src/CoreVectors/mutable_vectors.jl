
mutable struct MutableTuple{N,T}
    data::NTuple{N,T}
end

###
### unsafe_getindex
###
#= TODO fiure out this stuff

unsafe_getindex(v::MutableTuple{T}, i::Integer) where {T} = unsafe_getindex(v, Int(i))
function unsafe_getindex(v::MutableTuple{T}, i::Int) where {T}
    if isbitstype(T)
        return GC.@preserve v unsafe_load(Base.unsafe_convert(Ptr{T}, pointer_from_objref(v)), i)
    else
        return getfield(getfield(v, :data), i)
    end
end

###
### unsafe_setindex!
###

unsafe_setindex!(v::MutableTuple{T}, val, i::Integer)  where {T} = unsafe_setindex!(v, Int(i))
function unsafe_setindex!(v::MutableTuple{T}, val, i::Int) where {T}
    GC.@preserve v unsafe_store!(Base.unsafe_convert(Ptr{T}, pointer_from_objref(v)), convert(T, val), i)
    if isbitstype(T)

    else
        # TODO this should be at the StaticMutableVector setindex! or perhaps constructor
        # This one is unsafe (#27)
        # unsafe_store!(Base.unsafe_convert(Ptr{Ptr{Nothing}}, pointer_from_objref(v.data)), pointer_from_objref(val), i)
        error("setindex!() with non-isbitstype eltype is not supported by StaticArrays. ConsidFixeder using SizedArray.")
    end

    return val
end
=#


"""
    MutableVector{T,I,Inds}

Subtype of `CoreVector` whose elements are mutable.
"""
abstract type MutableVector{T,I,Inds} <: CoreVector{T,I,Inds} end

Base.getindex(V::MutableVector{T,I}, ::Colon) where {T,I} = copy(V)

@propagate_inbounds function Base.setindex!(v::MutableVector{T,I,Inds}, val, i::Integer) where {T,I,Inds}
    @boundscheck checkbounds(Bool, v, i)
    return unsafe_setindex!(v, val, Int(i))
end

@propagate_inbounds function Base.setindex!(v::MutableVector{T,I,Inds}, vals, inds::AbstractVector{<:Integer}) where {T,I,Inds}
    @boundscheck checkbounds(Bool, v, inds)
    return unsafe_setindex!(v, vals, inds)
end

"""
    StaticMutableVector{T,I,L}
"""
struct StaticMutableVector{T,I,L} <: MutableVector{T,I,OneToSRange{Int,L}}
    data::MutableTuple{L,T}
    axis::OneToSRange{I,L}

    function StaticMutableVector{T,I,L}(data::Tuple, axis::OneToSRange{T,L}) where {T,I,L}
        if eltype(data) <: T
            if eltype(axis) <: I
                return new{T,I,L}(MutableTuple(data), axis)
            else
                return StaticMutableVector{T,I}(data, OneToSRange{L}(axis.stop))
            end
        else
            if eltype(axis) <: I
                return StaticMutableVector{T,I}(convert(Tuple{Varar{T}}, data), axis)
            else
                return StaticMutableVector{T,I}(convert(Tuple{Varar{T}}, data), OneToSRange{I}(axis.stop))
            end
        end
    end

    function StaticMutableVector{T,I}(data::Tuple) where {T,I}
        len = I(length(data))
        return StaticMutableVector{T,I,len}(data, OneToSRange{I}(len))
    end

    function StaticMutableVector{T,I}(data::AbstractVector) where {T,I}
        return StaticMutableVector{T,I}(tuple(data...))
    end

    StaticMutableVector{T}(data::Tuple) where {T,I} = StaticMutableVector{T,Int}(data)

    StaticMutableVector{T}(args::Vararg) where {T} = StaticMutableVector{T}(args)

    function StaticMutableVector{T}(data::AbstractVector) where {T}
        return StaticMutableVector{T}(tuple(data...))
    end

    StaticMutableVector(data::AbstractVector) = StaticMutableVector{eltype(data)}(tuple(data...))
    StaticMutableVector(data::Tuple) = StaticMutableVector{eltype(data)}(data)
    StaticMutableVector(args::Vararg) where {T} = StaticMutableVector(args)
end

@inline function unsafe_getindex(V::StaticMutableVector{T,I}, i::Int) where {T,I}
    return getfield(getfield(getfield(V, :data), :data), i, false)
end

function unsafe_getindex(V::StaticMutableVector{T,I}, inds::AbstractVector{<:Integer}) where {T,I}
    if is_static(inds)
        return StaticMutableVector{T,I}(unsafe_getindex_tuple(getfield(getfield(V, :data), :data), inds, Length(inds)))
    else
        v = getfield(V, :data)
        return FixedMutableVector{T,I}(tuple([getfield(v, i, false) for i in inds]...), OneTo{I}(length(inds)))
    end
end

function unsafe_setindex!(V::StaticMutableVector{T}, val, i::Int) where {T}
    v = getfield(getifield(V, :data), :data)
    GC.@preserve v unsafe_store!(Base.unsafe_convert(Ptr{T}, pointer_from_objref(v)), convert(T, val), i)
    return val
end

"""
    FixedMutableVector{T,I}

A vector is that is dynamic in size and has mutable elements.
"""
struct FixedMutableVector{T,I} <: MutableVector{T,I,OneTo{I}}
    data::MutableTuple{<:Any,T}
    axis::OneTo{I}

    function FixedMutableVector{T,I}(data::Tuple, axis::OneTo{T}) where {T,I}
        if eltype(data) <: T
            if eltype(axis) <: I
                return new{T,I}(MutableTuple(data), axis)
            else
                return FixedMutableVector{T,I}(data, OneTo{L}(axis.stop))
            end
        else
            if eltype(axis) <: I
                return FixedMutableVector{T,I}(convert(Tuple{Varar{T}}, data), axis)
            else
                return FixedMutableVector{T,I}(convert(Tuple{Varar{T}}, data), OneTo{I}(axis.stop))
            end
        end
    end

    function FixedMutableVector{T,I}(data::Tuple) where {T,I}
        return FixedMutableVector{T,I}(data, OneTo{I}(length(data)))
    end

    function FixedMutableVector{T,I}(data::AbstractVector) where {T,I}
        return FixedMutableVector{T,I}(tuple(data...), OneTo{I}(length(data)))
    end

    FixedMutableVector{T}(data::Tuple) where {T,I} = FixedMutableVector{T,Int}(data)

    FixedMutableVector{T}(args::Vararg) where {T} = FixedMutableVector{T}(args)

    function FixedMutableVector{T}(data::AbstractVector) where {T}
        return FixedMutableVector{T}(tuple(data...))
    end

    FixedMutableVector(data::AbstractVector) = FixedMutableVector{eltype(data)}(tuple(data...))
    FixedMutableVector(data::Tuple) = FixedMutableVector{eltype(data)}(data)
    FixedMutableVector(args::Vararg) where {T} = FixedMutableVector(args)
end

@inline function unsafe_getindex(V::FixedMutableVector{T,I}, i::Int) where {T,I}
    return getfield(getfield(getfield(V, :data), :data), i, false)
end

function unsafe_getindex(V::FixedMutableVector{T,I}, inds::AbstractVector{<:Integer}) where {T,I}
    v = getfield(getfield(V, :data), :data)
    if is_static(inds)
        return StaticMutableVector{T,I}(unsafe_getindex_tuple(v, inds), inds, Length(inds))
    else
        return FixedMutableVector{T,I}(tuple([getfield(v, i, false) for i in inds]...), OneTo{I}(length(inds)))
    end
end

function unsafe_setindex!(V::FixedMutableVector{T}, val, i::Int) where {T}
    v = getfield(getifield(V, :data), :data)
    GC.@preserve v unsafe_store!(Base.unsafe_convert(Ptr{T}, pointer_from_objref(v)), convert(T, val), i)
    return val
end

"""
    DynamicMutableVector{T,I}

A vector is that is dynamic in size and has mutable elements.
"""
struct DynamicMutableVector{T,I} <: MutableVector{T,I,OneToMRange{I}}
    data::Vector{T}
    axis::OneToMRange{I}

    function DynamicMutableVector{T,I}(data::Vector, axis::OneToMRange) where {T,I}
        if eltype(data) <: T
            if eltype(axis) <: I
                return new{T,I}(data, axis)
            else
                return DynamicMutableVector{T,I}(data, OneToMRange{L}(axis.stop))
            end
        else
            if eltype(axis) <: I
                return DynamicMutableVector{T,I}(convert(Vector{T}, data), axis)
            else
                return DynamicMutableVector{T,I}(convert(Vector{T}, data), OneToMRange{I}(axis.stop))
            end
        end
    end
    function DynamicMutableVector{T,I}(data::AbstractVector) where {T,I}
        return DynamicMutableVector{T,I}(data, OneToMRange{I}(length(data)))
    end

    DynamicMutableVector{T}(args::Vararg) where {T} = DynamicMutableVector{T}([args...])
    DynamicMutableVector{T}(data::AbstractVector) where {T} = DynamicMutableVector{T,Int}(data)

    DynamicMutableVector(data::AbstractVector) = DynamicMutableVector{eltype(data)}(data)
    DynamicMutableVector(args::Vararg) where {T} = DynamicMutableVector([args...])
end

function unsafe_getindex(V::DynamicMutableVector{T,I}, inds::AbstractVector{<:Integer}) where {T,I}
    v = getfield(V, :data)
    if is_static(inds)
        return StaticMutableVector{T,I}(unsafe_getindex_vector(v, inds), inds, Length(inds))
    else
        return DynamicMutableVector{T,I}([getfield(v, i, false) for i in inds], OneToMRange{I}(length(inds)))
    end
end


function unsafe_getindex(V::DynamicMutableVector{T,I}, i::Int) where {T,I}
    return unsafe_getindex(getfield(V, :data), i)
end

unsafe_getindex(v::Vector{T}, i::Int) where {T} = Core.arrayref(false, v, i)

function unsafe_setindex!(V::DynamicMutableVector{T}, vals, inds::AbstractUnitRange{<:Integer}) where {T}
    unsafe_copyto!(getfield(V, :data), first(inds), vals, 1, length(inds))
    return V
end

@inline function unsafe_setindex!(v::DynamicMutableVector{T}, vals, inds::AbstractVector{<:Integer}) where {T}
    v = getfield(v, :data)
    count = 1
    for i in inds
        unsafe_setindex!(v, @inbounds(vals[count]), i)
        count += 1
    end
    return V
end

function unsafe_setindex!(V::DynamicMutableVector{T}, vals, ::Colon) where {T}
    unsafe_copyto!(getfield(V, :data), 1, vals, 1, length(v))
    return V
end
