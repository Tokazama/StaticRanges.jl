# TODO
@testset "size" begin
    for S in (LinSRange(1,3,3),
              StepSRangeLen(1,1,3),
              StepSRange(1,1,3),
              UnitSRange(1,3),
              UnitSRange(UInt(1), UInt(3)),
              OneToSRange(3),
              OneToSRange(UInt(3))
             )
        @test Size(typeof(S)) === Size{(3,)}()
    end
end
