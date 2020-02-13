"""
    vcat_axes(x, y) -> Tuple

Returns the appropriate axes for `vcat(x, y)`.

## Examples
```jldoctest
julia> using StaticRanges

julia> vcat_axes((Axis(1:2), Axis(1:4)), (Axis(1:2), Axis(1:4)))
(Axis(1:4 => Base.OneTo(4)), Axis(1:4 => Base.OneTo(4)))

julia> a, b = [1 2 3 4 5], [6 7 8 9 10; 11 12 13 14 15];

julia> vcat_axes(a, b) == axes(vcat(a, b))
true

julia> c, d = LinearAxes((1:1, 1:5,)), LinearAxes((1:2, 1:5));

julia> length.(vcat_axes(c, d)) == length.(vcat_axes(a, b))
true
```
"""
vcat_axes(x::AbstractArray, y::AbstractArray) = vcat_axes(axes(x), axes(y))
function vcat_axes(x::Tuple{Any,Vararg}, y::Tuple{Any,Vararg})
    return (cat_axis(first(x), first(y)), Broadcast.broadcast_shape(tail(x), tail(y))...)
end

"""
    hcat_axes(x, y) -> Tuple

Returns the appropriate axes for `hcat(x, y)`.

## Examples
```jldoctest
julia> using StaticRanges

julia> hcat_axes((Axis(1:4), Axis(1:2)), (Axis(1:4), Axis(1:2)))
(Axis(1:4 => Base.OneTo(4)), Axis(1:4 => Base.OneTo(4)))

julia> a, b = [1; 2; 3; 4; 5], [6 7; 8 9; 10 11; 12 13; 14 15];

julia> hcat_axes(a, b) == axes(hcat(a, b))
true

julia> c, d = CartesianAxes((Axis(1:5),)), CartesianAxes((Axis(1:5), Axis(1:2)));

julia> length.(hcat_axes(c, d)) == length.(hcat_axes(a, b))
true
```
"""
hcat_axes(x::AbstractArray, y::AbstractArray) = hcat_axes(axes(x), axes(y))
function hcat_axes(x::Tuple, y::Tuple)
    if length(x) > length(y)
        return (front(x)..., grow_last(last(x), 1))
    elseif length(x) < length(y)
        return (front(y)..., grow_last(last(y), 1))
    else  # length(x) == length(y)
        return (front(x)..., cat_axis(last(x), last(y)))
    end
end
function hcat_axes(x::Tuple{Any}, y::Tuple{Any})
    return (combine_axis(first(x), first(y)), SimpleAxis(OneTo(2)))
end
#=
function _hcat_axes(x::Tuple, y::Tuple)
    (front(), cat_axis(last(x), last(y)),)
    return (combine_axis(first(x), first(y)), _hcat_axes(tail(x), tail(y))...)
end
_hcat_axes(x::Tuple{Any}, y::Tuple{Any}) = (cat_axis(first(x), first(y)),)
function _hcat_axes(x::Tuple{Any}, y::Tuple{})
    ax = first(x)
    return (set_length(ax, length(ax) + 1),)
end
function _hcat_axes(x::Tuple{}, y::Tuple{Any})
    ax = first(y)
    return (set_length(ax, length(ax) + 1),)
    =#

"""
    cat_axis(x, y)

Returns the concatenation of the axes `x` and `y`. New subtypes of `AbstractAxis`
must implement a unique `cat_axis` method.
"""
cat_axis(x::Axis, y) = Axis(cat_keys(x, y), cat_values(x, y))
cat_axis(x::SimpleAxis, y) = SimpleAxis(cat_values(x, y))
cat_axis(x, y) = cat_values(x, y)

"""
    cat_keys(x, y)

Returns the appropriate keys of the `x` and `y` index within the operation `cat_axis(x, y)`

See also: [`cat_axis`](@ref)
"""
cat_keys(x, y) = _cat_keys(keys(x), y)
_cat_keys(x, y) = __cat_keys(Continuity(x), x, y)
__cat_keys(::ContinuousTrait, x, y) = set_length(x, length(x) + length(y))
__cat_keys(::DiscreteTrait, x, y) = make_unique(x, keys(y))

"""
    cat_values(x, y)

Returns the appropriate values of the `x` and `y` index within the operation `cat_axis(x, y)`

See also: [`cat_axis`](@ref)
"""
cat_values(x::AbstractAxis, y) = cat_values(values(x), y)
cat_values(x::AbstractRange, y) = set_length(x, length(x) + length(y))

#=

"""
    cat_axes(x, y, dims) -> Tuple

Returns the appropriate axes for `cat(x, y; dims)`. If any of `dims` are names
then they should refer to the dimensions of `x`.

## Examples
```jldoctest
julia> cat_axes((Axis(1:4), Axis(1:2)), (Axis(1:4), Axis(1:2)), (:a, :b))
(Axis(1:8 => Base.OneTo(8)), Axis(1:4 => Base.OneTo(4)))
```
"""
cat_axes(x::AbstractArray, y::AbstractArray; dims) = hcat_axes(axes(x), axes(y))
function cat_axes(x::Tuple, y::Tuple; dims)
    return _cat_axes(x, to_axis(x, dims), y, to_axis(y, dims))
end

(combine_axis(first(x), first(y)), vcat_axes(tail(x), tail(y))...)
function _cat_axes(x, x_axes, y, y_axes)
    for (x_i, y_i) in zip(x, y)
    end
end

__cat_axis(x, x_axes, y, y_axes)

cat_axes(x::NTuple{1,Any}, y::NTuple{1,Any}) = _cat_axes(combine_axis(first(x), first(y)))
_cat_axes(x) = (x, set_length(unname(x), 2))

cat_axes()
=#

