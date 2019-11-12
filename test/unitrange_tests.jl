
@testset "UnitRange" begin
    for R in (UnitMRange, UnitSRange)
        @testset "$R" begin
            r = R(1, 10)
            rfloat = AbstractUnitRange{Float64}(r)
            @test eltype(rfloat) == Float64
            @test isa(rfloat, R)
            @test R{Int}(r) === r
            @test R{Float64}(r) == R(1., 10.)
            @test eltype(R{Int}(UnitRange(UInt(1), UInt(10)))) == Int
            @test R(UnitRange(UInt(1), UInt(10))) == R(UInt(1), UInt(10))
            @test first(r) == r.start
            @test last(r) == r.stop
            @test_throws ErrorException r.notfield
            if R == UnitMRange
                setproperty!(r, :start, 2)
                @test r == UnitMRange(2, 10)

                setproperty!(r, :stop, 8)
                @test r == UnitMRange(2, 8)

                @test_throws ErrorException setproperty!(r, :anything, 3)
            end
        end
    end
end

