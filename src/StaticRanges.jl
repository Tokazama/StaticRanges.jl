module StaticRanges

using StaticArrays

import Base.unsafe_getindex

struct StaticRange{B,E,S,F,L,T} <: AbstractRange{T} #<: StaticVector{L,T}
    function StaticRange{B,E,S,F,L,T}() where {B,E,S,F,L,T}
        L >= 0 || throw(ArgumentError("length cannot be negative, got $L"))
        1 <= F <= max(1,L) || throw(ArgumentError("StaticRange: step must be in [1,$L], got $S"))  # FIXME
        new{B,E,S,F,L,T}()
    end
end


function StaticRange(start::Real, step::Real, stop::Real, offset::Real)
    B, E, F = promote(start, stop, offset)
    StaticRange{B,E,step,F}()
end
StaticRange{B,E,S,F}() where {B,E,S,F} = StaticRange{B,E,S,F,floor(Int, (E-B)/S)+1}()
StaticRange{B,E,S,F,L}() where {B,E,S,F,L} = StaticRange{B,E,S,F,L,typeof(B+0*S)}()


SRBoth{B,E,S,F,L,T} = Union{StaticRange{B,E,S,F,L,T},Type{<:StaticRange{B,E,S,F,L,T}}}

# Indexing interface
Base.length(r::SRBoth{B,E,S,F,L}) where {B,E,S,F,L} = L
Base.step(r::SRBoth{B,E,S}) where {B,E,S} = S
Base.first(r::SRBoth{B}) where {B} = unsafe_getindex(r, 1)
Base.last(r::SRBoth{B,E}) where {B,E} = unsafe_getindex(r, length(r))
Base.firstindex(::SRBoth) = 1
Base.lastindex(::SRBoth{B,E,S,F,L}) where {B,E,S,F,L} = L
offset(::SRBoth{B,E,S,F}) where {B,E,S,F} = F

unsafe_getindex(::SRBoth{B,E,S,F,L,T}, i::Int) where {B,E,S,F,L,T} = T(B + (i - F)*S)


@inline function Base.getindex(r::SRBoth, s::SRBoth{B,E,S,F,L,<:Integer}) where {B,E,S,F,L}
    Base.@_inline_meta
    @boundscheck checkbounds(r, s)
    return srange(oftype(first(r), first(r) + B-1), step=S*step(r), length=L)
end

@inline function Base.getindex(r::AbstractRange, s::SRBoth{B,E,S,F,L,<:Integer}) where {B,E,S,F,L}
    Base.@_inline_meta
    @boundscheck checkbounds(r, s)
    f = first(r)
    st = oftype(f, f + B-1)
    range(st, step=S*step(r), length=L)
end

@inline function Base.getindex(r::Base.OneTo{T}, s::SRBoth) where T
    @boundscheck checkbounds(r, s)
    OneTo(T(last(s)))
end

@inline function getindex(r::StepRangeLen{T}, s::OrdinalRange{<:Integer}) where {T}
    @boundscheck checkbounds(r, s)
    # Find closest approach to offset by s
    ind = LinearIndices(s)
    offset = max(min(1 + round(Int, (r.offset - first(s))/step(s)), last(ind)), first(ind))
    ref = _getindex_hiprec(r, first(s) + (offset-1)*step(s))
    return StepRangeLen{T}(ref, r.step*step(s), length(s), offset)
end

@inline function getindex(r::LinRange, s::StaticRange)
    @boundscheck checkbounds(r, s)
    return LinRange(Base.unsafe_getindex(r, first(s)), Base.unsafe_getindex(r, last(s)), length(s))
end

# Bounds checking
Base.checkbounds(r::SRBoth, i::Int) = checkbounds(Bool, r, i)
Base.checkbounds(r::SRBoth, i::AbstractRange) = checkbounds(Bool, r, i)
Base.checkbounds(r::SRBoth, i::SRBoth) = checkbounds(Bool, r, i)



Base.checkbounds(::Type{Bool}, r::SRBoth, i::Int) = firstindex(r) <= i <= lastindex(r) || throw(BoundsError(r, i))
function Base.checkbounds(::Type{Bool}, r::SRBoth, i::AbstractRange)
    firstindex(r) <= first(i) || throw(BoundsError(r, i))
    last(i) <= lastindex(r) || throw(BoundsError(r, i))
end

@inline function Base.getindex(r::SRBoth, i::Int)
    @boundscheck checkbounds(r, i)
    @inbounds unsafe_getindex(r, i)
end

Base.iterate(r::SRBoth) = r[1], 1
function Base.iterate(r::SRBoth, state::Int)
    if state < lastindex(r)
        r[state+1], state+1
    else
        return nothing
    end
end



function showrange(io::IO, r::StaticRange)
    print(io, "StaticRange: $(first(r)):$(step(r)):$(last(r))")
end
Base.show(io::IO, r::StaticRange) = showrange(io, r)
Base.show(io::IO, ::MIME"text/plain", r::StaticRange) = showrange(io, r)


#TODO: twice precision
# StepRangeLen{Float64,Base.TwicePrecision{Float64},Base.TwicePrecision{Float64}}
#julia> base_range = range(1, 10, length=101)
#julia> static_range = srange(1, 10, length=101)
#julia> allequal(base_range, static_range)

"""
    srange(start[, stop]; lengtyh, stop, step=1, offset=1)


(see [`range`](@ref))

# Examples

`srange` should have nearly identical behavior as `range`. `srange` also
provides an interface to create ranges similar to those produced by
`StepRangeLen`. This is facilitated throught the `offset` argument.
```jldoctest
julia> allequal(r1, r2) = all(ntuple(i->r1[i] == r2[i], length(r1)))


# UnitRange with length keyword
julia> base_range = range(1, length=100);

julia> static_range = srange(1, length=100)
StaticRange: 1:1:100

julia> allequal(base_range, static_range)
true


# UnitRange with stop keyword
julia> base_range = range(1, stop=100);

julia> static_range = srange(1, stop=100)
StaticRange: 1:1:100

julia> allequal(base_range, static_range)
true


# StepRange with step keyword
julia> base_range = range(1, 100, step=5)

julia> static_range = srange(1, 100, step=5)
StaticRange: 1:5:96

julia> allequal(base_range, static_range)
true


# StepRange{Int64,Int64} with step keyword
julia> base_range = range(1, 100, step=5);

julia> static_range = srange(1, 100, step=5)
StaticRange: 1:5:96

julia> allequal(base_range, static_range)
true


# StepRange{Int64,Int64} with step and length keywords
julia> base_range = range(1, step=5, length=100);

julia> static_range = srange(1, step=5, length=100)
StaticRange: 1:5:496

julia> allequal(base_range, static_range)

julia> base_range = StepRangeLen(1, 2, 20, 4)
-5:2:33

julia> static_range = srange(1, step=2, length=20, offset=4)

julia> allequal(base_range, static_range)

```

Many of the same methods available to interface with ranges also applies to a
`StaticRange`.
```jldoctest
eltype(base_range) == eltype(static_range)
length(base_range) == length(static_range)
size(base_range) == size(static_range)
step(base_range) == step(static_range)

first(base_range) == first(static_range)
last(base_range) == last(static_range)

firstindex(base_range) == firstindex(static_range)
lastindex(base_range) == lastindex(static_range)

```

"""

function srange(start::Real; length::Union{Integer,Nothing}=nothing,
                stop::Union{Real,Nothing}=nothing,
                step::Union{Real,Nothing}=nothing,
                offset::Union{Real,Nothing}=1)
    _srange(start, step, stop, length, offset)()
end

# Blatantly copy range from base but adapt to StaticRange
function srange(start::Real, stop::Real;
                length::Union{Integer,Nothing}=nothing,
                step::Union{Real,Nothing}=nothing,
                offset::Union{Real,Nothing}=1)
    _srange2(start, step, stop, length, offset)()
end

_srange2(start, ::Nothing, stop, ::Nothing, offset) =
    throw(ArgumentError("At least one of `length` or `step` must be specified"))

_srange2(start, step, stop, length, offset) = _srange(start, step, stop, length, offset)

# Range from start to stop: range(a, [step=s,] stop=b), no length
_srange(start, step,        stop,      ::Nothing, offset) = _staticrange(start, step, stop, offset)
_srange(start, ::Nothing,   stop,      ::Nothing, offset) = _staticrange(start, oftype(start, 1), stop, offset)
_srange(start::T, step,        ::Nothing, len, offset) where T = _staticrange(start, step, convert(T, start+step*(len-1)), offset)
#StaticRange(::Int64, ::Int64, ::Nothing, ::Int64)


# Range of a given length: range(a, [step=s,] length=l), no stop
_srange(a::Real,          ::Nothing,         ::Nothing, len::Integer, offset) = _staticrange(a, oftype(a, 1), oftype(a, a+len-1), offset)
_srange(a::AbstractFloat, ::Nothing,         ::Nothing, len::Integer, offset) = _srange(a, oftype(a, 1),   nothing, len, offset)
_srange(a::AbstractFloat, st::AbstractFloat, ::Nothing, len::Integer, offset) = _srange(promote(a, st)..., nothing, len, offset)
_srange(a::Real,          st::AbstractFloat, ::Nothing, len::Integer, offset) = _srange(float(a), st,      nothing, len, offset)
_srange(a::AbstractFloat, st::Real,          ::Nothing, len::Integer, offset) = _srange(a, float(st),      nothing, len, offset)
_srange(a,                ::Nothing,         ::Nothing, len::Integer, offset) = _srange(a, oftype(a-a, 1), nothing, len, offset)
_srange(start::T,         ::Nothing,         stop::T,   len::Integer, offset) where {T} = _staticrange(start, (stop-start)/len, stop, offset)

# TODO
#_range(start::T, ::Nothing, stop::T, len::Integer, offset) where {T<:Real} = LinRange{T}(start, stop, len, offset)
_range(start::T, ::Nothing, stop::T, len::Integer, offset) where {T} = LinRange{T}(start, stop, len, offset)
_range(start::T, ::Nothing, stop::T, len::Integer, offset) where {T<:Integer} = _linspace(float(T), start, stop, len, offset)
## for Float16, Float32, and Float64 we hit twiceprecision.jl to lift to higher precision StepRangeLen
# for all other types we fall back to a plain old LinRange
#_linspace(::Type{T}, start::Integer, stop::Integer, len::Integer) where T = LinRange{T}(start, stop, len)

function _staticrange(start::Real, step::Real, stop::Real, offset::Real)
    B, E, F = promote(start, stop, offset)
    L = floor(Int, (E-B)/step)+1
    L >= 0 || throw(ArgumentError("length cannot be negative, got $L"))
    1 <= offset <= max(1,L) || throw(ArgumentError("StaticRange: step must be in [1,$L], got $step"))  # FIXME
    return StaticRange{B,E,step,offset,L,typeof(B+0*step)}
end

#(last(r)-first(r))/r.lendiv
#StepRangeLen(start, step, floor(Int, (stop-start)/step)+1)
# Malformed calls
_srange(start,     step,      ::Nothing, ::Nothing, offset) = # range(a, step=s)
    throw(ArgumentError("At least one of `length` or `stop` must be specified"))
_srange(start,     ::Nothing, ::Nothing, ::Nothing, offset) = # range(a)
    throw(ArgumentError("At least one of `length` or `stop` must be specified"))
_srange(::Nothing, ::Nothing, ::Nothing, ::Nothing, offset) = # range(nothing)
    throw(ArgumentError("At least one of `length` or `stop` must be specified"))
_srange(start::Real, step::Real, stop::Real, length::Integer, offset) = # range(a, step=s, stop=b, length=l)
    throw(ArgumentError("Too many arguments specified; try passing only one of `stop` or `length`"))
_srange(::Nothing, ::Nothing, ::Nothing, ::Integer, offset) = # range(nothing, length=l)
    throw(ArgumentError("Can't start a range at `nothing`"))


end
