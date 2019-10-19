# StaticRanges

[![Build Status](https://travis-ci.com/Tokazama/StaticRanges.jl.svg?branch=master)](https://travis-ci.com/Tokazama/StaticRanges.jl)

[![codecov](https://codecov.io/gh/Tokazama/StaticRanges.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/Tokazama/StaticRanges.jl)

## Introduction

StaticRanges is inspired by [StaticArrays](https://github.com/JuliaArrays/StaticArrays.jl).
It's main goal is to create statically parametrized and mutable counterparts to
the range types found in Julia's base. library. Therefore, the behavior of
ranges found herein should be fairly consistent with what one would typically
expect so that end users don't have to muck around in the specific details to
get started.

Although formal documentation is still in development, users can access most
functionality permitted by this package by simply using `mrange` and `srange`
to create mutable and static ranges in a similar manner to the `range` method.
Most docstrings are implemented in at least a rudimentary form at this point
but don't have examples. Until examples are present there's a fairly extensive
set of tests in the `test/runtests.jl` and `test/mutate.jl` files for refrence.

