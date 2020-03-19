for frange in (mrange, srange)
    @testset "intersect-$frange" begin
        @test intersect(frange(1, 5), frange(2, 3)) == 2:3
        @test intersect(frange(-3, 5), frange(2, 8)) == 2:5
        @test intersect(frange(-8, -3), frange(-8, -3)) == -8:-3
        @test intersect(frange(1, 5), frange(5, 13)) == 5:5
        @test isempty(intersect(frange(-8, -3), frange(-2, 2)))

        @test isempty(intersect(frange(-3, 7), frange(2, 1)))
        @test intersect(frange(1, 11), frange(-2, step=3, stop=15)) == 1:3:10
        @test intersect(frange(1, 11), frange(-2, step=2, stop=15)) == 2:2:10
        @test intersect(frange(1, 11), frange(-2, step=1, stop=15)) == 1:11
        @test intersect(frange(1, 11), frange(15, step=-1, stop=-2)) == 1:11
        @test intersect(frange(1, 11), frange(15, step=-4, stop=-2)) == 3:4:11
        @test intersect(frange(-20, -5), frange(-10, step=3, stop=-2)) == -10:3:-7
        @test isempty(intersect(frange(-5, 5), frange(-6, step=13, stop=20)))
        @test isempty(intersect(frange(1, 11), frange(15, step=4, stop=-2)))
        @test isempty(intersect(frange(11, 1), frange(15, step=-4, stop=-2)))
        #@test intersect(-5:5, 1+0*(1:3)) == 1:1
        #@test isempty(intersect(-5:5, 6+0*(1:3)))
        @test intersect(frange(-15, step=4, stop=7), frange(-10, -2)) == -7:4:-3
        @test intersect(frange(13, step=-2, stop=1), frange(-2, 8)) == 7:-2:1
        @test isempty(intersect(frange(13, step=2, stop=1), frange(-2, 8)))
        @test isempty(intersect(frange(13, step=-2, stop=1), frange(8, -2)))
        #@test intersect(5+0*(1:4), 2:8) == 5+0*(1:4)
        #@test isempty(intersect(5+0*(1:4), -7:3))
        @test intersect(frange(0, step=3, stop=24), frange(0, step=4, stop=24)) == 0:12:24
        @test intersect(frange(0, step=4, stop=24), frange(0, step=3, stop=24)) == 0:12:24
        @test intersect(frange(0, step=3, stop=24), frange(24, step=-4, stop=0)) == 0:12:24
        @test intersect(frange(24, step=-3, stop=0), frange(0, step=4, stop=24)) == 24:-12:0
        @test intersect(frange(24, step=-3, stop=0), frange(24, step=-4, stop=0)) == 24:-12:0
        @test intersect(frange(1, step=3, stop=24), frange(0, step=4, stop=24)) == 4:12:16
        @test intersect(frange(0, step=6, stop=24), frange(0, step=4, stop=24)) == 0:12:24
        @test isempty(intersect(frange(1, step=6, stop=2400), frange(0, step=4, stop=2400)))
        @test intersect(frange(-51, step=5, stop=100), frange(-33, step=7, stop=125)) == -26:35:79
        @test intersect(frange(-51, step=5, stop=100), frange(-32, step=7, stop=125)) == -11:35:94
        #@test intersect(0:6:24, 6+0*(0:4:24)) == 6:6:6
        #@test intersect(12+0*(0:6:24), 0:4:24) == AbstractRange(12, 0, 5)
        #@test isempty(intersect(6+0*(0:6:24), 0:4:24))
        @test intersect(frange(2, step=1, stop=1), frange(2, step=1, stop=1)) == intersect(range(2, step=1, stop=1), range(2, step=1, stop=1))
        @test intersect(frange(-10, step=3, stop=24), frange(-10, step=3, stop=24)) == -10:3:23
        @test isempty(intersect(frange(-11, step=3, stop=24), frange(-10, step=3, stop=24)))
        @test intersect(frange(typemin(Int), step=2, stop=typemax(Int)), 1:10) == 2:2:10
        @test intersect(1:10, frange(typemin(Int), step=2, stop=typemax(Int))) == 2:2:10

        @test intersect(reverse(typemin(Int):2:typemax(Int)), frange(typemin(Int), step=2, stop=typemax(Int))) == reverse(typemin(Int):2:typemax(Int))
        @test intersect(typemin(Int):2:typemax(Int), reverse(frange(typemin(Int), step=2, stop=typemax(Int)))) == typemin(Int):2:typemax(Int)

#            @test intersect(UnitRange(1,2),3) == UnitRange(3,2)
#            @test intersect(UnitRange(1,2), UnitRange(1,5), UnitRange(3,7), UnitRange(4,6)) == UnitRange(4,3)

        @test intersect(frange(1, 3), 2) == intersect(2, frange(1, 3)) == frange(2, 2)
        @test intersect(frange(1.0, 3.0), 2) == intersect(2, frange(1.0, 3.0)) == [2.0]

        if VERSION > v"1.2"
            @testset "Support StepRange with a non-numeric step" begin
                start = Date(1914, 7, 28)
                stop = Date(1918, 11, 11)

                @test intersect(frange(start, step=Day(1), stop=stop), start:Day(1):stop) == start:Day(1):stop
                @test intersect(start:Day(1):stop, start:Day(5):stop) == start:Day(5):stop
                @test intersect(start-Day(10):Day(1):stop-Day(10), start:Day(5):stop) ==
                                start:Day(5):stop-Day(10)-mod(stop-start, Day(5))
            end
        end
    end
end

