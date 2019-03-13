@pure first(::StaticRangeUnion{T,B,E,S,L}) where {T,B,E,S,L} = B::T
@pure last(::StaticRangeUnion{T,B,E,S,L}) where {T,B,E,S,L} = E::T
@pure step(::StaticRangeUnion{T,B,E,S,L}) where {T,B,E,S,L} = S::T

@pure length(::StaticRangeUnion{T,B,E,S,L}) where {T,B,E,S,L} = L::Int
@pure firstindex(::StaticRangeUnion{T,B,E,S,L}) where {T,B,E,S,L} = 1::Int
@pure lastindex(::StaticRangeUnion{T,B,E,S,L}) where {T,B,E,S,L} = L::Int

@pure size(::StaticRangeUnion{T,B,E,S,L}) where {T,B,E,S,L} = (L,)::NTuple{1,Int}

@pure Base.maximum(::StaticRangeUnion{T,B,E,S,L}) where {T,B,E,S,L} = E::T
@pure Base.minimum(::StaticRangeUnion{T,B,E,S,L}) where {T,B,E,S,L} = B::T
@pure Base.extrema(::StaticRangeUnion{T,B,E,S,L}) where {T,B,E,S,L} = (B, E)::NTuple{2,T}

@pure Base.isempty(::StaticRangeUnion{T,B,E,S,0}) where {T,B,E,S} = true
@pure Base.isempty(::StaticRangeUnion{T,B,E,S,L}) where {T,B,E,S,L} = false

@pure ==(::StaticRangeUnion{T1,B1,E1,S1,L1}, ::StaticRangeUnion{T2,B2,E2,S2,L2}) where {T1,B1,E1,S1,L1,T2,B2,E2,S2,L2} = false
@pure ==(::StaticRangeUnion{T,B,E,S,L}, ::StaticRangeUnion{T,B,E,S,L}) where {T,B,E,S,L} = true

@pure (+)(::StaticRangeUnion{T,B,E,S,L}, i::T) where {T,B,E,S,L} = StaticRangeUnion{T,B+i,E+i,S,L}()
@pure (-)(::StaticRangeUnion{T,B,E,S,L}, i::T) where {T,B,E,S,L} = StaticRangeUnion{T,B-i,E-i,S,L}()

@pure (+)(::StaticRangeUnion{T,B1,E1,S,L}, ::StaticRangeUnion{T,B2,E2,S,L}) where {T,B1,B2,E1,E2,S,L} = StaticRangeUnion{T,B+i,E+i,S,L}()
@pure (-)(::StaticRangeUnion{T,B1,E1,S,L}, ::StaticRangeUnion{T,B2,E2,S,L}) where {T,B1,B2,E1,E2,S,L} = StaticRangeUnion{T,B-i,E-i,S,L}()

@pure Base.reverse(::StaticRangeUnion{T,B,E,S,L}) where {T,B,E,S,L} = StaticRange{T,E,B,-S,L}()
@pure Base.similar(::StaticRangeUnion{T,B,E,S,L}, ::StaticRangeUnion{T2,B2,E2,S2,L2}) where {T,B,E,S,L,T2,B2,E2,S2,L2} = StaticRange{T2,B2,E2,S2,L2}()


@pure parentsize(::SubIndices{I,P,S,T,N,L}, i::Int) where {I,P,S,T,N,L} = fieldtype(P, i)::Int
@pure first(::SubIndices{I,P,S,T,N,L}, i::Int)  where {I,P,S,T,N,L} = first(fieldtype(I, i))::Int
@pure last(::SubIndices{I,P,S,T,N,L}, i::Int)  where {I,P,S,T,N,L} = last(fieldtype(I, i))::Int
@pure step(::SubIndices{I,P,S,T,N,L}, i::Int)  where {I,P,S,T,N,L} = step(fieldtype(I, i))::Int


