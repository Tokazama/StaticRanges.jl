# TODO:
#   - Account for empty ranges, small length, etc.
#   - ensure there are pop and popfirst working for all types (non-mutating)

# FIXME this should be defined somewhere
function StaticArrays.pop(v::AbstractVector)
    isempty(v) && error("array must be non-empty")
    return length(v) == 1 ? empty!(v) : @inbounds(v[1:end-1])
end

StaticArrays.pop(r::Union{OneTo,OneToRange}) = similar_type(r)(last(r) - one(eltype(r)))

function StaticArrays.pop(si::SimpleIndices)
    can_set_last(a) || error("Cannot change size of index of type $(typeof(a)).")
    return SimpleIndices{dimnames(si)}(pop(values(si)))
end

# FIXME this should be defined somewhere else
function StaticArrays.popfirst(v::AbstractVector)
    isempty(v) && error("array must be non-empty")
    return length(v) == 1 ? empty!(v) : @inbounds(v[2:end])
end

function Base.pop!(r::StepMRangeLen)
    isempty(r) && error("array must be non-empty")
    l = last(r)
    length(r) == 1 ? empty!(r) : setfield!(r, :len, length(r) - 1)
    return l
end

function Base.pop!(r::LinMRange)
    isempty(r) && error("array must be non-empty")
    l = last(r)
    if length(r) == 1
        empty!(r)
    else
        len = length(r) - 1
        setfield!(r, :stop, unsafe_getindex(r, len))
        setfield!(r, :len, len)
        setfield!(r, :lendiv, max(len - 1, 1))
    end
    return l
end

function Base.pop!(r::StepMRange{T}) where {T}
    isempty(r) && error("array must be non-empty")
    l = last(r)
    length(r) == 1 ? empty!(r) : set_last!(r, l - T(step(r)))
    return l
end

function Base.pop!(r::Union{UnitMRange{T},OneToMRange{T}}) where {T}
    isempty(r) && error("array must be non-empty")
    l = last(r)
    length(r) == 1 ? empty!(r) : set_last!(r, l - one(T))
    return l
end

function Base.pop!(a::AbstractIndices)
    can_set_last(a) || error("Cannot change size of index of type $(typeof(a)).")
    pop!(keys(a))
    return pop!(values(a))
end

Base.pop!(si::SimpleIndices) = pop!(values(si))

### popfirst!

function Base.popfirst!(r::StepMRangeLen)
    isempty(r) && error("array must be non-empty")
    f = first(r)
    if length(r) == 1
        empty!(r)
    else
        setfield!(r, :ref, @inbounds(r[2]))
        setfield!(r, :len, length(r) - 1)
    end
    return f
end

function Base.popfirst!(r::LinMRange)
    isempty(r) && error("array must be non-empty")
    f = first(r)
    if length(r) == 1
        empty!(r)
    else
        len = length(r) - 1
        setfield!(r, :start, @inbounds(r[2]))
        setfield!(r, :len, len)
        setfield!(r, :lendiv, max(len - 1, 1))
    end
    return f
end

function Base.popfirst!(r::Union{StepMRange,UnitMRange})
    isempty(r) && error("array must be non-empty")
    f = first(r)
    length(r) == 1 ? empty!(r) : setfield!(r, :start, @inbounds(r[2]))
    return f
end

Base.popfirst!(si::SimpleIndices) = popfirst!(values(si))

function Base.popfirst!(a::AbstractIndices)
    can_set_first(a) || error("Cannot change size of index of type $(typeof(a)).")
    popfirst!(keys(a))
    return popfirst!(values(a))
end

function StaticArrays.popfirst(si::SimpleIndices)
    can_set_first(a) || error("Cannot change size of index of type $(typeof(a)).")
    return SimpleIndices{dimnames(si)}(popfirst(values(si)))
end

