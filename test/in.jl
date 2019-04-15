@testset "in" begin
    @test 0 in SVal(UInt(0)):SVal(100):SVal(typemax(UInt))
    @test last(SVal(UInt(0)):SVal(100):SVal(typemax(UInt))) in SVal(UInt(0)):SVal(100):SVal(typemax(UInt))
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