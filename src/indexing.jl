#=
# may be good to provide streamlined boundschecking when 1 based indexing is known
# This could make it easier for inlining entire getindex

@inline function checkbounds()
end

@inline function checkbounds(::
    r1::SRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F},
    r2::StaticRange{T2,SVal{B,Tb2},SVal{S,Ts2},E2,L2,F2}
    ) where {T,T2<:Integer,Tb,Ts,Hb,Lb,Hs,Ls,E,L,F,B,Tb2,S,Ts2,E2,L2,F2}
    (minimum(r2) < 1)
end

@inline function checkbounds(
    r1::SRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F},
    r2::SRange{T2,SVal{B,Tb2},SVal{S,Ts2},E2,L2,F2}
    ) where {T,T2<:Integer,Tb,Ts,Hb,Lb,Hs,Ls,E,L,F,B,Tb2,S,Ts2,E2,L2,F2}
end

@inline function checkbounds(
    r1::SRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F},
    r2::SRange{T2,HPSVal{Tb2,Hb2,Lb2},HPSVal{Ts2,Hs2,Ls2},E2,L2,F2}
    ) where {T,T2<:Integer,Tb,Ts,Hb,Lb,Hs,Ls,E,L,F,B,Tb2,Hb2,Lb2,Ts2,Hs2,Ls2,E2,L2,F2}
end

=#


Base.iterate(r::StaticRange{T,B,S,E,0,F}) where {T,B,S,E,F} = nothing
@inline function Base.iterate(
    ::StaticRange{T,SVal{B},SVal{S},E,L,F},
     state::Int) where {T,B,S,E,L,F}
    state === nothing && return nothing
    (B + (state - F) * S, state + 1)::Tuple{T,Int}
end

@inline function getindex(r::StaticRange, i::Int)
    @boundscheck checkbounds(r, i)
    @inbounds _unsafe_getindex(r, i)
end

@inline function getindex(r::StaticRange, i::SVal)
    @boundscheck checkbounds(r, i)
    @inbounds _unsafe_getindex(r, i)
end

@inline function getindex(r::StaticRange, i::AbstractArray)
    @boundscheck checkbounds(r, i)
    @inbounds _unsafe_getindex(r, i)
end

@inline getindex(r::StaticRange, i::AbstractRange) = r[srange(i)]

@inline function getindex(r::StaticRange, i::StaticRange)
    @boundscheck checkbounds(r, i)
    @inbounds _unsafe_getindex(r, i)
end





#@inline function getindex(r::AbstractArray{T,N}, i::StaticRange) where {T,N}
#    @boundscheck checkbounds(r, i)
#    @inbounds _unsafe_getindex(r, i)
#end

@pure Base.to_index(A::Array, r::StaticRange) = r

@pure function _unsafe_getindex(
    r::StaticRange{T,SVal{B,T},SVal{S,T},E,L,F},
    i::Int) where {T,B,S,E,L,F}
    (B::T + (i - F::Int) * S::T)::T
end

@pure function _unsafe_getindex(
    r::StaticRange{T,SVal{B,Tb},SVal{S,Ts},E,L,F},
     i::Int) where {T,B,Tb,S,Ts,E,L,F}
    T(B::Tb + (i - F::Int) * S::Ts)::T
end

@pure function _unsafe_getindex(
    r::StaticRange{T,SVal{B,Tb},SVal{S,Ts},E,L,F},
     i::SInteger) where {T,B,Tb,S,Ts,E,L,F}
    T(B::Tb + (i - F::Int) * S::Ts)::T
end


@pure @inline function _unsafe_getindex(
    ::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F},
    i::Integer) where {T,Tb,Ts,Hb,Lb,Hs,Ls,E,L,F}
    u = i - F::Int
    shift_hi, shift_lo = u * Hs::Ts, u * Ls::Ts
    x_hi, x_lo = add12(SVal{Hb,Tb}(), SVal{shift_hi}())
    return T(x_hi + (x_lo + (shift_lo + Lb)))
end

@pure @inline function _unsafe_getindex(
    ::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F},
    i::SInteger{I}) where {T,Tb,Ts,Hb,Lb,Hs,Ls,E,L,F,I}
    u = I - F::Int
    shift_hi, shift_lo = u * Hs::Ts, u * Ls::Ts
    x_hi, x_lo = add12(SVal{Hb,Tb}(), SVal{shift_hi}())
    return T(x_hi + (x_lo + (shift_lo + Lb)))
end

@inline function _getindex_hprec(
    ::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,F,L},
    i::Integer) where {T,Tb,Ts,Hb,Lb,Hs,Ls,E,F,L}
    u = i - F
    shift_hi, shift_lo = u*Hs, u*Ls
    x_hi, x_lo = Base.add12(Hb, shift_hi)
    x_hi, x_lo = Base.add12(x_hi, x_lo + (shift_lo + Lb))
    TwicePrecision(x_hi, x_lo)
end

@inline function _unsafe_getindex(
    r::StaticRange{T,SVal{B},SVal{S},E,L,F},
    i::AbstractRange) where {T,B,S,E,L,F}
    oftype(r,
        SRange{T,T(B + (first(i) - F) * S),                              # start
                 T(B + (first(i) - F) * S) + (length(i)-F)*(S*step(i)),  # step
                       S*step(i),                                        # stop
                       length(i),                                        # length
                       1}())                                             # offset
end

@inline function _unsafe_getindex(
    r::StaticRange{T,SVal{B,Tb},SVal{S,Tb},E,L,F},
    s::StepRange{<:Integer}) where {T,B,Tb,S,Ts,E,L,F}
    oftype(r, SRange{T,
              SVal{T(B + (s.start-1) * S),T},  # start
              SVal{T(step(s)*S),T},            # step
              T(B + (last(s) - F) * S),  # stop
              length(s),                 # length
              1}())                      # offset
end


function _unsafe_getindex(
    r::StaticRange{T,SVal{B,Tb},SVal{S,Ts},E,L,F},
    s::AbstractUnitRange{<:Integer}) where {T,B,Tb,S,Ts,E,L,F}
    Base.@_inline_meta
    oftype(r, SRange{T,SVal{r[first(s)],Tb},  # start
                       SVal{S,Ts},            # step
                       r[last(s)],            # stop
                       length(s),             # length
                       F}())                  # offset
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

#=
@inline function _unsafe_getindex(
    r::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F},
    s::StaticRange{T2,SVal{B,Tb2},SVal{S,Ts2},E2,L2,F2}
    ) where {T,T2<:Integer,Tb,Ts,Hb,Lb,Hs,Ls,E,L,F,B,Tb2,S,Ts2,E2,L2,F2}
    soffset = SVal{1 + round(Int, (F - T2(B))/T2(S))}()
    soffset = clamp(soffset, SOne, SVal{L2}())
    ioffset = S + (soffset-SOne)*S
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
=#
@inline function _unsafe_getindex(
    r::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F},
    s::StaticRange{T2,SVal{B,Tb2},SVal{S,Ts2},E2,L2,F2}
    ) where {T,T2<:Integer,Tb,Ts,Hb,Lb,Hs,Ls,E,L,F,B,Tb2,S,Ts2,E2,L2,F2}
    l2 = SVal{L2}()
    soffset = SOne + round(Int, (F - T2(B))/SVal{T2(S)}())
    soffset = clamp(soffset, SOne, SVal{L2}())
    ioffset = S + (soffset-SOne)*S
    if l2 == SOne || l2 < SVal{2,Int}()
        newstep = HPSVal{Ts,Hs,Ls}()
    else
        newstep = twiceprecision(HPSVal{Ts,Hs,Ls}()*SVal{S,Ts2}(), nbitslen(T, l2, soffset))
    end
    if ioffset == F
        steprangelen(HPSVal{Tb,Hb,Lb}(), newstep, l2, max(SOne,soffset))
    else
        steprangelen(HPSVal{Tb,Hb,Lb}() + (ioffset-F)*HPSVal{Ts,Hs,Ls}(), newstep, l2, max(SOne,soffset))
    end
end

@inline function _unsafe_getindex(
    r1::StaticRange{T1,SVal{B1,T1},SVal{S1,T1},E1,L1,F1},
    r2::StaticRange{T2,SVal{B2,T2},SVal{S2,T2},E2,L2,F2}
    ) where {T1,B1,E1,S1,F2,L1,T2,B2,E2,S2,F1,L2}
    oftype(r1, SRange{T1,typeof(SVal{B1 + (B2 - F1) * S1}()),     # start
                         typeof(SVal{S1*S2}()),                   # step
                         (B1 + (B2 - F1) * S1) + (L2-1)*(S1*S2),  # stop
                         L2,                                      # length
                         1}())                                    # offset
end


@inline function _unsafe_getindex(r::StaticRange{T,B,S,E,L,F}, inds::AbstractVector{Bool}) where {T,B,S,E,L,F}
    out = T[]
    for i in 1:L
        if inds[i]
            push!(out, r[i])
        end
    end
    return out
end
