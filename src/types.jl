struct StaticRange{T,B,E,S,L} <: AbstractRange{T}
    function StaticRange{T,B,E,S,L}() where {T,B,E,S,L}
        (B*S) > E && error("StaticRange: the last index of a StaticRange cannot be less than the first index unless reverse indexing, got first = $B, and last = $E, step = $S.")
        new{T,B,E,S,L}()
    end
end

const StaticRangeUnion{T,B,E,S,L} = Union{StaticRange{T,B,E,S,L},Type{<:StaticRange{T,B,E,S,L}}}

const UnitSRange{T,B,E,L} = StaticRange{  T,B,E,1,L}
const OneToSRange{N}      = StaticRange{Int,1,N,1,N}
OneToSRange(N::Int) = OneToSRange{N}()

function StaticRange(start::Real, step::Real, stop::Real, length::Int)
    B, E = promote(start, stop)
    StaticRange{typeof(B),B,E,step,length}()
end

StaticRange{B,E,S}() where {B,E,S,F} = StaticRange{B,E,S,F,floor(Int, (E-B)/S)+1}()
StaticRange{B,E,S,L}() where {B,E,S,F,L} = StaticRange{B,E,S,F,L,typeof(B+0*S)}()

StaticRangeUnion{T,B,E,S,L} = Union{StaticRange{T,B,E,S,L},Type{<:StaticRange{T,B,E,S,L}}}

srange(r::AbstractRange{T}) where T = StaticRange{T,first(r),last(r),step(r),length(r)}()

"""
    srange(start[, stop]; lengtyh, stop, step=1)


(see [`range`](@ref))

# Examples

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

srange(start::Real; length::Union{Integer,Nothing}=nothing, stop::Union{Real,Nothing}=nothing, step::Union{Real,Nothing}=nothing) =
    _srange(start, step, stop, length)
# Blatantly copy range from base but adapt to StaticRange
srange(start::Real, stop::Real; length::Union{Integer,Nothing}=nothing, step::Union{Real,Nothing}=nothing) =
    _srange2(start, step, stop, length)

_srange2(start, ::Nothing, stop, ::Nothing) =
    throw(ArgumentError("At least one of `length` or `step` must be specified"))

_srange2(start, step, stop, length) = _srange(start, step, stop, length)

# Range from start to stop: range(a, [step=s,] stop=b), no length
_srange(start, ::Nothing,   stop,      ::Nothing) = _staticrange(start, oftype(start, 1), stop, offset)
_srange(start::T, step,        ::Nothing, len) where T = _staticrange(start, step, convert(T, start+step*(len-1)), offset)
#StaticRange(::Int64, ::Int64, ::Nothing, ::Int64)


#                  start,              step,      stop,       length
_srange(a::AbstractFloat,         ::Nothing, ::Nothing, len::Integer) = _srange(a, oftype(a, 1),   nothing, len)
_srange(a::AbstractFloat, st::AbstractFloat, ::Nothing, len::Integer) = _srange(promote(a, st)..., nothing, len)
_srange(         a::Real, st::AbstractFloat, ::Nothing, len::Integer) = _srange(float(a), st,      nothing, len)
_srange(a::AbstractFloat,          st::Real, ::Nothing, len::Integer) = _srange(a, float(st),      nothing, len)
#_srange(               a,         ::Nothing, ::Nothing, len::Integer) = _srange(a, oftype(a-a, 1), nothing, len)
_srange(            a::T,         ::Nothing, ::Nothing, len::Integer) where T = StaticRange{T,a,T(a+len-1),T(1),len}()
_srange(            a::T,         ::Nothing,      e::T, len::Integer) where T = StaticRange{T,a,e,T((e-a)/len),len}()
_srange(               a,                st,         e,    ::Nothing)         = StaticRange(a, st, e, floor(Int, (e-a)/st)+1)


# TODO
#_range(start::T, ::Nothing, stop::T, len::Integer) where {T<:Real} = LinRange{T}(start, stop, len)

## for Float16, Float32, and Float64 we hit twiceprecision.jl to lift to higher precision StepRangeLen
# for all other types we fall back to a plain old LinRange
#_linspace(::Type{T}, start::Integer, stop::Integer, len::Integer) where T = LinRange{T}(start, stop, len)

#(last(r)-first(r))/r.lendiv
#StepRangeLen(start, step, floor(Int, (stop-start)/step)+1)
# Malformed calls
_srange(start,     step,      ::Nothing, ::Nothing) = # range(a, step=s)
    throw(ArgumentError("At least one of `length` or `stop` must be specified"))
_srange(start,     ::Nothing, ::Nothing, ::Nothing) = # range(a)
    throw(ArgumentError("At least one of `length` or `stop` must be specified"))
_srange(::Nothing, ::Nothing, ::Nothing, ::Nothing) = # range(nothing)
    throw(ArgumentError("At least one of `length` or `stop` must be specified"))
_srange(start::Real, step::Real, stop::Real, length::Integer) = # range(a, step=s, stop=b, length=l)
    throw(ArgumentError("Too many arguments specified; try passing only one of `stop` or `length`"))
_srange(::Nothing, ::Nothing, ::Nothing, ::Integer) = # range(nothing, length=l)
    throw(ArgumentError("Can't start a range at `nothing`"))

"""
"""
abstract type StaticIndices{S<:Tuple,T,N,L} <: StaticArray{S,T,N} end

"""
    LinearSIndices

```jldoctest
julia> A = reshape([1:30...], (5,6));

julia> li = LinearIndices((5,4,3,2,2));

julia> sli = LinearSIndices((5,4,3,2,2));

julia> inds = (srange(2:3), srange(2:3), srange(1:3), srange(1:2), srange(1:2))

julia> subli = SubLinearIndices(sli, inds)

julia> subli[1] == sli[inds...][1] == li[inds...][1]

julia> subli[2] == sli[inds...][2] == li[inds...][2]

julia> subli[3] == sli[inds...][3] == li[inds...][3]

```
"""
struct LinearSIndices{S,N,L} <: StaticIndices{S,Int,N,L}
    LinearSIndices{S}() where S = new{S,tuple_length(S),tuple_prod(S)}()
end

LinearSIndices(ind::NTuple{N,Int}) where N = LinearSIndices{Tuple{ind...}}()
LinearSIndices(inds::Tuple{Vararg{<:StaticRange{Int},N}}) where N = LinearSIndices(ntuple(i->length(inds[i]), Val(N)))
LinearSIndices(inds::Vararg{<:StaticRange,N}) where N = LinearSIndices(ntuple(i->length(inds[i]), Val(N)))
LinearSIndices(A::AbstractArray) = LinearSIndices(size(A))
LinearSIndices(A::StaticArray{S}) where S = LinearSIndices{S}()

"""
    CartesianSIndices
"""
struct CartesianSIndices{S,N,L} <: StaticIndices{S,CartesianIndex{N},N,L}
    CartesianSIndices{S}() where S = new{S,tuple_length(S),tuple_prod(S)}()
end

CartesianSIndices(ind::NTuple{N,Int}) where N = CartesianSIndices{Tuple{ind...}}()
CartesianSIndices(inds::Tuple{Vararg{<:StaticRange{Int},N}}) where N = CartesianSIndices(ntuple(i->length(inds[i]), Val(N)))
CartesianSIndices(inds::Vararg{<:StaticRange,N}) where N = CartesianSIndices(ntuple(i->length(inds[i]), Val(N)))
CartesianSIndices(A::AbstractArray) = CartesianSIndices(size(A))
CartesianSIndices(A::StaticArray{S}) where S = CartesianSIndices{S}()

"""
    SubIndices
"""
abstract type SubIndices{I,P,S,T,N,L} <: StaticIndices{S,T,N,L} end

@inline SubIndices(A::AbstractArray, I) = SubIndices(IndexStyle(A), A, I)
@inline SubIndices(::IndexLinear, A, I) = SubLinearIndices(A, I)
@inline SubIndices(::IndexCartesian, A, I) = SubCartesianIndices(A, I)

"""
    SubLinearIndices
"""
struct SubLinearIndices{I,P,S,N,L} <: SubIndices{I,P,S,Int,N,L} end

SubLinearIndices{I,P}() where {I,P} = SubLinearIndices{I,P,Tuple{map(length, I.parameters)...}}()
SubLinearIndices{I,P,S}() where {I,P,S} = SubLinearIndices{I,P,S,tuple_length(S),tuple_prod(S)}()

function SubLinearIndices(si::StaticIndices{S,T,N,L}, inds::Tuple{Vararg{<:StaticRange,N}}) where {S,T,N,L}
    @_propagate_inbounds_meta
    @boundscheck checkbounds(si, inds...)
    SubLinearIndices{typeof(inds),S}()
end

function SubLinearIndices(si::StaticIndices{S,T,N,L}, inds::Vararg{<:StaticRange,N}) where {S,T,N,L}
    @_propagate_inbounds_meta
    @boundscheck checkbounds(si, inds...)
    SubLinearIndices{typeof(tuple(inds...)),S}()
end

function SubLinearIndices(sz::NTuple{N,Int}, inds::Vararg{<:StaticRange,N}) where {S,T,N,L}
    # TODO boundschecks
    SubLinearIndices{typeof(tuple(inds...)),Tuple{sz...}}()
end
function SubLinearIndices(sz::NTuple{N,Int}, inds::Tuple{Vararg{<:StaticRange,N}}) where {S,T,N,L}
    # TODO boundschecks
    SubLinearIndices{typeof(tuple(inds...)),Tuple{sz...}}()
end

"""
    SubCartesianIndices
"""
struct SubCartesianIndices{I,P,S,N,L} <: SubIndices{I,P,S,CartesianIndex{N},N,L} end

SubCartesianIndices{I,P}() where {I,P} = SubCartesianIndices{I,P,Tuple{map(length, inds)...}}()
SubCartesianIndices{I,P,S}() where {I,P,S} = SubCartesianIndices{I,P,S,tuple_length(S),tuple_prod(S)}()

function SubCartesianIndices(si::StaticIndices{S,T,N,L}, inds::Tuple{Vararg{<:StaticRange,N}}) where {S,T,N,L}
    @_propagate_inbounds_meta
    @boundscheck checkbounds(si, inds...)
    SubLinearIndices{typeof(inds),S}()
end

function SubCartesianIndices(si::StaticIndices{S,T,N,L}, inds::Vararg{<:StaticRange,N}) where {S,T,N,L}
    @_propagate_inbounds_meta
    @boundscheck checkbounds(si, inds...)
    SubLinearIndices{typeof(tuple(inds...)),S}()
end




# Indexing interface

