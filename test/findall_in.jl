
@testset "find_all(in(x), r)" begin
    r = @inferred(find_all(in(OneTo(10)), OneToSRange(8)))
    @test r == 1:8
    @test isa(r, UnitRange)

    r = @inferred(find_all(in(OneTo(10)), OneToMRange(8)))
    @test r == 1:8
    @test isa(r, UnitMRange)

    r = @inferred(find_all(in(OneToSRange(8)), OneToSRange(10)))
    @test r == 1:8
    @test isa(r, UnitSRange)

    r = @inferred(find_all(in(UnitRange(1,10)), UnitSRange(1,8)))
    @test r == 1:8
    @test isa(r, UnitRange)

    r = @inferred(find_all(in(OneTo(10)), UnitMRange(1, 8)))
    @test r == OneTo(8)
    @test isa(r, UnitMRange) == true

    r = @inferred(find_all(in(UnitSRange(1, 8)), UnitSRange(1, 10)))
    @test r == UnitSRange(1, 8)
    @test isa(r, UnitSRange)

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
end

