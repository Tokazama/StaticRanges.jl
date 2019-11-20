
### first(x)
Base.first(::OneToRange{T}) where {T} = one(T)

Base.first(::UnitSRange{T,F,L}) where {T,F,L} = F

Base.first(r::UnitMRange) = getfield(r, :start)

Base.first(r::StepSRange{T,Ts,F,S,L}) where {T,Ts,F,S,L} = F

Base.first(r::StepMRange) = getfield(r, :start)

Base.first(::LinSRange{T,B,E,L,D}) where {T,B,E,L,D} = B

Base.first(r::LinMRange) = getfield(r, :start)

Base.first(r::AbstractStepRangeLen) = unsafe_getindex(r, 1)

"refhi(x::AbstractStepRangeLen) - Returns the `hi` component of a twice precision ref"
refhi(::StepSRangeLen{T,Tr,Ts,R,S,L,F}) where {T,Tr<:TwicePrecision,Ts,R,S,L,F} = gethi(R)
refhi(r::StepMRangeLen{T,R,S}) where {T,R<:TwicePrecision,S} = r.ref.hi
refhi(r::StepRangeLen{T,R,S}) where {T,R<:TwicePrecision,S} = r.ref.hi

"reflo(x::AbstractStepRangeLen) - Returns the `lo` component of a twice precision ref"
reflo(::StepSRangeLen{T,Tr,Ts,R,S,L,F}) where {T,Tr<:TwicePrecision,Ts,R,S,L,F} = getlo(R)
reflo(r::StepMRangeLen{T,R,S}) where {T,R<:TwicePrecision,S} = r.ref.lo
reflo(r::StepRangeLen{T,R,S}) where {T,R<:TwicePrecision,S} = r.ref.lo

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
