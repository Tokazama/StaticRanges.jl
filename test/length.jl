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
