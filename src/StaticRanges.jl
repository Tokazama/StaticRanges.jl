
module StaticRanges

using LinearAlgebra
using SparseArrays
using SparseArrays: AbstractSparseMatrixCSC


using Dates
using ChainedFixes
using Reexport

using ArrayInterface
using ArrayInterface: can_change_size, can_setindex, parent_type
using ArrayInterface: known_first, known_step, known_last, known_length
using ArrayInterface: static_first, static_last, static_step
using ArrayInterface: OptionallyStaticUnitRange, unsafe_reconstruct, StaticInt, OptionallyStaticRange
using ArrayInterface.Static

using IntervalSets
using Requires

using Base.Broadcast: DefaultArrayStyle, broadcasted
import Base: OneTo, TwicePrecision, unsafe_getindex, step_hp, Fix1, Fix2, tail, front, unsafe_length

using Base.Order
using Base: @propagate_inbounds, @pure

export
    # Types
    GapRange,
    OneToMRange,
    MutableRange,
    StaticRange,
    # methods
    mrange,
    srange,
    as_dynamic,
    as_fixed

include("utils.jl")
include("./GapRange/GapRange.jl")
include("order.jl")

"""
    OneToMRange

A mutable range that parallels `OneTo` in behavior.
"""
mutable struct OneToMRange{T<:Integer} <: AbstractUnitRange{T}
    stop::T

    OneToMRange{T}(stop) where {T<:Integer} = new(max(zero(T), stop))


    function OneToMRange{T}(r::AbstractRange) where {T<:Integer}
        first(r) == 1 || (Base.@_noinline_meta; throw(ArgumentError("first element must be 1, got $(first(r))")))
        step(r)  == 1 || (Base.@_noinline_meta; throw(ArgumentError("step must be 1, got $(step(r))")))
        return OneToMRange(last(r))
    end

    OneToMRange(stop::T) where {T<:Integer} = OneToMRange{T}(stop)

    OneToMRange(r::AbstractRange{T}) where {T<:Integer} = OneToMRange{T}(r)
end


""" StaticRange{T,R} """
struct StaticRange{T,R} <: AbstractRange{T}

    function StaticRange{T,R}() where {T,R}
        @assert R <: AbstractRange
        @assert T <: eltype(R)
        return new{T,R}()
    end
    StaticRange{T}(x::StaticRange{T}) where {T} = x
    StaticRange{T}(x::AbstractRange{T}) where {T} = new{T,x}()
    function StaticRange(x::AbstractRange{T}) where {T}
        @assert !ismutable(x)
        return new{T,x}()
    end
end

""" MutableRange """
mutable struct MutableRange{T,P<:AbstractRange{T}} <:AbstractRange{T}
    parent::P

    MutableRange(x::StaticRange) = MutableRange(parent(x))
    MutableRange(x::AbstractRange{T}) where {T} = new{T,typeof(x)}(x)
end


mrange(start; kwargs...) = MutableRange(range(start; kwargs...))
function mrange(start, stop; kwargs...)
    if isempty(kwargs)
        return MutableRange(start:stop)
    else
        return MutableRange(range(start, stop; kwargs...))
    end
end

srange(start; kwargs...) = StaticRange(range(start; kwargs...))
function srange(start, stop; kwargs...)
    if isempty(kwargs)
        return StaticRange(start:stop)
    else
        return StaticRange(range(start, stop; kwargs...))
    end
end


const UnitMRange{T} = MutableRange{T,UnitRange{T}}
const StepMRange{T,S} = MutableRange{T,StepRange{T,S}}
const StepMRangeLen{T,R,S} = MutableRange{T,StepRangeLen{T,R,S}}
const LinMRange{T} = MutableRange{T,LinRange{T}}

# Things I have to had to avoid ambiguities with base
RANGE_LIST = ( UnitMRange, OneToMRange)

for R in RANGE_LIST
    @eval begin
        function Base.findfirst(f::Union{Base.Fix2{typeof(==),T}, Base.Fix2{typeof(isequal),T}}, r::$R) where T<:Integer
            return find_first(f, r)
        end
    end
end

const OneToUnion{T} = Union{OneTo{T},OneToMRange{T}}
const MRange{T} = Union{OneToMRange{T},UnitMRange{T},MutableRange{T}}
const FRange{T} = Union{OneTo{T},UnitRange{T},StepRange{T},LinRange{T}, StepRangeLen{T}}


ArrayInterface.ismutable(::Type{X}) where {X<:MRange} = true

ArrayInterface.can_change_size(::Type{T}) where {T<:OneToMRange} = true
ArrayInterface.can_change_size(::Type{T}) where {T<:MutableRange} = true

# Notes on implementation:
# Currently Base Julia reutrns an empty vector on empty(::AbstractRange)
# We want the appropriate variant of the range that returns true when isempty(::AbstractRange)
# Using the static version also ensures that it doesn't accidently "promote down" the type


# FIXME specify Bit operator filters here to <,<=,>=,>,==,isequal,isless
# Currently will return incorrect order or repeated results otherwise
Base.filter(f::Function, r::MRange)  = r[find_all(f, r)]

Base.filter(f::ChainedFix, r::MRange) = r[findall(f, r)]

include("promotion.jl")
include("merge.jl")
include("vcat.jl")
include("resize.jl")
include("./Find/Find.jl")


Base.show(io::IO, r::OneToMRange) = print(io, "OneToMRange($(last(r)))")

function Base.show(io::IO, r::UnitMRange)
    print(io, "UnitMRange(", repr(first(r)), ':', repr(last(r)), ")")
end


Base.reverse!(r::MutableRange) = setfield!(r, :parent, reverse(parent(r)))
Base.sort!(r::MutableRange) = setfield!(r, :parent, sort(parent(r)))

Base.:(==)(r::OneToMRange, s::OneToMRange) = last(r) == last(s)

Base.isempty(r::MutableRange) = isempty(parent(r))

Base.empty!(r::OneToMRange{T}) where {T} = (setfield!(r, :stop, zero(T)); r)

Base.empty!(r::MutableRange) = setfield!(r, :parent, empty(r))

_empty(r::LinRange) = LinRange(first(r), last(r), 0)
_empty(r::StepRangeLen) = StepRangeLen(r.ref, r.step, 0, r.offset)
_empty(r::StepRange)  = StepRange(r.start, r.step, r.start - step(r))
_empty(r::UnitRange{T}) where {T} = UnitRange(first(r), first(r) - one(T))
_empty(r::OneTo{T}) where {T} = OneTo(zero(T))


Base.in(x::Integer, r::OneToMRange{<:Integer}) = !(1 > x) & !(x > last(r))

function Base.in(x::Real, r::OneToMRange{T}) where {T}
    val = round(Integer, x)
    if in(val, r)
        return @inbounds(getindex(r, val)) == x
    else
        return false
    end
end


#=
function Base.broadcasted(s::DefaultArrayStyle{1}, f::typeof(+), x::Real, r::MutableRange)
    return broadcasted(s, f, x, parent(r))
end
function Base.broadcasted(s::DefaultArrayStyle{1}, f::typeof(+), r::MutableRange, x::Real)
    return broadcasted(s, f, parent(r), x)
end
=#

## TODO
#Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r1::AbstractRange, r2::AbstractRange) = r1 + r2
##
function Base.Broadcast.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::OneToMRange, x::Number)
    return range(first(r)-x, length=length(r))
end

Base.Broadcast.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r::OneToMRange) = r

Base.Broadcast.broadcasted(s::DefaultArrayStyle{1}, f::typeof(-), r::MutableRange) = broadcasted(s, f, parent(r))
Base.Broadcast.broadcasted(s::DefaultArrayStyle{1}, f::typeof(-), r::StaticRange) = static(broadcasted(s, f, parent(r)))

for R in (MutableRange, StaticRange)
    @eval begin
        Base.Broadcast.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r::$R) = r
        function Base.Broadcast.broadcasted(s::DefaultArrayStyle{1}, f::typeof(+), r::$R, x::Number)
            return broadcasted(s, f, parent(r), x)
        end
        function Base.Broadcast.broadcasted(s::DefaultArrayStyle{1}, f::typeof(+), x::Number, r::$R)
            return broadcasted(s, f, x, parent(r))
        end
        function Base.Broadcast.broadcasted(s::DefaultArrayStyle{1}, f::typeof(-), r::$R, x::Number)
            return broadcasted(s, f, parent(r), x)
        end
        function Base.Broadcast.broadcasted(s::DefaultArrayStyle{1}, f::typeof(-), x::Number, r::$R)
            return broadcasted(s, f, x, parent(r))
        end
        function Base.Broadcast.broadcasted(s::DefaultArrayStyle{1}, f::typeof(*), r::$R, x::Number)
            return broadcasted(s, f, parent(r), x)
        end
        function Base.Broadcast.broadcasted(s::DefaultArrayStyle{1}, f::typeof(*), x::Number, r::$R)
            return broadcasted(s, f, x, parent(r))
        end
        function Base.Broadcast.broadcasted(s::DefaultArrayStyle{1}, f::typeof(/), r::$R, x::Number)
            return broadcasted(s, f, parent(r), x)
        end
        function Base.Broadcast.broadcasted(s::DefaultArrayStyle{1}, f::typeof(/), x::Number, r::$R)
            return broadcasted(s, f, x, parent(r))
        end
        function Base.Broadcast.broadcasted(s::DefaultArrayStyle{1}, f::typeof(\), r::$R, x::Number)
            return broadcasted(s, f, parent(r), x)
        end
        function Base.Broadcast.broadcasted(s::DefaultArrayStyle{1}, f::typeof(\), x::Number, r::$R)
            return broadcasted(s, f, x, parent(r))
        end

        Base.first(x::$R) = first(parent(x))
        Base.step(x::$R) = step(parent(x))
        Base.last(x::$R) = last(parent(x))
        Base.length(x::$R) = length(parent(x))
        Base.step_hp(x::$R) = Base.step_hp(parent(x))

        Base.AbstractUnitRange{T}(x::$R) where {T} = AbstractUnitRange{T}(parent(x))

        @propagate_inbounds Base.getindex(x::$R, i::Integer) = parent(x)[i]
        @propagate_inbounds Base.getindex(x::$R, i::AbstractRange{<:Integer}) = parent(x)[i]

        Base.intersect(r::$R, s::AbstractRange) = intersect(parent(r), s)
        Base.intersect(r::AbstractRange, s::$R) = intersect(r, parent(s))
        Base.intersect(r::$R, s::$R) = intersect(parent(r), parent(s))
        Base.:(-)(x::$R, y::AbstractArray) = -(parent(x), y)
        Base.:(-)(x::AbstractArray, y::$R) = -(x, parent(y))
        Base.:(-)(x::$R, y::$R) = -(parent(x), parent(y))
        Base.:(+)(x::$R, y::AbstractArray) = +(parent(x), y)
        Base.:(+)(x::AbstractArray, y::$R) = +(x, parent(y))
        Base.:(+)(x::$R, y::$R) = +(parent(x), parent(y))

        Base.reverse(r::$R) = reverse(parent(r))

        Base.empty(r::$R) = _empty(parent(r))
        Base.sum(r::$R) = sum(parent(r))

        Base.iterate(x::$R) = iterate(parent(x))
        Base.iterate(x::$R, state) = iterate(parent(x), state)
    end
end

ArrayInterface.static_first(x::StaticRange) = static(known_first(x))
ArrayInterface.static_step(x::StaticRange) = static(known_step(x))
ArrayInterface.static_last(x::StaticRange) = static(known_last(x))

ArrayInterface.known_first(::Type{StaticRange{T,R}}) where {T,R} = first(R)
Base.first(::OneToMRange{T}) where {T} = one(T)

ArrayInterface.known_step(::Type{StaticRange{T,R}}) where {T,R} = step(R)
ArrayInterface.known_step(::Type{OneToMRange}) where {T,R} = one(T)

ArrayInterface.known_last(::Type{StaticRange{T,R}}) where {T,R} = last(R)
Base.last(r::OneToMRange) = getfield(r, :stop)

ArrayInterface.known_length(::Type{StaticRange{T,R}}) where {T,R} = length(R)
Base.length(x::OneToMRange) = last(x)

as_dynamic(x) = MutableRange(x)

# although these should technically not need to be completely typed for
# each, dispatch ignores TwicePrecision on the static version and only
# uses the first otherwise
###
### OneToRange
###
@propagate_inbounds function Base.getindex(v::OneToMRange{T}, i::Integer) where T
    @boundscheck ((i > 0) & (i <= last(v))) || throw(BoundsError(v, i))
    return T(i)
end

@propagate_inbounds function Base.getindex(r::OneToMRange{T}, s::OneTo) where T
    @boundscheck checkbounds(r, s)
    return OneTo(T(last(s)))
end

###
###
###
#=
@propagate_inbounds function revindex(x::OneTo{T}, val::T) where {T}
    @boundscheck ((i > 0) & (i <= last(v))) || throw(BoundsError(x, val))
    return Int(val)
end

@propagate_inbounds function revindex(x::AbstractUnitRange{T}, val::T) where {T<:Base.OverflowSafe}
    @boundscheck first(x) < val > last(x) && throw(BoundsError(x, val))
    return Int(val - static_first(x)) + 1
end

@propagate_inbounds function revindex(x::AbstractUnitRange{T}, val::T) where {T}
    out =  (x - static_first(x)) + 1
    @boundscheck if !iszero(mod(out, 1))  out > 1 && out
        throw(BoundsError(x, val))
    end
    return Int(out)
end

@propagate_inbounds function revindex(x::AbstractRange{T}, val::T) where {T}
    d, r = divrem((x - static_first(x)), static_step(x))
    @boundscheck iszero(r) || throw(BoundsError(x, i))
    return Int(d) + 1
end

@propagate_inbounds revindex(x::AbstractRange{T}, val) where {T} = revindex(x, T(val))

=#

Base.intersect(r::OneToMRange, s::OneToMRange) = OneTo(min(last(r),last(s)))
Base.intersect(r::OneToMRange, s::OneTo) = OneTo(min(last(r),last(s)))
Base.intersect(r::OneTo, s::OneToMRange) = OneTo(min(last(r),last(s)))



Static.known(::Type{StaticRange{T,R}}) where {T,R} = R
function Static.static(x::AbstractRange)
    if can_change_size(x)
        return as_static(as_fixed(x))
    else
        return StaticRange(x)
    end
end

Base.parent(x::MutableRange) = getfield(x, :parent)
Base.parent(::StaticRange{T,R}) where {T,R} = R

ArrayInterface.parent_type(::Type{StaticRange{T,R}}) where {T,R} = typeof(R)
ArrayInterface.parent_type(::Type{MutableRange{T,R}}) where {T,R} = R

@inline Base.getproperty(x::MutableRange, s::Symbol) = getproperty(parent(x), s)
@inline Base.getproperty(x::StaticRange, s::Symbol) = getproperty(parent(x), s)


Static.is_static(::Type{T}) where {T<:StaticRange} = True()

Base.AbstractUnitRange{T}(r::OneToMRange) where {T} = OneToMRange{T}(r)

#Base.firstindex(::OneToMRange) = 1

Base.lastindex(r::OneToMRange) = Int(last(r))

Base.issubset(r::OneToMRange, s::OneTo) = last(r) <= last(s)
Base.issubset(r::OneToMRange, s::OneToMRange) = last(r) <= last(s)
Base.issubset(r::OneTo, s::OneToMRange) = last(r) <= last(s)

Base.mod(i::Integer, r::OneToMRange) = Base.mod1(i, last(r))

function Base.setproperty!(x::OneToMRange, s::Symbol, val)
    error("cannot use setproperty! on OneToMRange")
end

end

