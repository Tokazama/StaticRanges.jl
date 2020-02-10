
# have to define several getindex methods to avoid ambiguities with other unit ranges
@propagate_inbounds function Base.getindex(a::AbstractAxis{K,<:Integer}, inds) where {K}
    @boundscheck checkbounds(a, inds)
    @inbounds return _getindex(a, inds)
end
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
_getindex(a::Axis, i::Int) = @inbounds(values(a)[i])

_getindex(a::SimpleAxis, inds) = SimpleAxis(@inbounds(values(a)[inds]))
_getindex(a::SimpleAxis, i::Int) = @inbounds(values(a)[i])

@propagate_inbounds Base.to_index(x::AbstractAxis, f::F2Eq) = _maybe_throw_boundserror(x, find_first(f, keys(x)))
@propagate_inbounds Base.to_index(x::AbstractAxis, f::Function) = _maybe_throw_boundserror(x, find_all(f, keys(x)))

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

# TODO Type inference for things that we know produce UnitRange/GapRange, etc

