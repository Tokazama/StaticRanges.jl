@testset "nitty_gritty_promote_rules" begin
    onetomrange_type = typeof(OneToMRange(10))

    onetorange_type = typeof(OneTo(10))
    steprange_type = typeof(StepRange(1, 1, 2))
    steprangelen_type = typeof(StepRangeLen(1, 2, 3))
    unitrange_type = typeof(UnitRange(1, 2))


    @testset "promote_rule" begin
        # within type promotion
        @test promote_rule(onetomrange_type, typeof(OneToMRange(5))) <: OneToMRange




        # many combinations


        @test promote_rule(onetomrange_type, onetorange_type) <: OneToMRange
        @test promote_rule(onetorange_type, onetomrange_type) <: OneToMRange


        @test promote_rule(onetorange_type, onetomrange_type) <: OneToMRange
        @test promote_rule(onetomrange_type, onetorange_type) <: OneToMRange







        @test promote_rule(onetorange_type, unitrange_type) <: UnitRange{Int}
        @test promote_rule(unitrange_type, onetorange_type) <: UnitRange{Int}


    end

    @testset "lower_rangetype" begin
        @test StaticRanges.lower_rangetype(onetomrange_type) <: OneToMRange
        @test StaticRanges.lower_rangetype(onetorange_type) <: OneToMRange

    end

end
