
"""
    filter_axes(f, a) -> Tuple

Return the axes of `a`, removing those for which `f` is false. The function `f`
is passed one argument.

```jldoctest
julia> axs = (Axis{:a}(1:10), Axis{:b}(1:10), Axis(1:10));

julia> filter_axes(x -> axis_names(x) == :a, axs)
(Axis{a}(1:10 => Base.OneTo(10)),)

julia> filter_axes(x -> length(x) == 10, axs)
(Axis{a}(1:10 => Base.OneTo(10)), Axis{b}(1:10 => Base.OneTo(10)), Axis(1:10 => Base.OneTo(10)))
```
"""
filter_axes(f::Function, x::AbstractArray) = filter_axes(f, axes(x))
filter_axes(f::Function, x::Tuple) = _filter_axes(f, x)
function _filter_axes(f, x::Tuple)
    if f(first(x))
        return (first(x), _filter_axes(f, tail(x))...)
    else
        return _filter_axes(f, tail(x))
    end
end
_filter_axes(f, ::Tuple{}) = ()

