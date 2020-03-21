
@testset "GapRange" begin
    gr = GapRange(1:4, 5:10)
    @test getindex(gr, 2) == 2
    @test getindex(gr, 6) == 6
    @test getindex(gr, 1:3) == 1:3
    @test getindex(gr, 5:6) == 5:6
    @test getindex(gr, 2:8) == 2:8
    @test getindex(1:20, gr) == 1:10

    @test is_forward(gr)
    @test first(gr) == 1
    @test last(gr) == 10

    @test GapRange(1:5, 6:10) == GapRange(6:10, 1:5)
    @test GapRange(5:-1:1, 10:-1:6) == GapRange(10:-1:6, 5:-1:1)
    @test is_reverse(GapRange(10:-1:6, 5:-1:1))

    for (isf, gr) in (
            (true, GapRange(1, 2:9)),
            (true, GapRange(2:9, 1)),
            (true, GapRange(9, 1:8)),
            (true, GapRange(1:8, 9)),
            (false, GapRange(8:-1:1, 9)),
            (false, GapRange(9:-1:2, 1)),
            (false, GapRange(1, 9:-1:2)),
            (false, GapRange(9, 8:-1:1)))
        @test length(gr) == 9
        if isf
            @test gr == 1:9
            @test is_forward(gr)
        else
            @test is_reverse(gr)
        end
    end

    @test length(GapRange(1, 3)) == 2
    @test is_forward(GapRange(1, 3))

    @test length(GapRange(3, 1)) == 2
    @test is_reverse(GapRange(3, 1))

    @test StaticRanges.first_length(GapRange(1, 3)) == 1
    @test StaticRanges.last_length(GapRange(1, 3)) == 1

    @test is_reverse(GapRange(8:-1:1, 0))
    @test !is_forward(GapRange(8:-1:1, 0))
    @test is_forward(GapRange(9, 1:8))
    @test !is_reverse(GapRange(9, 1:8))

    @testset "iterate" begin
        for (gr_i, r_i) in zip(GapRange(1:5, 6:10), 1:10)
            @test gr_i == r_i
        end
    end

    @test length(GapRange(1, 2:9)) == 9
    @test length(GapRange(1:8, 9)) == 9
    @testset "errors" begin
        # TODO get gaprange tests working with exceptions
        @test_throws ErrorException GapRange(3, 2:9)
        @test_throws ErrorException GapRange(1:8, 3)
        @test_throws ErrorException GapRange(1:8, 1:8)
        @test_throws ErrorException GapRange(8:-1:1, 3)
        @test_throws ErrorException GapRange(3, 8:-1:1)
        @test_throws ErrorException GapRange(8:-1:1, 8:-1:1)
        @test_throws ErrorException GapRange(8:-1:1, 1:8)
        @test_throws ErrorException GapRange(1:8, 8:-1:1)
        @test_throws ErrorException GapRange(1:5, 10:-1:6)
        @test_throws ErrorException GapRange(5:-1:1, 6:10)
        @test_throws ErrorException GapRange{Int,UnitRange{Int},UnitRange{Float64}}(1:3,UnitRange(4.0, 6.0))
    end
end

