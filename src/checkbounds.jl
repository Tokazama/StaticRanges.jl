#=
function checkbounds(::Type{Bool}, A::AbstractArray, I::AbstractSRange...)
    Base.@_inline_meta
    # TODO should implement static axes here, will work better with static arrays
    Base.checkbounds_indices(Bool, axes(A), I)
end
=#

function checkbounds(A::AbstractSRange, I::SVal...)
    Base.@_inline_meta
    checkbounds(Bool, A, I...) || Base.throw_boundserror(A, get.(I))
    nothing
end

function checkbounds(::Type{Bool}, inds::AbstractArray, r::AbstractSRange)
    Base.@_inline_meta
    (checkindex(Bool, inds, sfirst(r)) & checkindex(Bool, inds, slast(r)))
end

function checkbounds(::Type{Bool}, inds::AbstractSRange, r::AbstractSRange)
    Base.@_propagate_inbounds_meta
    isempty(r) | (checkbounds(Bool, inds, sfirst(r)) & checkbounds(Bool, inds, slast(r)))
end

function checkbounds(::Type{Bool}, inds::AbstractSRange, i::SVal)
    checkindex(Bool, sfirstindex(inds), slastindex(inds), i)
end

checkbounds(::Type{Bool}, inds::AbstractSRange, i::Integer) =
    checkindex(Bool, sfirstindex(inds), slastindex(inds), i)

function checkbounds(::Type{Bool}, inds::AbstractSRange{T,SVal{L}}, I::AbstractArray{T2,N}) where {T,L,T2,N}
    Base.@_inline_meta
    b = true
    for i in I
        b &= checkindex(Bool, inds, i)
    end
    b
end

@pure checkindex(::Type{Bool}, start::SVal{B,T}, stop::SVal{E,T}, i::SVal{V,Tv}) where {B,E,T,V,Tv} =
    (B::T <= V::T) & (V::T <= E::T)

@pure checkindex(::Type{Bool}, start::HPSVal{Tb,Hb,Lb}, stop::HPSVal{Te,He,Le}, i::SVal{V,Tv}) where {Tb,Hb,Lb,Te,He,Le,T,V,Tv} =
    (T(Hb+Lb)::T <= V::T) & (V::T <= T(He+Le)::T)

checkindex(::Type{Bool}, inds::AbstractSRange, i::Real) =
    (first(inds) <= i) & (i <= last(inds))

checkindex(::Type{Bool}, inds::AbstractSRange, ::Base.Colon) = true

checkindex(::Type{Bool}, inds::AbstractSRange, ::Base.Slice) = true

function checkindex(::Type{Bool}, inds::AbstractRange, r::AbstractSRange)
    Base.@_propagate_inbounds_meta
    isempty(r) | (checkindex(Bool, inds, sfirst(r)) & checkindex(Bool, inds, slast(r)))
end

function checkindex(::Type{Bool}, inds::AbstractSRange, i::SVal)
    Base.@_propagate_inbounds_meta
    checkindex(Bool, sfirst(inds), slast(inds), i)
end

function checkindex(::Type{Bool}, inds::AbstractSRange, r::AbstractRange)
    Base.@_propagate_inbounds_meta
    isempty(r) | (checkindex(Bool, inds, sfirst(r)) & checkindex(Bool, inds, slast(r)))
end

#checkindex(::Type{Bool}, indx::AbstractUnitRange, I::AbstractVector{Bool}) = indx == axes1(I)
#checkindex(::Type{Bool}, indx::AbstractUnitRange, I::AbstractArray{Bool}) = false
