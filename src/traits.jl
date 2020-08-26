
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
as_dynamic(x::OneToUnion) = OneToMRange(last(x))
as_dynamic(x::AbstractUnitRange) = UnitMRange(first(x), last(x))
as_dynamic(x::OrdinalRange) = StepMRange(first(x), step(x), last(x))
as_dynamic(x::LinMRange) = x
as_dynamic(x::Union{LinRange,LinSRange}) = LinMRange(x.start, x.stop, x.len)
as_dynamic(x::StepMRangeLen) = x
as_dynamic(x::Union{StepRangeLen,StepSRangeLen}) = StepMRangeLen(x.ref, x.step, x.len, x.offset)
function as_dynamic(A::AbstractArray)
    if can_change_size(A)
        return A
    else
        return Array(A)
    end
end

# TODO as_dynamic(x::SubArray)

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

function as_fixed(x::AbstractRange)
    if is_fixed(x)
        return x
    else
        if known_step(x) === oneunit(eltype(x))
            if known_first(x) === oneunit(eltype(x))
                return OneTo(last(x))
            else
                return UnitRange(first(x), last(x))
            end
        else
            return StepRange(first(x), step(x), last(x))
        end
    end
end

as_fixed(x::LinMRange) = LinRange(first(x), last(x), length(x))

as_fixed(x::StepMRangeLen) = StepRangeLen(x.ref, x.step, x.len, x.offset)

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
3×4 SizedArray{Tuple{3,4},Int64,2,2} with indices SOneTo(3)×SOneTo(4):
 1  4  7  10
 2  5  8  11
 3  6  9  12

```
"""
as_static(x) = x

"""
    as_static(x::AbstractArray[, hint::Val{S}])

If `x` is static then returns `x`, otherwise returns a comparable but static size
type to `x`. `hint` provides the option of passing along a statically defined
tuple representing the size `S` of `x`.

## Examples
```jldoctest
julia> using StaticRanges, StaticArrays

julia> x = as_static([1], Val((1,)))
1-element SizedArray{Tuple{1},Int64,1,1} with indices SOneTo(1):
 1

```
"""
as_static(x::OneToSRange, hint::Val) = x
as_static(x::OneToSRange) = x

as_static(::SOneTo{L}) where {L} = OneToSRange{Int,L}()
as_static(::SOneTo{L}, hint::Val) where {L} = OneToSRange{Int,first(L)}()

as_static(x::StaticArrays.SUnitRange{F,L}) where {F,L} = UnitSRange{Int,F,L}()
as_static(x::StaticArrays.SUnitRange{F,L}, hint::Val) where {F,L} = UnitSRange{Int,F,L}()

as_static(x::OneTo) = as_static(x, Val(last(x)))
as_static(x::OneTo{T}, hint::Val{L}) where {T,L} = OneToSRange{T}(T(first(L)))

as_static(x::OneToMRange) = as_static(x, Val(last(x)))
as_static(x::OneToMRange{T}, hint::Val{L}) where {T,L} = OneToSRange{T}(T(first(L)))


as_static(x::StepSRangeLen) = x
as_static(x::StepSRangeLen, hint::Val) = x

as_static(x::StepRangeLen) = as_static(x, Val(length(x)))
as_static(x::StepRangeLen, hint::Val{L}) where {L} = StepSRangeLen(x.ref, x.step, first(L), x.offset)

as_static(x::StepMRangeLen) = as_static(x, Val(length(x)))
as_static(x::StepMRangeLen, hint::Val{L}) where {L} = StepSRangeLen(x.ref, x.step, first(L), x.offset)

as_static(x::StepSRange) = x
as_static(x::StepSRange, hint::Val) = x

# hints don't help without the rest of the parameters one these but these methods
# are included so that the method can be generalized
as_static(x::OrdinalRange) = StepSRange(first(x), step(x), last(x))
as_static(x::OrdinalRange, hint::Val) = StepSRange(first(x), step(x), last(x))

as_static(x::AbstractUnitRange) = UnitSRange(first(x), last(x))
as_static(x::AbstractUnitRange, hint::Val{L}) where {L} = UnitSRange(first(x), last(x))

as_static(x::LinSRange) = x
as_static(x::LinRange) = as_static(x, Val(length(x)))
as_static(x::LinRange, ::Val{L}) where {L} = LinSRange(x.start, x.stop, first(L))

as_static(x::LinMRange) = as_static(x, Val(length(x)))
as_static(x::LinMRange, ::Val{L}) where {L} = LinSRange(x.start, x.stop, first(L))

function as_static(x::AbstractVector, hint::Val{S}) where {S}
    if is_static(x)
        return x
    else
        return SizedVector{first(S)}(x)
    end
end

function as_static(x::AbstractArray, hint::Val{S}) where {S}
    if is_static(x)
        return x
    else
        return SizedArray{Tuple{S...}}(x)
    end
end

# type unstable version
@inline as_static(x::AbstractArray) = as_static(x, Val(size(x)))

@inline function as_static(x::AbstractRange, hint::Val{S}) where {S}
    if x isa OneToUnion
        T = eltype(x)
        return OneToSRange{T,T(first(S))}()
    else
        return as_static(x)
    end
end

"""
    of_staticness(x, y)

Convert `y` to be dynamic if `can_change_size(x)`, to fixed if `is_fixed(x)`, or static if
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

