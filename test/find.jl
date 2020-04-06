function typed_findfirst(f, x)
    out = findfirst(f, x)
    if out isa Nothing
        return 0
    else
        return out
    end
end

function find_tests(x, collection)
    @testset "find test - $x, $(typeof(collection))" begin
        @test @inferred(catch_nothing(find_firstgt(x, collection))) ==
              catch_nothing(findfirst(i -> i > x,  collection))
        @test @inferred(catch_nothing(find_firstgteq(x, collection))) ==
              catch_nothing(findfirst(i -> i >= x, collection))
        @test @inferred(catch_nothing(find_firstlt(x, collection))) ==
              catch_nothing(findfirst(i -> i < x, collection))
        @test @inferred(catch_nothing(find_firstlteq(x, collection))) ==
              catch_nothing(findfirst(i -> i <= x, collection))
        @test @inferred(catch_nothing(find_firsteq(x, collection))) ==
              catch_nothing(findfirst(i -> i == x, collection))

        @test @inferred(catch_nothing(find_lastgt(x, collection))) ==
              catch_nothing(findlast(i -> i > x,collection))
        @test @inferred(catch_nothing(find_lastgteq(x, collection))) ==
              catch_nothing(findlast(i -> i >= x, collection))
        @test @inferred(catch_nothing(find_lastlt(x, collection))) ==
              catch_nothing(findlast(i -> i < x,collection))
        @test @inferred(catch_nothing(find_lastlteq(x,collection))) ==
              catch_nothing(findlast(i -> i <= x, collection))
        @test @inferred(catch_nothing(find_lasteq(x, collection))) ==
              catch_nothing(findlast(i -> i == x, collection))
    end
end


@testset "find methods" begin
    for frange in (mrange, srange)
        @testset "findfirst-$(frange)" begin
            @test @inferred(typed_findfirst(isequal(7), frange(1, step=2, stop=10))) == 4
            @test @inferred(typed_findfirst(==(7), frange(1, step=2, stop=10))) == 4
            @test @inferred(typed_findfirst(==(10), frange(1, step=2, stop=10))) == 0
            @test @inferred(typed_findfirst(==(11), frange(1, step=2, stop=10))) == 0
        end
    end

    step_range = StepMRange(1,1,4)
    lin_range = LinMRange(1,4,4)
    oneto_range = OneToMRange(10)
    @test @inferred(typed_findfirst(isequal(3), step_range)) == 3
    @test @inferred(typed_findfirst(isequal(3), lin_range)) == 3
    @test @inferred(typed_findfirst(isequal(3), oneto_range)) == 3

    for collection in (OneTo(10),
                    IdOffsetRange(OneTo(10), 2),
                    1:10,
                    IdOffsetRange(1:10, 2),
                    UnitRange(1.0, 10.0),
                    StepRange(1, 2, 10),
                    StepRange(10, -2, 1),
                    LinRange(1, 5, 10),
                    LinRange(5, 1, 10),
                    range(1.0, step=0.25, stop=10),
                    range(10.0, step=-0.25, stop=1.0))
        for x in (first(collection) - step(collection),
                first(collection) - step(collection) / 2,
                first(collection),
                first(collection) + step(collection) / 2,
                first(collection) + step(collection),
                last(collection) - step(collection),
                last(collection) - step(collection) / 2,
                last(collection),
                last(collection) + step(collection) / 2,
                last(collection) + step(collection))
            find_tests(x, collection)
        end
    end

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
                            @testset "findfirst($f($i1), $b)" begin
                                @test findfirst(f(i1), m) == findfirst(f(i1), s)
                                @test findfirst(f(i1), s) == findfirst(f(i1), s)
                            end
                            @testset "findfirst($f($i2), $b)" begin
                                @test findfirst(f(i2), m) == findfirst(f(i2), s)
                                @test findfirst(f(i2), s) == findfirst(f(i2), s)
                            end

                            @testset "findlast($f($i1), $b)" begin
                                @test findlast(f(i1), m) == findlast(f(i1), b)
                                @test findlast(f(i1), s) == findlast(f(i1), b)
                            end
                            @testset "findlast($f($i2), $b)" begin
                                @test findlast(f(i2), m) == findlast(f(i2), b)
                                @test findlast(f(i2), s) == findlast(f(i2), b)
                            end

                            @testset "findall($f($i1), $b)" begin
                                @test findall(f(i1), m) == findall(f(i1), b)
                                @test findall(f(i1), s) == findall(f(i1), b)
                            end
                            @testset "findall($f($i2), $b)" begin
                                @test findall(f(i2), m) == findall(f(i2), b)
                                @test findall(f(i2), s) == findall(f(i2), b)
                            end

                            @testset "count($f($i1), $b)" begin
                                @test count(f(i1), m) == count(f(i1), b)
                                @test count(f(i1), s) == count(f(i1), b)
                            end
                            @testset "count($f($i2), $b)" begin
                                @test count(f(i2), m) == count(f(i2), b)
                                @test count(f(i2), s) == count(f(i2), b)
                            end

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
                                            @test filter(bitop(f(i1),  f2(i2)), m) == filter(x -> bitop(f(i1)(x), f2(i2)(x)), b)
                                            @test filter(bitop(f(i2),  f2(i1)), m) == filter(x -> bitop(f(i2)(x), f2(i1)(x)), b)
                                        end
                                    end
                                end
                            end
                            for f2 in (<, >, <=, >=, ==)
                                for bitop in (and, or)
                                    @testset "find_all($f($i1) $bitop $f2($i2), $b)" begin
                                        @test find_all(bitop(f(i1),  f2(i2)), m) == find_all(x -> bitop(f(i1)(x), f2(i2)(x)), b)
                                        @test find_all(bitop(f(i2),  f2(i1)), m) == find_all(x -> bitop(f(i2)(x), f2(i1)(x)), b)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    for collection in (OneTo(0), 1:0, 1:1:0, 0:-1:1,LinRange(1, 1, 0))
        for x in (-1, -0.5, 0, 0.5, 1)
            find_tests(x, collection)
        end
    end


    @testset "Find with empty range" begin
        for i in (0, 1)
            @testset "Number: $i" begin
                for f in (<, >, <=, >=, ==)
                    m, s, b = LinMRange(1, 1, 0), LinSRange(1, 1, 0), LinRange(1, 1, 0)
                    @testset "findall" begin
                        @test findall(f(i), m) == findall(f(i), b)
                        @test findall(f(i), s) == findall(f(i), b)
                    end
                    @testset "count" begin
                        @test count(f(i), m) == count(f(i), b)
                        @test count(f(i), s) == count(f(i), b)
                    end

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
end

