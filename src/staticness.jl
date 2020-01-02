"""
    is_dynamic(x) -> Bool

Returns true if the size of `x` is dynamic/can change.

## Examples
```jldoctest
julia> usr = UnitSRange(1, 10)
UnitSRange(1:10)

julia> smr = StepMRange(1, 2, 20)
StepMRange(1:2:19)

julia> sfr = StepRange(1, 2, 20)
1:2:19

julia> is_dynamic(usr)
false

julia> is_dynamic(ufr)
false

julia> is_dynamic(umr)
true
```
"""
is_dynamic(::T) where {T} = is_dynamic(T)
is_dynamic(::Type{T}) where {T} = is_fixed(T) | is_static(T) ? false : true
function is_dynamic(::Type{T}) where {T<:AbstractAxis}
    return is_dynamic(values_type(T)) & is_dynamic(keys_type(T))
end
is_dynamic(::Type{T}) where {T<:SimpleAxis} = is_dynamic(keys_type(T))

"""
    is_static(x) -> Bool

Returns `true` if `x` is static.

## Examples
```jldoctest
julia> usr = UnitSRange(1, 10)
UnitSRange(1:10)

julia> smr = StepMRange(1, 2, 20)
StepMRange(1:2:19)

julia> sfr = StepRange(1, 2, 20)
1:2:19

julia> is_static(usr)
true

julia> is_static(ufr)
false

julia> is_static(umr)
false
```
"""
is_static(::T) where {T} = is_static(T)
is_static(::Type{T}) where {T} = false
is_static(::Type{T}) where {T<:SRange} = true
function is_static(::Type{T}) where {T<:AbstractAxis}
    return is_static(values_type(T)) & is_static(keys_type(T))
end
is_static(::Type{T}) where {T<:SimpleAxis} = is_static(keys_type(T))

"""
    is_fixed(x) -> Bool

Returns `true` if the size of `x` is fixed.

## Examples
```jldoctest
julia> usr = UnitSRange(1, 10)
UnitSRange(1:10)

julia> smr = StepMRange(1, 2, 20)
StepMRange(1:2:19)

julia> sfr = StepRange(1, 2, 20)
1:2:19

julia> is_fixed(usr)
false

julia> is_fixed(ufr)
true

julia> is_fixed(umr)
false
```
"""
is_fixed(::T) where {T} = is_fixed(T)
is_fixed(::Type{T}) where {T} = !T.mutable & !is_static(T) ? true : false
function is_fixed(::Type{T}) where {T<:AbstractAxis}
    return is_fixed(values_type(T)) & is_fixed(keys_type(T))
end
is_fixed(::Type{T}) where {T<:SimpleAxis} = is_fixed(keys_type(T))


"""
    as_dynamic(x)

If `x` is mutable then returns `x`, otherwise returns a comparable but mutable
type to `x`.

## Examples
```jldoctest
julia> as_dynamic(OneTo(10))
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

as_dynamic(x::Axis{name}) where {name} = Axis{name}(as_dynamic(keys(x)), as_dynamic(values(x)))
as_dynamic(x::SimpleAxis{name}) where {name} = SimpleAxis{name}(as_dynamic(values(x)))

"""
    as_fixed(x)

If `x` is immutable then returns `x`, otherwise returns a comparable but fixed size
type to `x`.

## Examples
```jldoctest
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

as_fixed(x::Axis{name}) where {name} = Axis{name}(as_fixed(keys(x)), as_fixed(values(x)))
as_fixed(x::SimpleAxis{name}) where {name} = SimpleAxis{name}(as_fixed(values(x)))

"""
    as_static(x)

If `x` is static then returns `x`, otherwise returns a comparable but static size
type to `x`.

## Examples
```jldoctest
julia> as_static(OneTo(10))
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

as_static(x::Axis{name}) where {name} = Axis{name}(as_static(keys(x)), as_static(values(x)))
as_static(x::SimpleAxis{name}) where {name} = SimpleAxis{name}(as_static(values(x)))
