
@testset "filter" begin
    for (m,s,b) in ((OneToMRange(5), OneToSRange(5), OneTo(5)),
                    (UnitMRange(2, 6), UnitSRange(2, 6), UnitRange(2, 6)),
                    (StepMRange(1, 2, 11), StepSRange(1, 2, 11), StepRange(1, 2, 11)),
                    (StepMRange(11, -2, 1), StepSRange(11, -2, 1), StepRange(11, -2, 1)),
                    (StepMRangeLen(1, 3, 5), StepSRangeLen(1, 3, 5), StepRangeLen(1, 3, 5))
                   )
        @testset "Type: $(typeof(b))" begin
            for i1 in (m[1] - step(m), m[1], m[4], m[5] + 2step(m))
                for i2 in (m[2], m[3], m[5], m[5] + step(m))
                    for f in (<, >, <=, >=, ==)
                        @testset "Comparison: $f" begin
                            # FIXME - filter AbstractLinRange doesn't come out as
                            # expected because getindex results in inexact values
                            # in both base and AbstractLinRange.
                            if !isa(b, LinRange)
                                @testset "filter" begin
                                    @test filter(f(i1), m) == filter(f(i1), b)
                                    @test filter(f(i1), s) == filter(f(i1), b)
                                end
                                @testset "filter" begin
                                    @test filter(f(i2), m) == filter(f(i2), b)
                                    @test filter(f(i2), s) == filter(f(i2), b)
                                end

                                for f2 in (<, >, <=, >=, ==)
                                    for bitop in (and, or)
                                        @testset "filter($f($i1) $bitop $f2($i2), $b)" begin
                                            @test @inferred(filter(bitop(f(i1),  f2(i2)), m)) == filter(x -> bitop(f(i1)(x), f2(i2)(x)), b)
                                            @test @inferred(filter(bitop(f(i2),  f2(i1)), m)) == filter(x -> bitop(f(i2)(x), f2(i1)(x)), b)
                                        end
                                    end
                                end
                            end
                       end
                    end
                end
            end
        end
    end

    # TODO (LinMRange(1, 10, 5), LinSRange(1, 10, 5), LinRange(1, 10, 5)),
    @testset "Filter with empty range" begin
        for i in (0, 1)
            @testset "Number: $i" begin
                for f in (<, >, <=, >=, ==)
                    m, s, b = LinMRange(1, 1, 0), LinSRange(1, 1, 0), LinRange(1, 1, 0)
                    # FIXME - filter AbstractLinRange doesn't come out as
                    # expected because getindex results in inexact values
                    # in both base and AbstractLinRange.
                    @testset "filter" begin
                        @test filter(f(i), m) == filter(f(i), b)
                        @test filter(f(i), s) == filter(f(i), b)
                    end
                end
            end
        end
    end

    for (m,s,b) in ((OneToMRange(5), OneToSRange(5), OneTo(5)),
                    (UnitMRange(2, 6), UnitSRange(2, 6), UnitRange(2, 6)),
                    (StepMRange(1, 2, 11), StepSRange(1, 2, 11), StepRange(1, 2, 11)),
                    (StepMRange(11, -2, 1), StepSRange(11, -2, 1), StepRange(11, -2, 1)),
                    (LinMRange(1, 10, 5), LinSRange(1, 10, 5), LinRange(1, 10, 5)),
                    (StepMRangeLen(1, 3, 5), StepSRangeLen(1, 3, 5), StepRangeLen(1, 3, 5))
                   )
        for i in (m[1] - step(m), m[1], m[4], m[5] + 2step(m))
            @testset "filter(!=($i), $b)" begin
                @test filter(!=(i), m) == filter(!=(i), b)
                @test filter(!=(i), s) == filter(!=(i), b)
            end
        end
    end
end

