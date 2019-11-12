# TODO: this should be in ArrayInterface
ArrayInterface.can_setindex(::Type{X}) where {X<:AbstractRange} = false

"""
    is_static(x) -> Bool

Returns `true` if `x` is static.
"""
is_static(::T) where {T} = is_static(T)
is_static(::Type{T}) where {T} = false
is_static(::Type{T}) where {T<:SRange} = true

"""
    can_set_first(x) -> Bool

Returns `true` if the first element of `x` can be set. If `x` is a range then
changing the first element will also change the length of `x`.
"""
can_set_first(::T) where {T} = can_set_first(T)
can_set_first(::Type{T}) where {T} = can_setindex(T)
can_set_first(::Type{T}) where {T<:StepMRangeLen} = true
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
function set_first!(r::StepMRange{T,S}, val::T) where {T,S}
    setfield!(r, :start, val)
    setfield!(r, :stop, Base.steprange_last(val, step(r), last(r)))
end
set_first!(r::UnitMRange{T}, val::T) where {T} = (setfield!(r, :start, val); r)
set_first!(r::StepMRangeLen{T,R,S}, val::R) where {T,R,S} = (setfield!(r, :ref, val); r)
function set_first!(r::StepMRangeLen{T,R,S}, val) where {T,R,S}
    return set_ref!(r, val - (1 - r.offset) * step_hp(r))
end


"""
    can_set_last(x) -> Bool

Returns `true` if the last element of `x` can be set. If `x` is a range then
changing the first element will also change the length of `x`.
"""
can_set_last(::T) where {T} = can_set_last(T)
can_set_last(::Type{T}) where {T} = can_setindex(T)
can_set_last(::Type{T}) where {T<:LinMRange} = true
can_set_last(::Type{T}) where {T<:StepMRange} = true
can_set_last(::Type{T}) where {T<:StepMRangeLen} = true
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
function set_last!(r::StepMRange{T,S}, val::T) where {T,S}
    setfield!(r, :stop, Base.steprange_last(first(r), step(r), val))
    return r
end
set_last!(r::UnitMRange{T}, val::T) where {T} = (setfield!(r, :stop, val); r)
function set_last!(r::OneToMRange{T}, val::T) where {T}
    setfield!(r, :stop, max(zero(T), T(val)))
    return r
end
function set_last!(r::StepMRangeLen{T}, val::T) where {T}
    len = unsafe_findvalue(val, r)
    len >= 0 || throw(ArgumentError("length cannot be negative, got $len"))
    1 <= r.offset <= max(1, len) || throw(ArgumentError("StepSRangeLen: offset must be in [1,$len], got $(r.offset)"))
    setfield!(r, :len, len)
    return r
end

"""
    has_step(x) -> Bool

Returns `true` if type of `x` has `step` method defined.
"""
has_step(::T) where {T} = has_step(T)
has_step(::Type{T}) where {T} = false
has_step(::Type{T}) where {T<:AbstractRange} = true

"""
    can_set_step(x) -> Bool

Returns `true` if type of `x` has `step` field that can be set.
"""
can_set_step(::T) where {T} = can_set_step(T)
can_set_step(::Type{T}) where {T} = false
can_set_step(::Type{T}) where {T<:StepMRange} = true
can_set_step(::Type{T}) where {T<:StepMRangeLen} = true

"""
    set_step!(x, st)

Sets the `step` of `x` to `val`.
"""
set_step!(x::UnitMRange, st) = error("Step size of UnitMRange type can only be 1.")
set_step!(x::OneToMRange, st) = error("Step size of OneToMRange type can only be 1.")
function set_step!(x::Union{StepMRange{T,S},StepMRangeLen{T,S}}, st) where {T,S}
    return set_step!(x, convert(S, st))
end
function set_step!(r::StepMRange{T,S}, st::S) where {T,S}
    setfield!(r, :step, st)
    setfield!(r, :stop, Base.steprange_last(first(r), st, last(r)))
    return r
end
function set_step!(r::StepMRangeLen{T,R,S}, st::S) where {T,R,S}
    setfield!(r, :step, st)
    return r
end

"""
    can_set_length(x) -> Bool

Returns `true` if type of `x` can have its length set independent of changing
its first or last position.
"""
can_set_length(::T) where {T} = can_set_length(T)
can_set_length(::Type{T}) where {T} = false
can_set_length(::Type{T}) where {T<:LinMRange} = true
can_set_length(::Type{T}) where {T<:StepMRangeLen} = true
can_set_length(::Type{T}) where {T<:StepMRange} = true
can_set_length(::Type{T}) where {T<:UnitMRange} = true
can_set_length(::Type{T}) where {T<:OneToMRange} = true

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
set_length!(x::OneToMRange, len) = set_last!(x, len)
set_length!(x::UnitMRange{T}, len) where {T} = set_last!(x, T(first(x)+len-1))
function set_length!(r::StepMRange{T}, len) where {T}
    setfield!(r, :stop, convert(T, first(r) + step(r) * (len - 1)))
    return r
end

"""
    set_lendiv!(r, d)

Change the length of `x` while maintaining it's first and last positions.
"""
set_lendiv!(r::LinMRange, d) = set_lendiv!(r, Int(d))
function set_lendiv!(r::LinMRange, d::Int)
    d >= 0 || throw(ArgumentError("set_length!($r, $len): negative length"))
    #=
    we don't do this because on the off chance the user is intentionally
    setting lendiv we can't know if they want the length also set to 1 or 2
    if d == 1
        r.start == r.stop || throw(ArgumentError("set_length!($r, $len): endpoints differ"))
        setfield!(r, :len, 1)
        setfield!(r, :lendiv, 1)
        return r
    end
    =#
    setfield!(r, :len, d + 1)
    setfield!(r, :lendiv, d)
    return r
end

"""
    set_ref!(x, val)
Set the reference field of an instance of `StepMRangeLen`.
"""
set_ref!(r::StepMRangeLen{T,R,S}, val::R) where {T,R,S} = (setfield!(r, :ref, val); r)
set_ref!(r::StepMRangeLen{T,R,S}, val) where {T,R,S} = set_ref!(r, convert(R, val))

"""
    set_offset!(x, val)

Set the offset field of an instance of `StepMRangeLen`.
"""
function set_offset!(r::StepMRangeLen, val::Int)
    1 <= val <= max(1,r.len) || throw(ArgumentError("StepMRangeLen: offset must be in [1,$len], got $offset"))
    setfield!(r, :offset, val)
    return r
end
set_offset!(r::StepMRangeLen, val) = set_offset!(r, Int(val))
