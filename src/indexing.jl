
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
unsafe_getindex(::SRBoth{B,E,S,F,L,T}, i::Int) where {B,E,S,F,L,T} = T(B + (i - F)*S)

# AbstractArray
#Base.checkbounds(a::AbstractArray, I::SRBoth) = checkbounds(Bool, a, I) || throw(BoundsError(a,I))
#function Base.checkbounds(::Type{Bool}, a::AbstractArray{T,N}, I::SRBoth{B,E,S,F,L}) where {T,N,B,E,S,F,L}
#    firstindex(a) <= B && E <= lastindex(a)
#end
#function Base.getindex(a::AbstractArray, I::SRBoth{B,E,S,F,L,T}) where {T,N,B,E,S,F,L}
#    @boundscheck checkbounds(a, I)
#    @inbounds unsafe_getindex(a, I)
#end
#

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
