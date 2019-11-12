@testset "AbstractStepRangeLen" begin
    for frange in (mrange, srange, range)
        @testset "$frange" begin
            r = frange(1.0, step=1, stop=10.0)
            @test stephi(r) == 1
            @test steplo(r) == 0
            @test refhi(r) == 1
            @test reflo(r) == 0
            @test eltype(StepRangeLen{Float64}(r)) == Float64

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
end

