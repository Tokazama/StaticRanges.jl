@testset "AbstractStepRangeLen" begin
    for frange in (mrange, srange, range)
        @testset "$frange" begin
            r = frange(1.0, step=1, stop=10.0)
            @test stephi(r) == 1
            @test steplo(r) == 0
            @test refhi(r) == 1
            @test reflo(r) == 0
            @test eltype(StepRangeLen{Float64}(r)) == Float64
        end
    end
end

