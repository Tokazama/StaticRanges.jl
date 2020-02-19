
@testset "first" begin
    @testset "can_set_first" begin
        @test @inferred(can_set_first(LinRange)) == false
        @test @inferred(can_set_first(LinMRange)) == true
        @test @inferred(can_set_first(StepMRange)) == true
        @test @inferred(can_set_first(UnitMRange)) == true
        @test @inferred(can_set_first(StepMRangeLen)) == true
    end

 
    for (r1,b,v,r2) in ((UnitMRange(1,3), true, 2, UnitMRange(2,3)),
                        (StepMRange(1,1,4), true, 2, StepMRange(2,1,4)),
                        (StepSRange(1,1,4), false, 2, StepSRange(2,1,4)),
                        (LinMRange(1,3,3), true, 2, LinMRange(2,3,3)),
                        (StepMRangeLen(1,1,3), true, 2, StepMRangeLen(2,1,3)),
                        (StepSRangeLen(1,1,3), false, 2, StepSRangeLen(2,1,3)),
                        ([1,2,3], true, 2, [2,2,3]))
        @testset "set_first-$(r1)" begin
            x = @inferred(can_set_first(r1))
            @test x == b
            if x
                set_first!(r1, v)
                @test r1 == r2
            end
            @test set_first(r1, v) == r2
        end
    end
    @test first(GapRange(2:5, 7:10)) == 2
    @test set_first(Int[], 1) == [1]
end

