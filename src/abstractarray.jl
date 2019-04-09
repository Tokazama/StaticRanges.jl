#=
function Base.eachindex(::IndexLinear, r::StaticRange)
    static_firstindex(r):static_lastindex(r)
end
=#

function checkbounds(::Type{Bool}, A::AbstractArray, I::StaticRange...)
    Base.@_inline_meta
    # TODO should implement static axes here, will work better with static arrays
    Base.checkbounds_indices(Bool, axes(A), I)
end

function checkbounds(::Type{Bool}, inds::AbstractArray, r::StaticRange)
    Base.@_inline_meta
    (checkindex(Bool, inds, static_first(r)) & checkindex(Bool, inds, static_last(r)))
end

function checkbounds(::Type{Bool}, inds::StaticRange, r::StaticRange)
    Base.@_inline_meta
    isempty(r) | (checkbounds(Bool, inds, static_first(r)) & checkbounds(Bool, inds, static_last(r)))
end

function checkbounds(::Type{Bool}, inds::StaticRange, r::AbstractRange)
    Base.@_propagate_inbounds_meta
    isempty(r) | (checkbounds(Bool, inds, static_first(r)) & checkbounds(Bool, inds, static_last(r)))
end

function checkbounds(::Type{Bool}, inds::StaticRange, i::SVal)
    checkindex(Bool, static_firstindex(inds), static_lastindex(inds), i)
end

function checkbounds(::Type{Bool}, inds::StaticRange, I::AbstractArray)
    Base.@_inline_meta
    b = true
    for i in I
        b &= checkindex(Bool, inds, i)
    end
    b
end


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

@pure function checkindex(::Type{Bool}, start::SVal{B,T}, stop::SVal{E,T}, i::SVal{V,Tv}) where {B,E,T,V,Tv}
    (B::T <= V::T) & (V::T <= E::T)
end

@pure function checkindex(::Type{Bool}, start::HPSVal{Tb,Hb,Lb}, stop::HPSVal{Te,He,Le}, i::SVal{V,Tv}) where {Tb,Hb,Lb,Te,He,Le,T,V,Tv}
    (T(Hb+Lb)::T <= V::T) & (V::T <= T(He+Le)::T)
end


function checkindex(::Type{Bool}, inds::StaticRange, i::Real)
    (first(inds) <= i) & (i <= last(inds))
end

checkindex(::Type{Bool}, inds::StaticRange, ::Base.Colon) = true
checkindex(::Type{Bool}, inds::StaticRange, ::Base.Slice) = true
function checkindex(::Type{Bool}, inds::AbstractRange, r::StaticRange)
    Base.@_propagate_inbounds_meta
    isempty(r) | (checkindex(Bool, inds, static_first(r)) & checkindex(Bool, inds, static_last(r)))
end

function checkindex(::Type{Bool}, inds::StaticRange, i::SVal)
    Base.@_propagate_inbounds_meta
    checkindex(Bool, static_first(inds), static_last(inds), i)
end

function checkindex(::Type{Bool}, inds::StaticRange, r::AbstractRange)
    Base.@_propagate_inbounds_meta
    isempty(r) | (checkindex(Bool, inds, static_first(r)) & checkindex(Bool, inds, static_last(r)))
end
#checkindex(::Type{Bool}, indx::AbstractUnitRange, I::AbstractVector{Bool}) = indx == axes1(I)
#checkindex(::Type{Bool}, indx::AbstractUnitRange, I::AbstractArray{Bool}) = false
function checkindex(::Type{Bool}, inds::StaticRange, I::AbstractArray)
    Base.@_inline_meta
    b = true
    for i in I
        b &= checkindex(Bool, inds, i)
    end
    b
end