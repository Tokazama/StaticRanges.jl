
@testset "first" begin
    @testset "can_set_first" begin
        @test @inferred(can_set_first(Axis(UnitMRange(1, 2)))) == true
        @test @inferred(can_set_first(Axis(UnitSRange(1, 2)))) == false
    end

 
    for (r1,b,v,r2) in ((SimpleAxis(UnitMRange(1,3)), true, 2, SimpleAxis(UnitMRange(2,3))),
                        (Axis(UnitMRange(1,3),UnitMRange(1,3)), true, 2, Axis(UnitMRange(2,3),UnitMRange(2,3))))
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
end

@testset "last" begin
   @testset "can_set_last" begin
       @test @inferred(can_set_last(Axis(UnitMRange(1:2)))) == true
        @test @inferred(can_set_last(Axis(UnitSRange(1:2)))) == false
    end

    for (r1,b,v,r2) in ((SimpleAxis(UnitMRange(1,3)), true, 2, SimpleAxis(UnitMRange(1,2))),
                        (Axis(UnitMRange(1,3),UnitMRange(1,3)), true, 2, Axis(UnitMRange(1,2),UnitMRange(1,2))))
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

@testset "step(r)" begin
    for (r,b) in ((SimpleAxis(OneToMRange(10)), OneToMRange(10)),)
        @test @inferred(step(r)) === step(b)
        @test @inferred(step_hp(r)) === step_hp(b)
        if b isa StepRangeLen
            @test @inferred(stephi(r)) == stephi(b)
            @test @inferred(steplo(r)) == steplo(b)
        end
    end
end

@testset "length - tests" begin
    @testset "length(r)" begin
        for (r,b) in ((SimpleAxis(UnitMRange(1,3)), 1:3),
                      (Axis(UnitMRange(1,3),UnitMRange(1,3)), 1:3)
                     )
            @test @inferred(length(r)) == length(b)
            @test @inferred(length(r)) == length(b)
            if b isa StepRangeLen
                @test @inferred(stephi(r)) == stephi(b)
                @test @inferred(steplo(r)) == steplo(b)
            end

            @test length(GapRange(1:5, 6:10)) == 10
        end
    end

    @testset "can_set_length" begin
        @test @inferred(can_set_length(Axis(UnitMRange(1:2)))) == true
        @test @inferred(can_set_length(Axis(UnitSRange(1:2)))) == false
    end

    @testset "set_length!" begin
        @test @inferred(set_length!(SimpleAxis(OneToMRange(10)), UInt32(11))) == SimpleAxis(OneToMRange(11))
        @test @inferred(set_length!(Axis(OneToMRange(10), OneToMRange(10)), UInt32(11))) == Axis(OneToMRange(11), OneToMRange(11))
    end

    @testset "set_length" begin
        @test @inferred(set_length(SimpleAxis(OneToMRange(10)), UInt32(11))) == SimpleAxis(OneToMRange(11))
        @test @inferred(set_length(Axis(OneToMRange(10), OneToMRange(10)), UInt32(11))) == Axis(OneToMRange(11), OneToMRange(11))
    end
end
