# StaticRanges

[![Build Status](https://travis-ci.com/Tokazama/StaticRanges.jl.svg?branch=master)](https://travis-ci.com/Tokazama/StaticRanges.jl)
[![codecov](https://codecov.io/gh/Tokazama/StaticRanges.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/Tokazama/StaticRanges.jl)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://Tokazama.github.io/StaticRanges.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://Tokazama.github.io/StaticRanges.jl/dev)

This package was originally inspired by the StaticArrays package.
It attempts to cover all basic types and methods that would naturally be present given ranges that are either static, fixed, or dynamic.
The details of what exactly this means are more fully explored in the documentation.
For those simply wishing to take this package for a spin, try using `srange` and `mrange` just as you would the `range` method from base Julia.
