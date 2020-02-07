# StaticRanges

[![Build Status](https://travis-ci.com/Tokazama/StaticRanges.jl.svg?branch=master)](https://travis-ci.com/Tokazama/StaticRanges.jl)

[![codecov](https://codecov.io/gh/Tokazama/StaticRanges.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/Tokazama/StaticRanges.jl)

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://Tokazama.github.io/StaticRanges.jl/stable)

[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://Tokazama.github.io/StaticRanges.jl/dev)

## Introduction

StaticRanges was originally inspired by [StaticArrays](https://github.com/JuliaArrays/StaticArrays.jl).
It's objectives are:

1. Easy/intuitive composition of mutable and static ranges.
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


