
# TODO: this should be in ArrayInterface
ArrayInterface.can_setindex(::Type{X}) where {X<:AbstractRange} = false

"""
    isstatic(x) -> Bool

Returns `true` if `x` is static.
"""
isstatic(::X) where {X} = isstatic(X)
isstatic(::Type{X}) where {X} = false
isstatic(::Type{X}) where {X<:SRange} = true

"""
    can_setfirst(x) -> Bool

Returns `true` if the first element of `x` can be set. If `x` is a range then
changing the first element will also change the length of `x`.
"""
can_setfirst(::X) where {X} = can_setfirst(X)
can_setfirst(::Type{X}) where {X} = can_setindex(X)
# TODO figure out how to make this possible
#can_setfirst(::Type{T}) where {T<:StepMRangeLen} = true
can_setfirst(::Type{T}) where {T<:LinMRange} = true
can_setfirst(::Type{T}) where {T<:StepMRange} = true
can_setfirst(::Type{T}) where {T<:UnitMRange} = true

"""
    setfirst!(x, val)

Set the first element of `x` to `val`.
"""
function setfirst!(x::AbstractVector{T}, val::T) where {T}
    can_setfirst(x) || throw(MethodError(setfirst!, (x, val)))
    setindex!(x, val, firstindex(x))
    return x
end
setfirst!(x::AbstractVector{T}, val) where {T} = setfirst!(x, convert(T, val))
setfirst!(r::LinMRange{T}, val::T) where {T} = (setfield!(r, :start, val); r)
setfirst!(r::StepMRange{T,S}, val::T) where {T,S} = (setfield!(r, :start, val); r)
setfirst!(r::UnitMRange{T}, val::T) where {T} = (setfield!(r, :start, val); r)

"""
    can_setlast(x) -> Bool

Returns `true` if the last element of `x` can be set. If `x` is a range then
changing the first element will also change the length of `x`.
"""
can_setlast(::X) where {X} = can_setlast(X)
can_setlast(::Type{X}) where {X} = can_setindex(X)
can_setlast(::Type{T}) where {T<:LinMRange} = true
can_setlast(::Type{T}) where {T<:StepMRange} = true
can_setlast(::Type{T}) where {T<:UnitMRange} = true
can_setlast(::Type{T}) where {T<:OneToMRange} = true

"""
    setlast!(x, val)

Set the last element of `x` to `val`.
"""
function setlast!(x::AbstractVector{T}, val::T) where {T}
    can_setlast(x) || throw(MethodError(setlast!, (x, val)))
    setindex!(x, val, lastindex(x))
    return x
end
setlast!(x::AbstractVector{T}, val) where {T} = setlast!(x, convert(T, val))
setlast!(r::LinMRange{T}, val::T) where {T} = (setfield!(r, :stop, val); r)
setlast!(r::StepMRange{T,S}, val::T) where {T,S} = (setfield!(r, :stop, val); r)
setlast!(r::UnitMRange{T}, val::T) where {T} = (setfield!(r, :stop, val); r)
setlast!(r::OneToMRange{T}, val::T) where {T} = (setfield!(r, :stop, val); r)


"""
    has_step(x) -> Bool

Returns `true` if type of `x` has `step` method defined.
"""
has_step(::X) where {X} = has_step(X)
has_step(::Type{T}) where {T} = false
has_step(::Type{T}) where {T<:AbstractRange} = true

"""
    can_setstep(x) -> Bool

Returns `true` if type of `x` has `step` field that can be set.
"""
can_setstep(::X) where {X} = can_setstep(X)
can_setstep(::Type{X}) where {X} = false
can_setstep(::Type{T}) where {T<:StepMRange} = true
can_setstep(::Type{T}) where {T<:StepMRangeLen} = true

"""
    setstep!(x, val)

Sets the `step` of `x` to `val`.
"""
setstep!(x::AbstractRange{T}, val) where {T} = setstep!(x, convert(T, val))
function setstep!(r::StepMRange{T,S}, val::S) where {T,S}
    setfield!(r, :step, val)
    setlast!(r, Base.steprange_last(first(r), val, last(r)))
    return r
end
setstep!(r::StepMRangeLen{T,R,S}, val::S) where {T,R,S} = (setfield!(r, :step, val); r)

"""
    can_setlength(x) -> Bool

Returns `true` if type of `x` can have its length set independent of changing
its first or last position.
"""
can_setlength(::T) where {T} = can_setlength(T)
can_setlength(::Type{T}) where {T} = false
can_setlength(::Type{T}) where {T<:LinMRange} = true
can_setlength(::Type{T}) where {T<:StepMRangeLen} = true

"""
    setlength!(x, len)

Change the length of `x` while maintaining it's first and last positions.
"""
setlength!(x::AbstractRange, val) = setlength!(x, Int(val))

function setlength!(r::LinMRange, len::Int)
    len >= 0 || throw(ArgumentError("setlength!($r, $len): negative length"))
    if len == 1
        r.start == r.stop || throw(ArgumentError("setlength!($r, $len): endpoints differ"))
        setfield!(r, :len, 1)
        setfield!(r, :lendiv, 1)
        return r
    end
    setfield!(r, :len, len)
    setfield!(r, :lendiv, max(len - 1, 1))
    return r
end

function setlength!(r::StepMRangeLen, len::Int)
    len >= 0 || throw(ArgumentError("length cannot be negative, got $len"))
    1 <= r.offset <= max(1,len) || throw(ArgumentError("StepMRangeLen: offset must be in [1,$len], got $offset"))
    setfield!(r, :len, len)
    return r
end

"""
    setref!(x)

Set the reference field of an instance of `StepMRangeLen`.
"""
setref!(r::StepMRangeLen{T,R,S}, val::R) where {T,R,S} = (setfield!(r, :ref, val); r)
setref!(r::StepMRangeLen{T,R,S}, val) where {T,R,S} = setref!(r, convert(R, val))

"""
    setoffset!(x)

Set the offset field of an instance of `StepMRangeLen`.
"""
function setoffset!(r::StepMRangeLen, val::Int)
    1 <= val <= max(1,r.len) || throw(ArgumentError("StepMRangeLen: offset must be in [1,$len], got $offset"))
    setfield!(r, :offset, val)
    return r
end
setoffset!(r::StepMRangeLen, val) = setoffset!(r, Int(val))

"""
    isforward(x) -> Bool

Returns `true` if `x` is sorted forward.
"""
isforward(x) = issorted(x)
isforward(::ForwardOrdering) = true
isforward(::Ordering) = false
isforward(::Union{AbstractUnitRange,LinRange,AbstractLinRange}) = true
isforward(x::AbstractRange) = step(x) > 0

"""
    isreverse(x) -> Bool

Returns `true` if `x` is sorted in reverse.
"""
isreverse(x) = issorted(x, order=Reverse)
isreverse(::ReverseOrdering) = true
isreverse(::Ordering) = false
isreverse(::Union{AbstractUnitRange,LinRange,AbstractLinRange}) = false
isreverse(x::AbstractRange) = step(x) < 0

