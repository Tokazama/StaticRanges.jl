"""
    drop_axes(x, dims)

Returns all axes of `x` except for those identified by `dims`. Elements of `dims`
must be unique integers or symbols corresponding to the dimensions or names of
dimensions of `x`.

## Examples
```jldoctest
julia> axs = (Axis{:a}(1:10), Axis{:b}(1:10), Axis(1:10));

julia> drop_axes(axs, :a)
(Axis{b}(1:10 => Base.OneTo(10)), Axis(1:10 => Base.OneTo(10)))

julia> drop_axes(axs, :b)
(Axis{a}(1:10 => Base.OneTo(10)), Axis(1:10 => Base.OneTo(10)))

julia> drop_axis(axs, (:a, :b))
(Axis(1:10 => Base.OneTo(10)),)
```
"""
drop_axes(x::AbstractArray, dims) = drop_axes(axes(x), dims)
drop_axes(x::Tuple, dims) = _drop_axes(x, to_axis(x, dims))

_drop_axes(x, dims::Tuple) = __drop_axes(x, dims)
_drop_axes(x, dims) = __drop_axes(x, (dims,))

function __drop_axes(axs::Tuple{Vararg{<:Any,D}}, dims::NTuple{N,Int}) where {D,N}
    for i in 1:N
        1 <= dims[i] <= D || throw(ArgumentError("dropped dims must be in range 1:ndims(A)"))
        for j = 1:i-1
            dims[j] == dims[i] && throw(ArgumentError("dropped dims must be unique"))
        end
    end
    d = ()
    for (i,axis_i) in zip(1:D,axs)
        if !in(i, dims)
            d = tuple(d..., axis_i)
        end
    end
    return d
end
