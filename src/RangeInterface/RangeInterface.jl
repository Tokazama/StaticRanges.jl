module RangeInterface

using ArrayInterface
using ArrayInterface: parent_type
using ArrayInterface: known_first, known_step, known_last
using StaticArrays

using Base: OneTo

export 
    axes_type,
    has_parent,
    has_len_field,
    has_lendiv_field,
    has_offset_field,
    has_offset_start,
    has_offset_stop,
    has_step_field,
    known_first,
    known_last,
    known_length,
    known_size,
    known_len,
    known_lendiv,
    known_offset,
    parent_type,
    has_offset_axes,
    first_is_known_one,
    is_dynamic,
    is_fixed,
    is_static,
    is_range,
    step_is_known_one

include("range_fields.jl")
include("known.jl")
include("staticness.jl")
include("length.jl")

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

is_range(x) = is_range(typeof(x))
is_range(::Type{T}) where {T<:AbstractRange} = true
function is_range(::Type{T}) where {T}
    if has_parent(T)
        return is_range(parent_type(T))
    else
        return false
    end
end

###
###
###
first_is_known_one(x) = first_is_known_one(typeof(x))
function first_is_known_one(::Type{<:AbstractVector{T}}) where {T}
    if T <: Number
        return known_first(T) === oneunit(T)
    else
        return false
    end
end

step_is_known_one(x) = step_is_known_one(typeof(x))
function step_is_known_one(::Type{T}) where {T<:AbstractRange}
    S = step_type(T)
    if S <: Number
        return known_step(T) === oneunit(S)
    else
        return false
    end
end

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
axes_type(::Type{T}, i::Int) where {T<:AbstractArray} = OneTo{Int}
axes_type(::Type{T}, i::Int) where {T} = axes_type(T).parameters[i]
@inline function axes_type(::Type{<:StaticArray{S}}, i::Int) where {S}
    if S.parameters[i] isa Int
        SOneTo{S.parameters[i]}
    else
        OneTo{Int}
    end
end



end
