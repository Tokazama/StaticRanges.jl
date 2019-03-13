using BenchmarkTools, Statistics, StaticArrays, StaticRanges, UnicodePlots

# FIXME
function itr_cartesian()
    r = CartesianIndices((10,10))
    i, state = iterate(r)
    for i in 1:100
        r[i]
    end
end

ci = CartesianIndices((10,10));
si = SubIndices((10,10), srange(1,10,step=1), srange(1,10,step=1));
li = LinearIndices((10,10));
a = rand(100,100);
function itr_indices(x::AbstractArray, inds::SubIndices)
    for i in 1:length(inds)
        x[inds[i]...]
    end
end

function itr_indices(x::AbstractArray, inds::CartesianIndices)
    for i in 1:length(inds)
        x[inds[i]]
    end
end

function itr_indices(x::AbstractArray, inds::LinearIndices)
    for i in 1:length(inds)
        x[inds[i]]
    end
end


@btime itr_indices(a, si)
@btime itr_indices(a, ci)
@btime itr_indices(a, li)



function itr_subindices()
    r = SubIndices((10,10), srange(1,10,step=1), srange(1,10,step=1))
    i, state = iterate(r)
    for i in 1:100
        r[i]
    end
end


function itr_linearindices()
    r = LinearIndices((10,10))
    i, state = iterate(r)
    while i < lastindex(r)
        i, state = iterate(r, state)
    end
end


function itr_staticindices()
    r = StaticIndices((10,10))
    i, state = iterate(r)
    while i < lastindex(r)
        i, state = iterate(r, state)
    end
end


const SRBench = BenchmarkGroup()
SRBench["iterating"] = BenchmarkGroup();

itr_OneTo() = for i in Base.OneTo(1000); i; end
SRBench["iterating"]["itr_OneTo"] = @benchmarkable itr_OneTo()

itr_OneToSRange() = for i in OneToSRange(1000); i; end
SRBench["iterating"]["itr_OneToSRange"] = @benchmarkable itr_OneToSRange()

itr_OneToSRangeType() = for i in OneToSRange{1000}; i; end
SRBench["iterating"]["itr_OneToSRangeType"] = @benchmarkable itr_OneToSRange()

itr_idx_OneTo() = for i in 1:100; Base.OneTo(1000)[i]; end
SRBench["iterating"]["itr_idx_OneToSRangeType"] = @benchmarkable itr_OneToSRange()

itr_idx_OneToSRange() = for i in 1:100; OneToSRange(1000)[i]; end
SRBench["iterating"]["itr_idx_OneToSRangeType"] = @benchmarkable itr_OneToSRange()

itr_idx_OneToSRangeType() = for i in 1:100; OneToSRange{1000}[i]; end
SRBench["iterating"]["itr_idx_OneToSRangeType"] = @benchmarkable itr_OneToSRange()

itr_step_r() = for i in 1:2:1000; i; end
SRBench["iterating"]["itr_step_r"] = @benchmarkable itr_step_r()

itr_step_sr() = for i in srange(1,1000,step=2); i; end
SRBench["iterating"]["itr_step_sr"] = @benchmarkable itr_step_sr()

itr_step_srtype() = for i in StaticRange{Int,1,1000,2,500}; i; end
SRBench["iterating"]["itr_step_srtype"] = @benchmarkable itr_step_sr()

itr_li() = for i in LinearIndices((5,6)); i; end
SRBench["iterating"]["itr_LinearIndices"] = @benchmarkable itr_li()

itr_sli() = for i in LinearSIndices((5,6)); i; end
SRBench["iterating"]["itr_LinearSIndices"] = @benchmarkable itr_sli()

function idx_li()
    a = LinearIndices((5,6))[2:3,1:3]
    a[2,1]
end

function idx_li()
    a = LinearSIndices((5,6))[2:3,1:3]
    a[2,1]
end

function itr_sub_li()
    for i in 
        i
    end
end

function itr_sub_sli()
    for i in LinearSIndices((5,6))[2:3,1:3]
        i
    end
end

function itr_sub_subli()
    a = SubLinearIndices(LinearSIndices((5,6)), (srange(2:3), srange(1:3)))
    for i in 
        i
    end
end


### Sub Indexing
function while_r()
    r = 1:1000
    i, state = iterate(r)
    while i < 1000
        i, state = iterate(r, state)
    end
end
SRBench["iterating"]["while_r"] = @benchmarkable while_r()

function while_sr()
    r = srange(1,1000,step=1)
    i, state = iterate(r)
    while i < 1000
        i, state = iterate(r, state)
    end
end
SRBench["iterating"]["while_sr"] = @benchmarkable while_sr()

function while_step_r()
    r = 1:2:1000
    i, state = iterate(r)
    while i < lastindex(r)
        i, state = iterate(r, state)
    end
end
SRBench["iterating"]["while_step_r"] = @benchmarkable while_step_r()

function while_step_sr()
    r = srange(1,1000,step=2)
    i, state = iterate(r)
    while i < lastindex(r)
        i, state = iterate(r, state)
    end
end
SRBench["iterating"]["while_step_sr"] = @benchmarkable while_step_sr()


# # Indexing
containers = Dict("range" => 1:1000,
                  "srange" => srange(1,1000,step=1),
                  "srange_type" => OneToSRange{1000},
                  "SVector" => SVector(1:1000...),
                  "Vector" => [1:1000...],
                  "Matrix" => rand(Int, 20, 50),
                  "SMatrix" => SMatrix{20,50}(1:1000...));

by_r(x) = x[range(1, 500, step=1)];
by_sr(x) = x[srange(1, 500, step=1)];
# TODO: should this be a thing?
#by_srtype(x) = x[OneToSRange{500}];

by_step_r(x) = x[range(1, 500, step=2)];
by_step_sr(x) = x[srange(1, 500, step=2)];

fxns = Dict("range" => by_r,
            "srange" => by_sr,
            "step_range" => by_step_r,
            "step_srange" => by_step_sr)
by_nd_r(x::AbstractMatrix) = x[range(1, 20, step=1), range(1, 20, step=1)];
by_nd_sr(x::AbstractMatrix) = x[srange(1, 20, step=1), srange(1, 20, step=1)];

SRBench["indexing"] = BenchmarkGroup();
for  (ck,cv) in containers
    for (fk, fv) in fxns
        if !haskey(SRBench["indexing"], ck)
            SRBench["indexing"][ck] = BenchmarkGroup([ck])
        end
        SRBench["indexing"][ck][fk] = @benchmarkable $(fv)($cv)
    end
end


SRBench["indexing"]["Matrix"]["by_nd_r"] = @benchmarkable by_nd_r($(containers["Matrix"]))
SRBench["indexing"]["Matrix"]["by_nd_sr"] = @benchmarkable by_nd_sr($(containers["Matrix"]))
SRBench["indexing"]["SMatrix"]["by_nd_r"] = @benchmarkable by_nd_r($(containers["SMatrix"]))
SRBench["indexing"]["SMatrix"]["by_nd_sr"] = @benchmarkable by_nd_sr($(containers["SMatrix"]))

results = run(SRBench, verbose = true, seconds = 1)

function bplots(results)
    println(barplot(["range", "srange", "step_range", "step_srange", "by_nd_r", "by_nd_sr"],
            [median(results[["indexing", "Matrix", "range"]].times),
             median(results[["indexing", "Matrix", "srange"]].times),
             median(results[["indexing", "Matrix", "step_range"]].times),
             median(results[["indexing", "Matrix", "step_srange"]].times),
             median(results[["indexing", "Matrix", "by_nd_r"]].times),
             median(results[["indexing", "Matrix", "by_nd_sr"]].times)],
            xlabel="time", title="Index Matrix"))

    println(barplot(["range", "srange", "step_range", "step_srange", "by_nd_r", "by_nd_sr"],
            [median(results[["indexing", "SMatrix", "range"]].times),
             median(results[["indexing", "SMatrix", "srange"]].times),
             median(results[["indexing", "SMatrix", "step_range"]].times),
             median(results[["indexing", "SMatrix", "step_srange"]].times),
             median(results[["indexing", "SMatrix", "by_nd_r"]].times),
             median(results[["indexing", "SMatrix", "by_nd_sr"]].times)],
            xlabel="time", title="Index SMatrix"))

    println(barplot(["range", "srange", "step_range", "step_srange"],
            [median(results[["indexing", "Vector", "range"]].times),
             median(results[["indexing", "Vector", "srange"]].times),
             median(results[["indexing", "Vector", "step_range"]].times),
             median(results[["indexing", "Vector", "step_srange"]].times)],
            xlabel="time", title="Index Vector"))

    println(barplot(["range", "srange", "step_range", "step_srange"],
            [median(results[["indexing", "SVector", "range"]].times),
             median(results[["indexing", "SVector", "srange"]].times),
             median(results[["indexing", "SVector", "step_range"]].times),
             median(results[["indexing", "SVector", "step_srange"]].times)],
            xlabel="time", title="Index SVector"))


    println(barplot(["range", "srange", "step_range", "step_srange"],
            [median(results[["indexing", "range", "range"]].times),
             median(results[["indexing", "range", "srange"]].times),
             median(results[["indexing", "range", "step_range"]].times),
             median(results[["indexing", "range", "step_srange"]].times)],
            xlabel="time", title="Index range"))

    println(barplot(["range", "srange", "step_range", "step_srange"],
            [median(results[["indexing", "srange", "range"]].times),
             median(results[["indexing", "srange", "srange"]].times),
             median(results[["indexing", "srange", "step_range"]].times),
             median(results[["indexing", "srange", "step_srange"]].times)],
            xlabel="time", title="Index srange"))
end

df.step_vector  = [(@benchmark by_step_r(x)).times..., (@benchmark by_step_sr(x)).times...]
df.step_range   = [(@benchmark by_step_r(x)).times..., (@benchmark by_step_sr(x)).times...]
df.step_svector = [(@benchmark by_step_r(x)).times..., (@benchmark by_step_sr(x)).times...]
df.step_matrix  = [(@benchmark by_step_r(x)).times..., (@benchmark by_step_sr(x)).times...]
df.step_smatrix = [(@benchmark by_step_r(x)).times..., (@benchmark by_step_sr(x)).times...]
