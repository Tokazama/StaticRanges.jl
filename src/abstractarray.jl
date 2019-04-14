#=
function Base.eachindex(::IndexLinear, r::StaticRange)
    static_firstindex(r):static_lastindex(r)
end
=#



#=
@inline checkbounds(r::StaticRange, i::AbstractRange) =
    (minimum(i) < firstindex(r) || maximum(i) > lastindex(r)) && throw(BoundsError(r, i))

@inline checkbounds(r::StaticRange, i::StaticRange) =
@inline checkbounds(r::StaticRange, i::SVal) = 
    (i < firstindex(r) || i > lastindex(r)) && throw(BoundsError(r, i))
@inline function checkindex(
    ::Type{Bool},
    inds::StaticRange{T,HPSVal{Tb,Hb,Lb},HPSVal{Ts,Hs,Ls},E,L,F},
    i::SVal{V,Ti}) where {T,B,S,E,L,F,V,Ti,Tb,Hb,Lb,Ts,Hs,Ls}
    Ti(Hb::Tb + Lb::Tb)::Ti
    (T(B::Tb)::T <= V::Ti) & (V::Ti <= E::T)
end
=#

