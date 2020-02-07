# Order Functions

## Optimized for Order

Traits are used to conveniently characterize the order of ranges.
```@docs
StaticRanges.is_forward
StaticRanges.is_reverse
StaticRanges.order
StaticRanges.is_ordered
StaticRanges.ordmax
StaticRanges.ordmin
StaticRanges.find_max
StaticRanges.find_min
StaticRanges.is_within
StaticRanges.gtmax
StaticRanges.ltmax
StaticRanges.eqmax
StaticRanges.gtmin
StaticRanges.ltmin
StaticRanges.eqmin
StaticRanges.group_max
StaticRanges.group_min
StaticRanges.cmpmax
StaticRanges.cmpmin
StaticRanges.min_of_group_max
StaticRanges.max_of_group_min
StaticRanges.is_before
StaticRanges.is_after
StaticRanges.is_contiguous
```

## Search and Sort

## Order traits

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
```@docs
StaticRanges.find_first
StaticRanges.find_last
StaticRanges.merge_sort
StaticRanges.first_segment
StaticRanges.last_segment
StaticRanges.middle_segment
StaticRanges.vcat_sort
```

