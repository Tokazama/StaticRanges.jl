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

    # TODO this raises ambiguity errors
    #@test StepMRangeLen{Float64}(1.0:2:10) isa StepMRangeLen



end

