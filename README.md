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
julia> using StaticRanges
julia> using Base: OneTo

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

There are some small improvements to the family of "find and filter" methods
available in base Julia. In Order to avoid type piracy but generalize the
benefits to all types of ranges, some minor syntactic differences are used here.

Starting with `findall`, there's a difference in the type that is returned.
```julia
julia> mr = StepMRange(1, 2, 19)
StepMRange(1:2:19)

julia> @btime findall(<(5), $fr)
  142.072 ns (3 allocations: 208 bytes)
2-element Array{Int64,1}:
 1
 2

julia> @btime find_all(<(5), $fr)
  0.027 ns (0 allocations: 0 bytes)
1:2
```

```julia
julia> r = 1:10
1:10

julia> mr = UnitMRange(1, 10)
UnitMRange(1:10)

julia> findall(or(<(4), >(12)), mr)
7-element Array{Int64,1}:
  1
  2
  3
  7
  8
  9
 10

julia> find_all(or(<(4), >(6)), r)
7-element GapRange{Int64,UnitRange{Int64},UnitRange{Int64}}:
  1
  2
  3
  7
  8
  9
 10

julia> @btime filter(or(<(4), >(6)), $r)
  124.496 ns (3 allocations: 320 bytes)
7-element Array{Int64,1}:
  1
  2
  3
  7
  8
  9
 10

julia> @btime filter(or(<(4), >(6)), $mr)
  72.911 ns (3 allocations: 208 bytes)
7-element Array{Int64,1}:
  1
  2
  3
  7
  8
  9
 10

```

## Experimental Syntax

Currently there's some experimental syntax that can be used to chain together
functions. This functionality is an obvious case of type piracy and is currently
only included as a proof of concept.
```julia
julia> findall(>(4) & <(8), fr)
2-element Array{Int64,1}:
  3
  4

julia> findall(<(4) | >(8), fr)
8-element Array{Int64,1}:
  1
  2
  5
  6
  7
  8
  9
 10
```

Internally it provides an intermediate structure for chaining functions an
arbitrary number of functions.
```julia
julia> fxn1 = <(4) | >(8)
(::StaticRanges.ChainedFix{typeof(|),Base.Fix2{typeof(<),Int64},Base.Fix2{typeof(>),Int64}}) (generic function with 3 methods)

julia> fxn2 = <(4) | >(8) & iseven
(::StaticRanges.ChainedFix{typeof(|),Base.Fix2{typeof(<),Int64},StaticRanges.ChainedFix{typeof(&),Base.Fix2{typeof(>),Int64},typeof(iseven)}}) (generic function with 3 methods)

julia> fxn1(10)
true

julia> fxn1(11)
true

julia> fxn2(10)
true

julia> fxn2(11)
false
```

This becomes particularly useful when trying to preserve a range in a type
stable manner. Without knowing the specific functions that compose the
conditional operator in `findall` at compile time it's impossible to determine
whether the output should be a continuous range or discrete vector.
```julia
julia> findall(i -> >(4)(i) & <(8)(i), fr)
2-element Array{Int64,1}:
 3
 4

julia> find_all(>(4) & <(8), fr)
3:4
```
## Mutation

### set_length

```julia
julia> r = 1:10
1:10

julia> set_length(r, 20)
1:20

julia> mr = UnitMRange(1, 10)
UnitMRange(1:10)

julia> set_length!(mr, 20)
UnitMRange(1:20)

julia> length(mr)
20
```

### set_first

```julia
julia> r = 1:10
1:10

julia> set_first(r, 2)
2:10

julia> mr = UnitMRange(1, 10)
UnitMRange(1:10)

julia> set_first!(mr, 2)
UnitMRange(2:20)

julia> first(mr)
2
```

### set_last

```julia
julia> r = 1:10
1:10

julia> set_last(r, 5)
1:5

julia> mr = UnitMRange(1, 10)
UnitMRange(1:10)

julia> set_last!(r, 5)
UnitMRange(1:5)

julia> last(mr)
5
```

### set_step

```julia
julia> r = 1:1:10
1:1:10

julia> set_step(r, 2)
1:2:10

julia> mr = StepMRange(1, 1, 10)
1:1:10

julia> set_step!(mr, 2)
StepMRange(1:2:9)

julia> step(mr)
2
```
