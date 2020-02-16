for (frange, oneto) in ((mrange, OneToMRange),(srange ,OneToSRange))
    @testset "$oneto" begin
        let r = oneto(-5)
            @test isempty(r)
            @test length(r) == 0
            @test size(r) == (0,)
        end
        let r = oneto(3)
            @test !isempty(r)
            @test last(r) == r.stop
            @test getindex(r, oneto(2)) == oneto(2)

            @test getindex(r, oneto(2)) == oneto(2)
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
            @test 2*r == frange(2, step=2, stop=6)
            @test r + r == frange(2, step=2, stop=6)
            k = 0
            for i in r
                @test i == (k += 1)
            end
            @test intersect(r, oneto(2)) == oneto(2)
            @test intersect(r, OneTo(2)) == oneto(2)
            @test intersect(OneTo(2), r) == oneto(2)
            @test intersect(r, 0:5) == 1:3
            @test intersect(r, 2) == intersect(2, r) == frange(2, 2)
            @test findall(in(r), r) == findall(in(frange(1, length(r))), r) ==
                findall(in(r), frange(1, length(r))) == frange(1, length(r))
            io = IOBuffer()
            show(io, r)
            str = String(take!(io))
            @test str == "$(oneto)(3)"
            @test in(1, r) == true

        end

        @test oneto{Int}(oneto(10)) == oneto(10)
        @test oneto{UInt}(oneto(10)) == oneto(UInt(10))
        @test intersect(oneto(2), OneTo(2)) == oneto(2)
        @test intersect(OneTo(2), oneto(2)) == oneto(2)

        @test issubset(oneto(2), OneTo(2)) == true
        @test issubset(OneTo(2), oneto(2)) == true

        let r = oneto(7)
            @test findall(in(frange(2, (length(r) - 1))), r) == frange(2, (length(r) - 1))
            @test findall(in(r), frange(2, (length(r) - 1))) == frange(1, (length(r) - 2))
        end
        @test convert(oneto, 1:2) == oneto{Int}(2)
        @test_throws ArgumentError("first element must be 1, got 2") convert(oneto, 2:3)
        @test_throws ArgumentError("step must be 1, got 2") convert(oneto, 1:2:5)
        @test oneto(1:2) == oneto{Int}(2)
        @test oneto(1:1:2) == oneto{Int}(2)
        @test oneto{Int32}(1:2) == oneto{Int32}(2)
        @test oneto(Int32(1):Int32(2)) == oneto{Int32}(2)
        @test oneto{Int16}(3.0) == oneto{Int16}(3)
        @test_throws InexactError(:Int16, Int16, 3.2) oneto{Int16}(3.2)
    end

    @test mod(22, OneToMRange(10)) == mod(22, Base.OneTo(10))


    r = OneToMRange(10)
    r.stop = -3
    @test last(r) == 0

    @test AbstractUnitRange{Int}(OneToMRange(10)) isa OneToMRange
    @test AbstractUnitRange{Int}(OneToSRange(10)) isa OneToSRange

    @test_throws ErrorException r.throw_error_please
end
