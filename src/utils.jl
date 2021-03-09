
first_is_known_one(x) = first_is_known_one(typeof(x))
function first_is_known_one(::Type{R}) where {R}
    T = eltype(R)
    if T <: Number
        return known_first(R) === oneunit(T)
    else
        return false
    end
end

###
### iterate
###
# unsafe_iterate
is_range(x) = is_range(typeof(x))
is_range(::Type{T}) where {T<:AbstractRange} = true
function is_range(::Type{T}) where {T}
    if parent_type(T) <: T
        return false
    else
        return false
    end
end

checkindexlo(r, i::AbstractVector) = checkindexlo(r, minimum(i))
checkindexlo(r, i) = firstindex(r) <= i
checkindexlo(r, i::CartesianIndex{1}) = firstindex(r) <= first(i.I)

checkindexhi(r, i::AbstractVector) = checkindexhi(r, maximum(i))
checkindexhi(r, i) = lastindex(r) >= i
checkindexhi(r, i::CartesianIndex{1}) = firstindex(r) <= first(i.I)

# TODO this needs to be in base
Base.isassigned(r::AbstractRange, i::Integer) = checkindex(Bool, r, i)

###
### Generic array traits
###
# TODO This is a more trait like version of the same method from base
# (base doesn't operate on types)
has_offset_axes(::T) where {T} = has_offset_axes(T)
has_offset_axes(::Type{T}) where {T<:AbstractRange} = false
has_offset_axes(::Type{T}) where {T<:AbstractArray} = _has_offset_axes(axes_type(T))
Base.@pure function _has_offset_axes(::Type{T}) where {T<:Tuple}
    for ax_i in T.parameters
        has_offset_axes(ax_i) && return true
    end
    return false
end

