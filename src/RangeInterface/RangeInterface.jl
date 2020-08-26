module RangeInterface

using LinearAlgebra
using ArrayInterface
using ArrayInterface: parent_type
using ArrayInterface: known_first, known_step, known_last
using StaticArrays

using Base: OneTo

export
    axes_type,
    has_parent,
    known_size,
    has_offset_axes,
    is_fixed,
    is_static

#include("range_fields.jl")
#include("known.jl")
include("staticness.jl")

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

end
