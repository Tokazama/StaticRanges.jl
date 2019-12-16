
@testset "GapRange" begin
    gr = GapRange(1:4, 5:10)
    @test getindex(gr, 2) == 2
    @test getindex(gr, 6) == 6
    @test getindex(gr, 1:3) == 1:3
    @test getindex(gr, 5:6) == 5:6
    @test getindex(gr, 2:8) == 2:8
end
