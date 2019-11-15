@testset "Index" begin
    @test keys(Index(1:10)) === 1:10
end
