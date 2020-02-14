# AbstractAxis

## Indexing

The standard syntax for indexing doesn't change at all.
```jldoctest
julia> using StaticRanges

julia> sa = SimpleAxis(1:10)
SimpleAxis(1:10)

julia> sa[2]
2

julia> sa[>(2)]
SimpleAxis(3:10)

julia> a = Axis(1:10)
Axis(1:10 => Base.OneTo(10))

julia> a[2]
2

julia> a[2:3]
Axis(2:3 => 2:3)
```

But now we can also use functions to index by the keys of an `AbstractAxis`.
```jldoctest
julia> using StaticRanges

julia> a = Axis(2.0:11.0, 1:10)
Axis(2.0:1.0:11.0 => 1:10)

julia> a[1]
1

julia> a[isequal(2.0)]
1

julia> a[>(2)]
Axis(3.0:1.0:11.0 => 2:10)

julia> a[>(2.0)]
Axis(3.0:1.0:11.0 => 2:10)

julia> a[and(>(2.0), <(8.0))]
Axis(3.0:1.0:7.0 => 2:6)
```

## Benchmarks

Indexing `CartesianAxes` is comparable to that of `CartesianIndices`
```julia
julia> using StaticRanges, BenchmarkTools

julia> cartaxes = CartesianAxes((Axis(2.0:5.0), Axis(1:4)));

julia> cartinds = CartesianIndices((1:4, 1:4));

julia> @btime getindex(cartaxes, 2, 2)
  20.848 ns (1 allocation: 32 bytes)
CartesianIndex(2, 2)

julia> @btime getindex(cartinds, 2, 2)
  22.317 ns (1 allocation: 32 bytes)
CartesianIndex(2, 2)

julia> @btime getindex(cartaxes, ==(3.0), 2)
  444.374 ns (7 allocations: 416 bytes)
CartesianIndex(2, 2)

```

Indexing `LinearAxes` is comparable to that of `LinearIndices`
```julia
julia> using StaticRanges, BenchmarkTools

julia> linaxes = LinearAxes((Axis(1.0:4.0), Axis(1:4)));

julia> lininds = LinearIndices((1:4, 1:4));

julia> @btime getindex(linaxes, 2, 2)
  18.275 ns (0 allocations: 0 bytes)
6

julia> @btime getindex(lininds, 2, 2)
  18.849 ns (0 allocations: 0 bytes)
6

julia> @btime getindex(linaxes, ==(3.0), 2)
  381.098 ns (6 allocations: 384 bytes)
7
```

## Chaining filters

```@docs
StaticRanges.and
StaticRanges.or
```

## Types

```@docs
StaticRanges.AbstractAxis
StaticRanges.Axis
StaticRanges.SimpleAxis
StaticRanges.CartesianAxes
StaticRanges.LinearAxes
```

## AbstractAxis Interface

The majority of the `AbstractAxis` interface is already present in Julia, but we provide several methods to gather type information.

```@docs
StaticRanges.values_type
StaticRanges.keys_type
```

## Reindexing

```@docs
StaticRanges.reindex
StaticRanges.unsafe_reindex
```

## Swapping Axes

```@docs
StaticRanges.drop_axes
StaticRanges.permute_axes
StaticRanges.reduce_axes
StaticRanges.reduce_axis
```

## Matrix Multiplication and Axes

```@docs
StaticRanges.matmul_axes
StaticRanges.inverse_axes
StaticRanges.covcor_axes
```

## Appending Axes

```@docs
StaticRanges.append_axes
StaticRanges.append_axes!
StaticRanges.append_keys
StaticRanges.append_values
StaticRanges.append_axis
StaticRanges.append_axis!
```

## Concatenating Axes

```@docs
StaticRanges.cat_axes
StaticRanges.hcat_axes
StaticRanges.vcat_axes
StaticRanges.cat_axis
StaticRanges.cat_values
StaticRanges.cat_keys
```

## Resizing Axes

These methods help with operations that need to resize axes, either dynamically or by creating a new instance of an axis. In addition to helping with operations related to array resizing, these may be useful for managing the axis of a vector throughout a `push!`, `pushfirst!`, `pop`, and `popfirst!` operation.

```@docs
StaticRanges.resize_first
StaticRanges.resize_first!
StaticRanges.resize_last
StaticRanges.resize_last!

StaticRanges.grow_first
StaticRanges.grow_first!
StaticRanges.grow_last
StaticRanges.grow_last!

StaticRanges.shrink_first
StaticRanges.shrink_first!
StaticRanges.shrink_last
StaticRanges.shrink_last!

StaticRanges.next_type
StaticRanges.prev_type
```

## Combine Axes

These methods are responsible for assisting in broadcasting operations.

```@docs
StaticRanges.combine_axis
StaticRanges.combine_values
StaticRanges.combine_keys
```

