Base.in(x::Integer, r::OneToRange{<:Integer}) = (1 <= x) & (x <= last(r))

function Base.findfirst(
    f::Union{Fix2{typeof(isequal),T},Fix2{typeof(==),T}},
    a::OneToRange{T}
   ) where {T}
    @boundscheck if 1 > f.x > last(a)
        return nothing
    end
    return Int(f.x)
end

function Base.findfirst(
    p::Union{Fix2{typeof(isequal),T},Fix2{typeof(==),T}},
    r::Union{AbstractStepRangeLen{T},AbstractLinRange{T},AbstractStepRange{T}}
   ) where {T}
    n = round(Integer, (p.x - first(r)) / step(r)) + 1
    @boundscheck if n < firstindex(r) || n > lastindex(r) || r[n] != p.x
        return nothing
    end
    return n
end
