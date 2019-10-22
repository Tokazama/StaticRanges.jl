
for frange in (mrange, srange)
    @testset "findfirst-$(frange)" begin
        @test findfirst(isequal(7), frange(1, step=2, stop=10)) == 4
        @test findfirst(==(7), frange(1, step=2, stop=10)) == 4
        @test findfirst(==(10), frange(1, step=2, stop=10)) == nothing
        @test findfirst(==(11), frange(1, step=2, stop=10)) == nothing
    end
end

step_range = StepMRange(1,1,4)
lin_range = LinMRange(1,4,4)
oneto_range = OneToMRange(10)

@testset "findfirst" begin
    @test findfirst(isequal(3), step_range) == 3
    @test findfirst(isequal(3), lin_range) == 3
    @test findfirst(isequal(3), oneto_range) == 3
end
