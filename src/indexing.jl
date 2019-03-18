# checkbounds
@inline checkbounds(r::AbstractRange, i::StaticRangeUnion{T,B,E,S,F,L}) where {T,B,E,S,F,L} =
    (B < firstindex(r) || L > lastindex(r)) && throw(BoundsError(r, i))

@inline checkbounds(r::StaticRangeUnion{T,B,E,S,F,L}, i::AbstractRange) where {T,B,E,S,F,L} =
    (first(i) < F || last(i) > L + F) && throw(BoundsError(r, i))

@pure checkbounds(r::SOneTo{N}, i::StaticRangeUnion{T,B,E,S,L}) where {T,B,E,S,L,N} =
    (B < 1 || L > N) && throw(BoundsError(r, i))

@pure checkbounds(r::StaticRangeUnion{T,B,E,S,L}, i::SOneTo{N}) where {T,B,E,S,L,N} =
     N > L && throw(BoundsError(r, i))

#=
@pure Base.checkbounds(::StaticAxes{Ax,S,T,N,L}, i::Int) where {Ax,S,T,N,L} =
    i < 1 || i > L && throw(BoundsError(inds, i))

@inline Base.checkbounds(::StaticAxes{Ax,S,T,N,L}, r::AbstractRange) where {Ax,S,T,N,L} =
    first(r) < 1 || last(r) > L && throw(BoundsError(inds, r))

@pure Base.checkbounds(::StaticAxes{Ax,S,T,N,L}, r::StaticRangeUnion{<:Integer,B,E}) where {Ax,S,T,N,L,B,E} =
    B < 1 || E > L && throw(BoundsError(inds, r))

@pure Base.checkbounds(inds::StaticAxes, i::NTuple{N,Int}) where N =
    first(inds) > i || i > last(inds) && throw(BoundsError(inds, i))
=#

#function getindex(A::AbstractArray, I...)
#    @_propagate_inbounds_meta
#    error_if_canonical_getindex(IndexStyle(A), A, I...)
#    _getindex(IndexStyle(A), A, to_indices(A, I)...)
#end

# Always index with the exactly indices provided.
@pure Base.iterate(::StaticRangeUnion{T,B,E,S,F,0}) where {T,B,E,S,F} = nothing
@pure Base.iterate(::StaticRangeUnion{T,B,E,S,F,L}) where {T,B,E,S,F,L} = (B, 1)::Tuple{T,Int}
@pure function Base.iterate(::StaticRangeUnion{T,B,E,S,F,L}, i::Int) where {T,B,E,S,F,L}
    Base.@_inline_meta
    i == L && return nothing
    (T(B + i * S), i + 1)::Tuple{T,Int}
end

@pure @propagate_inbounds function getindex(r::StaticRange{T,B,E,S,F,L}, i::Int) where {T,B,E,S,F,L}
    @boundscheck if i < F || i > L
        throw(BoundsError(r, i))
    end
    return T(B + (i - F) * S)
end

@pure @propagate_inbounds function getindex(r::SOneTo{N}, i::StaticRangeUnion{T,B,E,S,F,L}) where {T,B,E,S,F,L,N}
    @boundscheck checkbounds(r, i)
    return i
end

@inline function getindex(r::StaticRangeUnion{T,B,E,S,F,L}, i::OneTo) where {T,B,E,S,F,L}
    @boundscheck checkbounds(r, i)
    StaticRange{T,B,B+(length(i)-1)*S,S,1,length(i)}()
end

# TODO: What's the most user friendly way to index offsets?
# e.g. new offset starts from where index was? or just start at 1 again?
@inline function getindex(r::StaticRangeUnion{T,B,E,S,F,L}, i::AbstractUnitRange{<:Integer}) where {T,B,E,S,F,L}
    @boundscheck checkbounds(r, i)
    StaticRange{T,T(B + (first(i) - F) * S),T(B + (last(i) - F) * S),S,1,length(i)}()
end

@inline function getindex(r::StaticRangeUnion{T,B,E,S,F,L}, i::StepRange{<:Integer}) where {T,B,E,S,F,L}
    @boundscheck checkbounds(r, i)
    StaticRange{T,T(B + (first(i) - F) * S),T(B + (first(i) - F) * S) + (length(i)-1)*(S*step(i)),S*step(i),1,length(i)}()
end

@inline function getindex(r::AbstractUnitRange, i::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L}
    @boundscheck checkbounds(r, i)
    range(oftype(r.start, r.start + B*S), step=S, length=L)
end

@inline function getindex(r::OneTo{T}, i::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L}
    @boundscheck checkbounds(r, i)
    range(T(B), T(E), step=S)
end

@inline function getindex(r::LinRange, i::UnitSRange{T,B,E,L}) where {T,B,E,L}
    @boundscheck checkbounds(r, i)
    return LinRange(B, E, L)
end

@inline function getindex(r::LinRange, i::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L}
    @boundscheck checkbounds(r, i)
    return range(B, step=S, length=L)
end


# ## Index <:AbstractArray

# Array[srange]
@inline function getindex(a::Array{T}, I::StaticRange{Int,B,E,S,F,L}) where {B,E,S,F,L,T}
    @boundscheck checkbounds(a, I)
    out = Vector{T}(undef, L)
    unsafe_copyto!(pointer(out), OneToSRange{L}(), pointer(a), I)
    return out
end

# StaticArray[srange]
@inline function getindex(
    a::StaticArray{S,T,N}, I::StaticRange{<:Integer,<:Integer,<:Integer,<:Integer,L}) where {S,T,N,L}
    @boundscheck checkbounds(a, I)
    ref = Ref{NTuple{L,T}}()
    unsafe_copyto!(convert(Ptr{T},Base.unsafe_convert(Ptr{Nothing}, ref)), dig4pointer(a), I)
    return similar_type(a, Size(L))(ref[])
end

@pure @propagate_inbounds function getindex(r::StaticRangeUnion{T,B,E,S,F,L}, i::Int) where {T,B,E,S,F,L}
    @boundscheck if i < 1 || i > L
        throw(BoundsError(r, i))
    end
    return T(B + (i - 1) * S)
end


# TODO: ensure that r2 with offset actual gives right result
@pure @propagate_inbounds function getindex(
    r1::StaticRangeUnion{T1,B1,E1,S1,F1,L1}, r2::StaticRange{T2,B2,E2,S2,F2,L2}) where {T1,B1,E1,S1,F1,L1,T2,B2,E2,S2,F2,L2}
    @boundscheck if B2 < F1 || E2 > L1 + F1 - 1
        throw(BoundsError(r1, r2))
    end
    StaticRange{T1,T1(B1 + (B2-1) * S1),T1(B1 + (B2-1) * S1) + (L2-1)*(S1*S2),S1*S2,1,L2}()
end

@inline function getindex(a::Array{T}, inds::SubIndices) where T
    @_propagate_inbounds_meta
    @boundscheck checkbounds(a, inds)
    out = Array{T}(undef, size(inds))
    unsafe_copyto!(pointer(out), OneToSRange{L}(), pointer(a), inds)
    return out
end

@inline function getindex(
    a::StaticArray{S,T,N}, inds::SubIndices) where {S,T,N}
    @boundscheck checkbounds(a, I)
    ref = Ref{NTuple{length(inds),T}}()
    unsafe_copyto!(convert(Ptr{T},Base.unsafe_convert(Ptr{Nothing}, ref)), OneToSRange{L}(), _unsafe_pointer(a), inds)
    return similar_type(a, Size(L))(ref[])
end
