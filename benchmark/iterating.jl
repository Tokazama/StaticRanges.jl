SRBench["iterating"] = BenchmarkGroup();


itr_OneTo() = for i in Base.OneTo(1000); i; end
itr_OneToSRange() = for i in OneToSRange(1000); i; end
itr_OneToSRangeType() = for i in OneToSRange{1000}; i; end

SRBench["iterating"]["OneTo"] = BenchmarkGroup();
SRBench["iterating"]["OneTo"]["<:AbstractRange"] = @benchmarkable itr_OneTo()
SRBench["iterating"]["OneTo"]["OneToSRange"] = @benchmarkable itr_OneToSRange()
SRBench["iterating"]["OneTo"]["Type{OneToSRange}"] = @benchmarkable itr_OneToSRange()


# Indexing into OneTo iterators
SRBench["iterating"]["OneTo[i]"] = BenchmarkGroup();

itr_idx_OneTo() = for i in 1:100; Base.OneTo(1000)[i]; end
itr_idx_OneToSRange() = for i in 1:100; OneToSRange(1000)[i]; end
itr_idx_OneToSRangeType() = for i in 1:100; OneToSRange{1000}[i]; end

SRBench["iterating"]["OneTo[i]"]["<:AbstractRange"] = @benchmarkable itr_idx_OneTo()
SRBench["iterating"]["OneTo[i]"]["OneToSRange"] = @benchmarkable itr_OneToSRange()
SRBench["iterating"]["OneTo[i]"]["Type{OneToSRange}"] = @benchmarkable itr_OneToSRangeType()


# Iterating by steps
SRBench["iterating"]["1:2:1000"] = BenchmarkGroup();

itr_step_r() = for i in 1:2:1000; i; end
itr_step_sr() = for i in srange(1,1000,step=2); i; end
itr_step_srtype() = for i in StaticRange{Int,1,1000,2,500}; i; end

SRBench["iterating"]["1:2:1000"]["<:AbstractRange"] = @benchmarkable itr_step_r()
SRBench["iterating"]["1:2:1000"]["StaticRange"] = @benchmarkable itr_step_sr()
SRBench["iterating"]["1:2:1000"]["Type{StaticRange}"] = @benchmarkable itr_step_sr()


# Iterating into multidimensional linear indices
SRBench["iterating"]["LinearIndices((5,6))"] = BenchmarkGroup();

itr_li() = for i in LinearIndices((5,6)); i; end
itr_sli() = for i in LinearSIndices((5,6)); i; end

SRBench["iterating"]["LinearIndices((5,6))"]["LinearIndices"] = @benchmarkable itr_li()
SRBench["iterating"]["LinearIndices((5,6))"]["SIndices"] = @benchmarkable itr_sli()

### Sub Indexing
# TODO Figure out how to best test SubIndices
SRBench["iterating"]["LinearIndices((5,6))[2:3,1:3]"] = BenchmarkGroup();

# Indexing into 
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


SRBench["iterating"]["while_step_sr"] = @benchmarkable while_step_sr()

