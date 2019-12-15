@testset "last" begin
   @testset "can_set_last" begin
        @test @inferred(can_set_last(LinRange)) == false
        @test @inferred(can_set_last(LinMRange)) == true
        @test @inferred(can_set_last(StepMRange)) == true
        @test @inferred(can_set_last(StepMRangeLen)) == true
        @test @inferred(can_set_last(UnitMRange)) == true
        @test @inferred(can_set_last(OneToMRange)) == true
    end

    for (r1,b,v,r2) in ((UnitMRange(1,3), true, 5, UnitMRange(1,5)),
                        (OneToMRange(4), true, 5, OneToMRange(5)),
                        (OneToMRange(4), true, Int32(5), OneToMRange(5)),
                        (StepMRange(1,1,4), true, 5, StepMRange(1,1,5)),
                        (StepSRange(1,1,4), false, nothing, nothing),
                        (LinMRange(1,3,3), true, 4, LinMRange(1,4,3)),
                        (StepMRangeLen(1,1,3), true, 4, StepMRangeLen(1,1,4)),
                        ([1,2,3], true, 2, [1,2,2]))
        @testset "set_last-$(r1)" begin
            x = @inferred(can_set_last(r1))
            @test x == b
            if x
                @test @inferred(set_last!(r1, v)) == r2
            end
            if x
                @test @inferred(set_last(r1, v)) == r2
            end
        end
    end

    @test last(GapRange(2:5, 7:10)) == 10
end
