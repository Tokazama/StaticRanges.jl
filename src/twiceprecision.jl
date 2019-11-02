"""
    TPVal{T,H,L}

A static parametrized counterpart to the `TwicePrecision` type. Any instance
of `TPVal` should be converted to `TwicePrecision` as soon as it is not serving
as a parametric storage type.
"""
struct TPVal{T,H,L} end

"""
    gethi(x::Union{TPVal{T}, TwicePrecision{T}}) -> T

Returns the `hi` component of a twice precision number. Works for both
statically set `TPVal` and `TwicePrecision`.
"""
@inline gethi(::T) where {T<:TPVal} = gethi(T)
Base.@pure gethi(::Type{<:TPVal{T,H,L}}) where {T,H,L} = H::T
gethi(x::TwicePrecision) = getfield(x, :hi)

"""
    getlo(x::Union{TPVal{T}, TwicePrecision{T}}) -> T

Returns the `lo` component of a twice precision number. Works for both
statically set `TPVal` and `TwicePrecision`.
"""
@inline getlo(::T) where {T<:TPVal} = getlo(T)
Base.@pure getlo(::Type{<:TPVal{T,H,L}}) where {T,H,L} = L::T
getlo(x::TwicePrecision) = getfield(x, :lo)

Base.eltype(::TPVal{T,H,L}) where {T,H,L} = T
Base.eltype(::Type{<:TPVal{T,H,L}}) where {T,H,L} = T

TPVal(x::TwicePrecision{T}) where {T} = TPVal{T}(x)
TPVal{T}(x::TwicePrecision) where {T} = TPVal{T,T(gethi(x)),T(getlo(x))}()
TPVal{T}(x::TwicePrecision{T}) where {T} = TPVal{T,gethi(x),getlo(x)}()

Base.TwicePrecision(x::TPVal) = TwicePrecision(gethi(x), getlo(x))

@inline (::Type{T})(x::TPVal) where {T<:Number} = T(gethi(x) + getlo(x))::T

function Base.convert(::Type{TwicePrecision{T}}, x::TPVal{T}) where {T}
    return TwicePrecision{T}(gethi(x), getlo(x))
end
function Base.convert(::Type{TwicePrecision{T}}, x::TPVal) where {T}
    return TwicePrecision{T}(convert(T, gethi(x)), convert(T, getlo(x)))
end
Base.convert(::Type{T}, x::TPVal) where {T<:Number} = T(x)

# hacky catch for converting TwicePrecision to TPVal for static parameters
tp2val(x::TwicePrecision{T}) where {T} = TPVal{T}(x)
tp2val(x) = x
