Base.minimum(r::StaticRange{T,SVal{0}}) where {T} = throw(ArgumentError("range must be non-empty"))
Base.maximum(r::StaticRange{T,SVal{0}}) where {T} = throw(ArgumentError("range must be non-empty"))

Base.minimum(r::StaticRange) = min(first(r), last(r)) 
Base.maximum(r::StaticRange) = max(first(r), last(r)) 

Base.extrema(r::StaticRange) = (minimum(r), maximum(r))


function +(
    r1::StaticRange{T,L1},
    r2::StaticRange{T,L2}) where {T,L1,L2}
    throw(DimensionMismatch("argument dimensions must match"))
end
#=

@inline function +(
    r1::SRange{T,B1,S1,E1,L,F1},
    r2::SRange{T,B2,S2,E2,L,F2}) where {T,B1,B2,S1,S2,E1,E2,L,F1,F2}
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

function *(x::Real, r::StaticRange{<:Real,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,F,L}) where {T,Tb,Ts,Hb,Lb,Hs,Ls,E,F,L}
    oftype(r, steprangelen(x*HPSVal{Tb,Hb,Lb}(), twiceprecision(x*HPSVal{Ts,Hs,Ls}(), nbitslen(r)), SVal{L}(), SVal{F}()))
end

*(r::StaticRange{<:Real,<:HPSVal}, x::Real) = x*r

function /(x::Real, r::StepSRangeLen{<:Real,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,F,L}) where {T,Tb,Ts,Hb,Lb,Hs,Ls,E,F,L}
    StepSRangeLen(HPSVal{Tb,Hb,Lb}()/x, twiceprecision(HPSVal{Ts,Hs,Ls}()/x, nbitslen(r)), SVal{L}(), SVal{F}(0))
end

function sum(r::StepSRangeLen{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,F,L}) where {T,Tb,Ts,Hb,Lb,Hs,Ls,E,F,L}
    # Compute the contribution of step over all indices.
    # Indexes on opposite side of r.offset contribute with opposite sign,
    #    r.step * (sum(1:np) - sum(1:nn))
    np, nn = L - F, F - 1  # positive, negative
    # To prevent overflow in sum(1:n), multiply its factors by the step
    sp, sn = sumpair(np), sumpair(nn)
    tp = _tp_prod(SVal{Ts,Hs,Ls}(), sp[1], sp[2])
    tn = _tp_prod(r.step, sn[1], sn[2])
    s_hi, s_lo = add12(tp.hi, -tn.hi)
    s_lo += tp.lo - tn.lo
    # Add in contributions of ref
    ref = r.ref * l
    sm_hi, sm_lo = add12(s_hi, ref.hi)
    add12(sm_hi, sm_lo + ref.lo)[1]
end

Base.sum(r::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} =
    L * B + (iseven(L) ? (S * (L-1)) * (L>>1) : (S * L) * ((L-1)>>1))
end

=#

#=
function sum(r::StaticRange{<:Real})
    l = slength(r)
    # note that a little care is required to avoid overflow in l*(l-1)/2
    return l * sfirst(r) + (iseven(l) ? (step(r) * (l-1)) * (l>>1)
                                     : (step(r) * l) * ((l-1)>>1))
end
=#