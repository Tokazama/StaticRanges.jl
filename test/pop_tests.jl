@testset "pop" begin
    for x in (OneToMRange(10),
              UnitMRange(1, 10),
              StepMRange(1, 1, 10),
              LinMRange(1, 3, 3),
             )
        y = collect(x)
        @test pop(x) == pop(y)
        @test pop!(x) == pop!(y)
        @test x == y
    end

    r = UnitMRange(1, 1)
    y = collect(r)
    @test pop!(r) == pop!(y)
    @test isempty(r) == true
end

@testset "popfirst" begin
    for x in (UnitMRange(1, 10),
              StepMRange(1, 1, 10),
              LinMRange(1, 3, 3),
              StepMRangeLen(1, 1, 10),
             )
        y = collect(x)
        @test popfirst(x) == popfirst(y)
        @test popfirst!(x) == popfirst!(y)
        @test x == y
    end
    r = UnitMRange(1, 1)
    y = collect(r)
    @test popfirst!(r) == popfirst!(y)
    @test isempty(r) == true
end
