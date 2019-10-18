
"""
    StaticUnitRange
"""
abstract type StaticUnitRange{T<:Real} <: AbstractUnitRange{T} end

Base.firstindex(::StaticUnitRange) = 1

Base.lastindex(r::StaticUnitRange) = length(r)

function Base.getproperty(r::StaticUnitRange, s::Symbol)
    if s === :start
        return first(r)
    elseif s === :stop
        return last(r)
    else
        error("type $(typeof(r)) has no property $s")
    end
end

function Base.show(io::IO, r::StaticUnitRange)
    print(io, typeof(r).name, "(", repr(first(r)), ':', repr(last(r)), ")")
end

_in_unit_range(v::StaticUnitRange, val, i::Integer) = i > 0 && val <= last(v) && val >= first(v)

function Base.getindex(v::StaticUnitRange{T}, i::Integer) where T
    Base.@_inline_meta
    val = convert(T, first(v) + (i - 1))
    @boundscheck _in_unit_range(v, val, i) || throw(BoundsError(v, i))
    val
end

function Base.getindex(v::StaticUnitRange{T}, i::Integer) where {T<:Base.OverflowSafe}
    Base.@_inline_meta
    val = v.start + (i - 1)
    @boundscheck _in_unit_range(v, val, i) ||  throw(BoundsError(v, i))
    val % T
end

struct UnitSRange{T,F,L} <: StaticUnitRange{T}

    function UnitSRange{T}(start, stop) where {T<:Real}
        return new{T,start,Base.unitrange_last(start,stop)}()
    end
end

Base.first(::UnitSRange{T,F,L}) where {T,F,L} = F
Base.last(::UnitSRange{T,F,L}) where {T,F,L} = L

isstatic(::Type{X}) where {X<:UnitSRange} = true

mutable struct UnitMRange{T<:Real} <: StaticUnitRange{T}
    start::T
    stop::T

    UnitMRange{T}(start, stop) where {T<:Real} = new(start, Base.unitrange_last(start,stop))
end

Base.first(r::UnitMRange) = getfield(r, :start)

Base.last(r::UnitMRange) = getfield(r, :stop)
setfirst!(r::UnitMRange, val) = setfield!(r, :start, val)

setlast!(r::UnitMRange, val) = setfield!(r, :stop, val)

can_setfirst(::Type{T}) where {T<:UnitMRange} = true
can_setlast(::Type{T}) where {T<:UnitMRange} = true


for (F,f) in ((:M,:m), (:S,:s))
    UR = Symbol(:Unit, F, :Range)
    frange = Symbol(f, :range)
    @eval begin
        Base.AbstractUnitRange{T}(r::$(UR)) where {T} = $(UR){T}(r)
        $(UR)(start::T, stop::T) where {T<:Real} = $(UR){T}(start, stop)
        $(UR){T}(r::AbstractUnitRange) where {T<:Real} = $(UR){T}(first(r), last(r))
        $(UR)(r::AbstractUnitRange) = $(UR)(first(r), last(r))

        $(UR){T}(r::$(UR){T}) where {T<:Real} = r
        $(UR){T}(r::$(UR)) where {T<:Real} = $(UR){T}(first(r), last(r))
    end
end
