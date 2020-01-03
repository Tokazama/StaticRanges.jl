"""
    matmul_axes(a, b) -> Tuple

Returns the appropriate axes for the return of `a * b` where `a` and `b` are a
vector or matrix.

## Examples
```jldoctest
julia> axs2, axs1 = (Axis{:b}(1:10), Axis(1:10)), (Axis{:a}(1:10),);

julia> matmul_axes(axs2, axs2)
(Axis{b}(1:10 => Base.OneTo(10)), Axis(1:10 => Base.OneTo(10)))

julia> matmul_axes(axs1, axs2)
(Axis{a}(1:10 => Base.OneTo(10)), Axis(1:10 => Base.OneTo(10)))

julia> matmul_axes(axs2, axs1)
(Axis{b}(1:10 => Base.OneTo(10)),)

julia> matmul_axes(axs1, axs1)
()
```
"""
matmul_axes(a::AbstractArray,  b::AbstractArray ) = matmul_axes(indices(a), indices(b))
matmul_axes(a::Tuple{Any},     b::Tuple{Any,Any}) = (first(a), last(b))
matmul_axes(a::Tuple{Any,Any}, b::Tuple{Any,Any}) = (first(a), last(b))
matmul_axes(a::Tuple{Any,Any}, b::Tuple{Any}    ) = (first(a),)
matmul_axes(a::Tuple{Any},     b::Tuple{Any}    ) = ()

"""
    inverse_axes(a::AbstractMatrix) = inverse_axes(axes(a))
    inverse_axes(a::Tuple{I1,I2}) -> Tuple{I2,I1}

Returns the inverted axes of `a`, corresponding to the `inv` method from the 
`LinearAlgebra` package in the standard library.

## Examples
```jldoctest
julia> inverse_axes((Axis{:a}(1:4), Axis{:b}(1:4)))
(Axis{b}(1:4 => Base.OneTo(4)), Axis{a}(1:4 => Base.OneTo(4)))
```
"""
inverse_axes(x::AbstractMatrix) = inverse_axes(axes(x))
inverse_axes(x::Tuple{I1,I2}) where {I1,I2} = (last(x), first(x))

"""
    covcor_axes(x, dim) -> NTuple{2}

Returns appropriate axes for a `cov` or `var` method on array `x`.

## Examples
```jldoctest
julia> covcor_axes((Axis{:a}(1:4), Axis{:b}(1:4)), 2)
(Axis{a}(1:4 => Base.OneTo(4)), Axis{a}(1:4 => Base.OneTo(4)))

julia> covcor_axes((Axis{:a}(1:4), Axis{:b}(1:4)), :b)
(Axis{a}(1:4 => Base.OneTo(4)), Axis{a}(1:4 => Base.OneTo(4)))

julia> covcor_axes((Axis{:a}(1:4), Axis{:b}(1:4)), 1)
(Axis{b}(1:4 => Base.OneTo(4)), Axis{b}(1:4 => Base.OneTo(4)))

julia> covcor_axes((Axis{:a}(1:4), Axis{:b}(1:4)), :a)
(Axis{b}(1:4 => Base.OneTo(4)), Axis{b}(1:4 => Base.OneTo(4)))
```
"""
covcor_axes(x::AbstractMatrix, dim) = _covcor_axes(axes(x), to_axis(x, dim))
covcor_axes(x::NTuple{2,Any}, dim) = _covcor_axes(x, to_axis(x, dim))
_covcor_axes(x::NTuple{2,Any}, dim::Int) = dim === 1 ? (x[2], x[2]) : (x[1], x[1])
