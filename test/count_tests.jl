
@testset "cont" begin
    for (m,s,b) in ((OneToMRange(5), OneToSRange(5), OneTo(5)),
                    (UnitMRange(2, 6), UnitSRange(2, 6), UnitRange(2, 6)),
                    (StepMRange(1, 2, 11), StepSRange(1, 2, 11), StepRange(1, 2, 11)),
                    (StepMRange(11, -2, 1), StepSRange(11, -2, 1), StepRange(11, -2, 1)),
                    (LinMRange(1, 10, 5), LinSRange(1, 10, 5), LinRange(1, 10, 5)),
                    (StepMRangeLen(1, 3, 5), StepSRangeLen(1, 3, 5), StepRangeLen(1, 3, 5))
                   )
        @testset "Type: $(typeof(b))" begin
            for i1 in (m[1] - step(m), m[1], m[4], m[5] + 2step(m))
                for i2 in (m[2], m[3], m[5], m[5] + step(m))
                    for f in (<, >, <=, >=, ==)
                        @testset "Comparison: $f" begin
                            @testset "count($f($i1), $b)" begin
                                @test count(f(i1), m) == count(f(i1), b)
                                @test count(f(i1), s) == count(f(i1), b)
                            end
                            @testset "count($f($i2), $b)" begin
                                @test count(f(i2), m) == count(f(i2), b)
                                @test count(f(i2), s) == count(f(i2), b)
                            end
                        end
                   end
                end
            end
        end
    end

    @testset "Find with empty range" begin
        for i in (0, 1)
            @testset "Number: $i" begin
                for f in (<, >, <=, >=, ==)
                    m, s, b = LinMRange(1, 1, 0), LinSRange(1, 1, 0), LinRange(1, 1, 0)
                    @testset "count" begin
                        @test count(f(i), m) == count(f(i), b)
                        @test count(f(i), s) == count(f(i), b)
                    end
                end
            end
        end
    end
end

