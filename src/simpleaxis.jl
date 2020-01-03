"""
    SimpleAxis
"""
struct SimpleAxis{name,V,Vs<:AbstractUnitRange{V}} <: AbstractAxis{name,V,V,Vs,Vs}
    _kv::Vs
end

Base.values(si::SimpleAxis) = getfield(si, :_kv)
Base.keys(si::SimpleAxis) = getfield(si, :_kv)

SimpleAxis(vs) = SimpleAxis{nothing}(vs)
SimpleAxis{name}(vs) where {name} = SimpleAxis{name,eltype(vs),typeof(vs)}(vs)

function SimpleAxis{name,V,Vs}(idx::AbstractAxis) where {name,V,Vs}
    return SimpleAxis{name,V,Vs}(Vs(values(idx)))
end

# This is a bit tricky b/c it requires that we permit both the keys and vals
# to be set in order to have the same format as other AbstractAxis constructors
function StaticArrays.similar_type(
    ::Type{A},
    ks_type::Type=keys_type(A),
    vs_type::Type=values_type(A)
   ) where {A<:SimpleAxis}
    return SimpleAxis{axis_names(A),eltype(vs_type),vs_type}
end


###
### Traits
###
index_by(a::SimpleAxis{name,K}, i::K) where {name,K<:Integer} = ByValue
index_by(a::SimpleAxis{name,K}, i::AbstractVector{K}) where {name,K<:Integer} = ByValue
index_by(a::SimpleAxis{name,K}, i::I) where {name,K,I<:Integer} = ByValue
index_by(a::SimpleAxis{name,K}, i::AbstractVector{I}) where {name,K,I<:Integer} = ByValue

