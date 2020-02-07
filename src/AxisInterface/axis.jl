"""
    Axis(k[, v=OneTo(length(k))])

Subtypes of `AbstractAxis` that maps keys to values. The first argument specifies the keys and the second specifies the values. If only one argument is specified then the values span from 1 to the length of `k`.

## Examples

```jldoctest
julia> using StaticRanges

julia> x = Axis(2.0:11.0, 1:10)
Axis(2.0:1.0:11.0 => 1:10)

julia> y = Axis(2.0:11.0)
Axis(2.0:1.0:11.0 => Base.OneTo(10))

julia> z = Axis(1:10)
Axis(1:10 => Base.OneTo(10))

julia> x[2]
2

julia> x[2] == y[2] == z[2]
true

julia> x[==(2.0)]
1
```
"""
struct Axis{K,V,Ks,Vs} <: AbstractAxis{K,V,Ks,Vs}
    _keys::Ks
    _values::Vs

    function Axis{K,V,Ks,Vs}(ks::Ks, vs::Vs, check_unique::Bool=true, check_length::Bool=true) where {K,V,Ks,Vs}
        if check_unique
            allunique(ks) || error("All keys must be unique.")
            allunique(vs) || error("All values must be unique.")
        end

        if check_length
            length(ks) == length(vs) || error("Length of keys and values must be equal, got length(keys) = $(length(ks)) and length(values) = $(length(vs)).")
        end

        eltype(Ks) <: K || error("keytype of keys and keytype do no match, got $(eltype(Ks)) and $K")
        eltype(Vs) <: V || error("valtype of values and valtype do no match, got $(eltype(Vs)) and $V")
        return new{K,V,Ks,Vs}(ks, vs)
    end
end

Base.keys(idx::Axis) = getfield(idx, :_keys)

Base.values(idx::Axis) = getfield(idx, :_values)

Axis(ks, vs, check_unique::Bool=true, check_length::Bool=true) = Axis{eltype(ks),eltype(vs),typeof(ks),typeof(vs)}(ks, vs, check_unique, check_length)

function Axis(ks, check_unique::Bool=true, check_length::Bool=false)
    if is_static(ks)
        return Axis(ks, OneToSRange(length(ks)))
    elseif is_fixed(ks)
        return Axis(ks, OneTo(length(ks)))
    else  # is_dynamic
        return Axis(ks, OneToMRange(length(ks)))
    end
end

Axis(x::Pair) = Axis(x.first, x.second)

Axis(a::AbstractAxis{K,V,Ks,Vs}) where {K,V,Ks,Vs} = Axis{K,V,Ks,Vs}(keys(a), vlaues(a))

Axis{K,V,Ks,Vs}(a::AbstractAxis) where {K,V,Ks,Vs} = Axis{K,V,Ks,Vs}(Ks(keys(a)), Vs(values(a)))

function StaticArrays.similar_type(
    ::Type{A},
    ks_type::Type=keys_type(A),
    vs_type::Type=values_type(A)
   ) where {A<:Axis}
    return Axis{eltype(ks_type),eltype(vs_type),ks_type,vs_type}
end
