using StaticRanges: steprange

@testset "steprange" begin
    # steprange_length Int
    @test length(steprange(SVal(1), SVal(1), SVal(5))) == 5
    # steprange_length general
    @test length(steprange(SVal(1.0), SVal(1.0), SVal(5.0))) == 5
    # steprange_last start == stop
    @test last(steprange(SVal(4), SVal(1), SVal(4))) == 4
    # steprange_last general
    @test last(steprange(SVal(1.0), SVal(1.0), SVal(5.0))) == 5.0
    # steprange_last_empty integer
    # steprange_last_empty general
end