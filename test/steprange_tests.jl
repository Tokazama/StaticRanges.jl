@testset "StepRange" begin
    for R in (StepMRange, StepSRange)
        @testset "$R" begin
            r = R(1, 1, 10)
            b = StepRange(1, 1, 10)
            @test R(1:10) == 1:1:10
            @test eltype(R(UInt(1), UInt(1), UInt(10))) == UInt
            @test R{Int,Int}(r) === r
            @test eltype(R{UInt,UInt}(r)) == UInt
            @test first(r) == r.start
            @test last(r) == r.stop

            @test intersect(r, r[2]) == intersect(b, b[2])
            @test intersect(r, r[2]) == intersect(b, b[2])

            @test_throws ErrorException r.notfield
            if R == StepMRange
                setproperty!(r, :step, 2)
                @test r == StepMRange(1, 2, 9)

                setproperty!(r, :start, 2)
                @test r == StepMRange(2, 2, 8)

                setproperty!(r, :stop, 10)
                @test r == StepMRange(2, 2, 10)

                @test_throws ErrorException setproperty!(r, :anything, 3)
            end
        end
    end
end

