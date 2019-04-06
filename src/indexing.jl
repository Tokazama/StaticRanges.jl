@inline checkbounds(r::AbstractArray, I::StaticRange) =
    (minimum(I) < firstindex(r) || maximum(I) > lastindex(r)) && throw(BoundsError(r, I))

@inline checkbounds(r::StaticRange, i::AbstractRange) =
    (minimum(i) < firstindex(r) || maximum(i) > lastindex(r)) && throw(BoundsError(r, i))

@inline function checkbounds(r::StaticRange, i::StaticRange)
    (minimum(i) < firstindex(r) || maximum(i) > lastindex(r)) && throw(BoundsError(r, i))
end

Base.iterate(r::StaticRange{T,B,S,E,0,F}) where {T,B,S,E,F} = nothing
@inline function Base.iterate(::StaticRange{T,SVal{B},SVal{S},E,L,F}, state::Int) where {T,B,S,E,L,F}
    state === nothing && return nothing
    (B + (state - F) * S, state + 1)::Tuple{T,Int}
end

@inline function getindex(r::StaticRange, i::Int)
    @boundscheck checkbounds(r, i)
    @inbounds _unsafe_getindex(r, i)
end

@inline function getindex(r::StaticRange, i::AbstractArray)
    @boundscheck checkbounds(r, i)
    @inbounds _unsafe_getindex(r, i)
end

#@inline function getindex(r::AbstractArray{T,N}, i::StaticRange) where {T,N}
#    @boundscheck checkbounds(r, i)
#    @inbounds _unsafe_getindex(r, i)
#end

@pure Base.to_index(A::Array, r::StaticRange) = r

@pure function _unsafe_getindex(r::StaticRange{T,SVal{B,T},SVal{S,T},E,L,F}, i::Int) where {T,B,S,E,L,F}
    (B + (i - F) * S)::T
end

@pure function _unsafe_getindex(r::StaticRange{T,SVal{B,Tb},SVal{S,Ts},E,L,F}, i::Int) where {T,B,Tb,S,Ts,E,L,F}
    T(B + (i - F) * S)::T
end


@pure @inline function _unsafe_getindex(
    ::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F},
    i::Integer) where {T,Tb,Ts,Hb,Lb,Hs,Ls,E,L,F}
    u = i - F
    shift_hi, shift_lo = u*Hs, u*Ls
    x_hi, x_lo = add12(SVal{Hb}(), SVal{shift_hi}())
    return T(x_hi + (x_lo + (shift_lo + Lb)))
end

@inline function _getindex_hprec(::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,F,L}, i::Integer) where {T,Tb,Ts,Hb,Lb,Hs,Ls,E,F,L}
    u = i - F
    shift_hi, shift_lo = u*Hs, u*Ls
    x_hi, x_lo = Base.add12(Hb, shift_hi)
    x_hi, x_lo = Base.add12(x_hi, x_lo + (shift_lo + Lb))
    TwicePrecision(x_hi, x_lo)
end

@inline function _unsafe_getindex(
    r1::StaticRange{T1,SVal{B1,T1},SVal{S1,T1},E1,L1,F1},
    r2::StaticRange{T2,SVal{B2,T2},SVal{S2,T2},E2,L2,F2}) where {T1,B1,E1,S1,F2,L1,T2,B2,E2,S2,F1,L2}
    SRange{T1,typeof(SVal{B1 + (B2 - F1) * S1}()),typeof(SVal{S1*S2}()),(B1 + (B2 - F1) * S1) + (L2-1)*(S1*S2),L2,1}()
end

@inline _unsafe_getindex(r::StaticRange{T,SVal{B},SVal{S},E,L,F}, i::AbstractRange) where {T,B,S,E,L,F} =
    oftype(r, SRange{T,T(B + (first(i) - F) * S),T(B + (first(i) - F) * S) + (length(i)-F)*(S*step(i)),S*step(i),1,length(i)}())


function _unsafe_getindex(
    r::StaticRange{T,SVal{B,Tb},SVal{S,Ts},E,L,F},
    s::AbstractUnitRange{<:Integer}) where {T,B,Tb,S,Ts,E,L,F}
    Base.@_inline_meta
    SRange{T,SVal{r[first(s)],Tb},SVal{S,Ts},r[last(s)],length(s),F}()
end

function _unsafe_getindex(
    r::StaticRange{T,B,S,E,L,F},
    s::OrdinalRange{<:Integer}) where {T,B<:HPSVal,S<:HPSVal,E,L,F}
    soffset = SVal{1 + round(Int, (F - first(s))/step(s))}()
    soffset = clamp(soffset, SVal{1}(), SVal{length(s)}())
    ioffset = first(s) + (soffset-1)*step(s)
    if step(s) == 1 || length(s) < 2
        newstep = S()
    else
        newstep = twiceprecision(S()*step(s), nbitslen(T, SVal{length(s)}(), soffset))
    end
    if ioffset == F
        steprangelen(B(), newstep, SVal{length(s)}(), max(SVal{1}(),soffset))
    else
        steprangelen(B() + (ioffset-F)*S(), newstep, SVal{length(s)}(), max(SVal{1}(),soffset))
    end
end

@inline function _unsafe_getindex(
    r::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F},
    s::StaticRange{T2,SVal{B,Tb2},SVal{S,Ts2},E2,L2,F2}
    ) where {T,T2<:Integer,Tb,Ts,Hb,Lb,Hs,Ls,E,L,F,B,Tb2,S,Ts2,E2,L2,F2}
    soffset = SVal{1 + round(Int, (F - T2(B))/T2(S))}()
    soffset = clamp(soffset, SVal{1}(), SVal{L2}())
    ioffset = S + (soffset-1)*S
    if L2 == 1 || L2 < 2
        newstep = HPSVal{Ts,Hs,Ls}()
    else
        newstep = twiceprecision(HPSVal{Ts,Hs,Ls}()*S, nbitslen(T, SVal{L2}(), soffset))
    end
    if ioffset == F
        steprangelen(HPSVal{Tb,Hb,Lb}(), newstep, SVal{L2}(), max(SVal{1}(),soffset))
    else
        steprangelen(HPSVal{Tb,Hb,Lb}() + (ioffset-F)*HPSVal{Ts,Hs,Ls}(), newstep, SVal{L2}(), max(SVal{1}(),soffset))
    end
end

