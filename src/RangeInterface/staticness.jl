
"""
    is_static(x) -> Bool

Returns `true` if `x` is static.

## Examples
```jldoctest
julia> using StaticRanges

julia> is_static(UnitSRange(1, 10))
true

julia> is_static(StepMRange(1, 2, 20))
false

julia> is_static(StepRange(1, 2, 20))
false

julia> is_static(())
true

julia> is_static((a=1, b=2))
true
```
"""
is_static(x) = is_static(typeof(x))
is_static(::Type{T}) where {T} = false
is_static(::Type{T}) where {T<:AbstractRange} = false
is_static(::Type{T}) where {T<:Tuple} = true
is_static(::Type{T}) where {T<:Val} = true
is_static(::Type{T}) where {T<:NamedTuple} = true
is_static(::Type{T}) where {T<:SArray} = true
is_static(::Type{T}) where {T<:MArray} = true
is_static(::Type{T}) where {T<:SizedArray} = true
is_static(::Type{T}) where {T<:SOneTo} = true
is_static(::Type{T}) where {T<:StaticArrays.SUnitRange} = true
is_static(::Type{T}) where {T<:AbstractVector} = is_static(axes_type(T, 1))
@inline function is_static(::Type{T}) where {T<:AbstractArray}
    for i in 1:ndims(T)
        is_static(axes_type(T, i)) || return false
    end
    return true
end


"""
    is_fixed(x) -> Bool

Returns `true` if the size of `x` is fixed.

## Examples
```jldoctest
julia> using StaticRanges

julia> is_fixed(UnitSRange(1, 10))
true

julia> is_fixed(StepRange(1, 2, 20))
true

julia> is_fixed(StepMRange(1, 2, 20))
false
```
"""
is_fixed(x) = is_fixed(typeof(x))
is_fixed(::Type{T}) where {T} = true
is_fixed(::Type{T}) where {T<:LinRange} = true
is_fixed(::Type{T}) where {T<:StepRange} = true
is_fixed(::Type{T}) where {T<:StepRangeLen} = true
is_fixed(::Type{T}) where {T<:UnitRange} = true
is_fixed(::Type{T}) where {T<:OneTo} = true
is_fixed(::Type{T}) where {T<:AbstractVector} = !ArrayInterface.ismutable(T)
is_fixed(::Type{T}) where {T<:SubArray{<:Any,1}} = true
@inline function is_fixed(::Type{T}) where {T<:AbstractArray}
    for i in 1:ndims(T)
        can_change_size(axes_type(T, i)) && return false
    end
    return true
end

