# Manipulating Ranges

There are options for in place mutations and corresponding non mutating operations. These allow safe mutation of ranges by avoiding states that are typically prohibited at time of construction. For example, `OneToMRange` cannot have a negative value for it's `stop` field. These methods are also called whenever `setproperty!` is used.

```@docs
StaticRanges.can_set_first
StaticRanges.set_first!
StaticRanges.set_first
```

```@docs
StaticRanges.can_set_step
StaticRanges.set_step!
StaticRanges.set_step
```

```@docs
StaticRanges.can_set_last
StaticRanges.set_last!
StaticRanges.set_last
```

```@docs
StaticRanges.can_set_length
StaticRanges.set_length!
StaticRanges.set_length
```
