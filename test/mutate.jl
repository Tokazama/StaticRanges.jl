
@testset "Mutable interface" begin
    for (r1,b,v,r2) in ((UnitMRange(1,3), true, 2, UnitMRange(2,3)),
                        (StepMRange(1,1,4), true, 2, StepMRange(2,1,4)),
                        (StepSRange(1,1,4), false, nothing, nothing),
                        (LinMRange(1,3,3), true, 2, LinMRange(2,3,3)),
                        (StepMRangeLen(1,1,3), false, nothing, nothing),
                        (StepSRangeLen(1,1,3), false, nothing, nothing),
                       )
        @testset "setfirst-$(r1)" begin
            x = @inferred(can_setfirst(r1))
            @test x == b
            if x
                @test @inferred(setfirst!(r1, v)) == r2
            end
        end
    end

    for (r1,b,v,r2) in ((UnitMRange(1,3), true, 5, UnitMRange(1,5)),
                        (OneToMRange(4), true, 5, OneToMRange(5)),
                        (OneToMRange(4), true, Int32(5), OneToMRange(5)),
                        (StepMRange(1,1,4), true, 5, StepMRange(1,1,5)),
                        (StepSRange(1,1,4), false, nothing, nothing),
                        (LinMRange(1,3,3), true, 4, LinMRange(1,4,3)),
                       )
        @testset "setlast-$(r1)" begin
            x = @inferred(can_setlast(r1))
            @test x == b
            if x
                @test @inferred(setlast!(r1, v)) == r2
            end
        end
    end

    @testset "step" begin
        @testset "has_step" begin
            @test @inferred(has_step(OneToMRange{Int})) == true
            @test @inferred(has_step([])) == false
        end

        for (r1,b,v,r2) in ((UnitMRange(1,3), false, nothing, nothing),
                            (StepMRange(1,1,4), true, 2, StepMRange(1,2,4)),
                            (StepMRangeLen(1,1,4), true, 2, StepMRangeLen(1,2,4)),
                           )

            @testset "setstep!-$(r1)" begin
                x = @inferred(can_setstep(r1))
                @test x == b
                if x
                    @test @inferred(setstep!(r1, v)) == r2
                end
            end
        end
    end
end
