# Introduction

```@meta
CurrentModule = StaticRanges
```

# StaticRanges

```@index
```

```@autodocs
Modules = [StaticRanges]
```

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
7-element Vector{Int64}:
  1
  2
  3
  7
  8
  9
 10

julia> find_all(or(<(4), >(6)), r)
7-element GapRange{Int64, UnitRange{Int64}, UnitRange{Int64}}:
  1
  2
  3
  7
  8
  9
 10

julia> @btime filter(or(<(4), >(6)), $r)
  124.496 ns (3 allocations: 320 bytes)
7-element Vector{Int64}:
  1
  2
  3
  7
  8
  9
 10

julia> @btime filter(or(<(4), >(6)), $mr)
  72.911 ns (3 allocations: 208 bytes)
7-element Vector{Int64,1}:
  1
  2
  3
  7
  8
  9
 10

```
