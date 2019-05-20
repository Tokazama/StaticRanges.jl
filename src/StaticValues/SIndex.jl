
abstract type StaticIndex{I<:Tuple,T<:Tuple,N} end

@pure Base.length(::StaticIndex{I,T,N}) where {I,T,N} = N::Int
@pure Base.get(::StaticIndex{I,T,N}) where {I,T,N} = I::T
@pure Base.eltype(::StaticIndex{I,T,N}) where {I,T,N} = T


"""
    SIndex

The static equivalent of a Tuple. Primary for the purpose of multidimensional
indexing.
"""
struct SIndex{I,T,N} <: StaticIndex{I,T,N}
    function SIndex{I,T,N} where {I,T,N}
        length(I.parameters) != length(T.parameters) | length(T.parameters) != N && throw("Length of I and T must equal N in SIndex, got $I, $T, $N.")
    end
end


struct NamedSIndex{names,I,T,N} <: StaticIndex{I,T,N} end
