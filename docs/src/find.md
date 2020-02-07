# "Find" Functions

These are further used to make quick simple comparisons between objects.

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

