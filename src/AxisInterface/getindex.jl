
# have to define several getindex methods to avoid ambiguities with other unit ranges
@propagate_inbounds function Base.getindex(a::AbstractAxis{K,<:Integer}, inds::AbstractUnitRange{<:Integer}) where {K}
    @boundscheck checkbounds(a, inds)
    @inbounds return _getindex(a, inds)
end
@propagate_inbounds function Base.getindex(a::AbstractAxis{K,<:Integer}, i::Integer) where {K}
    @boundscheck checkbounds(a, i)
    @inbounds return _getindex(a, i)
end
@propagate_inbounds function Base.getindex(a::AbstractAxis, inds::Function)
    return getindex(a, to_index(a, inds))
end

function _getindex(a::Axis, inds)
    return Axis(@inbounds(keys(a)[inds]), @inbounds(values(a)[inds]), allunique(inds), false)
end
_getindex(a::Axis, i::Integer) = @inbounds(values(a)[i])

_getindex(a::SimpleAxis, inds) = SimpleAxis(@inbounds(values(a)[inds]))
_getindex(a::SimpleAxis, i::Integer) = @inbounds(values(a)[i])

@propagate_inbounds Base.to_index(x::AbstractAxis, f::F2Eq) = _maybe_throw_boundserror(x, find_first(f, keys(x)))
@propagate_inbounds Base.to_index(x::AbstractAxis, f::Function) = _maybe_throw_boundserror(x, find_all(f, keys(x)))
@propagate_inbounds Base.to_index(x::AbstractAxis, f::CartesianIndex{1}) = first(f.I)


@propagate_inbounds function _maybe_throw_boundserror(x, i)::Integer
    @boundscheck if i isa Nothing
        throw(BoundsError(x, i))
    end
    return i
end

@propagate_inbounds function _maybe_throw_boundserror(x, inds::AbstractVector)::AbstractVector{<:Integer}
    @boundscheck if !(eltype(inds) <: Integer)
        throw(BoundsError(x, i))
    end
    return inds
end

@propagate_inbounds function Base.to_indices(A, inds::Tuple{<:AbstractAxis, Vararg{Any}}, I::Tuple{Any, Vararg{Any}})
    Base.@_inline_meta
    return (to_index(first(inds), first(I)), to_indices(A, maybetail(inds), tail(I))...)
end

@propagate_inbounds function Base.to_indices(A, inds::Tuple{<:AbstractAxis, Vararg{Any}}, I::Tuple{Colon, Vararg{Any}})
    Base.@_inline_meta
    return (values(first(inds)), to_indices(A, maybetail(inds), tail(I))...)
end

@propagate_inbounds function Base.to_indices(A, inds::Tuple{<:AbstractAxis, Vararg{Any}}, I::Tuple{CartesianIndex{1}, Vararg{Any}})
    Base.@_inline_meta
    return (to_index(first(inds), first(I)), to_indices(A, maybetail(inds), tail(I))...)
end

@inline function Base.to_indices(A, inds::Tuple{<:AbstractAxis, Vararg{Any}}, I::Tuple{CartesianIndex, Vararg{Any}})
    return to_indices(A, inds, (I[1].I..., tail(I)...))
end

maybetail(::Tuple{}) = ()
maybetail(t::Tuple) = tail(t)

# TODO Type inference for things that we know produce UnitRange/GapRange, etc

Base.checkbounds(a::AbstractAxis, i) = checkbounds(Bool, a, i)
Base.checkbounds(::Type{Bool}, a::AbstractAxis, i) = checkindex(Bool, a, i)
function Base.checkbounds(::Type{Bool}, a::AbstractAxis, i::CartesianIndex{1})
    return checkindex(Bool, a, first(i.I))
end
function Base.checkindex(::Type{Bool}, a::AbstractAxis, i::Integer)
    return checkindexlo(a, i) & checkindexhi(a, i)
end
function Base.checkindex(::Type{Bool}, a::AbstractAxis, i::AbstractVector)
    return checkindexlo(a, i) & checkindexhi(a, i)
end
function Base.checkindex(::Type{Bool}, a::AbstractAxis, i::AbstractUnitRange)
    return checkindexlo(a, i) & checkindexhi(a, i)
end

