
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
is_dynamic(x) = is_dynamic(typeof(x))
is_dynamic(::Type{T}) where {T} = false
is_dynamic(::Type{T}) where {T<:AbstractArray} = true
is_dynamic(::Type{T}) where {T<:AbstractRange} = false
is_dynamic(::Type{T}) where {T<:AbstractDict} = true

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
is_static(::Type{T}) where {T<:Tuple} = true
is_static(::Type{T}) where {T<:Val} = true
is_static(::Type{T}) where {T<:NamedTuple} = true

"""
    is_fixed(x) -> Bool

Returns `true` if the size of `x` is fixed.

## Examples
```jldoctest
julia> using StaticRanges

julia> is_fixed(UnitSRange(1, 10))
false

julia> is_fixed(StepRange(1, 2, 20))
true

julia> is_fixed(StepMRange(1, 2, 20))
false
```
"""
is_fixed(x) = is_fixed(typeof(x))
is_fixed(::Type{T}) where {T} = true
is_fixed(::Type{T}) where {T<:AbstractVector} = !ismutable(T)
is_fixed(::Type{T}) where {T<:LinRange} = true
is_fixed(::Type{T}) where {T<:StepRange} = true
is_fixed(::Type{T}) where {T<:StepRangeLen} = true
is_fixed(::Type{T}) where {T<:UnitRange} = true
is_fixed(::Type{T}) where {T<:OneTo} = true


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
as_dynamic(x) = x

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
function as_fixed(x::AbstractArray{T,N}) where {T,N}
    if is_fixed(x)
        return x
    else
        return view(x, ntuple(_->:, Val(N)))
    end
end

@inline function as_fixed(v::V) where {V<:AbstractVector}
    if is_fixed(V)
        return v
    elseif is_range(V)
        if has_start_field(V)
            if has_step_field(V)
                return StepRange(first(v), step(v), last(v))
            else
                if has_len_field(V)
                    return LinRange(first(v), last(v), length(v))
                else
                    return UnitRange(first(v), last(v))
                end
            end
        else
            if has_offset_field(V)
                return StepRangeLen(
                    get_ref_field(v),
                    get_step_field(v),
                    get_len_field(v),
                    get_offset_field(v)
                )
            else
                return OneTo(last(v))
            end
        end
    else
        return view(v, :)
    end
end

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
as_static(x) = x


"""
    of_staticness(x, y)

Convert `y` to be dynamic if `is_dynamic(x)`, to fixed if `is_fixed(x)`, or static if
`is_static(x)`.
"""
@inline function of_staticness(x, y)
    if is_static(x)
        return as_static(y)
    elseif is_fixed(x)
        return as_fixed(y)
    else
        return as_dynamic(y)
    end
end
