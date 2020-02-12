

@testset "nitty_gritty_promote_rules" begin
    onetosrange_type = typeof(OneToSRange(10))
    stepsrange_type = typeof(StepSRange(1, 1, 2))
    stepsrangelen_type = typeof(StepSRangeLen(1, 2, 3))
    unitsrange_type = typeof(UnitSRange(1, 2))
    linsrange_type = typeof(LinSRange(1.5, 5.5, 9))

    onetomrange_type = typeof(OneToMRange(10))
    stepmrange_type = typeof(StepMRange(1, 1, 2))
    stepmrangelen_type = typeof(StepMRangeLen(1, 2, 3))
    unitmrange_type = typeof(UnitMRange(1, 2))
    linmrange_type = typeof(LinMRange(1.5, 5.5, 9))

    onetorange_type = typeof(OneTo(10))
    steprange_type = typeof(StepRange(1, 1, 2))
    steprangelen_type = typeof(StepRangeLen(1, 2, 3))
    unitrange_type = typeof(UnitRange(1, 2))
    linrange_type = typeof(LinRange(1.5, 5.5, 9))

    @testset "similar_range" begin
        @test StaticRanges.similar_range(stepmrange_type, stepmrange_type) == mrange
        @test StaticRanges.similar_range(stepsrange_type, stepsrange_type) == srange
        @test StaticRanges.similar_range(steprange_type, steprange_type) == range

        @test StaticRanges.similar_range(stepmrange_type, stepsrange_type) == mrange
        @test StaticRanges.similar_range(stepsrange_type, stepmrange_type) == mrange

        @test StaticRanges.similar_range(stepmrange_type, steprange_type) == mrange
        @test StaticRanges.similar_range(steprange_type, stepmrange_type) == mrange

        @test StaticRanges.similar_range(steprange_type, stepsrange_type) == range
        @test StaticRanges.similar_range(stepsrange_type, steprange_type) == range
    end

    @testset "promote_rule" begin
        # within type promotion
        @test promote_rule(onetosrange_type, typeof(OneToSRange(5))) <: OneToSRange
        @test promote_rule(onetomrange_type, typeof(OneToMRange(5))) <: OneToMRange

        @test promote_rule(unitsrange_type, typeof(UnitSRange(2,3))) <: UnitSRange
        @test promote_rule(unitmrange_type, typeof(UnitMRange(2,3))) <: UnitMRange

        @test promote_rule(stepsrange_type, typeof(StepSRange(1,3,9))) <: StepSRange
        @test promote_rule(stepmrange_type, typeof(StepMRange(1,3,9))) <: StepMRange

        @test promote_rule(linmrange_type, typeof(LinMRange(1,3,9))) <: LinMRange
        @test promote_rule(linsrange_type, typeof(LinSRange(1,3,9))) <: LinSRange

        @test promote_rule(stepsrangelen_type, typeof(StepSRangeLen(1,3,9))) <: StepSRangeLen
        @test promote_rule(stepmrangelen_type, typeof(StepMRangeLen(1,3,9))) <: StepMRangeLen

        # many combinations
        @test promote_rule(unitsrange_type, onetosrange_type) <: UnitSRange
        @test promote_rule(onetosrange_type, unitsrange_type) <: UnitSRange

        @test promote_rule(unitmrange_type, stepmrange_type) <: StepMRange
        @test promote_rule(stepmrange_type, unitmrange_type) <: StepMRange

        @test promote_rule(unitmrange_type, onetomrange_type) <: UnitMRange
        @test promote_rule(onetomrange_type, unitmrange_type) <: UnitMRange

        @test promote_rule(onetomrange_type, onetorange_type) <: OneToMRange
        @test promote_rule(onetorange_type, onetomrange_type) <: OneToMRange

        @test promote_rule(onetorange_type, onetosrange_type) <: OneTo
        @test promote_rule(onetomrange_type, onetorange_type) <: OneToMRange

        @test promote_rule(unitmrange_type, linmrange_type) <: LinMRange
        @test promote_rule(linmrange_type, unitmrange_type) <: LinMRange

        @test promote_rule(linmrange_type, stepmrange_type) <: LinMRange
        @test promote_rule(stepmrange_type, linmrange_type) <: LinMRange

        @test promote_rule(onetomrange_type, linmrange_type) <: LinMRange
        @test promote_rule(linmrange_type, onetomrange_type) <: LinMRange

        @test promote_rule(onetosrange_type, linsrange_type) <: LinSRange
        @test promote_rule(linsrange_type, onetosrange_type) <: LinSRange

        @test promote_rule(unitsrange_type, linsrange_type) <: LinSRange
        @test promote_rule(linsrange_type, unitsrange_type) <: LinSRange

        @test promote_rule(onetosrange_type, stepsrange_type) <: StepSRange
        @test promote_rule(stepsrange_type, onetosrange_type) <: StepSRange

        @test promote_rule(stepmrange_type, stepsrange_type) <: StepMRange
        @test promote_rule(stepsrange_type, stepmrange_type) <: StepMRange

        @test promote_rule(stepsrange_type, linsrange_type) <: LinSRange
        @test promote_rule(linsrange_type, stepsrange_type) <: LinSRange

        @test promote_rule(stepsrange_type, stepsrangelen_type) <: StepSRangeLen
        @test promote_rule(stepsrangelen_type, stepsrange_type) <: StepMRangeLen
        @test promote_rule(stepmrangelen_type, stepmrange_type) <: StepMRangeLen
        @test promote_rule(stepsrange_type, stepmrangelen_type) <: StepMRangeLen
    end

    @testset "lower_rangetype" begin
        @test StaticRanges.lower_rangetype(onetomrange_type) <: OneToMRange
        @test StaticRanges.lower_rangetype(onetorange_type) <: OneToMRange
        @test StaticRanges.lower_rangetype(onetosrange_type) <: OneTo

        @test StaticRanges.lower_rangetype(unitmrange_type) <: UnitMRange
        @test StaticRanges.lower_rangetype(unitrange_type) <: UnitMRange
        @test StaticRanges.lower_rangetype(unitsrange_type) <: UnitRange

        @test StaticRanges.lower_rangetype(stepmrange_type) <: StepMRange
        @test StaticRanges.lower_rangetype(steprange_type) <: StepMRange
        @test StaticRanges.lower_rangetype(stepsrange_type) <: StepRange

        @test StaticRanges.lower_rangetype(stepmrangelen_type) <: StepMRangeLen
        @test StaticRanges.lower_rangetype(steprangelen_type) <: StepMRangeLen
        @test StaticRanges.lower_rangetype(stepsrangelen_type) <: StepRangeLen

        @test StaticRanges.lower_rangetype(linmrange_type) <: LinMRange
        @test StaticRanges.lower_rangetype(linrange_type) <: LinMRange
        @test StaticRanges.lower_rangetype(linsrange_type) <: LinRange
    end

    @testset "same_type" begin
        for (x, y) in ((OneToSRange(1),OneToSRange(2)),
                       (UnitSRange(1, 2), UnitSRange(1, 10)),
                       (StepSRange(1, 1, 2), StepSRange(2, 2, 6)),
                       (LinSRange(1.5, 5.5, 9), LinSRange(2, 3, 4)),
                       (StepSRangeLen(1, 2, 3), StepSRangeLen(1, 2, 4)),
                      )
            @test StaticRanges.same_type(typeof(x), typeof(y))
        end
    end
end
