
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

checkindexlo(r, i::AbstractVector) = checkindexlo(r, minimum(i))
checkindexlo(r, i) = firstindex(r) <= i
checkindexlo(r, i::CartesianIndex{1}) = firstindex(r) <= first(i.I)

checkindexhi(r, i::AbstractVector) = checkindexhi(r, maximum(i))
checkindexhi(r, i) = lastindex(r) >= i
checkindexhi(r, i::CartesianIndex{1}) = firstindex(r) <= first(i.I)

# TODO this needs to be in base
Base.isassigned(r::AbstractRange, i::Integer) = checkindex(Bool, r, i)

###
### Generic array traits
###
# TODO This is a more trait like version of the same method from base
# (base doesn't operate on types)
has_offset_axes(::T) where {T} = has_offset_axes(T)
has_offset_axes(::Type{T}) where {T<:AbstractRange} = false
has_offset_axes(::Type{T}) where {T<:AbstractArray} = _has_offset_axes(axes_type(T))
Base.@pure function _has_offset_axes(::Type{T}) where {T<:Tuple}
    for ax_i in T.parameters
        has_offset_axes(ax_i) && return true
    end
    return false
end

"""
    has_parent(::Type{T}) -> Bool

Returns `true` if `T` has parent field.
"""
has_parent(x) = has_parent(typeof(x))
@inline function has_parent(::Type{T}) where {T}
    if parent_type(T) <: T
        return false
    else
        return true
    end
end

###
###
###


"""
    axes_type(::T) = axes_type(T)
    axes_type(::Type{T})

Returns the equivalent output of `typeof(axes(x))` but derives this directly
from the type of x (e.g., parametric typing).

## Examples
```jldoctest
julia> using StaticRanges

julia> axes_type([1 2; 3 4])
Tuple{Base.OneTo{Int64},Base.OneTo{Int64}}
```
"""
axes_type(x) = axes_type(typeof(x))

@inline function axes_type(::Type{T}) where {T<:AbstractArray}
    return Tuple{ntuple(i -> axes_type(T, i), Val(ndims(T)))...}
end

"""
    axes_type(::T, i) = axes_type(T, i)
    axes_type(::Type{T}, i)

Returns the equivalent output of `typeof(axes(x, i))` but derives this directly
from the type of x (e.g., parametric typing).

## Examples
```jldoctest
julia> using StaticRanges

julia> axes_type([1 2; 3 4], 1)
Base.OneTo{Int64}
```
"""
axes_type(::T, i::Int) where {T} = axes_type(T, i)
axes_type(::Type{T}, i::Int) where {T<:Array} = OneTo{Int}
function axes_type(::Type{T}, i::Int) where {T<:AbstractArray}
    if parent_type(T) <: T
        return OneTo{Int}
    else
        return axes_type(parent_type(T), i)
    end
end
function axes_type(::Type{T}, i::Int) where {T<:Union{Adjoint,Transpose}}
    if i === 1
        return axes_type(parent_type(T), 2)
    elseif i === 2
        return axes_type(parent_type(T), 1)
    else
        # let parent type throw error or choose automatic type
        return axes_type(parent_type(T), i)
    end
end
axes_type(::Type{T}, i::Int) where {T} = axes_type(T).parameters[i]
@inline function axes_type(::Type{<:StaticArray{S}}, i::Int) where {S}
    if S.parameters[i] isa Int
        SOneTo{S.parameters[i]}
    else
        OneTo{Int}
    end
end
function axes_type(::Type{<:PermutedDimsArray{<:Any,<:Any,I1,<:Any,A}}, i::Int) where {I1,A}
    return parent_type(A, I1[i])
end

