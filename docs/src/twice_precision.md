# Twice Precision

A number of operations on ranges depend on the internal type `Base.TwicePrecision`. This requires some unique handling for static ranges. This package has a limited number of methods that exist for consistency with base and easier readability when manipulating twice precision values internally. It's unlikely users should ever need to use these methods (or even know about them) but there's some minimal documentation included in case one should ever be so unfortunate to need to become aware of their existence.

```@docs
StaticRanges.gethi
StaticRanges.getlo
StaticRanges.stephi
StaticRanges.steplo
StaticRanges.refhi
StaticRanges.reflo
StaticRanges.set_ref!
StaticRanges.set_offset!
```

