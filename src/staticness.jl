
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
@inline function is_dynamic(::Type{T}) where {T}
    T2 = parent_type(T)
    if T2 <: T
        return !is_fixed(T)
    else
        return is_dynamic(T2)
    end
end

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
@inline function is_static(::Type{T}) where {T}
    T2 = parent_type(T)
    if T2 <: T
        return false
    else
        return is_static(T2)
    end
end
is_static(::Type{T}) where {T<:Tuple} = true
is_static(::Type{T}) where {T<:NamedTuple} = true

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
@inline function is_fixed(::Type{T}) where {T}
    T2 = parent_type(T)
    if T2 <: T
        return false
    else
        return is_fixed(T2)
    end
end
# most range types are fixed so just make it the default
is_fixed(::Type{T}) where {T<:AbstractRange} = true

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
as_dynamic(x::OneToMRange) = x
as_dynamic(x::Union{OneTo,OneToSRange}) = OneToMRange(last(x))

as_dynamic(x::UnitMRange) = x
as_dynamic(x::Union{UnitRange,UnitSRange}) = UnitMRange(first(x), last(x))

as_dynamic(x::StepMRange) = x
as_dynamic(x::Union{StepRange,StepSRange}) = StepMRange(first(x), step(x), last(x))

as_dynamic(x::LinMRange) = x
as_dynamic(x::Union{LinRange,LinSRange}) = LinMRange(first(x), last(x), length(x))

as_dynamic(x::StepMRangeLen) = x
as_dynamic(x::Union{StepRangeLen,StepSRangeLen}) = StepMRangeLen(first(x), step(x), length(x), x.offset)

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
as_fixed(x::AbstractStepRange) = StepRange(first(x), step(x), last(x))

as_fixed(x::LinRange) = x
as_fixed(x::AbstractLinRange) = LinRange(first(x), last(x), length(x))

as_fixed(x::StepRangeLen) = x
as_fixed(x::AbstractStepRangeLen) = StepRangeLen(first(x), step(x), length(x), x.offset)

"""
    as_static(x)

If `x` is static then returns `x`, otherwise returns a comparable but static size
type to `x`.

## Examples
```jldoctest
julia> using StaticRanges

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
```
"""
as_static(x::OneToSRange) = x
as_static(x::Union{OneTo,OneToMRange}) = OneToSRange(last(x))

as_static(x::UnitSRange) = x
as_static(x::Union{UnitRange,UnitMRange}) = UnitSRange(first(x), last(x))

as_static(x::StepSRange) = x
as_static(x::Union{StepRange,StepMRange}) = StepSRange(first(x), step(x), last(x))

as_static(x::LinSRange) = x
as_static(x::Union{LinRange,LinMRange}) = LinSRange(first(x), last(x), length(x))

as_static(x::StepSRangeLen) = x
as_static(x::Union{StepRangeLen,StepMRangeLen}) = StepSRangeLen(first(x), step(x), length(x), x.offset)

