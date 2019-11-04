
using Base.Order

@testset "Mutable interface" begin

    @testset "can_setfirst" begin
        @test @inferred(can_setfirst(LinRange)) == false
        @test @inferred(can_setfirst(LinMRange)) == true
        @test @inferred(can_setfirst(StepMRange)) == true
        @test @inferred(can_setfirst(UnitMRange)) == true
    end

    @testset "can_setlast" begin
        @test @inferred(can_setlast(LinRange)) == false
        @test @inferred(can_setlast(LinMRange)) == true
        @test @inferred(can_setlast(StepMRange)) == true
        @test @inferred(can_setlast(UnitMRange)) == true
        @test @inferred(can_setlast(OneToMRange)) == true
    end

    @testset "can_setstep" begin
        @test @inferred(can_setstep(LinRange)) == false
        @test @inferred(can_setstep(LinMRange)) == false
        @test @inferred(can_setstep(StepMRange)) == true
        @test @inferred(can_setstep(StepMRangeLen)) == true
    end

    @testset "can_setlength" begin
        @test @inferred(can_setlength(LinRange)) == false
        @test @inferred(can_setlength(1:10)) == false
        @test @inferred(can_setlength(LinMRange)) == true
        @test @inferred(can_setlength(StepMRangeLen)) == true
    end

    for (r1,b,v,r2) in ((UnitMRange(1,3), true, 2, UnitMRange(2,3)),
                        (StepMRange(1,1,4), true, 2, StepMRange(2,1,4)),
                        (StepSRange(1,1,4), false, nothing, nothing),
                        (LinMRange(1,3,3), true, 2, LinMRange(2,3,3)),
                        (StepMRangeLen(1,1,3), false, nothing, nothing),
                        (StepSRangeLen(1,1,3), false, nothing, nothing),
                        ([1,2,3], true, 2, [2,2,3]))
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
                        ([1,2,3], true, 2, [1,2,2]))
        @testset "setlast-$(r1)" begin
            x = @inferred(can_setlast(r1))
            @test x == b
            if x
                @test @inferred(setlast!(r1, v)) == r2
            end
        end
    end


    @testset "setstep!" begin
        @testset "has_step" begin
            @test @inferred(has_step(OneToMRange{Int})) == true
            @test @inferred(has_step([])) == false
            @test @inferred(has_step(Vector)) == false
        end

        for (r1,b,v,r2) in ((UnitMRange(1,3), false, nothing, nothing),
                            (StepMRange(1,1,4), true, 2, StepMRange(1,2,4)),
                            (StepMRange(1,1,4), true, UInt32(2), StepMRange(1,2,4)),
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

    @testset "setlength!" begin
        @test @inferred(setlength!(LinMRange(1, 10, 5), 10)) == LinMRange(1, 10, 10)
        @test @inferred(setlength!(LinMRange(1, 10, 5), UInt32(10))) == LinMRange(1, 10, 10)
        @test @inferred(setlength!(LinMRange(1,1,0), 1)) == LinMRange(1,1,1)

        @test @inferred(setlength!(StepMRangeLen(1, 1, 10), 11)) == StepMRangeLen(1, 1, 11)
        @test @inferred(setlength!(StepMRangeLen(1, 1, 10), UInt32(11))) == StepMRangeLen(1, 1, 11)
    end

    @testset "setref!" begin
        @test @inferred(setref!(StepMRangeLen(1, 1, 10), 2)) == StepMRangeLen(2, 1, 10)
        @test @inferred(setref!(StepMRangeLen(1, 1, 10), UInt32(2))) == StepMRangeLen(2, 1, 10)
    end

    @testset "setoffset!" begin
        @test @inferred(setoffset!(StepMRangeLen(1, 1, 10), 2)) == StepMRangeLen(1, 1, 10, 2)
        @test @inferred(setoffset!(StepMRangeLen(1, 1, 10), UInt32(2))) == StepMRangeLen(1, 1, 10, 2)
    end

    @testset "isstatic" begin
        @test @inferred(isstatic(Any[])) == false
        @test @inferred(isstatic(UnitSRange(1, 10))) == true
    end

    @testset "isstatic" begin
        @test @inferred(isstatic(Any[])) == false
        @test @inferred(isstatic(UnitSRange(1, 10))) == true
    end

    @testset "isforward" begin
        @test @inferred(isforward([1, 2, 3])) == true
        @test @inferred(isforward(Forward)) == true
        @test @inferred(isforward(Reverse)) == false
        @test @inferred(isforward(UnitSRange(1, 10))) == true
    end
    @testset "isreverse" begin
        @test @inferred(isreverse([1, 2, 3])) == false
        @test @inferred(isreverse(Forward)) == false
        @test @inferred(isreverse(Reverse)) == true
        @test @inferred(isreverse(UnitSRange(1, 10))) == false
    end
end
