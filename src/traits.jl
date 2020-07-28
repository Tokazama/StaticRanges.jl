

function RangeInterface.axes_type(::Type{<:StaticArray{S,T,N}}) where {S,T,N}
    axs = ntuple(Val(N)) do i
        if S.parameters[i] isa Int
            SOneTo{S.parameters[i]}
        else
            OneTo{Int}
        end
    end
    return Tuple{axs...}
end


# this expand on the idea of `Dynamic` in StaticArrays
abstract type Staticness end

struct Static <: Staticness end

struct Dynamic <: Staticness end

struct Fixed <: Staticness end

Staticness(::T) where {T} = Staticness(T)

Staticness(::Type{T}) where {T} = Fixed()  # fall back is `Fixed`

Staticness(::Type{T}) where {T<:Tuple} = Static()

Staticness(::Type{T}) where {T<:NamedTuple} = Static()

Staticness(::Type{T}) where {T<:OneToSRange} = Static()

Staticness(::Type{T}) where {T<:UnitSRange} = Static()

Staticness(::Type{T}) where {T<:StepSRange} = Static()

Staticness(::Type{T}) where {T<:StepSRangeLen} = Static()

Staticness(::Type{T}) where {T<:LinSRange} = Static()

Staticness(::Type{T}) where {T<:AbstractVector} = Dynamic()

Staticness(::Type{T}) where {T<:AbstractRange} = Fixed()

Staticness(::Type{T}) where {T<:OneToMRange} = Dynamic()

Staticness(::Type{T}) where {T<:UnitMRange} = Dynamic()

Staticness(::Type{T}) where {T<:StepMRange} = Dynamic()

Staticness(::Type{T}) where {T<:StepMRangeLen} = Dynamic()

Staticness(::Type{T}) where {T<:LinMRange} = Dynamic()

Staticness(::Type{T}) where {T<:SOneTo} = Static()

Staticness(::Type{T}) where {T<:StaticArrays.SUnitRange} = Static()

Staticness(::Type{T}) where {T<:StaticArray} = Static()


# degenerative combinations of staticness
Staticness(x, y) = Staticness(Staticness(x), Staticness(y))
Staticness(x::Staticness) = x
Staticness(x::T, y::T) where {T<:Staticness} = x
Staticness(::Static, ::Dynamic) = Dynamic()
Staticness(::Dynamic, ::Static) = Dynamic()
Staticness(::Fixed, ::Dynamic) = Dynamic()
Staticness(::Dynamic, ::Fixed) = Dynamic()
Staticness(::Fixed, ::Static) = Fixed()
Staticness(::Static, ::Fixed) = Fixed()

Staticness(::Type{T}) where {T<:AbstractArray} = _combine(RangeInterface.axes_type(T))

Base.@pure function _combine(::Type{T}) where {T<:Tuple}
    out = Static()
    for ax_i in T.parameters
        out = Staticness(out, Staticness(ax_i))
    end
    return out
end

# SubArray cannot be dynamic
function Staticness(::Type{A}) where {A<:SubArray}
    S = Staticness(parent_type(A))
    if S isa Static
        return S
    else
        Fixed()
    end
end

RangeInterface.as_dynamic(x::OneToUnion) = OneToMRange(last(x))

RangeInterface.as_dynamic(x::AbstractUnitRange) = UnitMRange(first(x), last(x))

RangeInterface.as_dynamic(x::OrdinalRange) = StepMRange(first(x), step(x), last(x))

RangeInterface.as_dynamic(x::LinMRange) = x
RangeInterface.as_dynamic(x::Union{LinRange,LinSRange}) = LinMRange(x.start, x.stop, x.len)

RangeInterface.as_dynamic(x::StepMRangeLen) = x
RangeInterface.as_dynamic(x::Union{StepRangeLen,StepSRangeLen}) = StepMRangeLen(x.ref, x.step, x.len, x.offset)

function RangeInterface.as_dynamic(A::AbstractArray)
    if is_dynamic(A)
        return A
    else
        return Array(A)
    end
end

RangeInterface.as_static(x::OneToSRange) = x
RangeInterface.as_static(::SOneTo{L}) where {L} = OneToSRange{Int,L}()
RangeInterface.as_static(x::StaticArrays.SUnitRange{F,L}) where {F,L} = UnitSRange{Int,F,L}()
RangeInterface.as_static(x::Union{OneTo,OneToMRange}) = OneToSRange(last(x))

RangeInterface.as_static(x::AbstractUnitRange) = UnitSRange(first(x), last(x))

RangeInterface.as_static(x::StepSRange) = x
RangeInterface.as_static(x::OrdinalRange) = StepSRange(first(x), step(x), last(x))

RangeInterface.as_static(x::LinSRange) = x
RangeInterface.as_static(x::Union{LinRange,LinMRange}) = LinSRange(x.start, x.stop, x.len)

RangeInterface.as_static(x::StepSRangeLen) = x
RangeInterface.as_static(x::Union{StepRangeLen,StepMRangeLen}) = StepSRangeLen(x.ref, x.step, x.len, x.offset)

function RangeInterface.as_static(A::AbstractArray)
    if is_static(A)
        return A
    else
        return SArray{Tuple{size(A)...}}(A)
    end
end

# FIXME
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
@inline function RangeInterface.as_static(x::AbstractArray, hint::Val{S}) where {S}
    if is_static(x)
        return x
    else
        return SArray{Tuple{S...}}(x)
    end
end
RangeInterface.is_static(::Type{T}) where {T<:SArray} = true
RangeInterface.is_dynamic(::Type{T}) where {T<:SArray} = false

@inline function RangeInterface.as_static(x::AbstractRange, hint::Val{S}) where {S}
    if x isa OneToUnion
        T = eltype(x)
        return OneToSRange{T,T(first(S))}()
    else
        return as_static(x)
    end
end


