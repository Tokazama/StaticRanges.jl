# StaticRanges

[![Build Status](https://travis-ci.com/Tokazama/StaticRanges.jl.svg?branch=master)](https://travis-ci.com/Tokazama/StaticRanges.jl)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://Tokazama.github.io/StaticRanges.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://Tokazama.github.io/StaticRanges.jl/dev)

This package was originally inspired by the StaticArrays package.
It provides a basic `srange` method that produces a static range with the same syntax and arguments as `range`.
Similarly, there is an `mrange` method for constructing mutable ranges.

It attempts to cover all basic types and methods that would naturally be present given ranges that are either static, fixed, or dynamic.
The details of what exactly this means are more fully explored in the documentation.
For those simply wishing to take this package for a spin, try using `srange` and `mrange` just as you would the `range` method from base Julia.
This will provide you with static and mutable ranges, respectively.

# "Find" Functions

"find" methods (`findall`, `findfirst`, `findlast`, `filter`, and `count`) for operators that can produce fixed methods (e.g., `<(1) -> Base.Fix2(<, 1)`) have been optimized. This includes `<`, `<=`, `>`, `>=`, `==`, and `!=` operators.

For example, `find_all` is able to preserve ranges as opposed to `findall`.
```julia
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

julia> mr = MutableRange(r)
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

