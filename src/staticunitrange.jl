
abstract type StaticUnitRange{T<:Real} <: AbstractUnitRange{T} end

Base.firstindex(::StaticUnitRange) = 1

Base.lastindex(r::StaticUnitRange) = length(r)




_in_unit_range(v::StaticUnitRange, val, i::Integer) = i > 0 && val <= last(v) && val >= first(v)

function Base.getindex(v::StaticUnitRange{T}, i::Integer) where T
    Base.@_inline_meta
    val = convert(T, first(v) + (i - 1))
    @boundscheck _in_unit_range(v, val, i) || throw(BoundsError(v, i))
    val
end


function Base.getindex(v::StaticUnitRange{T}, i::Integer) where {T<:Base.OverflowSafe}
    Base.@_inline_meta
    val =  + (i - 1)
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

UnitSRange{T}(r::UnitSRange{T}) where {T<:Real} = r
UnitSRange{T}(r::AbstractUnitRange) where {T<:Real} = UnitSRange{T}(first(r), last(r))
UnitSRange(start::T, stop::T) where {T<:Real} = UnitSRange{T}(start, stop)
UnitSRange(r::AbstractUnitRange) = UnitSRange(first(r), last(r))

isstatic(::Type{X}) where {X<:UnitSRange} = true

function Base.show(io::IO, r::UnitSRange)
    print(io, "UnitSRange(", repr(first(r)), ':', repr(last(r)), ")")
end

mutable struct UnitMRange{T<:Real} <: StaticUnitRange{T}
    start::T
    stop::T

    UnitMRange{T}(start, stop) where {T<:Real} = new(start, Base.unitrange_last(start,stop))
end

UnitMRange{T}(r::UnitMRange{T}) where {T<:Real} = r
UnitMRange(start::T, stop::T) where {T<:Real} = UnitMRange{T}(start, stop)
UnitMRange{T}(r::AbstractUnitRange) where {T<:Real} = UnitMRange{T}(first(r), last(r))
UnitMRange(r::AbstractUnitRange) = UnitMRange(first(r), last(r))

Base.first(r::UnitMRange) = getfield(r, :start)

Base.last(r::UnitMRange) = getfield(r, :stop)
setfirst!(r::UnitMRange, val) = setfield!(r, :start, val)

setlast!(r::UnitMRange, val) = setfield!(r, :stop, val)

can_setfirst(::Type{T}) where {T<:UnitMRange} = true
can_setlast(::Type{T}) where {T<:UnitMRange} = true

function Base.show(io::IO, r::UnitMRange)
    print(io, "UnitMRange(", repr(first(r)), ':', repr(last(r)), ")")
end

Base.AbstractUnitRange{T}(r::UnitMRange) where {T} = UnitMRange{T}(r)
#AbstractUnitRange{T}(r::OneTo) where {T} = OneTo{T}(r)


for (F,f) in ((:M,:m), (:S,:s))
    UR = Symbol(:Unit, F, :Range)
    frange = Symbol(f, :range)
    @eval begin
        Base.AbstractUnitRange{T}(r::$(UR)) where {T} = $(UR){T}(r)
        function Base.promote_rule(
            a::Type{<:$(UR){T1}},
            ::Type{UR}
           ) where {T1,UR<:AbstractUnitRange}
            return promote_rule(a, $(UR){eltype(UR)})
        end
        $(UR){T}(r::AbstractUnitRange) where {T<:Real} = $(UR){T}(first(r), last(r))
        $(UR)(r::AbstractUnitRange) = $(UR)(first(r), last(r))

        function promote_rule(
            a::Type{<:$(UR){T1}},
            b::Type{<:$(UR){T2}}
           ) where {T1,T2}
            return el_same(promote_type(T1,T2), a, b)
        end
        $(UR){T}(r::$(UR){T}) where {T<:Real} = r
        $(UR){T}(r::$(UR)) where {T<:Real} = $(UR){T}(first(r), last(r))
    end
end
