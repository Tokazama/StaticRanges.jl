
@testset "find_all(in(x), r)" begin
    r = @inferred(find_all(in(OneTo(10)), OneToSRange(8)))
    @test r == 1:8
    @test isa(r, StaticRanges.OneToUnion)

    r = @inferred(find_all(in(OneTo(10)), OneToMRange(8)))
    @test r == 1:8
    @test isa(r, StaticRanges.OneToUnion)

    r = @inferred(find_all(in(OneToSRange(8)), OneToSRange(10)))
    @test r == 1:8
    @test isa(r, OneToSRange)

    r = @inferred(find_all(in(UnitRange(1,10)), UnitSRange(1,8)))
    @test r == 1:8
    @test isa(r, UnitRange)

    r = @inferred(find_all(in(OneTo(10)), UnitMRange(1, 8)))
    @test r == OneTo(8)
    @test isa(r, UnitMRange) == true

    r = @inferred(find_all(in(UnitSRange(1, 8)), UnitSRange(1, 10)))
    @test r == UnitSRange(1, 8)
    @test isa(r, UnitSRange)

    @test find_all(in(collect(1:10)), 1:20) == find_all(in(1:10), 1:20)

    @testset "steps match but no overlap" begin
        r = @inferred(findin(1:3, 4:5))
        @test r == 1:0
        @test isa(r, UnitRange)
    end

    for (x, y, z) in ((1:10, 1:2:10, 1:5),
                      (1:2:20, 1:8:20, 1:3),
                      (1:2:20, 1:10, 1:2:9),
                      (1:2:10, 1.1:1:10.1, []),
                      (UnitRange(1.1, 10.1), UnitRange(2.1, 8.1), 1:7),
                      (UnitRange(2.1, 8.1), UnitRange(1.1, 10.1), 2:8)
                     )
        @testset "find_all(in($x), $y)" begin
            @test @inferred(find_all(in(x), y)) == z
        end
    end

    @testset "find_all(in(::IntervalSets), r)" begin
        for (i,t) in ((Interval{:closed,:closed}(1, 10), 1:10),
                      (Interval{:open,:closed}(1, 10), 2:10),
                      (Interval{:closed,:open}(1, 10), 1:9),
                      (Interval{:open,:open}(1, 10), 2:9))
            @test find_all(in(i), 1:10) == t
        end
    end
end


