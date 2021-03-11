
module StaticRanges

using LinearAlgebra
using SparseArrays
using SparseArrays: AbstractSparseMatrixCSC
using ChainedFixes

using ArrayInterface
using ArrayInterface: can_change_size, can_setindex, parent_type
using ArrayInterface: known_first, known_step, known_last, known_length
using ArrayInterface: static_first, static_last, static_step, static_length
using ArrayInterface: OptionallyStaticUnitRange, unsafe_reconstruct, StaticInt, OptionallyStaticRange
using ArrayInterface.Static
using ArrayInterface.Static: eq, gt, lt, ge, le
using IntervalSets

using Base.Broadcast: DefaultArrayStyle, broadcasted
import Base: OneTo, TwicePrecision, unsafe_getindex, step_hp, Fix1, Fix2, tail, front, unsafe_length

using Base: @propagate_inbounds, @pure

export
    # Types
    GapRange,
    DynamicAxis,
    MutableRange,
    StaticRange,
    # methods
    mrange,
    srange,
    as_dynamic,
    find_first,
    find_last,
    find_all_in,
    find_all

include("utils.jl")
include("gap_range.jl")
include("dynamic_axis.jl")
include("mutable_range.jl")
include("static_range.jl")
# Things I have to had to avoid ambiguities with base
RANGE_LIST = ( UnitMRange, DynamicAxis)

#=
function Base.findfirst(f::Union{Base.Fix2{typeof(==),T}, Base.Fix2{typeof(isequal),T}}, r::DynamicAxis) where T<:Integer
    return find_first(f, r)
end
=#

const OneToUnion = Union{OneTo,DynamicAxis}
const FRange{T} = Union{OneTo{T},UnitRange{T},StepRange{T},LinRange{T}, StepRangeLen{T}}


ArrayInterface.ismutable(::Type{X}) where {X<:MRange} = true



MutableRange(x::StaticRange) = MutableRange(parent(x))

# Notes on implementation:
# Currently Base Julia reutrns an empty vector on empty(::AbstractRange)
# We want the appropriate variant of the range that returns true when isempty(::AbstractRange)
# Using the static version also ensures that it doesn't accidently "promote down" the type


# FIXME specify Bit operator filters here to <,<=,>=,>,==,isequal,isless
# Currently will return incorrect order or repeated results otherwise
Base.filter(f::Function, r::MRange)  = r[find_all(f, r)]

include("resize.jl")
include("find.jl")

Base.findfirst(f::Equal{T}, r::DynamicAxis) where {T<:Integer} = find_first(f, r)
for T in (StaticRange,MutableRange,DynamicAxis)
    @eval begin
        Base.findfirst(f::Function, r::$T) = find_first(f, r)
        Base.findlast(f::Function, r::$T) = find_last(f, r)
        Base.findall(f::Function, r::$T) = find_all(f, r)
        Base.findall(f::In{Interval{L, R, T}}, r::$T) where {L, R, T} = find_all(f, r)
        Base.findall(f::In, r::$T) = find_all(f, r)
    end
end



function Base.show(io::IO, r::UnitMRange)
    print(io, "UnitMRange(", repr(first(r)), ':', repr(last(r)), ")")
end

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
        Base.:(-)(x::$R, y::$R) = -(parent(x), parent(y))
        Base.:(-)(r1::Union{LinRange, OrdinalRange, StepRangeLen}, r2::$R)  = -(r1, parent(r2))
        Base.:(-)(r1::$R, r2::Union{LinRange, OrdinalRange, StepRangeLen})  = -(parent(r1), r2)
        Base.:(+)(x::$R, y::$R) = +(parent(x), parent(y))
        Base.:(+)(r1::Union{LinRange, OrdinalRange, StepRangeLen}, r2::$R)  = +(r1, parent(r2))
        Base.:(+)(r1::$R, r2::Union{LinRange, OrdinalRange, StepRangeLen})  = +(parent(r1), r2)

        Base.reverse(r::$R) = reverse(parent(r))

        Base.empty(r::$R) = _empty(parent(r))
        Base.sum(r::$R) = sum(parent(r))

        Base.iterate(x::$R) = iterate(parent(x))
        Base.iterate(x::$R, state) = iterate(parent(x), state)
    end
end

Base.intersect(r::StaticRange, s::MutableRange) = intersect(parent(r), s)
Base.intersect(r::MutableRange, s::StaticRange) = intersect(r, parent(s))
#intersect(r::MutableRange, s::AbstractRange) in StaticRanges at /Users/zchristensen/projects/StaticRanges.jl/src/StaticRanges.jl:137,
#intersect(r::AbstractRange, s::StaticRange) in StaticRanges at /Users/zchristensen/projects/StaticRanges.jl/src/StaticRanges.jl:138)

ArrayInterface.known_length(::Type{StaticRange{T,R}}) where {T,R} = length(R)

as_dynamic(x) = MutableRange(x)
# although these should technically not need to be completely typed for
# each, dispatch ignores TwicePrecision on the static version and only
# uses the first otherwise
###
### OneToRange
###

end

