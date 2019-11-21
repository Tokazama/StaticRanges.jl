
@testset "pop" begin
    for x in (OneToMRange(10),
              UnitMRange(1, 10),
              StepMRange(1, 1, 10),
              StepMRangeLen(1, 1, 10))
        y = collect(x)
        @test pop(x) == pop(y)
        @test pop!(x) == pop!(y)
        @test x == y
    end
end

@testset "popfirst" begin
    for x in (UnitMRange(1, 10),
              StepMRange(1, 1, 10),
              StepMRangeLen(1, 1, 10))
        y = collect(x)
        @test popfirst(x) == popfirst(y)
        @test popfirst!(x) == popfirst!(y)
        @test x == y
    end
end
