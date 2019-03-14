@pure Base.iterate(::StaticRangeUnion{T,B,E,S,0}) where {T,B,E,S} = nothing
@pure Base.iterate(::StaticRangeUnion{T,B,E,S,L}) where {T,B,E,S,L} = (B, 1)::Tuple{T,Int}
@pure function Base.iterate(::StaticRangeUnion{T,B,E,S,L}, i::Int) where {T,B,E,S,L}
    Base.@_inline_meta
    i == L && return nothing
    (T(B + i * S), i + 1)::Tuple{T,Int}
end

@pure @propagate_inbounds function getindex(r::StaticRange{T,B,E,S,L}, i::Int) where {T,B,E,S,L}
    @boundscheck if i < 1 || i > L
        throw(BoundsError(r, i))
    end
    return T(B + (i - 1) * S)
end

#function getindex(A::AbstractArray, I...)
#    @_propagate_inbounds_meta
#    error_if_canonical_getindex(IndexStyle(A), A, I...)
#    _getindex(IndexStyle(A), A, to_indices(A, I)...)
#end


# Always index with the exactly indices provided.
"""
    getindex(A, StaticRange)

# Examples

```jldoctest
using StaticRanges

julia> A = reshape([1:400...], (20, 20));

julia> A[srange(1, 8, step=1), srange(1, 8, step=1)]
8×8 SArray{Tuple{8,8},Int64,2,64}:
 1  21  41  61  81  101  121  141
 2  22  42  62  82  102  122  142
 3  23  43  63  83  103  123  143
 4  24  44  64  84  104  124  144
 5  25  45  65  85  105  125  145
 6  26  46  66  86  106  126  146
 7  27  47  67  87  107  127  147
 8  28  48  68  88  108  128  148

julia> A[srange(1, 8, step=2), srange(1, 8, step=2)]
4×4 SArray{Tuple{4,4},Int64,2,16}:
 1  41  81  121
 3  43  83  123
 5  45  85  125
 7  47  87  127
```
"""
# ## Index StaticRange

"""
Index with integer
```jldoctest
julia> srange(1,10,step=1)[4]
4
```
"""
# StaticRange[i]
"""
Index `SOneTo` with `StaticRange`
```jldoctest
julia> SOneTo(10)[srange(1,3,step=1)]
SOneTo(3)
```
"""
@pure @propagate_inbounds function getindex(r::SOneTo{N}, i::StaticRange{T,B,E,S,L}) where {T,B,E,S,L,N}
    @boundscheck checkbounds(r, i)
    return i
end

"""
Index with `Base.OneTo`
```jldoctest
julia> srange(1,10,step=1)[Base.OneTo(5)]
StaticRange(1:1:5)
```
"""
# StaticRange[OneTo]
@inline function getindex(r::StaticRangeUnion{T,B,E,S,L}, i::OneTo) where {T,B,E,S,L}
    @boundscheck checkbounds(r, i)
    StaticRange{T,B,B+(length(i)-1)*S,S,1,length(i)}()
end


"""
Index with `UnitRange`
```jldoctest
julia> srange(1,10,step=1)[3:10]
StaticRange(3:1:10)
```
"""
# StaticRange[UnitRange]
@inline function getindex(r::StaticRangeUnion{T,B,E,S,L}, i::AbstractUnitRange{<:Integer}) where {T,B,E,S,L}
    @boundscheck checkbounds(r, i)
    StaticRange{T,T(B + (first(i)-1) * S),T(B + (last(i) -1) * S),S,length(i)}()
end

"""
Index with `StepRange`
```jldoctest
julia> srange(1,10,step=1)[3:2:10]
StaticRange(3:2:9)
```
"""
# StaticRange[StepRange]
@inline function getindex(r::StaticRangeUnion{T,B,E,S,L}, i::StepRange{<:Integer}) where {T,B,E,S,L}
    @boundscheck checkbounds(r, i)
    StaticRange{T,T(B + (first(i)-1) * S),T(B + (first(i)-1) * S) + (length(i)-1)*(S*step(i)),S*step(i),length(i)}()
end

# ## Index Other Ranges

"""
Index `UnitRange` with `StepRange`
```jldoctest
julia> (1:2:10)[srange(1,5,step=1)]
1:2:9
```
"""
# ### AbstractUnitRange[srange]
@inline function getindex(r::AbstractUnitRange, i::StaticRange{T,B,E,S,L}) where {T,B,E,S,L}
    @boundscheck checkbounds(r, i)
    range(oftype(r.start, r.start + B*S), step=S, length=L)
end

# OneTo[UnitSRange]
@inline function getindex(r::OneTo{T}, i::StaticRange{T,B,E,S,L}) where {T,B,E,S,L}
    @boundscheck checkbounds(r, i)
    range(T(B), T(E), step=S)
end

# LinRange[UnitSRange]
@inline function getindex(r::LinRange, i::UnitSRange{T,B,E,L}) where {T,B,E,L}
    @boundscheck checkbounds(r, i)
    return LinRange(B, E, L)
end

# LinRange{srange]
@inline function getindex(r::LinRange, i::StaticRange{T,B,E,S,L}) where {T,B,E,S,L}
    @boundscheck checkbounds(r, i)
    return range(B, step=S, length=L)
end


# ## Index <:AbstractArray

"""
```jldoctest
julia> [1:10...][srange(2,10,step=2)]
10-element Array{Int64,1}:
  2
  4
  6
  8
  10
```
"""
# Array[srange]
@inline function getindex(a::Array{T}, I::StaticRange{Tr,B,E,S,L}) where {Tr,B,E,S,L,T}
    @boundscheck checkbounds(a, I)
    out = Vector{T}(undef, L)
    unsafe_copyto!(pointer(out), OneToSRange{L}(), pointer(a), I)
    return out
end


"""
```jldoctest
julia> SVector(1:10...)[srange(2,10,step=2)]
5-element SArray{Tuple{5},Int64,1,5}:
  2
  4
  6
  8
 10
 ```
 """
_unsafe_pointer(a::SArray{S,T}) where {S,T} = convert(Ptr{T}, Base.unsafe_convert(Ptr{Nothing}, Ref(a.data)))
_unsafe_pointer(a::MArray{S,T}) where {S,T} = Base.unsafe_convert(Ptr{T}, pointer_from_objref(a))
_unsafe_pointer(a::Array{T}) where T = pointer(a)
_unsafe_pointer(a::SizedArray{S,T}) where {S,T} = pointer(a.data)::Ptr{T}


# StaticArray[srange]
@inline function getindex(
    a::StaticArray{S,T,N}, I::StaticRange{<:Integer,<:Integer,<:Integer,<:Integer,L}) where {S,T,N,L}
    @boundscheck checkbounds(a, I)
    ref = Ref{NTuple{L,T}}()
    unsafe_copyto!(convert(Ptr{T},Base.unsafe_convert(Ptr{Nothing}, ref)), _unsafe_pointer(a), I)
    return similar_type(a, Size(L))(ref[])
end

@pure @propagate_inbounds function getindex(r::StaticRangeUnion{T,B,E,S,L}, i::Int) where {T,B,E,S,L}
    @boundscheck if i < 1 || i > L
        throw(BoundsError(r, i))
    end
    return T(B + (i - 1) * S)
end


# TODO: ensure that r2 with offset actual gives right result
@pure @propagate_inbounds function getindex(
    r1::StaticRangeUnion{T1,B1,E1,S1,L1}, r2::StaticRange{T2,B2,E2,S2,L2}) where {T1,B1,E1,S1,L1,T2,B2,E2,S2,L2}
    @boundscheck if B2 < 1 || E2 > L1
        throw(BoundsError(r1, r2))
    end
    StaticRange{T1,T1(B1 + (B2-1) * S1),T1(B1 + (B2-1) * S1) + (L2-1)*(S1*S2),S1*S2,L2}()
end

@inline function Base.unsafe_copyto!(
    dest::Ptr{T}, ::StaticRange{Int,B1,E1,S1,L},
    src::Ptr{T}, ::StaticRange{Int,B2,E2,S2,L}) where {B1,E1,S1,B2,E2,S2,L,T}
    i = 1
    while i < L
        unsafe_store!(dest, unsafe_load(src, B2 + (i-1) * S2)::T, B1 + (i-1) * S1)
        i += 1
    end
end



