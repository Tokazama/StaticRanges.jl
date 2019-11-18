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

unsafe_findvalue(val, ::LinearIndices{1,Tuple{OneTo{Int64}}}) = Int(val)

Base.in(x::Integer, r::OneToRange{<:Integer}) = (1 <= x) & (x <= last(r))

Base.findall(f::Function, r::UnionRange) = find_all(f, r)

Base.findall(f::Fix2{typeof(in)}, r::UnionRange) = find_all(f, r)

Base.findlast(f::Function, x::UnionRange) = find_last(f, x)

Base.findfirst(f::Function, r::UnionRange) = find_first(f, r)

# TODO this could easily be optimized more
@propagate_inbounds Base.count(f::Function, r::UnionRange) = length(find_all(f, r))
