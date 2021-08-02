if !isdefined(Base, :checked_length)
    const checked_length = length
else
    using Base: checked_length
end


@testset "length - tests" begin
    for (r,b) in ((DynamicAxis(10), OneTo(10)),
                  (mrange(1.0, step=2.0, stop=10.0), 1.0:2.0:10.0),
                  (mrange(UInt32(1), step=UInt32(2), stop=UInt32(10)), UInt32(1):UInt32(2):UInt32(10)),
                 )

        @testset "length($r)" begin
            @test @inferred(length(r)) == length(b)
            @test @inferred(length(r)) == length(b)

            @test length(GapRange(1:5, 6:10)) == 10
        end
    end

    @testset "length($(mrange))" begin
        @test length(mrange(.1, step=.1, stop=.3)) == 3
        @test length(mrange(1.1, step=1.1, stop=3.3)) == 3
        @test length(mrange(1.1, step=1.3, stop=3)) == 2
        @test length(mrange(1, step=1, stop=1.8)) == 1
        @test length(mrange(1, step=.2, stop=2)) == 6
        @test length(mrange(1., step=.2, stop=2.)) == 6
        @test length(mrange(2, step=-.2, stop=1)) == 6
        @test length(mrange(2., step=-.2, stop=1.)) == 6
        @test length(mrange(2, step=.2, stop=1)) == 0
        @test length(mrange(2., step=.2, stop=1.)) == 0

        @test length(mrange(1, 0)) == 0
        @test length(mrange(0.0, -0.5)) == 0
        @test length(mrange(1, step=2, stop=0)) == 0
        @test length(mrange(Char(0), Char(0x001fffff))) == 2097152
        @test length(mrange(typemax(UInt64)//one(UInt64), step=1, stop=typemax(UInt64)//one(UInt64))) == 1
    end

    @testset "length(mrange) with typemin/typemax" begin
        let r = mrange(typemin(Int64), step=2, stop=typemax(Int64)), s = mrange(typemax(Int64), step=-2, stop=typemin(Int64))
            @test first(r) == typemin(Int64)
            @test last(r) == (typemax(Int64)-1)
            #@test_throws OverflowError checked_length(r)

            @test first(s) == typemax(Int64)
            @test last(s) == (typemin(Int64)+1)
            #@test_throws OverflowError checked_length(s)
        end

        @test length(mrange(typemin(Int64), step=3, stop=typemax(Int64))) == 6148914691236517206
        @test length(mrange(typemax(Int64), step=-3, stop=typemin(Int64))) == 6148914691236517206

        #= No static type for big
        for s in 3:100
            @test length(mrange(typemin(Int), step=s, stop=typemax(Int))) == length(big(typemin(Int)):big(s):big(typemax(Int)))
            @test length(mrange(typemax(Int), step=-s, stop=typemin(Int))) == length(big(typemax(Int)):big(-s):big(typemin(Int)))
        end
        =#

        #= TODO
        @test length(mrange(UInt(1), step=UInt(1), stop=UInt(0))) == 0
        @test length(mrange(typemax(UInt), step=UInt(1), stop=(typemax(UInt)-1))) == 0
        @test length(mrange(typemax(UInt), step=UInt(2), stop=(typemax(UInt)-1))) == 0
        @test length((mrange(typemin(Int)+3, step=5, stop=(typemin(Int)+1)))) == 0
        =#
    end

    # avoiding intermediate overflow (#5065)
    @test length(mrange(1, step=4, stop=typemax(Int))) == div(typemax(Int),4) + 1

    # issue #6364
    @test length((mrange(1, 64))*(pi/5)) == 64

    @testset "overflow in length($mrange)" begin
        Tset = Int === Int64 ? (Int,UInt,Int128,UInt128) :
                               (Int,UInt,Int64,UInt64,Int128, UInt128)
        for T in Tset
            @test_throws OverflowError checked_length(zero(T):typemax(T))
            @test_throws OverflowError checked_length(typemin(T):typemax(T))
            @test_throws OverflowError checked_length(zero(T):one(T):typemax(T))
            @test_throws OverflowError checked_length(typemin(T):one(T):typemax(T))
            if T <: Signed
                @test_throws OverflowError checked_length(-one(T):typemax(T)-one(T))
                @test_throws OverflowError checked_length(-one(T):one(T):typemax(T)-one(T))
            end
        end
    end
    # small ints
    @test length(DynamicAxis(10)) == 10

    @test length(DynamicAxis(UInt8(10))) == 10
end

