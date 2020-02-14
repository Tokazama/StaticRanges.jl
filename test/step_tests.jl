@testset "step(r)" begin
    @testset "can_set_step" begin
        @test @inferred(can_set_step(LinRange)) == false
        @test @inferred(can_set_step(LinMRange)) == false
        @test @inferred(can_set_step(StepMRange)) == true
        @test @inferred(can_set_step(StepMRangeLen)) == true
    end
    @testset "set_step!" begin
        @testset "has_step" begin
            @test @inferred(has_step(OneToMRange{Int})) == true
            @test @inferred(has_step([])) == false
            @test @inferred(has_step(Vector)) == false
        end
        @test_throws ErrorException set_step!(OneToMRange(10), 2)
        @test_throws ErrorException set_step!(UnitMRange(1, 10), 2)


        for (r1,b,v,r2) in ((UnitMRange(1,3), false, nothing, nothing),
                            (StepMRange(1,1,4), true, 2, StepMRange(1,2,4)),
                            (StepMRange(1,1,4), true, UInt32(2), StepMRange(1,2,4)),
                            (StepMRangeLen(1,1,4), true, 2, StepMRangeLen(1,2,4)))
            @testset "set_step!-$(r1)" begin
                x = @inferred(can_set_step(r1))
                @test x == b
                if x
                    @test @inferred(set_step(r1, v)) == r2
                    @test @inferred(set_step!(r1, v)) == r2
                end
            end
        end
    end

    @test set_step(StepSRangeLen(1,1,4), 2) == StepSRangeLen(1,2,4)

    @test set_step(StepSRangeLen(1,1,4), 2) == StepSRangeLen(1,2,4)
    @test set_step(StepRangeLen(1,1,4), 2) == StepRangeLen(1,2,4)


    for (r,b) in ((OneToMRange(10), OneTo(10)),
                  (OneToSRange(UInt(10)), OneTo(UInt(10))),
                  (UnitMRange(1, 10), UnitRange(1, 10)),
                  (UnitSRange(1.,10.), UnitRange(1.0, 10.0)),
                  (StepMRange(1, 2, 10), StepRange(1, 2, 10)),
                  (StepSRange(UInt32(1), UInt32(2), UInt32(10)), StepRange(UInt32(1), UInt32(2), UInt32(10))),
                  (mrange(1.0, step=2.0, stop=10.0), 1.0:2.0:10.0),
                  (srange(UInt32(1), step=UInt32(2), stop=UInt32(10)), UInt32(1):UInt32(2):UInt32(10)),
                 )
        @test @inferred(step(r)) === step(b)
        @test @inferred(step_hp(r)) === step_hp(b)
        if b isa StepRangeLen
            @test @inferred(stephi(r)) == stephi(b)
            @test @inferred(steplo(r)) == steplo(b)
        end
    end
end
