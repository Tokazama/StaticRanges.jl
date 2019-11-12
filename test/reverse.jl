
for frange in (mrange,srange)
    @testset "reverse-$frange" begin
        @test reverse(reverse(frange(1, 10))) == 1:10
        @test reverse(reverse(frange(typemin(Int), typemax(Int)))) == typemin(Int):typemax(Int)
        @test reverse(reverse(frange(typemin(Int), step=2, stop=typemax(Int)))) == typemin(Int):2:typemax(Int)
    end
end

@testset "reverse!" begin
    r = StepMRange(1, 1, 10)
    @test reverse!(r) == StepMRange(10, -1, 1)
    @test reverse!(r) == StepMRange(1, 1, 10)

    r = LinMRange(1, 10, 10)
    @test reverse!(r) == LinMRange(10, 1, 10)
    @test reverse!(r) == LinMRange(1, 10, 10)

    r = StepMRangeLen(1, 1, 10)
    @test reverse!(r) == StepMRangeLen(10, -1, 10)
    @test reverse!(r) == StepMRangeLen(1, 1, 10)
end
