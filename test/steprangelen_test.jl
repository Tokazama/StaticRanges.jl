@testset "AbstractStepRangeLen" begin
    for frange in (mrange, srange, range)
        @testset "$frange" begin
            r = frange(1.0, step=1, stop=10.0)
            b = range(1.0, step=1, stop=10.0)
            @test stephi(r) == 1
            @test steplo(r) == 0
            @test refhi(r) == 1
            @test reflo(r) == 0
            @test eltype(StepRangeLen{Float64}(r)) == Float64

            @test intersect(r, r[2]) == intersect(b, b[2])
            @test intersect(r, r[2]) == intersect(b, b[2])

            if frange == mrange
                setproperty!(r, :step, 2)
                @test r == range(1.0, step=2, length=10)

                setproperty!(r, :ref, 2)
                @test r == range(2.0, step=2, length=10)

                setproperty!(r, :len, 5)
                @test r == range(2.0, step=2, length=5)

                setproperty!(r, :offset, 2)
                @test r == StepRangeLen(2.0, 2.0, 5, 2)

                @test_throws ErrorException setproperty!(r, :anything, 3)
            end
        end
    end
    @test +(StepMRangeLen(1, 2, 10, 1), StepMRangeLen(1, 2, 10, 2)) == +(StepRangeLen(1, 2, 10, 1), StepRangeLen(1, 2, 10, 2))

    @test_throws ErrorException getproperty(srange(1.0, step=1.0, length=10), :foo)
    # constructors
    @test StepSRangeLen{Float64}(1:2) isa StepSRangeLen
    @test StepMRangeLen{Float64}(1:2) isa StepMRangeLen
    @test StepSRangeLen{Int,Int,Int}(StepSRangeLen(1, 2, 3)) isa StepSRangeLen
    @test StepMRangeLen{Int,Int,Int}(StepMRangeLen(1, 2, 3)) isa StepMRangeLen

    getindex(mrange(1.0, step=1, length=10), 1:2:10)

    # TODO this raises ambiguity errors
    #@test StepMRangeLen{Float64}(1.0:2:10) isa StepMRangeLen

    +(StepRangeLen(0, 1, 2) + StepRangeLen(0, 1, 2))
    @test first(srange(1.0, step=2, length=11) / 2) ==
          first(range(1.0, step=2, length=11) / 2) ==
          first(mrange(1.0, step=2, length=11) / 2)

    @test srange(1.0, step=2, length=10) * 2 ==
          mrange(1.0, step=2, length=10) * 2 ==
          range(1.0, step=2, length=10) * 2

    @test +(range(0.0, step=0.5, length=10), range(1.0, step=0.5, length=10)) ==
          +(mrange(0.0, step=0.5, length=10), mrange(1.0, step=0.5, length=10)) ==
          +(srange(0.0, step=0.5, length=10), srange(1.0, step=0.5, length=10))

    x = StepRangeLen(0, 2, 3)
    @test +(x, x) ==
          +(as_dynamic(x), as_dynamic(x)) ==
          +(as_static(x), as_static(x))

    sr = srange(1, step=1.0, length=10)

    @test StepSRangeLen{Float64,Base.TwicePrecision{Float64},Base.TwicePrecision{Float64}}(sr) isa StepSRangeLen{Float64,Base.TwicePrecision{Float64},Base.TwicePrecision{Float64}}
    # TODO StepSRange{Float64}(sr)

    @test StepSRangeLen(1:10) isa StepSRangeLen{Int64,Int64,Int64,1,1,10,1}

    @test StepMRangeLen{Float32}(1:10) isa StepMRangeLen{Float32,Float64,Float64}
    @test StepSRangeLen{Float32}(sr) isa StepSRangeLen{Float32,Float64,Float64,1.0,1.0,10,1}

    r = StepRangeLen(1, 1, 1)
    @test eltype(StepMRangeLen{Float64}(r)) <: Float64

    r = StepMRangeLen(1,1,1)
    @test eltype(StepMRangeLen{Int}(r)) <: Int

    @test eltype(StepMRangeLen{UInt,Int,Int}(r)) <: UInt64

end

