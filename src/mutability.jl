const SRange{T} = Union{OneToSRange{T},UnitSRange{T},StepSRange{T},LinSRange{T},StepSRangeLen{T}}
const MRange{T} = Union{OneToMRange{T},UnitMRange{T},StepMRange{T},LinMRange{T},StepMRangeLen{T}}
const UnionRange{T} = Union{SRange{T},MRange{T}}
const IRange{T} = Union{OneTo{T},UnitRange{T},StepRange{T},LinRange{T}, StepRangeLen{T}}

# TODO: this should be in ArrayInterface
ArrayInterface.can_setindex(::Type{X}) where {X<:AbstractRange} = false

# TODO: this should be in ArrayInterface
ArrayInterface.ismutable(::Type{X}) where {X<:AbstractRange} = false
ArrayInterface.ismutable(::Type{X}) where {X<:MRange} = false

"""
    is_static(x) -> Bool

Returns `true` if `x` is static.
"""
is_static(::T) where {T} = is_static(T)
is_static(::Type{T}) where {T} = false
is_static(::Type{T}) where {T<:SRange} = true

"""
    Mutability
"""
abstract type Mutability end

struct MutableTrait <: Mutability end
const Mutable = MutableTrait()

struct ImmutableTrait <: Mutability end
const Immutable = ImmutableTrait()

struct StaticTrait <: Mutability end
const Static = StaticTrait()

Mutability(::T) where {T} = Mutability(T)
Mutability(::Type{T}) where {T<:AbstractArray} = Immutable
Mutability(::Type{T}) where {T<:Array} = Mutable
Mutability(::Type{T}) where {T<:MRange} = Mutable
Mutability(::Type{T}) where {T<:StaticArray} = Static
Mutability(::Type{T}) where {T<:SRange} = Static

"""
    as_mutable(x)

If `x` is mutable then returns `x`, otherwise returns a comparable but mutable
type to `x`.
"""
as_mutable(x::OneToMRange) = x
as_mutable(x::Union{OneTo,OneToSRange}) = OneToMRange(last(x))

as_mutable(x::UnitMRange) = x
as_mutable(x::Union{UnitRange,UnitSRange}) = UnitMRange(first(x), last(x))

as_mutable(x::StepMRange) = x
as_mutable(x::Union{StepRange,StepSRange}) = StepMRange(first(x), step(x), last(x))

as_mutable(x::LinMRange) = x
as_mutable(x::Union{LinRange,LinSRange}) = LinMRange(first(x), last(x), length(x))

as_mutable(x::StepMRangeLen) = x
as_mutable(x::Union{StepRangeLen,StepSRangeLen}) = StepMRangeLen(first(x), step(x), length(x), x.offset)

"""
    as_immutable(x)

If `x` is immutable then returns `x`, otherwise returns a comparable but immutable
type to `x`.
"""
as_immutable(x::OneTo) = x
as_immutable(x::OneToRange) = OneTo(last(x))

as_mutable(x::UnitRange) = x
as_mutable(x::StaticUnitRange) = UnitRange(first(x), last(x))

as_mutable(x::StepRange) = x
as_mutable(x::AbstractStepRange) = StepRange(first(x), step(x), last(x))

as_mutable(x::LinRange) = x
as_mutable(x::AbstractLinRange) = LinRange(first(x), last(x), length(x))

as_mutable(x::StepRangeLen) = x
as_mutable(x::AbstractStepRangeLen) = StepMRangeLen(first(x), step(x), length(x), x.offset)

"""
    as_static(x)

If `x` is static then returns `x`, otherwise returns a comparable but static
type to `x`.
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
