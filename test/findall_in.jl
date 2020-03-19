
@testset "find_all(in(x), r)" begin
    r = find_all(in(OneTo(10)), OneToSRange(8))
    @test r == OneTo(8)
    @test isa(r, OneTo) == true

    r = find_all(in(OneTo(10)), OneToMRange(8))
    @test r == OneTo(8)
    @test isa(r, OneToMRange) == true

    r = find_all(in(OneToSRange(8)), OneToSRange(10))
    @test r == OneTo(8)
    @test isa(r, OneToSRange) == true

    r = find_all(in(UnitRange(1,10)), UnitSRange(1,8))
    @test r == OneTo(8)
    @test isa(r, UnitRange) == true

    r = find_all(in(OneTo(10)), UnitMRange(1, 8))
    @test r == OneTo(8)
    @test isa(r, UnitMRange) == true

    r = find_all(in(UnitSRange(1, 8)), UnitSRange(1, 10))
    @test r == UnitSRange(1, 8)
    @test isa(r, UnitSRange) == true

    @test find_all(in(1:10), 1:2:10) == 1:5
    @test find_all(in(1:2:20), 1:8:20) == 1:3
    @test find_all(in(1:2:10), 1:10) == 1:2:9
    @test find_all(in(1:2:10), 1.1:1:10.1) == Int[]
    @test find_all(in(UnitRange(1.1, 10.1)), UnitRange(2.1, 8.1)) == 1:7
    @test find_all(in(UnitRange(2.1, 8.1)), UnitRange(1.1, 10.1)) == 2:8
end
