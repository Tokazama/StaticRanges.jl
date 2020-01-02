# TODO: temporary fix while working out details in Dictionary.jl

"""
    Axis
"""
struct Axis{name,K,V,Ks,Vs} <: AbstractAxis{name,K,V,Ks,Vs}
    _keys::Ks
    _values::Vs

    function Axis{name,K,V,Ks,Vs}(ks::Ks, vs::Vs, uc::Uniqueness, lc::AbstractLengthCheck) where {name,K,V,Ks,Vs}
        check_index_length(ks, vs, lc)
        check_index_uniqueness(ks, uc)
        eltype(Ks) <: K || error("keytype of keys and keytype do no match, got $(eltype(Ks)) and $K")
        eltype(Vs) <: V || error("valtype of values and valtype do no match, got $(eltype(Vs)) and $V")
        return new{name,K,V,Ks,Vs}(ks, vs)
    end
end

Base.keys(idx::Axis) = getfield(idx, :_keys)

Base.values(idx::Axis) = getfield(idx, :_values)

function Base.setproperty!(idx::Axis{name,K,V,Ks,Vs}, p::Symbol, val) where {name,K,V,Ks,Vs}
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
        error("The keys and values of an Axis must be mutable to use `setproperty!`, got $(typeof(idx)).")
    end
end

###
### Constructors
###
function Axis{name,K,V,Ks,Vs}(
    ks::Ks2,
    vs::Vs2,
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   ) where {name,K,V,Ks,Vs,Ks2,Vs2}
    return Axis{name}(Ks(ks), Vs(vs), uc, lc)
end

function Axis(ks, uc::Uniqueness=UnkownUnique)
    if is_static(ks)
        return Axis(ks, OneToSRange(length(ks)), uc, LengthChecked)
    elseif is_fixed(ks)
        return Axis(ks, OneTo(length(ks)), uc, LengthChecked)
    else
        return Axis(ks, OneToMRange(length(ks)), uc, LengthChecked)
    end
end

function Axis{name}(ks, uc::Uniqueness=UnkownUnique) where {name}
    if is_static(ks)
        return Axis{name}(ks, OneToSRange(length(ks)), uc, LengthChecked)
    elseif is_fixed(ks)
        return Axis{name}(ks, OneTo(length(ks)), uc, LengthChecked)
    else
        return Axis{name}(ks, OneToMRange(length(ks)), uc, LengthChecked)
    end
end

function Axis(
    ks::AbstractVector,
    vs::AbstractUnitRange{Int},
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   )
    return Axis{nothing}(ks, vs, uc, lc)
end

function Axis{name}(
    ks,
    vs::AbstractUnitRange{Int},
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   ) where {name}
    return Axis{name,eltype(ks)}(ks, vs, uc, lc)
end

function Axis{name,K}(
    ks::Ks,
    vs::AbstractUnitRange{V},
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   ) where {name,K,V,Ks}
    return Axis{name,K,V,Ks}(ks, vs, uc, lc)
end

function Axis{name,K,V,Ks}(
    ks::Ks,
    vs::AbstractUnitRange{V},
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   ) where {name,K,V,Ks}
    return Axis{name,K,V,Ks,typeof(vs)}(ks, vs, uc, lc)
end

function Axis(
    ks::AbstractAxis,
    vs::AbstractUnitRange,
    uc::Uniqueness=UnkownUnique,
    lc::AbstractLengthCheck=LengthNotChecked
   )
    return Axis{indnames(ks)}(keys(ks), vs, uc, lc)
end

#function Axis{name1,K,V,Ks,Vs}(idx::Axis) where {name1,name2,K,V,Ks,Vs}
#    return Axis{}()
#end

Axis(idx::Axis) = Axis(keys(idx), values(idx), AllUnique, LengthChecked)

###
### Interface
###
function StaticArrays.similar_type(
    idx::Axis{name},
    ks_type::Type=keys_type(idx),
    vs_type::Type=values_type(idx)
   ) where {name}
    return Axis{name,eltype(ks_type),eltype(vs_type),ks_type,vs_type}
end

# TODO: is this the best fall back for and AbstractAxis?
AbstractAxis(x) = Axis(x)

#=
"""
    Index{name,K,V}
"""
struct Index{name,K,V} <: AbstractIndex{name,K,V}
    key::K
    value::V

    Index{name,K,V}(k::K, v::V) where {name,K,V<:Integer} = new{name,K,V}(k,v)
end

Base.keys(si::Index) = getfield(r, :key)
Base.values(si::Index) = getfield(r, :value)

Index(k, v) = Index{nothing}(k, v)
Index{name}(k, v) where {name} = Index{name,typeof(k),typeof(v)}(k, v)
Index{name,K,V}(k, v) where {name,K,V<:Integer} = Index{name,K,V}(K(k),v)
Index{name,K,V}(k::K, v) where {name,K,V<:Integer} = Index{name,K,V}(k,V(v))
=#
