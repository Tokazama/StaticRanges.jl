# Introduction


StaticRanges was originally a small set of functions inspired by [StaticArrays](https://github.com/JuliaArrays/StaticArrays.jl). It eventually evolved into a project the aimed to improve the performance and flexibility of range related methods.
It's objectives are:

1. Easy/intuitive composition of mutable and static ranges.
2. Optimized methods involving ranges:
    - "find" methods are currently the focus and optimizations currently exist for `findall`, `findfirst`, `findlast`, `filter`, and `count` using the `<`, `<=`, `>`, `>=`, `==`, and `!=` operators.
    - Indexing related to `AbstractAxis` related methods.

