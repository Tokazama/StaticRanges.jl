"""
    TPVal{T,H,L}

A static parametrized counterpart to the `TwicePrecision` type. Any instance
of `TPVal` should be converted to `TwicePrecision` as soon as it is not serving
as a parametric storage type.
"""
struct TPVal{T,H,L} end

@inline gethi(::T) where {T<:TPVal} = gethi(T)
Base.@pure gethi(::Type{<:TPVal{T,H,L}}) where {T,H,L} = H::T

@inline getlo(::T) where {T<:TPVal} = getlo(T)
Base.@pure getlo(::Type{<:TPVal{T,H,L}}) where {T,H,L} = L::T

Base.eltype(::TPVal{T,H,L}) where {T,H,L} = T
Base.eltype(::Type{<:TPVal{T,H,L}}) where {T,H,L} = T

Base.get(::TPVal{T,H,L}) where {T,H,L} = TwicePrecision{T}(H,L)
Base.get(::Type{<:TPVal{T,H,L}}) where {T,H,L} = TwicePrecision{T}(H,L)

@inline (::Type{T})(x::TPVal) where {T<:Number} = T(gethi(x) + getlo(x))::T

Base.convert(::Type{<:TPVal{T}}, x::TPVal{T}) where {T} = x
function Base.convert(::Type{<:TPVal{T}}, x::TPVal) where {T}
    return TPVal{T,convert(T, gethi(x)), convert(T, getlo(x))}()
end

Base.convert(::Type{T}, x::TPVal) where {T<:Number} = T(x)

function Base.convert(::Type{TwicePrecision{T}}, x::TPVal{T}) where {T}
    return TwicePrecision{T}(gethi(x), getlo(x))
end
function Base.convert(::Type{TwicePrecision{T}}, x::TPVal) where {T}
    return TwicePrecision{T}(convert(T, gethi(x)), convert(T, getlo(x)))
end

# hacky catch for converting TwicePrecision to TPVal for static parameters
tp2val(x::TwicePrecision{T}) where {T} = TPVal{T,x.hi,x.lo}()
tp2val(x) = x
