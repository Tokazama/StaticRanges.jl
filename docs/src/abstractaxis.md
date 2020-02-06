# AbstractAxis

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

