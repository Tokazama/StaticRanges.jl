@inline checkbounds(r::AbstractArray, I::StaticRange) =
    (minimum(I) < firstindex(r) || maximum(I) > lastindex(r)) && throw(BoundsError(r, I))

@inline checkbounds(r::StaticRange, i::AbstractRange) =
    (minimum(i) < firstindex(r) || maximum(i) > lastindex(r)) && throw(BoundsError(r, i))

Base.iterate(r::StaticRange{T,B,S,E,0,F}) where {T,B,S,E,F} = nothing
@inline function Base.iterate(::StaticRange{T,SVal{B},SVal{S},E,L,F}, state::Int) where {T,B,S,E,L,F}
    state === nothing && return nothing
    (B + (state - F) * S, state + 1)::Tuple{T,Int}
end

@inline function getindex(r::StaticRange, i::Int)
    @boundscheck checkbounds(r, i)
    @inbounds unsafe_getindex(r, i)
end

@inline function getindex(r::StaticRange, i::AbstractArray)
    @boundscheck checkbounds(r, i)
    @inbounds unsafe_getindex(r, i)
end

#@inline function getindex(r::AbstractArray{T,N}, i::StaticRange) where {T,N}
#    @boundscheck checkbounds(r, i)
#    @inbounds unsafe_getindex(r, i)
#end

@pure Base.to_index(A::Array, r::StaticRange) = r

@pure unsafe_getindex(r::StaticRange{T,B,S,E,L,F}, i::Int) where {T,B,S,E,L,F} =
    (first(r) + (i - F) * step(r))::T

@pure function unsafe_getindex(::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F}, i::Integer) where {T,Tb,Ts,Hb,Lb,Hs,Ls,E,L,F}
    Base.@_inline_meta
    u = i - F
    shift_hi, shift_lo = u*Hs, u*Ls
    x_hi, x_lo = add12(SVal{Hb}(), SVal{shift_hi}())
    return T(x_hi + (x_lo + (shift_lo + Lb)))
end

function _getindex_hprec(::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,F,L}, i::Integer) where {T,Tb,Ts,Hb,Lb,Hs,Ls,E,F,L}
    u = i - F
    shift_hi, shift_lo = u*Hs, u*Ls
    x_hi, x_lo = Base.add12(Hb, shift_hi)
    x_hi, x_lo = Base.add12(x_hi, x_lo + (shift_lo + Lb))
    TwicePrecision(x_hi, x_lo)
end

function getindex(r::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F}, s::OrdinalRange{<:Integer}) where {T,Tb,Ts,Hb,Lb,Hs,Ls,E,L,F}
    @boundscheck checkbounds(r, s)
    soffset = 1 + round(Int, (F - first(s))/step(s))
    soffset = clamp(soffset, 1, length(s))
    ioffset = first(s) + (soffset-1)*step(s)
    if step(s) == 1 || length(s) < 2
        newstep = HPSVal{Ts,Hs,Ls}()
    else
        newstep = twiceprecision(HPSVal{Ts,Hs,Ls}()*step(s), nbitslen(T, length(s), soffset))
    end
    if ioffset == F
        steprangelen(HPSVal{Tb,Hb,Lb}(), newstep, SVal{L}(), SVal{max(1,soffset)}())
    else
        steprangelen(HPSVal{Tb,Hb,Lb}() + (ioffset-F)*HPSVal{Ts,Hs,Ls}(), newstep, SVal{L}(), SVal{max(1,soffset)}())
    end
end

@inline function unsafe_getindex(
    r1::StaticRange{T1,B1,S1,E1,L1,F1},
    r2::StaticRange{T2,B2,S2,E2,L2,F2}) where {T1,B1,E1,S1,F2,L1,T2,B2,E2,S2,F1,L2}
    SRange{T1,B1 + (B2 - F1) * S1,(B1 + (B2 - F1) * S1) + (L2-1)*(S1*S2),S1*S2,L2}()
end

@inline unsafe_getindex(r::StaticRange{T,SVal{B},SVal{S},E,L,F}, i::AbstractRange) where {T,B,S,E,L,F} =
    oftype(r, SRange{T,T(B + (first(i) - F) * S),T(B + (first(i) - F) * S) + (length(i)-F)*(S*step(i)),S*step(i),1,length(i)}())


function unsafe_getindex(r::StaticRange{T,SVal{B,Tb},SVal{S,Ts},E,L,F}, s::AbstractUnitRange{<:Integer}) where {T,B,Tb,S,Ts,E,L,F}
    Base.@_inline_meta
    SRange{T,SVal{r[first(s)],Tb},SVal{S,Ts},r[last(s)],length(s),F}()
end