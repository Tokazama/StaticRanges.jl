const SRange{T} = Union{OneToSRange{T},UnitSRange{T},StepSRange{T},LinSRange{T},StepSRangeLen{T}}
const MRange{T} = Union{OneToMRange{T},UnitMRange{T},StepMRange{T},LinMRange{T},StepMRangeLen{T}}
const UnionRange{T} = Union{SRange{T},MRange{T}}
const FRange{T} = Union{OneTo{T},UnitRange{T},StepRange{T},LinRange{T}, StepRangeLen{T}}

"is_dynamic(x) - Returns true if the size of `x` is dynamic/can change."
is_dynamic(::T) where {T} = is_dynamic(T)
is_dynamic(::Type{T}) where {T} = is_fixed(T) | is_static(T) ? false : true

"is_static(x) - Returns `true` if `x` is static."
is_static(::T) where {T} = is_static(T)
is_static(::Type{T}) where {T} = false
is_static(::Type{T}) where {T<:SRange} = true

"is_fixed(x) - Returns `true` if the size of `x` is fixed."
is_fixed(::T) where {T} = is_fixed(T)
is_fixed(::Type{T}) where {T} = isimmutable(T) & !is_static(T) ? true : false

# TODO: this should be in ArrayInterface
ArrayInterface.can_setindex(::Type{X}) where {X<:AbstractRange} = false

# TODO: this should be in ArrayInterface
ArrayInterface.ismutable(::Type{X}) where {X<:AbstractRange} = false
ArrayInterface.ismutable(::Type{X}) where {X<:MRange} = true

"""
    as_dynamic(x)

If `x` is mutable then returns `x`, otherwise returns a comparable but mutable
type to `x`.
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
"""
as_fixed(x::OneTo) = x
as_fixed(x::OneToRange) = OneTo(last(x))

as_fixed(x::UnitRange) = x
as_fixed(x::StaticUnitRange) = UnitRange(first(x), last(x))

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
