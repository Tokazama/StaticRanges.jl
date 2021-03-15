@testset "nitty_gritty_promote_rules" begin
    onetomrange_type = typeof(DynamicAxis(10))

    onetorange_type = typeof(OneTo(10))
    steprange_type = typeof(StepRange(1, 1, 2))
    steprangelen_type = typeof(StepRangeLen(1, 2, 3))
    unitrange_type = typeof(UnitRange(1, 2))


    @testset "promote_rule" begin
        # within type promotion
        @test promote_rule(onetomrange_type, typeof(DynamicAxis(5))) <: DynamicAxis

        @test promote_rule(onetomrange_type, onetorange_type) <: DynamicAxis
        @test promote_rule(onetorange_type, onetomrange_type) <: DynamicAxis


        @test promote_rule(onetorange_type, onetomrange_type) <: DynamicAxis
        @test promote_rule(onetomrange_type, onetorange_type) <: DynamicAxis







        @test promote_rule(onetorange_type, unitrange_type) <: UnitRange{Int}
        @test promote_rule(unitrange_type, onetorange_type) <: UnitRange{Int}


    end

    @testset "lower_rangetype" begin
        @test StaticRanges.lower_rangetype(onetomrange_type) <: DynamicAxis
        @test StaticRanges.lower_rangetype(onetorange_type) <: DynamicAxis

    end

end
