# Order Functions

## Optimized for Order

```@docs
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
```

## Search and Sort

## Order traits

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
StaticRanges.vcat_sort
```

