# AbstractAxis

Currently this functionality is exerimental. If the `AbstractAxis` interface proves useful it will likely be moved to a different package.

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

But now we can also use functions to index by the the keys of an `AbstractAxis`.
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

julia> a[>(2.0) & <(8.0)]
Axis(3.0:1.0:7.0 => 2:6)
```
## Chaining filters

```@docs
StaticRanges.and
StaticRanges.or
```


## Reindexing

```@docs
StaticRanges.reindex
StaticRanges.unsafe_reindex
```
## Types

```@docs
StaticRanges.AbstractAxis
StaticRanges.Axis
StaticRanges.SimpleAxis
```

## Interface

```@docs
StaticRanges.values_type
StaticRanges.keys_type
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
StaticRanges.hcat_axes
StaticRanges.vcat_axes
StaticRanges.cat_axis
StaticRanges.cat_values
StaticRanges.cat_keys
```

## Resizing Axes

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

## Combine Indices

```@docs
StaticRanges.combine_indices
StaticRanges.combine_index
StaticRanges.combine_values
StaticRanges.combine_keys
```

