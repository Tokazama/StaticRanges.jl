function Base.findall(
    f::Fix2{<:Union{typeof(<),typeof(<=)}},
    r::Union{OneToRange,StaticUnitRange,AbstractLinRange,AbstractStepRange,AbstractStepRangeLen}
   )
    isempty(r) && Int[]
    if isforward(r)
        idx = findlast(f, r)
        return isnothing(idx) ? empty(r) : firstindex(r):idx
    else
        idx = findfirst(f, r)
        return isnothing(idx) ? empty(r) : idx:lastindex(r)
    end
end

function Base.findall(
    f::Fix2{<:Union{typeof(>),typeof(>=)}},
    r::Union{OneToRange,StaticUnitRange,AbstractLinRange,AbstractStepRange,AbstractStepRangeLen}
   )
    isempty(r) && Int[]
    if isforward(r)
        idx = findfirst(f, r)
        return isnothing(idx) ? empty(r) : idx:lastindex(r)
    else
        idx = findlast(f, r)
        return isnothing(idx) ? empty(r) : firstindex(r):idx
    end
end

function Base.findall(
    f::Fix2{<:Union{typeof(==),typeof(isequal)}},
    r::Union{OneToRange,StaticUnitRange,AbstractLinRange,AbstractStepRange,AbstractStepRangeLen}
   )
    isempty(r) && Int[]
    idx = findfirst(f, r)
    return isnothing(idx) ? Int[] : idx:findlast(f, r)
end
