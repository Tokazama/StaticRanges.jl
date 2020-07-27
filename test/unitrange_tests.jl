
@testset "UnitRange" begin
    for R in (UnitMRange, UnitSRange)
        @testset "$R" begin
            r = R(1, 10)
            b = UnitRange(1, 10)
            rfloat = AbstractUnitRange{Float64}(r)
            @test eltype(rfloat) == Float64
            @test isa(rfloat, R)
            @test R{Int}(r) == r  # we don't use `===` because dynamic ranges should construct different ones
            @test R{Float64}(r) == R(1., 10.)
            @test eltype(R{Int}(UnitRange(UInt(1), UInt(10)))) == Int
            @test R(UnitRange(UInt(1), UInt(10))) == R(UInt(1), UInt(10))
            @test first(r) == r.start
            @test last(r) == r.stop

            @test intersect(r, r[2]) == intersect(b, b[2])
            @test intersect(r, r[2]) == intersect(b, b[2])

            @test @inferred(getindex(UnitMRange(1.0, 10.0), 2)) == 2.0

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

    @testset "Fully typed reconstruction" begin
        T = typeof(UnitMRange(1, 2))
        @test @inferred(T(2, 3)) isa UnitMRange{Int}
        T = typeof(UnitSRange(1, 2))
        @test T(2, 3) isa UnitSRange{Int,2,3}
        @test !isa(T(2, 3),  UnitSRange{Int,1,2})
    end

    @testset "show" begin
        r = UnitSRange(1, 2)
        io = IOBuffer()
        show(io, r)
        str = String(take!(io))
        @test str == "UnitSRange(1:2)"

        r = UnitMRange(1, 2)
        io = IOBuffer()
        show(io, r)
        str = String(take!(io))
        @test str == "UnitMRange(1:2)"
    end

end

