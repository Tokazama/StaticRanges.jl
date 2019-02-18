# StaticRanges

Currently, the workhorse of this package is `srange` which is meant to act
similarly to `range` from base.

## Grab each index of a range

```julia
julia> ridx() = map(i->i, range(1,100,step=1));
julia> sridx() = map(i->i, srange(1,100,step=1));

julia> @benchmark ridx()
BenchmarkTools.Trial:
  memory estimate:  896 bytes
  allocs estimate:  1
  --------------
  minimum time:     107.088 ns (0.00% GC)
  median time:      125.157 ns (0.00% GC)
  mean time:        161.919 ns (19.27% GC)
  maximum time:     57.389 μs (99.70% GC)
  --------------
  samples:          10000
  evals/sample:     932

julia> @benchmark sridx()
BenchmarkTools.Trial:
  memory estimate:  0 bytes
  allocs estimate:  0
  --------------
  minimum time:     16.800 ns (0.00% GC)
  median time:      16.803 ns (0.00% GC)
  mean time:        16.932 ns (0.00% GC)
  maximum time:     84.687 ns (0.00% GC)
  --------------
  samples:          10000
  evals/sample:     998

ridx() = map(i->i, range(1,1_000,step=1));
sridx() = map(i->i, srange(1,1_000,step=1));
@benchmark ridx()
BenchmarkTools.Trial:
  memory estimate:  7.94 KiB
  allocs estimate:  1
  --------------
  minimum time:     746.848 ns (0.00% GC)
  median time:      1.297 μs (0.00% GC)
  mean time:        2.033 μs (37.60% GC)
  maximum time:     535.556 μs (99.83% GC)
  --------------
  samples:          10000
  evals/sample:     92

@benchmark sridx()
BenchmarkTools.Trial:
  memory estimate:  0 bytes
  allocs estimate:  0
  --------------
  minimum time:     161.910 ns (0.00% GC)
  median time:      162.013 ns (0.00% GC)
  mean time:        163.869 ns (0.00% GC)
  maximum time:     752.167 ns (0.00% GC)
  --------------
  samples:          10000
  evals/sample:     780
```

## Step indexing

```julia
julia> step_ridx() = map(i->i, range(1,100,step=2));

julia> step_sridx() = map(i->i, srange(1,100,step=2));

julia> @benchmark step_ridx()
BenchmarkTools.Trial:
  memory estimate:  496 bytes
  allocs estimate:  1
  --------------
  minimum time:     74.181 ns (0.00% GC)
  median time:      83.130 ns (0.00% GC)
  mean time:        129.203 ns (18.00% GC)
  maximum time:     61.861 μs (99.81% GC)
  --------------
  samples:          10000
  evals/sample:     971

julia> @benchmark step_sridx()
BenchmarkTools.Trial:
  memory estimate:  0 bytes
  allocs estimate:  0
  --------------
  minimum time:     16.253 ns (0.00% GC)
  median time:      20.982 ns (0.00% GC)
  mean time:        21.431 ns (0.00% GC)
  maximum time:     208.428 ns (0.00% GC)
  --------------
  samples:          10000
  evals/sample:     999


julia> step_ridx() = map(i->i, range(1,1_000,step=2));

julia> step_sridx() = map(i->i, srange(1,1_000,step=2));

julia> @benchmark step_ridx()

BenchmarkTools.Trial:
  memory estimate:  4.06 KiB
  allocs estimate:  1
  --------------
  minimum time:     477.202 ns (0.00% GC)
  median time:      784.167 ns (0.00% GC)
  mean time:        1.258 μs (38.80% GC)
  maximum time:     279.186 μs (99.78% GC)
  --------------
  samples:          10000
  evals/sample:     198

julia> @benchmark step_sridx()
BenchmarkTools.Trial:
  memory estimate:  0 bytes
  allocs estimate:  0
  --------------
  minimum time:     81.394 ns (0.00% GC)
  median time:      81.436 ns (0.00% GC)
  mean time:        82.248 ns (0.00% GC)
  maximum time:     364.602 ns (0.00% GC)
  --------------
  samples:          10000
  evals/sample:     967
```

## Pre- vs Post-Compilation times

Improved runtime comes at the cost of a significantly higher compile time.

Redifine some funcitons so compiler is triggered
```julia
julia> ridx() = map(i->i, range(1,1000,step=1));
julia> sridx() = map(i->i, srange(1,1000,step=1));
```

Pre-compilation time
```julia

julia> @time ridx();
  0.058123 seconds (167.90 k allocations: 8.965 MiB)

julia> @time sridx();

  6.298867 seconds (8.23 M allocations: 510.420 MiB, 2.07% gc time)
```

Post-compilation time
```julia
julia> @time ridx();
  0.000006 seconds (5 allocations: 8.094 KiB)

julia> @time sridx();
  0.000005 seconds (5 allocations: 8.031 KiB)
```

## Index Array structures


### Vectors
```julia
using BenchmarkTools, StaticArrays, .StaticRanges

by_r(x) = x[range(1, 500, step=1)];
by_sr(x) = x[srange(1, 500, step=1)];

by_step_r(x) = x[range(1, 500, step=2)];
by_step_sr(x) = x[srange(1, 500, step=2)];



containers = (range = 1:1000,
              srange = srange(1,1000,step=1),
              svector = SVector(1:1000...),
              vector  = [1:1000...],
              matrix  = rand(Int, 20, 50),
              smatrix = SMatrix{20,50}(1:1000...));

fxns = (range = by_r,
        srange = by_sr,
        range_step = by_step_r,
        srange_step = by_step_sr);

for i in keys(containers)
    for f in keys(fxns)
        println("\nIndexer = $f, Container: = $i")
        fv = fxns[f]
        cv = containers[i]
        println(@benchmark $fv($cv))
    end
end

Indexer = range, Container: = range

Trial(12.304 ns)

Indexer = srange, Container: = range
Trial(100.634 ns)

Indexer = range_step, Container: = range
Trial(12.303 ns)

Indexer = srange_step, Container: = range
Trial(98.481 ns)

Indexer = range, Container: = srange
Trial(492.806 ns)

Indexer = srange, Container: = srange
Trial(1.962 ns)

Indexer = range_step, Container: = srange
Trial(337.676 ns)

Indexer = srange_step, Container: = srange
Trial(1.962 ns)

Indexer = range, Container: = svector
Trial(508.016 ns)

Indexer = srange, Container: = svector
Trial(81.453 ns)

Indexer = range_step, Container: = svector
Trial(346.349 ns)

Indexer = srange_step, Container: = svector
Trial(81.040 ns)

Indexer = range, Container: = vector
Trial(552.117 ns)

Indexer = srange, Container: = vector
Trial(399.609 ns)

Indexer = range_step, Container: = vector
Trial(362.707 ns)

Indexer = srange_step, Container: = vector
Trial(249.500 ns)

Indexer = range, Container: = matrix
Trial(554.591 ns)

Indexer = srange, Container: = matrix
Trial(387.647 ns)

Indexer = range_step, Container: = matrix
Trial(356.803 ns)

Indexer = srange_step, Container: = matrix
Trial(249.805 ns)

Indexer = range, Container: = smatrix
Trial(524.464 ns)

Indexer = srange, Container: = smatrix
Trial(81.444 ns)

Indexer = range_step, Container: = smatrix
Trial(330.293 ns)

Indexer = srange_step, Container: = smatrix
Trial(81.042 ns)
```

### Multi-dimensional

```julia
using BenchmarkTools, StaticArrays, .StaticRanges

by_r(x::AbstractMatrix) = x[range(1, 20, step=1),range(1, 20, step=1)];
by_sr(x::AbstractMatrix) = x[srange(1, 20, step=1),srange(1, 20, step=1)];

containers = (matrix  = rand(Int, 25, 25),
              smatrix = SMatrix{25,25}(rand(Int, 25, 25)));

fxns = (range = by_r, srange = by_sr);

for i in keys(containers)
    for f in keys(fxns)
        println("\nIndexer = $f, Container: = $i")
        fv = fxns[f]
        cv = containers[i]
        println(@benchmark $fv($cv))
    end
end
Indexer = range, Container: = matrix

Trial(500.508 ns)

Indexer = srange, Container: = matrix
Trial(144.482 ns)

Indexer = range, Container: = smatrix
Trial(487.135 ns)

Indexer = srange, Container: = smatrix
Trial(99.863 ns)
```
