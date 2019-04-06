
function +(
    r1::StaticRange{T,B1,S1,E1,L1,F1},
    r2::StaticRange{T,B2,S2,E2,L2,F2}) where {T,B1,B2,S1,S2,E1,E2,L1,L2,F1,F2}
    throw(DimensionMismatch("argument dimensions must match"))
end

@inline function +(
    r1::StaticRange{T,B1,S1,E1,L,F1},
    r2::StaticRange{T,B2,S2,E2,L,F2}) where {T,B1,B2,S1,S2,E1,E2,L,F1,F2}
    len = length(r1)
    steprangelen(B1()+B2(), S1()+S2(), SVal{L}())
end

-(r1::StaticRange, r2::StaticRange) = +(r1, -r2)

+(::StaticRange{T,B1,E1,S1,F,L}, ::StaticRange{T,B2,E2,S2,F,L}) where {T,B1,E1,S1,B2,E2,S2,F,L} =
    StaticRange{T,B1+B2,E1+E2,S1+S2,F,L}()

-(::StaticRange{T,B1,E1,S1,F,L}, ::StaticRange{T,B2,E2,S2,F,L}) where {T,B1,E1,S1,B2,E2,S2,F,L} =
    StaticRange{T,B1-B2,E1-E2,S1-S2,F,L}()

-(::StaticRange{T,SVal{B,Tb},SVal{S,Ts},E,L,F})  where {T,B,Tb,S,Ts,E,L,F} =
    StaticRange{T,SVal{-B,Tb},SVal{-S,Ts},-E,L,F}()

-(::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F})  where {T,Tb,Hb,Lb,Ts,Hs,Ls,E,L,F} =
    StaticRange{T,HPSVal{Tb,-Hb,-Lb},HPSVal{Ts,-Hs,-Ls},-E,L,F}()