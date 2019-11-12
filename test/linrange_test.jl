@testset "LinRange" begin
    for R in (LinMRange,LinSRange)
        @testset "$R" begin
            r = R(1, 4, 4)
            b = LinRange(1, 4, 4)
            @test reverse(r) == reverse(b)
            @test R(r) == r
            @test R(1:4) == r
            @test -(r) == -(b)
            @test -(r, R(2, 5, 4)) == -(b, LinRange(2, 5, 4))
            @test +(r, R(2, 5, 4)) == +(b, LinRange(2, 5, 4))

            @test R(1,1,1) == LinRange(1, 1, 1)

            @test intersect(r, r[2]) == intersect(b, b[2])
            @test intersect(r, r[2]) == intersect(b, b[2])

            @test R{Float64}(r) == LinRange{Float64}(r)

            @test_throws ErrorException r.notfield
            # issue #20380
            let r = R(1,4,4)
                @test isa(r[UnitSRange(1, 4)], StaticRanges.AbstractLinRange)
            end

            if R == LinMRange
               setproperty!(r, :start, 2)
                @test r == LinMRange(2, 4, 4)

                setproperty!(r, :stop, 10)
                @test r == LinMRange(2, 10, 4)

                setproperty!(r, :len, 9)
                @test r == LinMRange(2, 10, 9)

                setproperty!(r, :lendiv, 8)
                @test r == LinMRange(2, 10, 9)

                @test_throws ErrorException setproperty!(r, :anything, 3)
            end
        end
    end
end

