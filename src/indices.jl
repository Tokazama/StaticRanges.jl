"""
    Indices
"""
struct Indices{name,K,V,Ks,Vs} <: AbstractIndices{name,K,V,Ks,Vs}
    _keys::Ks
    _values::Vs

    function Indices{name,K,V,Ks,Vs}(ks::Ks, vs::Vs, uc::Uniqueness, lc::AbstractLengthCheck) where {name,K,V,Ks,Vs}
        check_index_length(ks, vs, lc)
        check_index_uniqueness(ks, uc)
        eltype(Ks) <: K || error("keytype of keys and keytype do no match, got $(eltype(Ks)) and $K")
        eltype(Vs) <: V || error("valtype of values and valtype do no match, got $(eltype(Vs)) and $V")
        return new{name,K,V,Ks,Vs}(ks, vs)
    end
end

Base.keys(idx::Indices) = getfield(idx, :_keys)

Base.values(idx::Indices) = getfield(idx, :_values)

function Base.setproperty!(idx::Indices{name,K,V,Ks,Vs}, p::Symbol, val) where {name,K,V,Ks,Vs}
    if is_dynamic(idx)
        if p === :keys
            if val isa Ks
                if length(val) == length(idx)
                    return setfield!(idx, :_keys, val)
                else
                    error("`val` must be the same length as the provided index.")
                end
            else
                return setproperty!(idx, p, convert(Ks, val))
            end
        elseif p === :values
            if val isa Vs
                if length(val) == length(idx)
                    return setfield!(idx, :_values, val)
                else
                    error("`val` must be the same length as the provided index.")
                end
            else
                return setproperty!(idx, p, convert(Vs, val))
            end
        else
            error("No property named $p.")
        end
    else
        error("The keys and values of an Indices must be mutable to use `setproperty!`, got $(typeof(idx)).")
    end
end

###
### Constructors
###
function Indices{name,K,V,Ks,Vs}(
    ks::Ks2,
    vs::Vs2,
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   ) where {name,K,V,Ks,Vs,Ks2,Vs2}
    return Indices{name}(Ks(ks), Vs(vs), uc, lc)
end

function Indices(ks, uc::Uniqueness=UnkownUnique)
    if is_static(ks)
        return Indices(ks, OneToSRange(length(ks)), uc, LengthChecked)
    elseif is_fixed(ks)
        return Indices(ks, OneTo(length(ks)), uc, LengthChecked)
    else
        return Indices(ks, OneToMRange(length(ks)), uc, LengthChecked)
    end
end

function Indices{name}(ks, uc::Uniqueness=UnkownUnique) where {name}
    if is_static(ks)
        return Indices{name}(ks, OneToSRange(length(ks)), uc, LengthChecked)
    elseif is_fixed(ks)
        return Indices{name}(ks, OneTo(length(ks)), uc, LengthChecked)
    else
        return Indices{name}(ks, OneToMRange(length(ks)), uc, LengthChecked)
    end
end

function Indices(
    ks::AbstractVector,
    vs::AbstractUnitRange{Int},
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   )
    return Indices{nothing}(ks, vs, uc, lc)
end

function Indices{name}(
    ks,
    vs::AbstractUnitRange{Int},
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   ) where {name}
    return Indices{name,eltype(ks)}(ks, vs, uc, lc)
end

function Indices{name,K}(
    ks::Ks,
    vs::AbstractUnitRange{V},
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   ) where {name,K,V,Ks}
    return Indices{name,K,V,Ks}(ks, vs, uc, lc)
end

function Indices{name,K,V,Ks}(
    ks::Ks,
    vs::AbstractUnitRange{V},
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   ) where {name,K,V,Ks}
    return Indices{name,K,V,Ks,typeof(vs)}(ks, vs, uc, lc)
end

function Indices(
    ks::AbstractIndices,
    vs::AbstractUnitRange,
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   )
    return Indices{indnames(ks)}(keys(ks), vs, uc, lc)
end

#function Indices{name1,K,V,Ks,Vs}(idx::Indices) where {name1,name2,K,V,Ks,Vs}
#    return Indices{}()
#end

Indices(idx::Indices) = Indices(keys(idx), values(idx), AllUnique, LengthChecked)

###
### Interface
###

function StaticArrays.similar_type(
    idx::Indices{name},
    ks_type::Type=keys_type(idx),
    vs_type::Type=values_type(idx)
   ) where {name}
    return Indices{name,eltype(ks_type),eltype(vs_type),ks_type,vs_type}
end

# TODO: is this the best fall back for and AbstractIndices?
AbstractIndices(x) = Indices(x)

"""
    Index{name,K,V}
"""
struct Index{name,K,V} <: AbstractIndex{name,K,V}
    key::K
    value::V

    Index{name,K,V}(k::K, v::V) where {name,K,V} = new{name,K,V}(k,v)
end

Index(k, v) = Index{nothing}(k, v)
Index{name}(k, v) where {name} = Index{name,typeof(k),typeof(v)}(k, v)
Index{name,K,V}(k, v) where {name,K,V<:Integer} = Index{name,K,V}(K(k),v)
Index{name,K,V}(k::K, v) where {name,K,V<:Integer} = Index{name,K,V}(k,V(v))
