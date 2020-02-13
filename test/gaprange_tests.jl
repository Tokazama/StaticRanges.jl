
@testset "GapRange" begin
    gr = GapRange(1:4, 5:10)
    @test getindex(gr, 2) == 2
    @test getindex(gr, 6) == 6
    @test getindex(gr, 1:3) == 1:3
    @test getindex(gr, 5:6) == 5:6
    @test getindex(gr, 2:8) == 2:8

    @test first(gr) == 1
    @test last(gr) == 10

    @test GapRange(1, 2:9) == 1:9
    @test GapRange(2:9, 1) == 1:9
    @test GapRange(9, 1:8) == 1:9
    @test GapRange(1:8, 9) == 1:9
    @test GapRange(8:-1:1, 0) == 8:-1:0
    @test GapRange(0, 8:-1:1) == 8:-1:0
    @test GapRange(8:-1:1, 9) == 9:-1:1
    @test GapRange(9, 8:-1:1) == 9:-1:1


    @test length(GapRange(1, 2:9)) == 9
    @test length(GapRange(1:8, 9)) == 9
    # TODO get gaprange tests working with exceptions
    @test_throws ErrorException GapRange(3, 2:9)
    @test_throws ErrorException GapRange(1:8, 3)
    @test_throws ErrorException GapRange(1:8, 1:8)
    @test_throws ErrorException GapRange(8:-1:1, 3)
    @test_throws ErrorException GapRange(3, 8:-1:1)
    @test_throws ErrorException GapRange(8:-1:1, 8:-1:1)
    @test_throws ErrorException GapRange(8:-1:1, 1:8)
    @test_throws ErrorException GapRange(1:8, 8:-1:1)
end
