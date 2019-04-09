@testset "ranges" begin
    @test size(10:1:0) == (0,)
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
        @test length(srange(Char(0):Char(0x001fffff))) == 2097152  # TODO
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
    @testset "reverse" begin
        @test reverse(reverse(srange(1:10))) == srange(1:10)
        @test reverse(reverse(typemin(Int):typemax(Int))) == typemin(Int):typemax(Int)
        @test reverse(reverse(typemin(Int):2:typemax(Int))) == typemin(Int):2:typemax(Int)
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

