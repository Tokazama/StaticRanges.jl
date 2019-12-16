@testset "length - tests" begin
    @testset "length(r)" begin
        for (r,b) in ((OneToMRange(10), OneTo(10)),
                      (OneToSRange(UInt(10)), OneTo(UInt(10))),
                      (UnitMRange(1, 10), UnitRange(1, 10)),
                      (UnitSRange(1.,10.), UnitRange(1.0, 10.0)),
                      (UnitMRange(UInt(1), UInt(10)), UnitRange(UInt(1), UInt(10))),
                      (UnitSRange(UInt(1), UInt(10)), UnitRange(UInt(1), UInt(10))),
                      (StepMRange(1, 2, 10), StepRange(1, 2, 10)),
                      (StepSRange(UInt32(1), UInt32(2), UInt32(10)), StepRange(UInt32(1), UInt32(2), UInt32(10))),
                      (mrange(1.0, step=2.0, stop=10.0), 1.0:2.0:10.0),
                      (srange(UInt32(1), step=UInt32(2), stop=UInt32(10)), UInt32(1):UInt32(2):UInt32(10)),
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
        @test @inferred(can_set_length(LinRange)) == false
        @test @inferred(can_set_length(1:10)) == false
        @test @inferred(can_set_length(LinMRange)) == true
        @test @inferred(can_set_length(StepMRangeLen)) == true
        @test @inferred(can_set_length(StepMRange)) == true
        @test @inferred(can_set_length(UnitMRange)) == true
        @test @inferred(can_set_length(OneToMRange)) == true
    end

    @testset "set_length!" begin
        @test @inferred(set_length!(LinMRange(1, 10, 5), 10)) == LinMRange(1, 10, 10)
        @test @inferred(set_length!(LinMRange(1, 10, 5), UInt32(10))) == LinMRange(1, 10, 10)
        @test @inferred(set_length!(LinMRange(1,1,0), 1)) == LinMRange(1,1,1)
        @test @inferred(set_length!(StepMRangeLen(1, 1, 10), 11)) == StepMRangeLen(1, 1, 11)
        @test @inferred(set_length!(StepMRangeLen(1, 1, 10), UInt32(11))) == StepMRangeLen(1, 1, 11)
        @test @inferred(set_length!(StepMRange(1, 1, 10), UInt32(11))) == StepMRange(1, 1, 11)
        @test @inferred(set_length!(UnitMRange(2, 10), 10)) == UnitMRange(2, 11)
        @test @inferred(set_length!(OneToMRange(10), UInt32(11))) == OneToMRange(11)
    end

    @testset "set_length" begin
        @test @inferred(set_length(LinMRange(1, 10, 5), 10)) == LinMRange(1, 10, 10)
        @test @inferred(set_length(LinMRange(1, 10, 5), UInt32(10))) == LinMRange(1, 10, 10)
        @test @inferred(set_length(LinMRange(1,1,0), 1)) == LinMRange(1,1,1)
        @test @inferred(set_length(StepMRangeLen(1, 1, 10), 11)) == StepMRangeLen(1, 1, 11)
        @test @inferred(set_length(StepMRangeLen(1, 1, 10), UInt32(11))) == StepMRangeLen(1, 1, 11)
        @test @inferred(set_length(StepMRange(1, 1, 10), UInt32(11))) == StepMRange(1, 1, 11)
        @test @inferred(set_length(UnitMRange(2, 10), 10)) == UnitMRange(2, 11)
        @test @inferred(set_length(OneToMRange(10), UInt32(11))) == OneToMRange(11)
    end

    @testset "set_lediv!" begin
        @test @inferred(set_lendiv!(LinMRange(1, 10, 5), 9)) == LinMRange(1, 10, 10)
        @test @inferred(set_lendiv!(LinMRange(1, 10, 5), UInt32(9))) == LinMRange(1, 10, 10)
    end

    for frange in (mrange, srange)
        @testset "length($(frange))" begin
            @test length(frange(.1, step=.1, stop=.3)) == 3
            @test length(frange(1.1, step=1.1, stop=3.3)) == 3
            @test length(frange(1.1, step=1.3, stop=3)) == 2
            @test length(frange(1, step=1, stop=1.8)) == 1
            @test length(frange(1, step=.2, stop=2)) == 6
            @test length(frange(1., step=.2, stop=2.)) == 6
            @test length(frange(2, step=-.2, stop=1)) == 6
            @test length(frange(2., step=-.2, stop=1.)) == 6
            @test length(frange(2, step=.2, stop=1)) == 0
            @test length(frange(2., step=.2, stop=1.)) == 0

            @test length(frange(1, 0)) == 0
            @test length(frange(0.0, -0.5)) == 0
            @test length(frange(1, step=2, stop=0)) == 0
            @test length(frange(Char(0), Char(0x001fffff))) == 2097152
            @test length(frange(typemax(UInt64)//one(UInt64), step=1, stop=typemax(UInt64)//one(UInt64))) == 1
        end

        @testset "length($(frange)) with typemin/typemax" begin
            let r = frange(typemin(Int64), step=2, stop=typemax(Int64)), s = frange(typemax(Int64), step=-2, stop=typemin(Int64))
                @test first(r) == typemin(Int64)
                @test last(r) == (typemax(Int64)-1)
                #@test_throws OverflowError length(r)

                @test first(s) == typemax(Int64)
                @test last(s) == (typemin(Int64)+1)
                #@test_throws OverflowError length(s)
            end

            @test length(frange(typemin(Int64), step=3, stop=typemax(Int64))) == 6148914691236517206
            @test length(frange(typemax(Int64), step=-3, stop=typemin(Int64))) == 6148914691236517206

            #= No static type for big
            for s in 3:100
                @test length(frange(typemin(Int), step=s, stop=typemax(Int))) == length(big(typemin(Int)):big(s):big(typemax(Int)))
                @test length(frange(typemax(Int), step=-s, stop=typemin(Int))) == length(big(typemax(Int)):big(-s):big(typemin(Int)))
            end
            =#

            #= TODO
            @test length(frange(UInt(1), step=UInt(1), stop=UInt(0))) == 0
            @test length(frange(typemax(UInt), step=UInt(1), stop=(typemax(UInt)-1))) == 0
            @test length(frange(typemax(UInt), step=UInt(2), stop=(typemax(UInt)-1))) == 0
            @test length((frange(typemin(Int)+3, step=5, stop=(typemin(Int)+1)))) == 0
            =#
        end

        # avoiding intermediate overflow (#5065)
        @test length(frange(1, step=4, stop=typemax(Int))) == div(typemax(Int),4) + 1

        # issue #6364
        @test length((frange(1, 64))*(pi/5)) == 64

        @testset "overflow in length($frange)" begin
            Tset = Int === Int64 ? (Int,UInt,Int128,UInt128) :
                                   (Int,UInt,Int64,UInt64,Int128, UInt128)
            for T in Tset
                @test_throws OverflowError length(zero(T):typemax(T))
                @test_throws OverflowError length(typemin(T):typemax(T))
                @test_throws OverflowError length(zero(T):one(T):typemax(T))
                @test_throws OverflowError length(typemin(T):one(T):typemax(T))
                if T <: Signed
                    @test_throws OverflowError length(-one(T):typemax(T)-one(T))
                    @test_throws OverflowError length(-one(T):one(T):typemax(T)-one(T))
                end
            end
        end
        # small ints
        @test length(StepMRange(UInt16(1), UInt16(1), UInt16(10))) == 10
        @test length(StepMRange(UInt16(1), UInt16(1), UInt16(0))) == 0
        @test length(OneToMRange{Int16}(10)) == 10

    end
end
