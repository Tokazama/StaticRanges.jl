
@testset "Continuity" begin
    @test Continuity(Vector{Int}) == Discrete
    @test Continuity(UnitRange{Int}) == Continuous
    @test Continuity(1:10) == Continuous
end
