# TODO Account for empty ranges, small lengeth, etc.

# FIXME this should be defined somewhere
function StaticArrays.pop(v::AbstractVector)
    isempty(v) && error("array must be non-empty")
    return length(v) == 1 ? empty!(v) : @inbounds(v[1:end-1])
end

StaticArrays.pop(r::Union{OneTo,OneToRange}) = similar_type(r)(last(r) - one(eltype(r)))

# FIXME this should be defined somewhere
function StaticArrays.popfirst(v::AbstractVector)
    isempty(v) && error("array must be non-empty")
    return length(v) == 1 ? empty!(v) : @inbounds(v[2:end])
end

###
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
        setfield!(r, :stop, @inbounds(r[lastindex(r) - 1]))
        setfield!(r, :len, length(r) - 1)
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

###

function Base.popfirst!(r::StepMRangeLen)
    isempty(r) && error("array must be non-empty")
    f = first(r)
    if length(r) == 1
        return empty!(r)
    end
    setfield!(r, :ref, @inbounds(r[2]))
    setfield!(r, :len, length(r) - 1)
    return f
end

function Base.popfirst!(r::LinMRange)
    isempty(r) && error("array must be non-empty")
    f = first(r)
    if length(r) == 1
        return empty!(r)
    end
    setfield!(r, :start, @inbounds(r[2]))
    setfield!(r, :len, length(r) - 1)
    return f
end

function Base.popfirst!(r::Union{StepMRange,UnitMRange})
    isempty(r) && error("array must be non-empty")
    f = first(r)
    if length(r) == 1
        return empty!(r)
    end
    setfield!(r, :start, @inbounds(r[2]))
    return f
end
