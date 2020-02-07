# Range Types

## Static Ranges

```@docs
StaticRanges.OneToSRange
StaticRanges.UnitSRange
StaticRanges.LinSRange
StaticRanges.StepSRange
StaticRanges.StepSRangeLen
```

## Mutable Ranges

```@docs
StaticRanges.OneToMRange
StaticRanges.UnitMRange
StaticRanges.LinMRange
StaticRanges.StepMRange
StaticRanges.StepMRangeLen
```

## Abstract Ranges

```@docs
StaticRanges.OneToRange
StaticRanges.AbstractLinRange
StaticRanges.AbstractStepRangeLen
StaticRanges.AbstractStepRange
```

## Special Ranges

```@docs
StaticRanges.GapRange
```

## Manipulating Ranges

There are options for in place mutations and corresponding non mutationg operations. These allow safe mutation of ranges by avoiding states that are typically prohibited at time of construction. For example, `OneToMRange` cannot have a negative value for it's `stop` field. These methods are also called whenever `setproperty!` is used.

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

