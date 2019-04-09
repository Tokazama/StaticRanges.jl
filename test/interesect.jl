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

    #= TODO: this overflows when finding length, which happens in base too
    @test intersect(srange(typemin(Int):2:typemax(Int)), srange(1:10)) == srange(2:2:10)
    @test intersect(srange(1:10), srange(typemin(Int):2:typemax(Int))) == srange(2:2:10)

    @test intersect(reverse(srange(typemin(Int):2:typemax(Int))),srange(typemin(Int):2:typemax(Int))) == reverse(srange(typemin(Int):2:typemax(Int)))
    @test intersect(srange(typemin(Int):2:typemax(Int)), reverse(srange(typemin(Int):2:typemax(Int)))) == srange(typemin(Int):2:typemax(Int))
    =#

    @test intersect(srange(1,2), SVal(3)) == srange(3,2)
    @test intersect(srange(1,2), srange(1,5), srange(3,7), srange(4,6)) == srange(4,3)

    @test intersect(srange(1:3), SVal(2)) === intersect(SVal(2), srange(1:3)) === srange(2:2)
    @test intersect(srange(1.0:3.0), SVal(2)) == intersect(SVal(2), srange(1.0:3.0)) == 2.0
end