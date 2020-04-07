
"""
    parent_type(::T) = parent_type(T)
    parent_type(::Type{T})

Returns the equivalent output of `typeof(parent(x))` but derives this directly
from the type of x (e.g., parametric typing).

## Examples
```jldoctest
julia> using StaticRanges

julia> parent_type([1 2; 3 4])
Array{Int64,2}

julia> parent_type(view([1 2; 3 4], 1, 1))
Array{Int64,2}
```
"""
parent_type(::T) where {T} = parent_type(T)
parent_type(::Type{T}) where {T} = T
parent_type(::Type{<:SubArray{T,N,P}}) where {T,N,P} = P

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
axes_type(::T) where {T} = axes_type(T)
function axes_type(::Type{<:AbstractArray{T,N}}) where {T,N}
    return Tuple{ntuple(_ -> OneTo{Int}, Val(N))...}
end

function axes_type(::Type{<:StaticArray{S,T,N}}) where {S,T,N}
    axs = ntuple(Val(N)) do i
        if S.parameters[i] isa Int
            SOneTo{S.parameters[i]}
        else
            OneTo{Int}
        end
    end
    return Tuple{axs...}
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
axes_type(::T, i::Integer) where {T} = axes_type(T, i)
axes_type(::Type{T}, i::Integer) where {T} = axes_type(T).parameters[i]

for f in (:is_dynamic, :is_static, :is_fixed)
    @eval begin
        $f(::T) where {T} = $f(T)
        $f(::T, i::Integer) where {T} = $f(T, i)
        $f(::Type{T}, i::Integer) where {T} = $f(axes_type(T).parameters[i])
        @inline function $f(type::Type{<:AbstractArray{T,N}}) where {T,N}
            for i in 1:ndims(type)
                $f(axes_type(type, i)) || return false
            end
            return true
        end
    end
end

"""
    is_dynamic(x) -> Bool

Returns true if the size of `x` is dynamic/can change.

## Examples
```jldoctest
julia> using StaticRanges

julia> is_dynamic(UnitSRange(1, 10))
false

julia> is_dynamic(StepRange(1, 2, 20))
false

julia> is_dynamic(StepMRange(1, 2, 20))
true
```
"""
is_dynamic(::Type{T}) where {T} = false
is_dynamic(::Type{T}) where {T<:Vector} = true
is_dynamic(::Type{T}) where {T<:OneToMRange} = true
is_dynamic(::Type{T}) where {T<:UnitMRange} = true
is_dynamic(::Type{T}) where {T<:StepMRange} = true
is_dynamic(::Type{T}) where {T<:StepMRangeLen} = true
is_dynamic(::Type{T}) where {T<:LinMRange} = true
is_dynamic(::Type{T}) where {T<:AbstractRange} = false

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
is_static(::Type{T}) where {T} = false
is_static(::Type{T}) where {T<:Tuple} = true
is_static(::Type{T}) where {T<:NamedTuple} = true
is_static(::Type{T}) where {T<:SOneTo} = true
is_static(::Type{T}) where {T<:StaticArrays.SUnitRange} = true
is_static(::Type{T}) where {T<:OneToSRange} = true
is_static(::Type{T}) where {T<:UnitSRange} = true
is_static(::Type{T}) where {T<:StepSRange} = true
is_static(::Type{T}) where {T<:StepSRangeLen} = true
is_static(::Type{T}) where {T<:LinSRange} = true
is_static(::Type{T}) where {T<:AbstractRange} = false


"""
    is_fixed(x) -> Bool

Returns `true` if the size of `x` is fixed. Note that if the size of `x` is known
statically (at compile time) it is also interpreted as fixed.

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
is_fixed(::Type{T}) where {T} = true
is_fixed(::Type{T}) where {T<:AbstractRange} = true
is_fixed(::Type{T}) where {T<:Vector} = false
is_fixed(::Type{T}) where {T<:OneToMRange} = false
is_fixed(::Type{T}) where {T<:UnitMRange} = false
is_fixed(::Type{T}) where {T<:StepMRange} = false
is_fixed(::Type{T}) where {T<:StepMRangeLen} = false
is_fixed(::Type{T}) where {T<:LinMRange} = false

"""
    as_dynamic(x)

If `x` is mutable then returns `x`, otherwise returns a comparable but mutable
type to `x`.

## Examples
```jldoctest
julia> using StaticRanges

julia> as_dynamic(Base.OneTo(10))
OneToMRange(10)

julia> as_dynamic(UnitRange(1, 10))
UnitMRange(1:10)

julia> as_dynamic(StepRange(1, 2, 20))
StepMRange(1:2:19)

julia> as_dynamic(range(1.0, step=2.0, stop=20.0))
StepMRangeLen(1.0:2.0:19.0)

julia> as_dynamic(LinRange(1, 20, 10))
LinMRange(1.0, stop=20.0, length=10)
```
"""
as_dynamic(x::OneToUnion) = OneToMRange(last(x))

as_dynamic(x::AbstractUnitRange) = UnitMRange(first(x), last(x))

as_dynamic(x::OrdinalRange) = StepMRange(first(x), step(x), last(x))

as_dynamic(x::LinMRange) = x
as_dynamic(x::Union{LinRange,LinSRange}) = LinMRange(x.start, x.stop, x.len)

as_dynamic(x::StepMRangeLen) = x
as_dynamic(x::Union{StepRangeLen,StepSRangeLen}) = StepMRangeLen(x.ref, x.step, x.len, x.offset)

function as_dynamic(A::AbstractArray)
    if is_dynamic(A)
        return A
    else
        return Array(A)
    end
end

"""
    as_fixed(x)

If `x` is immutable then returns `x`, otherwise returns a comparable but fixed size
type to `x`.

## Examples
```jldoctest
julia> using StaticRanges

julia> as_fixed(OneToMRange(10))
Base.OneTo(10)

julia> as_fixed(UnitMRange(1, 10))
1:10

julia> as_fixed(StepMRange(1, 2, 20))
1:2:19

julia> as_fixed(mrange(1.0, step=2.0, stop=20.0))
1.0:2.0:19.0

julia> as_fixed(LinMRange(1, 20, 10))
10-element LinRange{Float64}:
 1.0,3.11111,5.22222,7.33333,9.44444,11.5556,13.6667,15.7778,17.8889,20.0
```
"""
as_fixed(x::OneTo) = x
as_fixed(x::OneToRange) = OneTo(last(x))

as_fixed(x::UnitRange) = x
as_fixed(x::AbstractUnitRange) = UnitRange(first(x), last(x))

as_fixed(x::StepRange) = x
as_fixed(x::OrdinalRange) = StepRange(first(x), step(x), last(x))

as_fixed(x::LinRange) = x
as_fixed(x::AbstractLinRange) = LinRange(x.start, x.stop, x.len)

as_fixed(x::StepRangeLen) = x
as_fixed(x::AbstractStepRangeLen) = StepRangeLen(x.ref, x.step, x.len, x.offset)

# FIXME there currently isn't a clear solution for "fixed" versions of these that
# aren't also static
as_fixed(x::AbstractArray) = x

"""
    as_static(x)

If `x` is static then returns `x`, otherwise returns a comparable but static size
type to `x`.

## Examples
```jldoctest
julia> using StaticRanges, StaticArrays

julia> as_static(Base.OneTo(10))
OneToSRange(10)

julia> as_static(UnitRange(1, 10))
UnitSRange(1:10)

julia> as_static(StepRange(1, 2, 20))
StepSRange(1:2:19)

julia> as_static(range(1.0, step=2.0, stop=20.0))
StepSRangeLen(1.0:2.0:19.0)

julia> as_static(LinRange(1, 20, 10))
LinSRange(1.0, stop=20.0, length=10)

julia> as_static(reshape(1:12, (3, 4)))
3×4 SArray{Tuple{3,4},Int64,2,12} with indices SOneTo(3)×SOneTo(4):
 1  4  7  10
 2  5  8  11
 3  6  9  12

```
"""
as_static(x::OneToSRange) = x
as_static(::SOneTo{L}) where {L} = OneToSRange{Int,L}()
as_static(x::Union{OneTo,OneToMRange}) = OneToSRange(last(x))

as_static(x::UnitSRange) = x
as_static(x::StaticArrays.SUnitRange{F,L}) where {F,L} = UnitSRange{Int,F,L}()
as_static(x::AbstractUnitRange) = UnitSRange(first(x), last(x))

as_static(x::StepSRange) = x
as_static(x::OrdinalRange) = StepSRange(first(x), step(x), last(x))

as_static(x::LinSRange) = x
as_static(x::Union{LinRange,LinMRange}) = LinSRange(x.start, x.stop, x.len)

as_static(x::StepSRangeLen) = x
as_static(x::Union{StepRangeLen,StepMRangeLen}) = StepSRangeLen(x.ref, x.step, x.len, x.offset)

function as_static(A::AbstractArray)
    if is_static(A)
        return A
    else
        return SArray{Tuple{size(A)...}}(A)
    end
end

"""
    as_static(x::AbstractArray[, hint::Val{S}])

If `x` is static then returns `x`, otherwise returns a comparable but static size
type to `x`. `hint` provides the option of passing along a statically defined
tuple representing the size `S` of `x`.

## Examples
```jldoctest
julia> using StaticRanges, StaticArrays

julia> x = as_static([1], Val((1,)))
1-element SArray{Tuple{1},Int64,1,1} with indices SOneTo(1):
 1

```
"""
@inline function as_static(x::AbstractArray, hint::Val{S}) where {S}
    if is_static(x)
        return x
    else
        return SArray{Tuple{S...}}(x)
    end
end

@inline function as_static(x::AbstractRange, hint::Val{S}) where {S}
    if x isa OneToUnion
        T = eltype(x)
        return OneToSRange{T,T(first(S))}()
    else
        return as_static(x)
    end
end

# TODO This should go in base, but 
has_offset_axes(::T) where {T} = has_offset_axes(T)
has_offset_axes(::Type{T}) where {T} = false

