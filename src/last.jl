
ArrayInterface.known_last(::Type{<:OneToSRange{<:Any,L}}) where {L} = L
ArrayInterface.known_last(::Type{<:StepSRange{<:Any,<:Any,<:Any,<:Any,L}}) where {L} = L
ArrayInterface.known_last(::Type{<:UnitSRange{<:Any,<:Any,L}}) where {L} = L
ArrayInterface.known_last(::Type{<:LinSRange{<:Any,<:Any,E}}) where {E} = E

Base.last(r::OneToSRange) = known_last(r)
Base.last(r::OneToMRange) = getfield(r, :stop)
Base.last(r::UnitSRange) = known_last(r)
Base.last(r::UnitMRange) = getfield(r, :stop)
Base.last(r::StepSRange) = known_last(r)
Base.last(r::StepMRange) = getfield(r, :stop)
Base.last(r::LinSRange) = known_last(r)
Base.last(r::LinMRange) = getfield(r, :stop)
Base.last(r::AbstractStepRangeLen) = unsafe_getindex(r, length(r))

"""
    can_set_last(x) -> Bool

Returns `true` if the last element of `x` can be set. If `x` is a range then
changing the first element will also change the length of `x`.
"""
can_set_last(x) = can_set_last(typeof(x))
can_set_last(::Type{T}) where {T} = can_setindex(T)
can_set_last(::Type{T}) where {T<:AbstractRange} = can_change_size(T)

"""
    set_last!(x, val)

Set the last element of `x` to `val`.

## Examples
```julia
julia> using StaticRanges

julia> mr = UnitMRange(1, 10);

julia> set_last!(r, 5);

julia> last(mr)
5
```
"""
function set_last!(x::AbstractVector, val)
    can_set_last(x) || throw(MethodError(set_last!, (x, val)))
    setindex!(x, val, lastindex(x))
    return x
end
function set_last!(x::StepMRangeLen{T}, val) where {T}
    len = unsafe_find_value(val, x) # FIXME should not use unsafe_find_value at this point
    len >= 0 || throw(ArgumentError("length cannot be negative, got $len"))
    1 <= x.offset <= max(1, len) || throw(ArgumentError("StepSRangeLen: offset must be in [1,$len], got $(x.offset)"))
    setfield!(x, :len, len)
    return x
end
function set_last!(x::LinMRange{T}, val) where {T}
    setfield!(x, :stop, T(val))
    return x
end
function set_last!(x::StepMRange{T}, val) where {T}
    setfield!(x, :stop, T(Base.steprange_last(first(x), step(x), val)))
    return x
end
function set_last!(x::UnitMRange{T}, val) where {T}
    setfield!(x, :stop, T(val))
    return x
end
function set_last!(x::OneToMRange{T}, val) where {T}
    setfield!(x, :stop, max(zero(T), T(val)))
    return x
end
function set_last!(x::AbstractRange, val)
    if parent_type(x) <: typeof(x)
        throw(MethodError(set_last!, (x, val)))
    else
        set_last!(parent(x), val)
        return x
    end
end

"""
    set_last(x, val)

Returns a similar type as `x` with its last value equal to `val`.

## Examplse
```jldoctest
julia> using StaticRanges

julia> set_last(1:10, 5)
1:5
```
"""
function set_last(x::AbstractVector, val)
    if isempty(x)
        # TODO when this is in ArrayInterface
        # return push(x, val)
        return vcat(x, val)
    elseif length(x) == 1
        return vcat(empty(x), val)
    else
        return vcat(@inbounds(x[1:end-1]), val)
    end
end
set_last(x::OptionallyStaticRange, val) = static_first(x):ArrayInterface.static_step(x):val
function set_last(x::AbstractRange{T}, val) where {T}
    if parent_type(x) <: typeof(x)
        throw(MethodError(set_last, (x, val)))
    else
        return ArrayInterface.unsafe_reconstruct(x, set_last(parent(x), val))
    end
end
set_last(x::Union{<:StepRange,<:StepSRange,<:StepMRange}, val) = typeof(x)(first(x), step(x), val)
set_last(x::Union{<:UnitRange,<:UnitSRange,<:UnitMRange}, val) = typeof(x)(first(x), val)
set_last(x::Union{<:LinRange,<:LinMRange,<:LinSRange}, val) = typeof(x)(first(x), val, x.len)
function set_last(x::Union{<:StepRangeLen,<:StepMRangeLen,<:StepSRangeLen}, val)
    return typeof(x)(x.ref, x.step, unsafe_find_value(val, x), x.offset)
end
@inline function set_last(x::Union{<:OneTo,<:OneToSRange,<:OneToMRange}, val)
    if val isa StaticInt
        return One():val
    else
        typeof(x)(val)
    end
end

