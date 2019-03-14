# StaticRanges

[![experimental](http://badges.github.io/stability-badges/dist/experimental.svg)](http://github.com/badges/stability-badges)

## Introduction

StaticRanges is inspired by [StaticArrays](https://github.com/JuliaArrays/StaticArrays.jl).
In its current form StaticRanges aims to be a tool for performant indexing using the strongly
typed `StaticRange`. Current work is focused towards optimizing multidimensional indexing
for a variety of use cases (sliding windows, multidimensional filters, etc.).

## Installation
```julia
]add https://github.com/JuliaDebug/JuliaInterpreter.jl
```

## Grab each index of a range

![Indexing Benchmarks](benchmark/indexing.svg)
