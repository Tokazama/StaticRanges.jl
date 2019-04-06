
@pure first(::StaticRange{T,SVal{B,Tb},SVal{S,Ts},E,L,F}) where {T,B,Tb,S,Ts,E,L,F} = B::Tb

@pure function first(::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F}) where {T,Tb,Hb,Lb,Ts,Hs,Ls,E,L,F}
    x_hi, x_lo = add12(SVal{Hb}(), SVal{Tb(0)}())
    return T(x_hi + (x_lo + Lb))
end

@pure step(::StaticRange{T,SVal{B,Tb},SVal{S,Ts},E,L,F}) where {T,B,Tb,S,Ts,E,L,F} = S::Ts

@pure function step(::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F}) where {T,Tb,Hb,Lb,Ts,Hs,Ls,E,L,F}
    T(Hs + Ls)::T
end

@pure last(::StaticRange{T,SVal{B,Tb},SVal{S,Ts},E,L,F}) where {T,B,Tb,S,Ts,E,L,F} = E::T

@pure last(::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F}) where {T,Tb,Hb,Lb,Ts,Hs,Ls,E,L,F} = E::T

@pure static_first(::StaticRange{T,B,S,E,L,F}) where {T,B,S,E,L,F}  = B
@pure static_step(::StaticRange{T,B,S,E,L,F}) where {T,B,S,E,L,F} = S


@pure firstindex(::StaticRange{T,B,S,E,L,E}) where {T,B,S,E,L,F} = F::Int
@pure lastindex(::StaticRange{T,B,S,E,L,E}) where {T,B,S,E,L,F} = (L - F + 1)::Int
@pure length(::StaticRange{T,B,S,E,L,F}) where {T,B,S,E,L,F} = L::Int

@inline function Base.getproperty(r::StaticRange, sym::Symbol)
    if sym === :step
        return step(r)
    elseif sym === :start
        return first(r)
    elseif sym === :stop
        return last(r)
    elseif sym === :len
        return length(r)
    elseif sym === :lendiv
        return (last(r) - first(r)) / step(r)
    elseif sym === :ref  # for now this is just treated the same as start
        return first(r)
    elseif sym === :offset
        return firstindex(r)
    else
        error("type $(typeof(r)) has no field $sym")
    end
end



#=
@pure Base.minimum(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = B::T
@pure Base.minimum(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = B::T

@pure Base.maximum(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = E::T
@pure Base.maximum(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = E::T

@pure Base.extrema(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = (B, E)::Tuple{T,T}
@pure Base.extrema(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = (B, E)::Tuple{T,T}
=#

