
@testset "DynamicAxis" begin
    let r = DynamicAxis(-5)
        @test isempty(r)
        @test length(r) == 0
        @test size(r) == (0,)
    end
    let r = DynamicAxis(3)
        @test !isempty(r)
        @test last(r) == r.stop
        @test getindex(r, DynamicAxis(2)) == DynamicAxis(2)

        @test getindex(r, OneTo(2)) === OneTo(2)

        @test getindex(r, DynamicAxis(2)) == DynamicAxis(2)
        @test_throws ErrorException r.notfield
        @test length(r) == 3
        @test size(r) == (3,)
        @test first(r) == 1
        @test last(r) == 3
        @test minimum(r) == 1
        @test maximum(r) == 3
        @test r[2] == 2
        @test r[2:3] == 2:3
        @test_throws BoundsError r[4]
        @test_throws BoundsError r[0]
        @test broadcast(+, r, 1) == 2:4
        @test 2*r == mrange(2, step=2, stop=6)
        @test r + r == mrange(2, step=2, stop=6)
        k = 0
        for i in r
            @test i == (k += 1)
        end
        @test intersect(r, DynamicAxis(2)) == DynamicAxis(2)
        @test intersect(r, OneTo(2)) == DynamicAxis(2)
        @test intersect(OneTo(2), r) == DynamicAxis(2)
        @test intersect(r, 0:5) == 1:3
        @test intersect(r, 2) == intersect(2, r) == mrange(2, 2)
        @test findall(in(r), r) == findall(in(mrange(1, length(r))), r) ==
            findall(in(r), mrange(1, length(r))) == mrange(1, length(r))
        @test in(1, r) == true
        @test in(1.0, r) == true
    end

    @test DynamicAxis(DynamicAxis(10)) == DynamicAxis(10)
    @test DynamicAxis(DynamicAxis(10)) == DynamicAxis(UInt(10))
    @test intersect(DynamicAxis(2), OneTo(2)) == OneTo(2)
    @test intersect(OneTo(2), DynamicAxis(2)) == DynamicAxis(2)

    @test issubset(DynamicAxis(2), OneTo(2)) == true
    @test issubset(OneTo(2), DynamicAxis(2)) == true

    let r = DynamicAxis(7)
        @test findall(in(mrange(2, (length(r) - 1))), r) == mrange(2, (length(r) - 1))
        @test findall(in(r), mrange(2, (length(r) - 1))) == mrange(1, (length(r) - 2))
    end
    @test convert(DynamicAxis, 1:2) == DynamicAxis(2)
    @test_throws ArgumentError("first element must be 1, got 2") convert(DynamicAxis, 2:3)
    @test_throws ArgumentError("step must be 1, got 2") convert(DynamicAxis, 1:2:5)
    @test DynamicAxis(1:2) == DynamicAxis(2)
    @test DynamicAxis(1:1:2) == DynamicAxis(2)
    @test DynamicAxis(1:2) == DynamicAxis(2)
    @test DynamicAxis(Int32(1):Int32(2)) == DynamicAxis(2)
    @test DynamicAxis(3.0) == DynamicAxis(3)
    @test_throws InexactError DynamicAxis(3.2)

    x = DynamicAxis(10)
    StaticRanges.grow_end!(x, 1)
    @test length(x) == 11
    StaticRanges.shrink_end!(x, 2)
    @test length(x) == 9
end

if VERSION > v"1.2"
    @test mod(22, DynamicAxis(10)) == mod(22, Base.OneTo(10))
end


r = DynamicAxis(10)
empty!(r)
@test last(r) == 0

@test AbstractUnitRange{Int}(DynamicAxis(10)) isa DynamicAxis

@test_throws ErrorException r.throw_error_please
@testset "show" begin
    r = DynamicAxis(10)
    io = IOBuffer()
    show(io, r)
    str = String(take!(io))
    @test str == "DynamicAxis(10)"
end

