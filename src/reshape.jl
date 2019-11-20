"""
    reshape_indices(a, dims)
    reshape_indices(a, dims...)
"""
reshape_indices(a, dims::Integer...) = reshape_indices(a, Tuple(dims))
reshape_indices(a, dims::Tuple) = _reshape_indices(axes(a), dims)
function _reshape_indices(axs::Tuple{Any,Vararg}, dims::Tuple{Integer,Vararg})
    (reshape_index(first(axs), first(dims)), _reshape_indices(tail(axs), tail(dims))...)
end
_reshape_indices(axs::Tuple{}, dims::Tuple{}) = ()

"""
    reshape_index(a, len)
"""
reshape_index(a::AbstractUnitRange, len::Integer) = set_length(a, len)
