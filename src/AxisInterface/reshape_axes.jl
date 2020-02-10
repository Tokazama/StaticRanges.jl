# this replaces a Colon by div(size(Array), prod(other dims))
function _to_newdims(x::Tuple, dims::Tuple{Vararg{Union{Colon,Integer}}})
    return __to_newdims(axes2length(x), dims)
end
_to_newdims(x::Tuple, dims::Tuple{Vararg{Integer}}) = dims

function __to_newdims(x::Int, dims::Tuple{Colon,Vararg{Any}})
    return (div(x, prod(tail(dims))), tail(dims)...)
end
function __to_newdims(x::Int, dims::Tuple{Integer,Vararg{Any}})
    f = first(dims)
    return (f, __to_newdims(x, f, tail(dims))...)
end
function __to_newdims(x::Int, val::Int, dims::Tuple{Integer,Vararg{Any}})
    f = first(dims)
    return (f, __to_newdims(x, val * f, tail(dims))...)
end
function __to_newdims(x::Int, val::Int, dims::Tuple{Colon,Vararg{Any}})
    return (newval, div(x, prod(tail(dims)) * val), tail(dims)...)
end
__to_newdims(x::Int, val::Int, dims::Tuple{Colon}) = (div(x, val),)

# FIXME reshape_axes
"""
    reshape_axes(a, dims)
    reshape_axes(a, dims...)

## Examples
```julia
julia> using StaticRanges

julia> A = Vector(1:16);

julia> axs = (Axis(1:10), Axis(1:10), Axis(1:10));
```
"""
reshape_axes(x::AbstractArray, dims...) = reshape_axes(x, Tuple(dims))
reshape_axes(x::Tuple, dims...) = reshape_axes(x, Tuple(dims))

reshape_axes(x::AbstractArray, dims::Tuple) = reshape_axes(axes(x), dims)
reshape_axes(x::Tuple, dims::Tuple) = _reshape_axes(x, _to_newdims(x, dims))

function _reshape_axes(axs::Tuple{Any,Vararg}, dims::Tuple{Integer,Vararg})
    (reshape_axis(first(axs), first(dims)), _reshape_axes(tail(axs), tail(dims))...)
end
_reshape_axes(axs::Tuple{}, dims::Tuple{}) = ()

"""
    reshape_axis(x::AbstractUnitRange, len) -> AbstractUnitRange

Returns an axis of the same type as `x` and length `len`.
"""
reshape_axis(x, len) = set_length(x, len)

"""
    resize_axis!(x::AbstractUnitRange, len) -> x

Returns `x` resized to the same length as `len`.
"""
resize_axis!(x, len) = (set_length!(x, len); return x)
