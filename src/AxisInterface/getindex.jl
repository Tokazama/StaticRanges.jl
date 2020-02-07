
# have to define several getindex methods to avoid ambiguities with other unit ranges
@propagate_inbounds function Base.getindex(a::AbstractAxis, inds)
    @boundscheck checkbounds(a, inds)
    @inbounds return _getindex(a, inds)
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

@propagate_inbounds Base.to_index(x::AbstractAxis, f::F2Eq) = find_first(f, keys(x))
@propagate_inbounds Base.to_index(x::AbstractAxis, f::Function) = find_all(f, keys(x))

