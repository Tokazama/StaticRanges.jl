
@testset "GapRange" begin
    gr = GapRange(1:4, 5:10)
    gr2 = gr[2:8]
    @test getindex(gr, 2) == 2
    @test getindex(gr, 6) == 6
end
