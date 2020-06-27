
using BenchmarkTools, Statistics, StaticArrays, StaticRanges,
      DataFrames, VegaLite

const SRBench = BenchmarkGroup()

include("indexing.jl")
include("iterating.jl")

# TODO: compare base benchmarks

results = run(SRBench, verbose = true, seconds = 1)


# groups tests appropriately in dataframes
function tablegroup(bgroup, groupname=nothing)
    t = []
    g = []
    m = []
    a = []
    n = []

    bts = leaves(bgroup)
    ntests = length(bts)
   if isnothing(groupname)
        groupname = bts[1][1][end-1]
    end
    gn = fill(groupname, ntests)

    for i in 1:ntests
        mbt = median(bts[i][2])
        push!(t, mbt.time)
        push!(g, mbt.gctime)
        push!(a, mbt.allocs)
        push!(m, mbt.memory)
        push!(n, bts[i][1][end])
    end
    DataFrame(test = gn, subtest = n, time = t, gctime = g, memory = m, allocs = a)
end

df = [tablegroup(results[@tagged "indexing" && "Matrix"]);
      tablegroup(results[@tagged "indexing" && "SMatrix"]);
      tablegroup(results[@tagged "indexing" && "Vector"]);
      tablegroup(results[@tagged "indexing" && "SVector"]);
      tablegroup(results[@tagged "indexing" && "range"]);
      tablegroup(results[@tagged "indexing" && "srange"])]
p = df |> @vlplot(:bar, x="subtest:o", y=:time, color=:subtest, column=:test)
save("indexing.svg", p)

df =  [tablegroup(results[@tagged "iterating" && "LinearIndices((5,6))"]);
#      tablegroup(results[@tagged "iterating" && "LinearIndices((5,6))[2:3,1:3]"]);
      tablegroup(results[@tagged "iterating" && "OneTo"]);
      tablegroup(results[@tagged "iterating" && "OneTo[i]"]);
      tablegroup(results[@tagged "iterating" && "1:2:1000"])]

p = df |> @vlplot(:bar, x="subtest:o", y=:time, color=:subtest, column=:test)
save("iterating.svg", p)
