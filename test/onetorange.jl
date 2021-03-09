
@testset "OneTo" begin
    let r = OneToMRange(-5)
        @test isempty(r)
        @test length(r) == 0
        @test size(r) == (0,)
    end
    let r = OneToMRange(3)
        @test !isempty(r)
        @test last(r) == r.stop
        @test getindex(r, OneToMRange(2)) == OneToMRange(2)

        @test getindex(r, OneToMRange(2)) == OneToMRange(2)
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
        @test intersect(r, OneToMRange(2)) == OneToMRange(2)
        @test intersect(r, OneTo(2)) == OneToMRange(2)
        @test intersect(OneTo(2), r) == OneToMRange(2)
        @test intersect(r, 0:5) == 1:3
        @test intersect(r, 2) == intersect(2, r) == mrange(2, 2)
        @test findall(in(r), r) == findall(in(mrange(1, length(r))), r) ==
            findall(in(r), mrange(1, length(r))) == mrange(1, length(r))
        @test in(1, r) == true
        @test in(1.0, r) == true
    end

    @test OneToMRange{Int}(OneToMRange(10)) == OneToMRange(10)
    @test OneToMRange{UInt}(OneToMRange(10)) == OneToMRange(UInt(10))
    @test intersect(OneToMRange(2), OneTo(2)) == OneTo(2)
    @test intersect(OneTo(2), OneToMRange(2)) == OneToMRange(2)

    @test issubset(OneToMRange(2), OneTo(2)) == true
    @test issubset(OneTo(2), OneToMRange(2)) == true

    let r = OneToMRange(7)
        @test findall(in(mrange(2, (length(r) - 1))), r) == mrange(2, (length(r) - 1))
        @test findall(in(r), mrange(2, (length(r) - 1))) == mrange(1, (length(r) - 2))
    end
    @test convert(OneToMRange{Int}, 1:2) == OneToMRange{Int}(2)
    @test_throws ArgumentError("first element must be 1, got 2") convert(OneToMRange{Int}, 2:3)
    @test_throws ArgumentError("step must be 1, got 2") convert(OneToMRange{Int}, 1:2:5)
    @test OneToMRange(1:2) == OneToMRange{Int}(2)
    @test OneToMRange(1:1:2) == OneToMRange{Int}(2)
    @test OneToMRange{Int32}(1:2) == OneToMRange{Int32}(2)
    @test OneToMRange(Int32(1):Int32(2)) == OneToMRange{Int32}(2)
    @test OneToMRange{Int16}(3.0) == OneToMRange{Int16}(3)
    @test_throws InexactError(:Int16, Int16, 3.2) OneToMRange{Int16}(3.2)
end

if VERSION > v"1.2"
    @test mod(22, OneToMRange(10)) == mod(22, Base.OneTo(10))
end


r = OneToMRange(10)
empty!(r)
@test last(r) == 0

@test AbstractUnitRange{Int}(OneToMRange(10)) isa OneToMRange

@test_throws ErrorException r.throw_error_please
@testset "show" begin
    r = OneToMRange(10)
    io = IOBuffer()
    show(io, r)
    str = String(take!(io))
    @test str == "OneToMRange(10)"
end

