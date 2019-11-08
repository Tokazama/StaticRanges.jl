# TODO: this should be in ArrayInterface
ArrayInterface.can_setindex(::Type{X}) where {X<:AbstractRange} = false

"""
    is_static(x) -> Bool

Returns `true` if `x` is static.
"""
is_static(::X) where {X} = is_static(X)
is_static(::Type{X}) where {X} = false
is_static(::Type{X}) where {X<:SRange} = true

"""
    can_set_first(x) -> Bool

Returns `true` if the first element of `x` can be set. If `x` is a range then
changing the first element will also change the length of `x`.
"""
can_set_first(::X) where {X} = can_set_first(X)
can_set_first(::Type{X}) where {X} = can_setindex(X)
# TODO figure out how to make this possible
#can_set_first(::Type{T}) where {T<:StepMRangeLen} = true
can_set_first(::Type{T}) where {T<:LinMRange} = true
can_set_first(::Type{T}) where {T<:StepMRange} = true
can_set_first(::Type{T}) where {T<:UnitMRange} = true

"""
    set_first!(x, val)

Set the first element of `x` to `val`.
"""
function set_first!(x::AbstractVector{T}, val::T) where {T}
    can_set_first(x) || throw(MethodError(set_first!, (x, val)))
    setindex!(x, val, firstindex(x))
    return x
end
set_first!(x::AbstractVector{T}, val) where {T} = set_first!(x, convert(T, val))
set_first!(r::LinMRange{T}, val::T) where {T} = (setfield!(r, :start, val); r)
set_first!(r::StepMRange{T,S}, val::T) where {T,S} = (setfield!(r, :start, val); r)
set_first!(r::UnitMRange{T}, val::T) where {T} = (setfield!(r, :start, val); r)

"""
    can_set_last(x) -> Bool

Returns `true` if the last element of `x` can be set. If `x` is a range then
changing the first element will also change the length of `x`.
"""
can_set_last(::X) where {X} = can_set_last(X)
can_set_last(::Type{X}) where {X} = can_setindex(X)
can_set_last(::Type{T}) where {T<:LinMRange} = true
can_set_last(::Type{T}) where {T<:StepMRange} = true
can_set_last(::Type{T}) where {T<:UnitMRange} = true
can_set_last(::Type{T}) where {T<:OneToMRange} = true

"""
    set_last!(x, val)

Set the last element of `x` to `val`.
"""
function set_last!(x::AbstractVector{T}, val::T) where {T}
    can_set_last(x) || throw(MethodError(set_last!, (x, val)))
    setindex!(x, val, lastindex(x))
    return x
end
set_last!(x::AbstractVector{T}, val) where {T} = set_last!(x, convert(T, val))
set_last!(r::LinMRange{T}, val::T) where {T} = (setfield!(r, :stop, val); r)
set_last!(r::StepMRange{T,S}, val::T) where {T,S} = (setfield!(r, :stop, val); r)
set_last!(r::UnitMRange{T}, val::T) where {T} = (setfield!(r, :stop, val); r)
set_last!(r::OneToMRange{T}, val::T) where {T} = (setfield!(r, :stop, val); r)


"""
    has_step(x) -> Bool

Returns `true` if type of `x` has `step` method defined.
"""
has_step(::X) where {X} = has_step(X)
has_step(::Type{T}) where {T} = false
has_step(::Type{T}) where {T<:AbstractRange} = true

"""
    can_set_step(x) -> Bool

Returns `true` if type of `x` has `step` field that can be set.
"""
can_set_step(::X) where {X} = can_set_step(X)
can_set_step(::Type{X}) where {X} = false
can_set_step(::Type{T}) where {T<:StepMRange} = true
can_set_step(::Type{T}) where {T<:StepMRangeLen} = true

"""
    set_step!(x, val)

Sets the `step` of `x` to `val`.
"""
set_step!(x::AbstractRange{T}, val) where {T} = set_step!(x, convert(T, val))
function set_step!(r::StepMRange{T,S}, val::S) where {T,S}
    setfield!(r, :step, val)
    set_last!(r, Base.steprange_last(first(r), val, last(r)))
    return r
end
set_step!(r::StepMRangeLen{T,R,S}, val::S) where {T,R,S} = (setfield!(r, :step, val); r)

"""
    can_set_length(x) -> Bool

Returns `true` if type of `x` can have its length set independent of changing
its first or last position.
"""
can_set_length(::T) where {T} = can_set_length(T)
can_set_length(::Type{T}) where {T} = false
can_set_length(::Type{T}) where {T<:LinMRange} = true
can_set_length(::Type{T}) where {T<:StepMRangeLen} = true

"""
    set_length!(x, len)

Change the length of `x` while maintaining it's first and last positions.
"""
set_length!(x::AbstractRange, val) = set_length!(x, Int(val))

function set_length!(r::LinMRange, len::Int)
    len >= 0 || throw(ArgumentError("set_length!($r, $len): negative length"))
    if len == 1
        r.start == r.stop || throw(ArgumentError("set_length!($r, $len): endpoints differ"))
        setfield!(r, :len, 1)
        setfield!(r, :lendiv, 1)
        return r
    end
    setfield!(r, :len, len)
    setfield!(r, :lendiv, max(len - 1, 1))
    return r
end

function set_length!(r::StepMRangeLen, len::Int)
    len >= 0 || throw(ArgumentError("length cannot be negative, got $len"))
    1 <= r.offset <= max(1,len) || throw(ArgumentError("StepMRangeLen: offset must be in [1,$len], got $offset"))
    setfield!(r, :len, len)
    return r
end

"""
    set_ref!(x)

Set the reference field of an instance of `StepMRangeLen`.
"""
set_ref!(r::StepMRangeLen{T,R,S}, val::R) where {T,R,S} = (setfield!(r, :ref, val); r)
set_ref!(r::StepMRangeLen{T,R,S}, val) where {T,R,S} = set_ref!(r, convert(R, val))

"""
    set_offset!(x)

Set the offset field of an instance of `StepMRangeLen`.
"""
function set_offset!(r::StepMRangeLen, val::Int)
    1 <= val <= max(1,r.len) || throw(ArgumentError("StepMRangeLen: offset must be in [1,$len], got $offset"))
    setfield!(r, :offset, val)
    return r
end
set_offset!(r::StepMRangeLen, val) = set_offset!(r, Int(val))
