
#Base.to_indices(A, I::Tuple{Vararg{Union{<:StaticRange,Integer,Colon},N}}) where N = SubIndices(A, I)

function getindex(inds::LinearSIndices{S,N,L}, i::Int) where {S,N,L}
    @_propagate_inbounds_meta
    @boundscheck checkbounds(inds, i)
    return i
end

@pure function getindex(inds::LinearSIndices{S,N,L}, i::Int, ii::Int...) where {S,N,L}
    @_propagate_inbounds_meta
    @boundscheck checkbounds(inds, i, ii...)
    stride = 1
    s2i = i
    for D ∈ 2:N
        stride *= fieldtype(S, D-1)
        s2i += (stride * (ii[D-1] - 1))
    end
    return s2i
end

# tmpfunc(x) = @inbounds x[1,1]
@generated function getindex(inds::CartesianSIndices{S,N,L}, i::Int) where {S,N,L}
    i2s = Vector{Expr}(undef, N)
    ind = :(i - 1)
    indnext = :()
    for D in 1:N
        indnext = :(div($ind, fieldtype(S, $D)))
        i2s[D] = :($ind - fieldtype(S, $D) * $indnext + 1)
        ind = indnext
    end
    return quote
        @_propagate_inbounds_meta
        @boundscheck checkbounds(inds, i)
        CartesianIndex($(i2s...))
    end
end

function getindex(inds::CartesianSIndices{S,N,L}, i::Int, ii::Int...) where {S,N,L}
    @_propagate_inbounds_meta
    @boundscheck checkbounds(inds, (i, ii...))
    return CartesianIndex(i, ii...)
end


@pure function getindex(si::SubLinearIndices{I,P,S,1,L}, i::Int) where {I,P,S,L}
    @_propagate_inbounds_meta
    @boundscheck checkbounds(si, i)
    stride = 1
    ind = i - 1
    indnext = div(ind, fieldtype(S, 1))
    return ind - fieldtype(S, 1) * indnext + first(fieldtype(I, 1))
end

@generated function getindex(si::SubLinearIndices{I,P,S,N,L}, i::Int) where {I,P,S,N,L}
    indnext = 0
    ind = :(i - 1)
    indnext = :(div($ind, fieldtype(S, 1)))
    i2i = :($ind - fieldtype(S, 1) * $indnext + first(fieldtype(I, 1)))
    stride = :(fieldtype(P, 1))
    for D ∈ 2:N
        ind = indnext
        indnext = :(div($ind, fieldtype(S, $D)))
        i2i = :($i2i + $stride * (($ind - fieldtype(S, $D) * $indnext + first(fieldtype(I, $D))) - 1))
        stride = :($stride * fieldtype(P, $D))
    end
    return quote
        @_propagate_inbounds_meta
        @boundscheck checkbounds(si, i)
        $i2i
    end
end


# Multi-Dimensional

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



##############
# unsafe_ops #
##############
# unsafe_copyto!
@inline function Base.unsafe_copyto!(
    dest::Ptr{T}, si1::OneToSRange{L},
    src::Ptr{T},  si2::SubIndices{I,P,S,N,L}) where {T,I,P,S,N,L}
    @inbounds for i in si1
        unsafe_coptyo!(dest, unsafe_load(src, si2[i]::Int)::T, i)
    end
end

@inline function Base.unsafe_copyto!(
    dest::Ptr{T}, si1::SubIndices{I,P,S,N,L},
    src::Ptr{T},  si2::OneToSRange{L}) where {T,I,P,S,N,L}
    @inbounds for i in OneToSRange{L}()
        unsafe_coptyo!(dest, unsafe_load(src, i)::T, si1[i]::Int)
    end
end

@inline function Base.unsafe_copyto!(
    dest::Ptr{T},          si1::SubIndices{I1,P1,S1,N1,L},
    src::AbstractArray{T}, si2::SubIndices{I2,P2,S2,N2,L}) where {T,I1,P1,S1,N1,I2,P2,S2,N2,L}
    @_propagate_inbounds_meta
    for i in OneToSRange{L}()
        unsafe_coptyo!(dest, src[si2[i]]::T, si1[i]::Int)
    end
end

@inline function _unsafe_copyto!(
    dest::AbstractArray{T}, si1::SubIndices{I1,P1,S1,N1,L},
    src::AbstractArray{T},  si2::SubIndices{I2,P2,S2,N2,L}) where {T,I1,P1,S1,N1,I2,P2,S2,N2,L}
    @_propagate_inbounds_meta
    for i in OneToSRange{L}()
        dest[si1[i]] = src[si2[i]]::T
    end
end

@inline function Base.unsafe_copyto!(
    dest::AbstractArray{T}, si1::SubIndices{I1,P1,S1,N1,L},
    src::Ptr{T},            si2::SubIndices{I2,P2,S2,N2,L}) where {T,I1,P1,S1,N1,I2,P2,S2,N2,L}
    @_propagate_inbounds_meta
    for i in OneToSRange{L}()
        dest[si1[i]] = unsafe_load(src, si2[i])::T
    end
end

@inline function Base.unsafe_copyto!(
    dest::Ptr{T}, si1::SubIndices{I1,P1,S1,N1,L},
    src::Ptr{T},  si2::SubIndices{I2,P2,S2,N2,L}) where {T,I1,P1,S1,N1,I2,P2,S2,N2,L}
    @_propagate_inbounds_meta
    for i in OneToSRange{L}()
        unsafe_coptyo!(dest, unsafe_load(src, si2[i]::Int)::T, si1[i]::Int)
    end
end

# I/O
@inline function Base.unsafe_read(io::IO, ptr::Ptr{T}, r::StaticRange{Tr,B,E,S,L}) where {Tr,B,E,S,L,T}
    for i in r
        unsafe_store!(ptr, read(io, UInt8)::UInt8, i)
    end
end

@inline function Base.unsafe_read(io::IO, ptr::Ptr{T}, si::SubIndices{I,P,S,N,L}) where {T,I,P,S,N,L}
    for i in si
        unsafe_store!(ptr, read(io, UInt8)::UInt8, i)
    end
end

@inline function Base.unsafe_write(io::IO, ptr::Ptr{T}, r::StaticRange{Tr,B,E,S,L}) where {Tr,B,E,S,L,T}
    written::Int = 0
    for i in si
        written += write(io, unsafe_load(ptr, i)::T)
    end
    return written
end

@inline function Base.unsafe_write(io::IO, ptr::Ptr{T}, si::SubIndices{I,P,S,N,L}) where {T,I,P,S,N,L}
    written::Int = 0
    for i in si
        written += write(io, unsafe_load(ptr, i)::T)
    end
    return written
end
