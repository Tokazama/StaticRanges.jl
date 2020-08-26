
gethi(x::TwicePrecision) = x.hi
gethi(x) = x

getlo(x::TwicePrecision) = x.lo
getlo(x) = x

stephi(x) = gethi(Base.step_hp(x))
steplo(x) = getlo(Base.step_hp(x))

refhi(x) = gethi(x.ref)
reflo(x) = getlo(x.ref)

first_is_known_one(x) = first_is_known_one(typeof(x))
function first_is_known_one(::Type{R}) where {R}
    T = eltype(R)
    if T <: Number
        return known_first(R) === oneunit(T)
    else
        return false
    end
end

step_is_known_one(x) = step_is_known_one(typeof(x))
step_is_known_one(::Type{R}) where {R<:AbstractUnitRange} = true
function step_is_known_one(::Type{R}) where {T,S,R<:OrdinalRange{T,S}}
    if S <: Number
        return known_step(R) === oneunit(S)
    else
        return false
    end
end
function step_is_known_one(::Type{R}) where {R<:AbstractVector}
    T = eltype(R)
    if T <: Number
        return known_step(R) === oneunit(T)
    else
        return false
    end
end

###
### iterate
###
# unsafe_iterate
function unsafe_iterate(x::OrdinalRange{T}, state) where {T}
    if step_is_known_one(x)
        next = state + one(T)
    else
        next = convert(T, state + step(x))
    end
    return next, next
end
unsafe_iterate(r::AbstractRange, i) = unsafe_getindex(r, i + 1), i + 1

# check_iterate
check_iterate(r::AbstractRange, i) = length(r) == i
check_iterate(r::OrdinalRange, i) = last(r) == i

function init_iterate(r::AbstractRange)
    if isempty(r)
        return nothing
    else
        return first(r), 1
    end
end
function init_iterate(r::OrdinalRange)
    if isempty(r)
        return nothing
    else
        itr = first(r)
        return itr, itr
    end
end

macro defiterate(T)
    esc(quote
        Base.iterate(x::$T) = StaticRanges.init_iterate(x)

        @inline function Base.iterate(x::$T, state)
            if StaticRanges.check_iterate(x, state)
                return nothing
            else
                return StaticRanges.unsafe_iterate(x, state)
            end
        end
    end)
end

is_range(x) = is_range(typeof(x))
is_range(::Type{T}) where {T<:AbstractRange} = true
function is_range(::Type{T}) where {T}
    if has_parent(T)
        return is_range(parent_type(T))
    else
        return false
    end
end

