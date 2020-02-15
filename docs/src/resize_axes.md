# Resizing Axes

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
