"""
    SimpleIndices
"""
struct SimpleIndices{name,V,Vs<:AbstractUnitRange{V}} <: AbstractIndices{name,V,V,Vs,Vs}
    _kv::Vs
end

Base.values(si::SimpleIndices) = getfield(si, :_kv)
Base.keys(si::SimpleIndices) = getfield(si, :_kv)

###
### Constructors
###
SimpleIndices(vs) = SimpleIndices{nothing}(vs)
SimpleIndices{name}(vs) where {name} = SimpleIndices{name,eltype(vs),typeof(vs)}(vs)


###
### Traits
###

index_by(a::SimpleIndices{name,K}, i::K) where {name,K<:Integer} = ByValue
index_by(a::SimpleIndices{name,K}, i::AbstractVector{K}) where {name,K<:Integer} = ByValue
index_by(a::SimpleIndices{name,K}, i::I) where {name,K,I<:Integer} = ByValue
index_by(a::SimpleIndices{name,K}, i::AbstractVector{I}) where {name,K,I<:Integer} = ByValue

"""
    SimpleIndex{name,V}
"""
struct SimpleIndex{name,V} <: AbstractIndex{name,V,V}
    value::V

    SimpleIndex{name,V}(v::V) where {name,V} = new{name,V}(v)
end

SimpleIndex(v) = SimpleIndex{nothing}(v)
SimpleIndex{name}(v::V) where {name,V<:Integer} = SimpleIndex{name,V}(v)
SimpleIndex{name,V}(v) where {name,V<:Integer} = SimpleIndex{name,V}(V(v))

function Base.:+(x::SimpleIndex{name1,V1}, y::SimpleIndex{name1,V1}) where {name1,V1,name2,V2}
    return SimpleIndex{combine_names(name1, name2)}(values(x) + values(y))
end
