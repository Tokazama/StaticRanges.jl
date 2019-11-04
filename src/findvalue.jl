# unsafe_findvalue doesn't confirm that the integer is in bounds or r[idx] == val
unsafe_findvalue(val, r::Union{OneToRange,OneTo}) = round(Integer, val)

function unsafe_findvalue(val, r::Union{StaticUnitRange,UnitRange})
    return round(Integer, (val - first(r)) + 1)
end

function unsafe_findvalue(val, r::Union{AbstractStepRangeLen,StepRangeLen})
    return round(Integer, ((val - r.ref) / step_hp(r)) + r.offset)
end

unsafe_findvalue(val, r::AbstractRange) = round(Integer, (val - r.start) / r.step) + 1

function unsafe_findvalue(val, r::Union{AbstractLinRange,LinRange})
    return round(Integer, (((val - r.start) / (r.stop - r.start)) * r.lendiv) + 1)
end

Base.in(x::Integer, r::OneToRange{<:Integer}) = (1 <= x) & (x <= last(r))

function Base.count(f::Function, r::Union{OneToRange,StaticUnitRange,AbstractLinRange,AbstractStepRange,AbstractStepRangeLen})
    return length(findall(f, r))
end

function Base.filter(f::Function, r::Union{OneToRange,StaticUnitRange,AbstractLinRange,AbstractStepRange,AbstractStepRangeLen})
    return @inbounds(r[findall(f, r)])
end