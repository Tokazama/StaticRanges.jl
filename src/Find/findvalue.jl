
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

function unsafe_findvalue(val, r::OrdinalRange{T,S}, rounding_mode=RoundToZero) where {T,S}
    if known_step(r) === oneunit(S)
        if known_first(r) === oneunit(T)
            return unsafe_find_value_oneto(val, r)
        else
            unsafe_find_value_unitrange(val, r)
        end
    else
        return unsafe_find_value_steprange(val, r)
    end
end
function unsafe_findvalue(val, r::Union{<:LinRange,<:LinSRange,<:LinMRange}, rounding_mode=RoundToZero)
    return unsafe_find_value_linrange(val, r)
end

function unsafe_findvalue(val, r::Union{<:StepRangeLen,<:StepSRangeLen,<:StepMRangeLen}, rounding_mode=RoundToZero)
    return unsafe_find_value_steprangelen(val, r)
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

