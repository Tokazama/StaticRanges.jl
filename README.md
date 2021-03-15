# StaticRanges

[![Build Status](https://travis-ci.com/Tokazama/StaticRanges.jl.svg?branch=master)](https://travis-ci.com/Tokazama/StaticRanges.jl)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://Tokazama.github.io/StaticRanges.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://Tokazama.github.io/StaticRanges.jl/dev)

This package was originally inspired by the StaticArrays package.
It provides a basic `srange` method that produces a static range with the same syntax and arguments as `range`.
Similarly, there is `mrange` constructs mutable ranges.
Currently, much of this package serves as a place to develop traits that are necessary (but not specific to) [AxisIndices.jl](https://github.com/Tokazama/AxisIndices.jl).
As more generally applicable traits and interfaces evolve they are often pushed to [ArrayInterface.jl](https://github.com/JuliaArrays/ArrayInterface.jl).
Therefore, users should consider this package in development and subject to unexpected changes.

