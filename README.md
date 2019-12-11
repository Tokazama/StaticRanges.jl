# StaticRanges

[![Build Status](https://travis-ci.com/Tokazama/StaticRanges.jl.svg?branch=master)](https://travis-ci.com/Tokazama/StaticRanges.jl)

[![codecov](https://codecov.io/gh/Tokazama/StaticRanges.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/Tokazama/StaticRanges.jl)

## Introduction

StaticRanges was originally inspired by [StaticArrays](https://github.com/JuliaArrays/StaticArrays.jl).
It's objectives are:

1. Easy/intuitive composition of mutable and static ranges: The utility of static and mutable ranges is not fully realized in this package (although there are performance gains offered by using statically defined ranges). This objective is more fully realized in the [AbstractIndices](https://github.com/Tokazama/AbstractIndices.jl) package.
2. Optimized methods involving ranges: "find" methods are currently the focus and optimizations currently exist for `findall`, `findfirst`, `findlast`, `filter`, and `count` using the `<`, `<=`, `>`, `>=`, `==`, and `!=` operators.

## New Types

Most subtypes of `AbstractRange` present in `Base` have counterparts implemented here.
```julia
using StaticRanges
using Base: OneTo

julia> mot = OneToMRange(10)
OneToMRange(10)

julia> fot = OneTo(10)
Base.OneTo(10)

julia> sot = OneToSRange(10)
OneToSRange(10)

julia> umr = UnitMRange(1, 10)
UnitMRange(1:10)

julia> ufr = UnitRange(1, 10)
1:10

julia> usr = UnitSRange(1, 10)
UnitSRange(1:10)

julia> smr = StepMRange(1, 2, 20)
StepMRange(1:2:19)

julia> sfr = StepRange(1, 2, 20)
1:2:19

julia> ssr = StepSRange(1, 2, 20)
StepSRange(1:2:19)

julia> smrl = mrange(1.0, step=2.0, stop=20.0)
StepMRangeLen(1.0:2.0:19.0)

julia> sfrl = range(1.0, step=2.0, stop=20.0)
1.0:2.0:19.0

julia> ssrl = srange(1.0, step=2.0, stop=20.0)
StepSRangeLen(1.0:2.0:19.0)

julia> lmr = LinMRange(1, 20, 10)
LinMRange(1.0, stop=20.0, length=10)

julia> lfr = LinRange(1, 20, 10)
10-element LinRange{Float64}:
 1.0,3.11111,5.22222,7.33333,9.44444,11.5556,13.6667,15.7778,17.8889,20.0

julia> lsr = LinSRange(1, 20, 10)
LinSRange(1.0, stop=20.0, length=10)
```

The difference between each type of range is conceptualized as "static", "fixed", or "dynamic".
```julia
julia> is_static(usr)
true

julia> is_fixed(usr)
false

julia> is_dynamic(usr)
false

julia> is_static(ufr)
false

julia> is_fixed(ufr)
true

julia> is_dynamic(ufr)
false

julia> is_static(umr)
false

julia> is_fixed(umr)
false

julia> is_dynamic(umr)
true
```

There's convenient syntax available for converting between these.
```julia

julia> as_static(OneTo(10))
OneToSRange(10)

julia> as_static(UnitRange(1, 10))
UnitSRange(1:10)

julia> as_static(StepRange(1, 2, 20))
StepSRange(1:2:19)

julia> as_static(range(1.0, step=2.0, stop=20.0))
StepSRangeLen(1.0:2.0:19.0)

julia> as_static(LinRange(1, 20, 10))
LinSRange(1.0, stop=20.0, length=10)

julia> as_dynamic(OneTo(10))
OneToMRange(10)

julia> as_dynamic(UnitRange(1, 10))
UnitMRange(1:10)

julia> as_dynamic(StepRange(1, 2, 20))
StepMRange(1:2:19)

julia> as_dynamic(range(1.0, step=2.0, stop=20.0))
StepMRangeLen(1.0:2.0:19.0)

julia> as_dynamic(LinRange(1, 20, 10))
LinMRange(1.0, stop=20.0, length=10)

julia> as_fixed(OneToMRange(10))
Base.OneTo(10)

julia> as_fixed(UnitMRange(1, 10))
1:10

julia> as_fixed(StepMRange(1, 2, 20))
1:2:19

julia> as_fixed(mrange(1.0, step=2.0, stop=20.0))
1.0:2.0:19.0

julia> as_fixed(LinMRange(1, 20, 10))
10-element LinRange{Float64}:
 1.0,3.11111,5.22222,7.33333,9.44444,11.5556,13.6667,15.7778,17.8889,20.0
```

## Order traits

Traits are used to conveniently characterize the order of ranges.
```julia
julia> fr = 1:2:10
1:2:9

julia> rr = 10:-2:1
10:-2:2

julia> is_forward(fr)
true

julia> is_forward(rr)
false

julia> is_reverse(fr)
false

julia> is_reverse(rr)
true
```

These are further used to make quick simple comparisons between objects.

```julia
julia> r1 = 1:5
1:5

julia> r2 = 6:10
6:10

julia> r3 = 5:10
5:10

julia> is_before(r1, r2)  # all of r1 is before all of r2
true

julia> is_before(r1, r3)
false

julia> is_after(r2, r1)  # all of r2 is after all of r1
true

julia> is_after(r2, r3)
false

julia> is_contiguous(r1, r3)
true

julia> is_contiguous(r1, r2)
false
```

## Filtering

These are implemented but need examples
* `find_all`
* `find_first`
* `find_last`

## Mutation

These are implemented but need examples
* `set_length`
* `set_step`
* `set_first`
* `set_last`
* `set_length!`
* `set_step!`
* `set_first!`
* `set_last!`
