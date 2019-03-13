# checkbounds
@inline function checkbounds(r::AbstractRange, i::StaticRangeUnion{T,B,E,S,L}) where {T,B,E,S,L}
    (B < firstindex(r) || L > lastindex(r)) && throw(BoundsError(r, i))
end

@inline function checkbounds(r::StaticRangeUnion{T,B,E,S,L}, i::AbstractRange) where {T,B,E,S,L}
    (first(i) < 1 || last(i) > L) && throw(BoundsError(r, i))
end


@pure function checkbounds(r::SOneTo{N}, i::StaticRangeUnion{T,B,E,S,L}) where {T,B,E,S,L,N}
    (B < 1 || L > N) && throw(BoundsError(r, i))
end

@pure function checkbounds(r::StaticRangeUnion{T,B,E,S,L}, i::SOneTo{N}) where {T,B,E,S,L,N}
     N > L && throw(BoundsError(r, i))
end


function Base.checkbounds(::StaticIndices{S,T,N,L}, i::Int) where {S,T,N,L}
    if i < 1 || i > L
        throw(BoundsError(inds, i))
    end
end

@inline function Base.checkbounds(::StaticIndices{S,T,N,L}, r::AbstractRange) where {S,T,N,L}
    if first(r) < 1 || last(r) > L
        throw(BoundsError(inds, r))
    end
end

@pure function Base.checkbounds(::StaticIndices{S,T,N,L}, r::StaticRangeUnion{<:Integer,B,E}) where {S,T,N,L,B,E}
    if B < 1 || E > L
        throw(BoundsError(inds, r))
    end
end


