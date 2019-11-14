values_type(::T) where {T} = values_type(T)
values_type(::Type{T}) where {T} = T

keys_type(::T) where {T<:AbstractVector} = LinearIndices{1,Tuple{Base.OneTo{Int64}}}
keys_type(x::T) where {T} = typeof(keys(x))

key_continuity(::T) where {T} = Continuity(keys_type(T))
key_continuity(::Type{T}) where {T} = Continuity(keys_type(T))

function is_index(x::T, u::Uniqueness=NotUnique) where {T}
    return _is_index(x, _index_like_keys(x, _all_unique(Uniqueness(keys_type(T)), u)), values_type(T))
end

_index_like_keys(x, ::NotUniqueTrait) = NotUnique
_index_like_keys(x, ::AllUniqueTrait) = AllUnique
_index_like_keys(x, ::UnkownUniqueTrait) = allunique(keys(x)) ? AllUnique : NotUnique

_is_index(x, ::AllUniqueTrait, ::Vs) where {Ks,Vs<:AbstractUnitRange} = true
_is_index(x, ::NotUniqueTrait, ::Vs) where {Ks,Vs<:AbstractUnitRange} = false
_is_index(x, ::Ks, ::Vs) where {Ks,Vs} = false

"""
    Index
"""
struct Index{K,Ks,Vs} <: AbstractUnitRange{Int}
    _keys::Ks
    _values::Vs


    function Index{K,Ks,Vs}(ks::Ks, vs::Vs, u::Uniqueness, length_checked::Bool) where {K,Ks<:AbstractVector{K},Vs}
        if length_checked
            if all_unique(ks, u)
                return new{K,Ks,Vs}(ks, vs)
            else
                error("All keys must be unique.")
            end
        else
            if length(ks) != length(vs)
                error("The keys and values must be of the same length, got
                      length(keys) = $(length(ks)), length(values) = $(values(ks)).")
            else
                return new{K,Ks,Vs}(ks, vs)
            end
        end
    end
end

Base.keys(idx::Index) = getfield(idx, :_keys)

Base.values(idx::Index) = getindex(idx, :_values)

keys_type(::Type{Index{K,Ks,Vs}}) where {K,Ks,Vs} = Ks
values_type(::Type{Index{K,Ks,Vs}}) where {K,Ks,Vs} = Vs

