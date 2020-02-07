
"""
    AbstractAxis

An `AbstractUnitRange` subtype optimized for indexing.
"""
abstract type AbstractAxis{K,V,Ks,Vs} <: AbstractVector{V} end

Base.valtype(::Type{<:AbstractAxis{K,V,Ks,Vs}}) where {K,V,Ks,Vs} = V

"""
    values_type(::AbstractAxis)
"""
values_type(::T) where {T} = values_type(T)
values_type(::Type{<:AbstractAxis{K,V,Ks,Vs}}) where {K,V,Ks,Vs} = Vs

Base.keytype(::Type{<:AbstractAxis{K}}) where {K} = K

"""
    keys_type(::AbstractAxis)
"""
keys_type(::T) where {T} = keys_type(T)
keys_type(::Type{<:AbstractAxis{K,V,Ks,Vs}}) where {K,V,Ks,Vs} = Ks

Base.size(a::AbstractAxis) = (length(a),)

###
### first
###
Base.first(a::AbstractAxis) = first(values(a))
can_set_first(::Type{T}) where {T<:AbstractAxis} = is_dynamic(T)
function set_first!(x::AbstractAxis{K,V}, val::V) where {K,V}
    can_set_first(x) || throw(MethodError(set_first!, (x, val)))
    set_first!(values(x), val)
    resize_first!(keys(x), length(values(x)))
    return x
end
function set_first(x::AbstractAxis{K,V}, val::V) where {K,V}
    vs = set_first(values(x), val)
    return similar_type(x)(resize_first(keys(x), length(vs)), vs)
end

###
### last
###
Base.last(a::AbstractAxis) = last(values(a))
can_set_last(::Type{T}) where {T<:AbstractAxis} = is_dynamic(T)
function set_last!(x::AbstractAxis{K,V}, val::V) where {K,V}
    can_set_last(x) || throw(MethodError(set_last!, (x, val)))
    set_last!(values(x), val)
    resize_last!(keys(x), length(values(x)))
    return x
end
function set_last(x::AbstractAxis{K,V}, val::V) where {K,V}
    vs = set_last(values(x), val)
    return similar_type(x)(resize_last(keys(x), length(vs)), vs)
end

###
### length
###
Base.length(a::AbstractAxis) = length(values(a))
function can_set_length(::Type{T}) where {T<:AbstractAxis}
    return can_set_length(keys_type(T)) & can_set_length(values_type(T))
end
function set_length!(a::AbstractAxis, len::Int)
    can_set_length(a) || error("Cannot use set_length! for instances of typeof $(typeof(a)).")
    set_length!(keys(a), len)
    set_length!(values(a), len)
    return a
end
function set_length(a::AbstractAxis, len::Int)
    return similar_type(a)(set_length(keys(a), len), set_length(values(a), len))
end

Base.step(a::AbstractAxis) = step(values(a))

Base.step_hp(a::AbstractAxis) = step_hp(values(a))

Base.firstindex(a::AbstractAxis) = firstindex(values(a))

Base.lastindex(a::AbstractAxis) = lastindex(values(a))

Base.haskey(a::AbstractAxis{K}, key::K) where {K} = key in keys(a)

Base.allunique(a::AbstractAxis) = true

Base.isempty(a::AbstractAxis) = isempty(values(a))

Base.in(x, a::AbstractAxis) = in(x, values(a))

Base.eachindex(a::AbstractAxis) = eachindex(values(a))

function StaticArrays.similar_type(
    ::A,
    ks_type::Type=keys_type(A),
    vs_type::Type=values_type(A)
   ) where {A<:AbstractAxis}
    return similar_type(A, ks_type, vs_type)
end

Base.convert(::Type{T}, a::T) where {T<:AbstractAxis} = a
Base.convert(::Type{T}, a) where {T<:AbstractAxis} = T(a)

###
### checkbounds
###
Base.checkbounds(a::AbstractAxis, i) = checkbounds(Bool, a, i)
Base.checkbounds(::Type{Bool}, a::AbstractAxis, i) = checkindex(Bool, a, i)
Base.checkbounds(::Type{Bool}, a::AbstractAxis, i::CartesianIndex{1}) = checkindex(Bool, a, first(i.I))
function Base.checkindex(::Type{Bool}, a::AbstractAxis, i)
    return checkindexlo(a, i) & checkindexhi(a, i)
    #return _checkindex(index_by(inds, i), inds, i)
end

###
### pop
###
StaticArrays.pop(x::AbstractAxis) = similar_type(typeof(x))(pop(keys(x)), pop(values(x)))

StaticArrays.popfirst(x::AbstractAxis) = similar_type(typeof(x))(popfirst(keys(x)), popfirst(values(x)))

function Base.pop!(a::AbstractAxis)
    can_set_last(a) || error("Cannot change size of index of type $(typeof(a)).")
    pop!(keys(a))
    return pop!(values(a))
end

function Base.popfirst!(a::AbstractAxis)
    can_set_first(a) || error("Cannot change size of index of type $(typeof(a)).")
    popfirst!(keys(a))
    return popfirst!(values(a))
end
###
### show
###
function Base.show(io::IO, ::MIME"text/plain", a::AbstractAxis)
    print(io, "$(typeof(a).name)($(keys(a)) => $(values(a)))")
end

function Base.show(io::IO, a::AbstractAxis)
    print(io, "$(typeof(a).name)($(keys(a)) => $(values(a)))")
end

###
### operators
###

Base.sum(x::AbstractAxis) = sum(values(x))

###
### iterators
###
Base.pairs(a::AbstractAxis) = Base.Iterators.Pairs(a, keys(a))

check_iterate(r::AbstractAxis, i) = check_iterate(values(r), last(i))

Base.collect(a::AbstractAxis) = collect(values(a))
