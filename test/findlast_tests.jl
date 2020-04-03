
@testset "findlast" begin
    function typed_findlast(f, x)
        out = findlast(f, x)
        if out isa Nothing
            return 0
        else
            return out
        end
    end

    for (m,s,b) in ((OneToMRange(5), OneToSRange(5), OneTo(5)),
                    (UnitMRange(2, 6), UnitSRange(2, 6), UnitRange(2, 6)),
                    (StepMRange(1, 2, 11), StepSRange(1, 2, 11), StepRange(1, 2, 11)),
                    (StepMRange(11, -2, 1), StepSRange(11, -2, 1), StepRange(11, -2, 1)),
                    (LinMRange(1, 10, 5), LinSRange(1, 10, 5), LinRange(1, 10, 5)),
                    (StepMRangeLen(1, 3, 5), StepSRangeLen(1, 3, 5), StepRangeLen(1, 3, 5)))
        @testset "Type: $(typeof(b))" begin
            for i1 in (m[1] - step(m), m[1], m[2], m[3], m[4], m[5] + step(m), m[5] + 2step(m))
                for f in (<, >, <=, >=, ==)
                    @testset "Comparison: $f" begin
                        @testset "findlast($f($i1), $b)" begin
                            @test @inferred(typed_findlast(f(i1), m)) == @inferred(typed_findlast(f(i1), b))
                            @test @inferred(typed_findlast(f(i1), s)) == @inferred(typed_findlast(f(i1), b))
                        end
                    end
                end
            end
        end
    end

    @testset "Find with empty range" begin
        m, s, b = LinMRange(1, 1, 0), LinSRange(1, 1, 0), LinRange(1, 1, 0)
        for i in (0, 1)
            @testset "Number: $i" begin
                for f in (<, >, <=, >=, ==)
                    @testset "findlast" begin
                        @test @inferred(typed_findlast(f(i), m)) == @inferred(typed_findlast(f(i), b))
                        @test @inferred(typed_findlast(f(i), s)) == @inferred(typed_findlast(f(i), b))
                    end
                end
            end
        end
    end
end

@testset "find_lastgt" begin
    one_to = OneToMRange(10)
    @testset "find_lastgt(::Int, ::OneToUnion)" begin
        @test catch_nothing(find_lastgt(11, one_to)) == 0
        @test catch_nothing(find_lastgt(-1, one_to)) == 10
        @test catch_nothing(find_lastgt(9, one_to)) == 10
        @test catch_nothing(find_lastgt(10, one_to)) == 0
    end

    @testset "find_lastgt(::Any, ::OneToUnion)" begin
        @test catch_nothing(find_lastgt(11.0, one_to)) == 0
        @test catch_nothing(find_lastgt(-1.0, one_to)) == 10
        @test catch_nothing(find_lastgt(2.0, one_to)) == 10
        @test catch_nothing(find_lastgt(9.0, one_to)) == 10
        @test catch_nothing(find_lastgt(9.5, one_to)) == 10
    end

    unit_range = 1:10
    @testset "find_lastgt(::Int, ::AbstractUnitRange)" begin
        @test catch_nothing(find_lastgt(11, unit_range)) == 0
        @test catch_nothing(find_lastgt(-1, unit_range)) == 10
        @test catch_nothing(find_lastgt(9, unit_range)) == 10
        @test catch_nothing(find_lastgt(10, unit_range)) == 0
    end

    @testset "find_lastgt(::Any, ::AbstractUnitRange)" begin
        @test catch_nothing(find_lastgt(11.0, unit_range)) == 0
        @test catch_nothing(find_lastgt(-1.0, unit_range)) == 10
        @test catch_nothing(find_lastgt(2.0, unit_range)) == 10
        @test catch_nothing(find_lastgt(9.0, unit_range)) == 10
        @test catch_nothing(find_lastgt(9.5, unit_range)) == 10
    end

    x = collect(1:10)
    @testset "find_lastgt(::Any, ::Any)" begin
        @test catch_nothing(find_lastgt(11.0, x)) == 0
        @test catch_nothing(find_lastgt(-1.0, x)) == 10
        @test catch_nothing(find_lastgt(2.0, x)) == 10
        @test catch_nothing(find_lastgt(9, x)) == 10
        @test catch_nothing(find_lastgt(10, x)) == 0
    end
end

@testset "find_lastgteq" begin
    one_to = OneToMRange(10)
    @testset "find_lastgteq(::Int, ::OneToUnion)" begin
        @test catch_nothing(find_lastgteq(11, one_to)) == 0
        @test catch_nothing(find_lastgteq(-1, one_to)) == 10
        @test catch_nothing(find_lastgteq(2, one_to)) == 10
        @test catch_nothing(find_lastgteq(3, one_to)) == 10
    end

    @testset "find_lastgteq(::Any, ::OneToUnion)" begin
        @test catch_nothing(find_lastgteq(11.0, one_to)) == 0
        @test catch_nothing(find_lastgteq(-1.0, one_to)) == 10
        @test catch_nothing(find_lastgteq(2.0, one_to)) == 10
        @test catch_nothing(find_lastgteq(3.0, one_to)) == 10
        @test catch_nothing(find_lastgteq(9.5, one_to)) == 10
    end

    unit_range = 1:10
    @testset "find_lastgteq(::Int, ::AbstractUnitRange)" begin
        @test catch_nothing(find_lastgteq(11, unit_range)) == 0
        @test catch_nothing(find_lastgteq(-1, unit_range)) == 10
        @test catch_nothing(find_lastgteq(2, unit_range)) == 10
        @test catch_nothing(find_lastgteq(10, unit_range)) == 10
    end

    @testset "find_lastgteq(::Any, ::AbstractUnitRange)" begin
        @test catch_nothing(find_lastgteq(11.0, unit_range)) == 0
        @test catch_nothing(find_lastgteq(-1.0, unit_range)) == 10
        @test catch_nothing(find_lastgteq(2.0, unit_range)) == 10
        @test catch_nothing(find_lastgteq(3.0, unit_range)) == 10
        @test catch_nothing(find_lastgteq(10, unit_range)) == 10
    end

    x = collect(1:10)
    @testset "find_lastgteq(::Any, ::Any)" begin
        @test catch_nothing(find_lastgteq(11.0, x)) == 0
        @test catch_nothing(find_lastgteq(-1.0, x)) == 10
        @test catch_nothing(find_lastgteq(2.0, x)) == 10
        @test catch_nothing(find_lastgteq(3.0, x)) == 10
        @test catch_nothing(find_lastgteq(10, x)) == 10
    end
end

@testset "find_lastlt" begin
    one_to = OneToMRange(10)

    x = collect(1:10)
    @testset "find_lastlt(::Any, ::Any)" begin
        @test catch_nothing(find_lastlt(11.0, x)) == 10
        @test catch_nothing(find_lastlt(-1.0, x)) == 0
        @test catch_nothing(find_lastlt(2.0, x)) == 1
        @test catch_nothing(find_lastlt(3.0, x)) == 2
        @test catch_nothing(find_lastlt(3.5, x)) == 3
    end
end

@testset "find_lastlteq" begin
    one_to = OneToMRange(10)

    x = collect(1:10)
    @testset "find_lastlteq(::Any, ::Any)" begin
        @test catch_nothing(find_lastlteq(11.0, x)) == 10
        @test catch_nothing(find_lastlteq(-1.0, x)) == 0
        @test catch_nothing(find_lastlteq(2.0, x)) == 2
        @test catch_nothing(find_lastlteq(3.0, x)) == 3
        @test catch_nothing(find_lastlteq(3.5, x)) == 3
    end
end

