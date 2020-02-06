# Indexing

The standard syntax for indexing doesn't change at all.
```jldoctest
julia> using StaticRanges

julia> sa = SimpleAxis(1:10)
SimpleAxis(1:10)

julia> sa[2]
2

julia> sa[>(2)]
SimpleAxis(3:10)

julia> a = Axis(1:10)
Axis(1:10 => Base.OneTo(10))

julia> a[2]
2

julia> a[2:3]
Axis(2:3 => 2:3)
```

But now we can also use functions to index by the the keys of an `AbstractAxis`.
```jldoctest
julia> using StaticRanges

julia> a = Axis(2.0:11.0, 1:10)
Axis(2.0:1.0:11.0 => 1:10)

julia> a[1]
1

julia> a[isequal(2.0)]
1

julia> a[>(2)]
Axis(3.0:1.0:11.0 => 2:10)

julia> a[>(2.0)]
Axis(3.0:1.0:11.0 => 2:10)

julia> a[>(2.0) & <(8.0)]
Axis(3.0:1.0:7.0 => 2:6)
```
## Chaining filters

```@docs
StaticRanges.and
StaticRanges.or
```


## Reindexing

```@docs
StaticRanges.reindex
StaticRanges.unsafe_reindex
```
