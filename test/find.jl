
@noinline function find_first_tests(x, collection)
    @testset "find first test - $x, $(typeof(collection))" begin
        @test @inferred(catch_nothing(find_firstgt(x, collection))) ==
              catch_nothing(findfirst(i -> i > x,  collection)) ==
              catch_nothing(find_first(>(x),  collection))

        @test @inferred(catch_nothing(find_firstgteq(x, collection))) ==
              catch_nothing(findfirst(i -> i >= x, collection)) ==
              catch_nothing(find_first(>=(x),  collection))

        @test @inferred(catch_nothing(find_firstlt(x, collection))) ==
              catch_nothing(findfirst(i -> i < x, collection)) ==
              catch_nothing(find_first(<(x),  collection))

        @test @inferred(catch_nothing(find_firstlteq(x, collection))) ==
              catch_nothing(findfirst(i -> i <= x, collection)) ==
              catch_nothing(find_first(<=(x),  collection))

        @test @inferred(catch_nothing(find_firsteq(x, collection))) ==
              catch_nothing(findfirst(i -> i == x, collection)) ==
              catch_nothing(find_first(==(x),  collection))
    end
end

@noinline function find_last_tests(x, collection)
    @testset "find last test - $x, $(typeof(collection))" begin
        @test @inferred(catch_nothing(find_lastgt(x, collection))) ==
              catch_nothing(findlast(i -> i > x,collection)) ==
              catch_nothing(find_last(>(x), collection))

        @test @inferred(catch_nothing(find_lastgteq(x, collection))) ==
              catch_nothing(findlast(i -> i >= x, collection)) ==
              catch_nothing(find_last(>=(x), collection))

        @test @inferred(catch_nothing(find_lastlt(x, collection))) ==
              catch_nothing(findlast(i -> i < x,collection)) ==
              catch_nothing(find_last(<(x), collection))

        @test @inferred(catch_nothing(find_lastlteq(x,collection))) ==
              catch_nothing(findlast(i -> i <= x, collection)) ==
              catch_nothing(find_last(<=(x), collection))

        @test @inferred(catch_nothing(find_lasteq(x, collection))) ==
              catch_nothing(findlast(i -> i == x, collection)) ==
              catch_nothing(find_last(==(x), collection))
    end
end

@noinline function find_all_tests(x, collection)
    @testset "find all test - $x, $(typeof(collection))" begin
        @test @inferred(find_allgt(x, collection)) ==
              findall(i -> i > x, collection) ==
              find_all(>(x),  collection)

        @test @inferred(find_allgteq(x, collection)) ==
              findall(i -> i >= x, collection) ==
              find_all(>=(x),  collection)

        @test @inferred(find_alllt(x, collection)) ==
              findall(i -> i < x, collection) ==
              find_all(<(x),  collection)

        @test @inferred(find_alllteq(x, collection)) ==
              findall(i -> i <= x, collection) ==
              find_all(<=(x),  collection)

        @test @inferred(find_alleq(x, collection)) ==
              findall(i -> i == x, collection) ==
              find_all(==(x),  collection)
    end
end

@noinline function filter_tests(x, collection)
    @testset "filter test - $x, $(typeof(collection))" begin
        @test @inferred(filter(>(x), collection)) ==
              filter(i -> i > x, collection) ==
              filter(>(x), as_fixed(collection))

        @test @inferred(filter(>=(x), collection)) ==
              filter(i -> i >= x, collection) ==
              filter(>=(x), as_fixed(collection))

        @test @inferred(filter(<(x), collection)) ==
              filter(i -> i < x, collection) ==
              filter(<(x), as_fixed(collection))

        @test @inferred(filter(<=(x), collection)) ==
              filter(i -> i <= x, collection) ==
              filter(<=(x), as_fixed(collection))

        @test @inferred(filter(==(x), collection)) ==
              filter(i -> i == x, collection) ==
              filter(==(x), as_fixed(collection))
    end
end

@noinline function count_tests(x, collection)
    @testset "count test - $x, $(typeof(collection))" begin
        @test @inferred(count(>(x), collection)) == count(i -> i > x, collection)
        @test @inferred(count(>=(x), collection)) == count(i -> i >= x, collection)
        @test @inferred(count(<(x), collection)) == count(i -> i < x, collection)
        @test @inferred(count(<=(x), collection)) == count(i -> i <= x, collection)
        @test @inferred(count(==(x), collection)) == count(i -> i == x, collection)
    end
end

@testset "find methods" begin
    for collection in (OneToMRange(10),
                    IdOffsetRange(OneTo(10), 2),
                    1:10,
                    IdOffsetRange(1:10, 2),
                    UnitMRange(1.0, 10.0),
                    StepMRange(1, 2, 10),
                    StepMRange(10, -2, 1),
                    LinMRange(1, 5, 10),
                    LinMRange(5, 1, 10),
                    mrange(1.0, step=0.25, stop=10),
                    mrange(10.0, step=-0.25, stop=1.0))
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
            find_first_tests(x, collection)
            find_last_tests(x, collection)
            find_all_tests(x, collection)
            # FIXME - filter AbstractLinRange doesn't come out as
            # expected because getindex results in inexact values
            # in both base and AbstractLinRange.
            if !isa(collection, LinMRange)
                filter_tests(x, collection)
            end
            count_tests(x, collection)
        end
    end

    for collection in (OneTo(0), 1:0, 1:1:0, 0:-1:1,LinRange(1, 1, 0))
        for x in (-1, -0.5, 0, 0.5, 1)
            find_first_tests(x, collection)
            find_last_tests(x, collection)
            find_all_tests(x, collection)
        end
    end

    for x in (-1, -0.5, 0, 0.5, 1, 9, 9.5, 10, 10.5, 11)
        find_first_tests(x, collect(1:10))
        find_last_tests(x, collect(1:10))
        find_all_tests(x, collect(1:10))
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
                            if !isa(b, LinRange)
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
end

@testset "findall(::ChainedFix,...)" begin
    for (m,s,b) in ((OneToMRange(5), OneToSRange(5), OneTo(5)),
                    (UnitMRange(2, 6), UnitSRange(2, 6), UnitRange(2, 6)),
                    (StepMRange(1, 2, 11), StepSRange(1, 2, 11), StepRange(1, 2, 11)),
                    (StepMRange(11, -2, 1), StepSRange(11, -2, 1), StepRange(11, -2, 1)),
                    (LinMRange(1, 10, 5), LinSRange(1, 10, 5), LinRange(1, 10, 5)),
                    (StepMRangeLen(1, 3, 5), StepSRangeLen(1, 3, 5), StepRangeLen(1, 3, 5)))
        for i1 in (m[1] - step(m), m[1], m[4], m[5] + 2step(m))
            for i2 in (m[2], m[3], m[5], m[5] + step(m))
                for f in (<, >, <=, >=, ==)
                   for f2 in (<, >, <=, >=, ==)
                        for bitop in (and, or)
                            @testset "find_all($f($i1) $bitop $f2($i2), $b)" begin
                                @test @inferred(find_all(bitop(f(i1),  f2(i2)), m)) == find_all(x -> bitop(f(i1)(x), f2(i2)(x)), b)
                                @test @inferred(find_all(bitop(f(i2),  f2(i1)), m)) == findall(x -> bitop(f(i2)(x), f2(i1)(x)), b)
                            end
                        end
                    end
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
                (StepMRangeLen(1, 3, 5), StepSRangeLen(1, 3, 5), StepRangeLen(1, 3, 5)))
    for i in (m[1] - step(m), m[1], m[4], m[5] + 2step(m))
        @testset "find_all(!=($i), $b)" begin
            @test @inferred(findall(!=(i), m)) == @inferred(findall(!=(i), b))
            @test @inferred(findall(!=(i), s)) == @inferred(findall(!=(i), b))
        end
    end
end

@testset "filter non numerics" begin
    x = Second(1):Second(1):Second(10)
    @test @inferred(find_all(and(>=(Second(1)), <=(Second(3))), x)) == 1:3
    @test @inferred(findin(Second(1):Second(1):Second(3), x)) == 1:3
end

@testset "find_all(in(x), r)" begin
    r = @inferred(find_all(in(OneTo(10)), OneToSRange(8)))
    @test r == 1:8
    @test isa(r, StaticRanges.OneToUnion)

    r = @inferred(find_all(in(OneTo(10)), OneToMRange(8)))
    @test r == 1:8
    @test isa(r, StaticRanges.OneToUnion)

    r = @inferred(find_all(in(OneToSRange(8)), OneToSRange(10)))
    @test r == 1:8
    @test isa(r, OneToSRange)

    r = @inferred(find_all(in(UnitRange(1,10)), UnitSRange(1,8)))
    @test r == 1:8
    @test isa(r, UnitRange)

    r = @inferred(find_all(in(OneTo(10)), UnitMRange(1, 8)))
    @test r == OneTo(8)
    @test isa(r, UnitMRange) == true

    r = @inferred(find_all(in(UnitSRange(1, 8)), UnitSRange(1, 10)))
    @test r == UnitSRange(1, 8)
    @test isa(r, UnitSRange)

    @test find_all(in(collect(1:10)), 1:20) == find_all(in(1:10), 1:20)

    @testset "steps match but no overlap" begin
        r = @inferred(findin(1:3, 4:5))
        @test r == 1:0
        @test isa(r, UnitRange)
    end

    for (x, y, z) in ((1:10, 1:2:10, 1:5),
                      (1:2:20, 1:8:20, 1:3),
                      (1:2:20, 1:10, 1:2:9),
                      (1:2:10, 1.1:1:10.1, []),
                      (UnitRange(1.1, 10.1), UnitRange(2.1, 8.1), 1:7),
                      (UnitRange(2.1, 8.1), UnitRange(1.1, 10.1), 2:8)
                     )
        @testset "find_all(in($x), $y)" begin
            @test @inferred(find_all(in(x), y)) == z
        end
    end

    @testset "find_all(in(::IntervalSets), r)" begin
        for (i,t) in ((Interval{:closed,:closed}(1, 10), 1:10),
                      (Interval{:open,:closed}(1, 10), 2:10),
                      (Interval{:closed,:open}(1, 10), 1:9),
                      (Interval{:open,:open}(1, 10), 2:9))
            @test find_all(in(i), 1:10) == t
        end
    end
end

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

