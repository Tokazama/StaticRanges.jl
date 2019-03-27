using StaticRanges, Test

@testset "ranges" begin
    @test size(10:1:0) == (0,)
    @testset "colon" begin
        #@inferred((:)(10, 1, 0))
        @inferred(srange(Val(10), step=Val(1), stop=Val(0)))

        #= these differ from Base because I haven't implemented StepRangeLen double precision
        #@inferred((:)(1, .2, 2))
        @inferred(srange(Val(1), step=Val(.2), stop=Val(2)))

        #@inferred((:)(1., .2, 2.))
        @inferred(srange(Val(1.), step=Val(.2), stop=Val(2.)))

        #@inferred((:)(2, -.2, 1))
        @inferred(srange(Val(2), step=Val(-.2), stop=Val(1)))

        #@inferred((:)(0.0, -0.5))
        @inferred(srange(Val(0.0), Val(-0.5)))

        =#
        #@inferred((:)(1, 0))
        @inferred(srange(Val(1),Val(0)))
    end

    @testset "indexing" begin
        # TODO: requires high precision
        L32 = @inferred(srange(Val(Int32(1)), stop=Val(Int32(4)), length=Val(4)))
        L64 = @inferred(srange(Val(Int64(1)), stop=Val(Int64(4)), length=Val(4)))
        @test @inferred(L32[1]) === 1.0 && @inferred(L64[1]) === 1.0
        @test L32[2] == 2 && L64[2] == 2
        @test L32[3] == 3 && L64[3] == 3
        @test L32[4] == 4 && L64[4] == 4
        @test @inferred(srange(1.0, stop=2.0, length=2))[1] === 1.0
        @test @inferred(srange(1.0f0, stop=2.0f0, length=2))[1] === 1.0f0
        @test @inferred(srange(Float16(1.0), stop=Float16(2.0), length=2))[1] === Float16(1.0)

        let r = srange(5:-1:1)
            @test r[1]==5
            @test r[2]==4
            @test r[3]==3
            @test r[4]==2
            @test r[5]==1
        end
        @test @inferred(srange(0.1:0.1:0.3)[2]) === 0.2
        @test @inferred(srange(0.1f0:0.1f0:0.3f0)[2]) === 0.2f0

        @test @inferred(srange(1:5)[1:4]) === srange(1:4)       # TODO
        @test @inferred(srange(1.0:5)[1:4]) === srange(1.0:4)   # TODO
        @test srange(2:6)[1:4] == srange(2:5)
        @test srange(1:6)[2:5] === srange(2:5)
        @test srange(1:6)[2:2:5] === srange(2:2:4)
        @test srange(1:2:13)[2:6] === srange(3:2:11)
        @test srange(1:2:13)[2:3:7] === srange(3:6:13)

        @test isempty(srange(1:4)[5:4])
        @test_throws BoundsError srange(1:10)[8:-1:-2]          # TODO

        let r = srange(typemax(Int)-5:typemax(Int)-1)
            @test_throws BoundsError r[7]
        end
    end
    @testset "length" begin
        @test length(srange(.1:.1:.3)) == 3
        @test length(srange(1.1:1.1:3.3)) == 3
        @test length(srange(1.1:1.3:3)) == 2
        @test length(srange(1:1:1.8)) == 1
        @test length(srange(1:.2:2)) == 6
        @test length(srange(1.:.2:2.)) == 6
        @test length(srange(2:-.2:1)) == 6
        @test length(srange(2.:-.2:1.)) == 6
        @test length(srange(2:.2:1)) == 0
        @test length(srange(2.:.2:1.)) == 0

        @test length(srange(1:0)) == 0
        @test length(srange(0.0:-0.5)) == 0
        @test length(srange(1:2:0)) == 0
        @test length(srange(Char(0):Char(0x001fffff))) == 2097152           # TODO
        @test length(srange(typemax(UInt64)//one(UInt64):1:typemax(UInt64)//one(UInt64))) == 1
    end
    @testset "findall(::Base.Fix2{typeof(in)}, ::Array)" begin
        @test findall(in(srange(3:20)), [5.2, 3.3]) == findall(in(Vector(srange(3:20))), [5.2, 3.3])

        let span = srange(5:20),
            r = srange(-7:3:42)
            @test findall(in(span), r) == srange(5:10)
            r = srange(15:-2:-38)
            @test findall(in(span), r) == srange(1:6)
        end
    end
    @testset "findfirst" begin
        @test findfirst(isequal(7), srange(1:2:10)) == 4
        @test findfirst(==(7), srange(1:2:10)) == 4
        @test findfirst(==(10), srange(1:2:10)) == nothing
        @test findfirst(==(11), srange(1:2:10)) == nothing
    end
    #=
    @testset "reverse" begin
        @test reverse(reverse(1:10)) == 1:10
        @test reverse(reverse(typemin(Int):typemax(Int))) == typemin(Int):typemax(Int)
        @test reverse(reverse(typemin(Int):2:typemax(Int))) == typemin(Int):2:typemax(Int)
    end
    =#
    @testset "intersect" begin
        @test intersect(srange(1:5), srange(2:3)) == srange(2:3)
        @test intersect(srange(-3:5), srange(2:8)) == srange(2:5)
        @test intersect(srange(-8:-3), srange(-8:-3)) == srange(-8:-3)
        @test intersect(srange(1:5), srange(5:13)) == srange(5:5)
        @test isempty(intersect(srange(-8:-3), srange(-2:2)))
        @test isempty(intersect(srange(-3:7), srange(2:1)))
        @test intersect(srange(1:11), srange(-2:3:15)) == srange(1:3:10)
        @test intersect(srange(1:11), srange(-2:2:15)) == srange(2:2:10)
        @test intersect(srange(1:11), srange(-2:1:15)) == srange(1:11)
        @test intersect(srange(1:11), srange(15:-1:-2)) == srange(1:11)
        @test intersect(srange(1:11), srange(15:-4:-2)) == srange(3:4:11)
        @test intersect(srange(-20:-5), srange(-10:3:-2)) == srange(-10:3:-7)
        @test isempty(intersect(srange(-5:5), srange(-6:13:20)))
        @test isempty(intersect(srange(1:11), srange(15:4:-2)))
        @test isempty(intersect(srange(11:1), srange(15:-4:-2)))
        #@test intersect(-5:5, 1+0*(1:3)) == 1:1
        #@test isempty(intersect(-5:5, 6+0*(1:3)))
        @test intersect(srange(-15:4:7), srange(-10:-2)) == srange(-7:4:-3)
        @test intersect(srange(13:-2:1), srange(-2:8)) == srange(7:-2:1)
        @test isempty(intersect(srange(13:2:1), srange(-2:8)))
        @test isempty(intersect(srange(13:-2:1), srange(8:-2)))
        #@test intersect(5+0*(1:4), 2:8) == 5+0*(1:4)
        #@test isempty(intersect(5+0*(1:4), -7:3))
        @test intersect(srange(0:3:24), srange(0:4:24)) == srange(0:12:24)
        @test intersect(srange(0:4:24), srange(0:3:24)) == srange(0:12:24)
        @test intersect(srange(0:3:24), srange(24:-4:0)) == srange(0:12:24)
        @test intersect(srange(24:-3:0), srange(0:4:24)) == srange(24:-12:0)
        @test intersect(srange(24:-3:0), srange(24:-4:0)) == srange(24:-12:0)
        @test intersect(srange(1:3:24), srange(0:4:24)) == srange(4:12:16)
        @test intersect(srange(0:6:24), srange(0:4:24)) == srange(0:12:24)
        @test isempty(intersect(1:6:2400, 0:4:2400))
        @test intersect(srange(-51:5:100), srange(-33:7:125)) == srange(-26:35:79)
        @test intersect(srange(-51:5:100), srange(-32:7:125)) == srange(-11:35:94)
        #@test intersect(0:6:24, 6+0*(0:4:24)) == 6:6:6
        #@test intersect(12+0*(0:6:24), 0:4:24) == AbstractRange(12, 0, 5)
        #@test isempty(intersect(6+0*(0:6:24), 0:4:24))
        @test intersect(srange(-10:3:24), srange(-10:3:24)) == srange(-10:3:23)
        @test isempty(intersect(srange(-11:3:24), srange(-10:3:24)))
        @test intersect(srange(typemin(Int):2:typemax(Int)), srange(1:10)) == srange(2:2:10)
        @test intersect(srange(1:10), srange(typemin(Int):2:typemax(Int))) == srange(2:2:10)

        @test intersect(reverse(srange(typemin(Int):2:typemax(Int))),srange(typemin(Int):2:typemax(Int))) == reverse(srange(typemin(Int):2:typemax(Int)))
        @test intersect(srange(typemin(Int):2:typemax(Int)), reverse(srange(typemin(Int):2:typemax(Int)))) == srange(typemin(Int):2:typemax(Int))

        @test intersect(srange(1,2),3) == srange(3,2)
        @test intersect(srange(1,2), srange(1,5), srange(3,7), srange(4,6)) == srange(4,3)

        @test intersect(srange(1:3), 2) === intersect(2, srange(1:3)) === srange(2:2)
        @test intersect(srange(1.0:3.0), 2) == intersect(2, srange(1.0:3.0)) == [2.0]
    end
    @testset "sort/sort!/partialsort" begin
        @test sort(srange(1,2)) == srange(1,2)
        @test sort!(srange(1,2)) == srange(1,2)
        @test sort(srange(1:10), rev=true) == srange(10:-1:1)
        @test sort(srange(-3:3), by=abs) == [0,-1,1,-2,2,-3,3]
        @test partialsort(srange(1:10), 4) == 4
    end
    @testset "in" begin
        @test 0 in UInt(0):100:typemax(UInt)
        @test last(UInt(0):100:typemax(UInt)) in UInt(0):100:typemax(UInt)
        @test -9223372036854775790 in srange(-9223372036854775790:100:9223372036854775710)
        @test -9223372036854775690 in srange(-9223372036854775790:100:9223372036854775710)
        @test -90 in srange(-9223372036854775790:100:9223372036854775710)
        @test 10 in srange(-9223372036854775790:100:9223372036854775710)
        @test 110 in srange(-9223372036854775790:100:9223372036854775710)
        @test 9223372036854775610 in srange(-9223372036854775790:100:9223372036854775710)
        @test 9223372036854775710 in srange(-9223372036854775790:100:9223372036854775710)


        @test !(3.5 in srange(1:5))
        @test (3 in srange(1:5))
        @test (3 in 5:-1:1)
        #@test (3 in 3+0*(1:5))
        #@test !(4 in 3+0*(1:5))

        let r = srange(0.0:0.01:1.0)
            @test (r[30] in r)
        end
        let r = (-4*Int64(maxintfloat(Int === Int32 ? Float32 : Float64))):5
            @test (3 in r)
            @test (3.0 in r)
        end

        @test !(1 in 1:0)
        @test !(1.0 in 1.0:0.0)
    end
    @testset "in() works across types, including non-numeric types (#21728)" begin
        @test 1//1 in srange(1:3)
        @test 1//1 in srange(1.0:3.0)
        @test !(5//1 in srange(1:3))
        @test !(5//1 in srange(1.0:3.0))
        @test Complex(1, 0) in srange(1:3)
        @test Complex(1, 0) in srange(1.0:3.0)
        @test Complex(1.0, 0.0) in srange(1:3)
        @test Complex(1.0, 0.0) in srange(1.0:3.0)
        @test !(Complex(1, 1) in srange(1:3))
        @test !(Complex(1, 1) in srange(1.0:3.0))
        @test !(Complex(1.0, 1.0) in srange(1:3))
        @test !(Complex(1.0, 1.0) in srange(1.0:3.0))
        @test !(π in srange(1:3))
        @test !(π in srange(1.0:3.0))
        @test !("a" in srange(1:3))
        @test !("a" in srange(1.0:3.0))
        @test !(1 in srange(Date(2017, 01, 01):Dates.Day(1):Date(2017, 01, 05)))
        @test !(Complex(1, 0) in srange(Date(2017, 01, 01):Dates.Day(1):Date(2017, 01, 05)))
        @test !(π in srange(Date(2017, 01, 01):Dates.Day(1):Date(2017, 01, 05)))
        @test !("a" in srange(Date(2017, 01, 01):Dates.Day(1):Date(2017, 01, 05)))
    end
end
@testset "indexing range with empty range (#4309)" begin
    @test srange(3:6)[5:4] == srange(7:6)
    @test_throws BoundsError srange(3:6)[5:5]
    @test_throws BoundsError srange(3:6)[5]
    @test srange(0:2:10)[7:6] == srange(12:2:10)
    @test_throws BoundsError srange(0:2:10)[7:7]
end
#=
# indexing with negative ranges (#8351)
for a=AbstractRange[srange(3:6), srange(0:2:10)], b=AbstractRange[srange(0:1), srange(2:-1:0)]
    @test_throws BoundsError a[b]
end
=#
