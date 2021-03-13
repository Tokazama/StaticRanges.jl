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


