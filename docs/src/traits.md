# Traits

## Comparing Static, Mutable, and Immutable Types

The difference between each type of range is conceptualized as "static", "fixed", or "dynamic".
```@docs
StaticRanges.is_dynamic
StaticRanges.is_static
StaticRanges.is_fixed

StaticRanges.as_dynamic
StaticRanges.as_static
StaticRanges.as_fixed
```

## Order traits

The following traits are used to conveniently characterize the order of ranges.
```@docs
StaticRanges.is_forward
StaticRanges.is_reverse
StaticRanges.order
StaticRanges.is_ordered
StaticRanges.is_before
StaticRanges.is_after
StaticRanges.is_contiguous
```

## Other Traits

```@docs
StaticRanges.axes_type
```
