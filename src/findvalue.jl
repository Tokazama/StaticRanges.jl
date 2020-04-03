
# helps when dividing by units changes types
add_one(x::T) where {T} = x + oneunit(T)

# unsafe_findvalue doesn't confirm that the integer is in bounds or r[idx] == val
@inline function unsafe_findvalue(val, r::Union{OneToRange,OneTo})
    return _unsafe_findvalue(val)
end

@inline function unsafe_findvalue(val, r::AbstractUnitRange)
    return _unsafe_findvalue(val - first(r)) + 1
end

@inline function unsafe_findvalue(val, r::Union{AbstractStepRangeLen,StepRangeLen})
    return _unsafe_findvalue(((val - r.ref) / step_hp(r)) + r.offset)
end

@inline function unsafe_findvalue(val, r::AbstractRange{T}) where {T}
    return add_one(_unsafe_findvalue((val - r.start) / r.step))
end

@inline function unsafe_findvalue(val, r::OrdinalRange{T,S}) where {T,S}
    return add_one(_unsafe_findvalue((val - first(r)) / step(r)))
end

@inline function unsafe_findvalue(val, r::Union{AbstractLinRange,LinRange})
    return add_one(_unsafe_findvalue((val - r.start) / (r.stop - r.start) * r.lendiv))
end

_unsafe_findvalue(idx) = round(Integer, idx)
_unsafe_findvalue(idx::Integer) = idx
_unsafe_findvalue(idx::TwicePrecision{T}) where {T} = round(Integer, T(idx))

Base.findall(f::Function, r::UnionRange) = find_all(f, r)

Base.findall(f::Fix2{typeof(in)}, r::UnionRange) = find_all(f, r)

Base.findlast(f::Function, x::UnionRange) = find_last(f, x)

Base.findfirst(f::Function, r::UnionRange) = find_first(f, r)

# TODO this could easily be optimized more
@propagate_inbounds Base.count(f::Function, r::UnionRange) = length(find_all(f, r))

