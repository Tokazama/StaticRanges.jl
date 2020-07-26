
# helps when dividing by units changes types
add_one(x::T) where {T} = x + oneunit(T)

#=
# unsafe_findvalue doesn't confirm that the integer is in bounds or r[idx] == val
@inline function unsafe_findvalue(val, r::Union{OneToRange,OneTo}, rounding_mode=RoundToZero)
    return _unsafe_findvalue(val, rounding_mode)
end

@inline function unsafe_findvalue(val, r::AbstractUnitRange, rounding_mode=RoundToZero)
    return _unsafe_findvalue(val - first(r), rounding_mode) + 1
end

@inline function unsafe_findvalue(val, r::Union{AbstractStepRangeLen,StepRangeLen}, rounding_mode=RoundToZero)
    return _unsafe_findvalue(((val - r.ref) / step_hp(r)) + r.offset, RoundToZero)
end

@inline function unsafe_findvalue(val, r::AbstractRange{T}, rounding_mode=RoundToZero) where {T}
    return add_one(_unsafe_findvalue((val - r.start) / r.step, rounding_mode))
end

@inline function unsafe_findvalue(val, r::OrdinalRange{T,S}, rounding_mode=RoundToZero) where {T,S}
    return add_one(_unsafe_findvalue((val - first(r)) / step(r), rounding_mode))
end

@inline function unsafe_findvalue(val, r::Union{AbstractLinRange,LinRange}, rounding_mode=RoundToZero)
    return add_one(_unsafe_findvalue((val - r.start) / (r.stop - r.start) * r.lendiv, rounding_mode))
end
=#

_unsafe_findvalue(idx, rounding_mode) = round(Integer, idx, rounding_mode)
_unsafe_findvalue(idx::Integer, rounding_mode) = idx
function _unsafe_findvalue(idx::TwicePrecision{T}, rounding_mode) where {T}
    return round(Integer, T(idx), rounding_mode)
end

function unsafe_findvalue(x, collection, rounding_mode=RoundToZero)
    if is_one_to(collection)
        return unsafe_find_value_oneto(x, collection)
    elseif step_is_one(collection)
        return unsafe_find_value_unitrange(x, collection)
    elseif is_linrange(collection)
        return unsafe_find_value_linrange(x, collection)
    elseif is_steprangelen(collection)
        return unsafe_find_value_steprangelen(x, collection)
    else
        return unsafe_find_value_steprange(x, collection)
    end
end

unsafe_find_value_oneto(x, collection) = _unsafe_findvalue(x, RoundToZero)

function unsafe_find_value_unitrange(x, collection)
    return add_one(_unsafe_findvalue(x - first(collection), RoundToZero))
end

function unsafe_find_value_steprange(x, collection)
    return add_one(_unsafe_findvalue((x - first(collection)) / step(collection), RoundToZero))
end

function unsafe_find_value_linrange(x, collection)
    return add_one(_unsafe_findvalue((x - collection.start) / (collection.stop - collection.start) * collection.lendiv, RoundToZero))
end

function unsafe_find_value_steprangelen(x, collection)
    return _unsafe_findvalue(((x - collection.ref) / step_hp(collection)) + collection.offset, RoundToZero)
end


#=
for T in (:OneToMRange,:UnitMRange,:StepMRange,:LinMRange,:StepMRangeLen,:OneToSRange,:UnitSRange,:StepSRange,:LinSRange,:StepSRangeLen)
    @eval begin
        Base.findall(f::Function, r::$T) = find_all(f, r)
        Base.findall(f::Fix2{typeof(in)}, r::$T) = find_all(f, r)
    end
end
=#

