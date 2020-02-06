
function Base.iterate(r::Union{AbstractLinRange,AbstractStepRangeLen}, i=1)
    Base.@_inline_meta
    return check_iterate(r, i) ? unsafe_iterate(r, i) : nothing
end

function Base.iterate(r::Union{AbstractStepRange,OneToRange,UnitMRange,UnitSRange}, i)
    Base.@_inline_meta
    return check_iterate(r, i) ? unsafe_iterate(r, i) : nothing
end

# check_iterate
check_iterate(r::Union{LinRangeUnion,StepRangeLenUnion}, i) = length(r) >= i
check_iterate(r::AbstractRange, i) = last(r) != i
check_iterate(r::AbstractVector, i) = lastindex(r) != i
# unsafe_iterate

function unsafe_iterate(x::AbstractUnitRange{T}, state) where {T}
    next = state + one(T)
    return next, next
end
function unsafe_iterate(x::OrdinalRange{T}, state) where {T}
    next = convert(T, state + step(x))
    return next, next
end
function unsafe_iterate(r::Union{LinRangeUnion,StepRangeLenUnion}, i)
    return unsafe_getindex(r, i), i + 1
end
function unsafe_iterate(v::AbstractVector, i)
    next = i + 1
    return @inbounds(v[next]), next
end

