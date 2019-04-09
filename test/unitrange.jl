
using StaticRanges: unitrange_last, unitrange_length, unitrange

@testset "unitrange" begin
    @testset "last" begin
        @test @inferred(unitrange_last(SVal(true), SVal(false))) == SVal(false)
        @test @inferred(unitrange_last(SVal(4), SVal(2))) == SVal(3)
        @test @inferred(unitrange_last(SVal(1.0), SVal(3.0))) == SVal(3.0)
        @test @inferred(unitrange_last(SVal(1), SVal(2))) == SVal(2)
    end
    #=
    @unittest "length" begin
    end
    =#

    @testset "unitrange" begin
        @test @inferred(unitrange(SVal(4), SVal(2))) == srange(4:3)
        @test @inferred(unitrange(SVal(1), SVal(2))) == srange(1:2)
    end
end