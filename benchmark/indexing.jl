# # Indexing
containers = Dict("<:AbstractRange" => 1:1000,
                  "StaticRange" => srange(1,1000,step=1),
                  "Type{StaticRange}" => OneToSRange{1000},
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


