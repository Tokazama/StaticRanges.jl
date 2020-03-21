
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
            for i1 in (m[1] - step(m), m[1], m[4], m[5] + 2step(m))
                for i2 in (m[2], m[3], m[5], m[5] + step(m))
                    for f in (<, >, <=, >=, ==)
                        @testset "Comparison: $f" begin
                            @testset "findlast($f($i1), $b)" begin
                                @test @inferred(typed_findlast(f(i1), m)) == @inferred(typed_findlast(f(i1), b))
                                @test @inferred(typed_findlast(f(i1), s)) == @inferred(typed_findlast(f(i1), b))
                            end
                            @testset "findlast($f($i2), $b)" begin
                                @test @inferred(typed_findlast(f(i2), m)) == @inferred(typed_findlast(f(i2), b))
                                @test @inferred(typed_findlast(f(i2), s)) == @inferred(typed_findlast(f(i2), b))
                            end
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

