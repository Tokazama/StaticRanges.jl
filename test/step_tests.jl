@testset "step(r)" begin
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
