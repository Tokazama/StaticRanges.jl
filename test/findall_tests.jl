
@testset "findall(::Fix2,...)" begin
    for (m,s,b) in ((OneToMRange(5), OneToSRange(5), OneTo(5)),
                    (UnitMRange(2, 6), UnitSRange(2, 6), UnitRange(2, 6)),
                    (StepMRange(1, 2, 11), StepSRange(1, 2, 11), StepRange(1, 2, 11)),
                    (StepMRange(11, -2, 1), StepSRange(11, -2, 1), StepRange(11, -2, 1)),
                    (LinMRange(1, 10, 5), LinSRange(1, 10, 5), LinRange(1, 10, 5)),
                    (StepMRangeLen(1, 3, 5), StepSRangeLen(1, 3, 5), StepRangeLen(1, 3, 5)))

        for i1 in (m[1] - step(m), m[1], m[4], m[5] + 2step(m))
            for i2 in (m[2], m[3], m[5], m[5] + step(m))
                for f in (<, >, <=, >=, ==)
                    @testset "findall($f($i1), $b)" begin
                        @test @inferred(findall(f(i1), m)) == @inferred(findall(f(i1), b))
                        @test @inferred(findall(f(i1), s)) == @inferred(findall(f(i1), b))
                    end
                    @testset "findall($f($i2), $b)" begin
                        @test @inferred(findall(f(i2), m)) == @inferred(findall(f(i2), b))
                        @test @inferred(findall(f(i2), s)) == @inferred(findall(f(i2), b))
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

@testset "Find with empty range" begin
    m, s, b = LinMRange(1, 1, 0), LinSRange(1, 1, 0), LinRange(1, 1, 0)
    for i in (0, 1)
        @testset "Number: $i" begin
            for f in (<, >, <=, >=, ==)
                @testset "findall" begin
                    @test @inferred(to_vec(findall(f(i), m))) == @inferred(to_vec(findall(f(i), b)))
                    @test @inferred(to_vec(findall(f(i), s))) == @inferred(to_vec(findall(f(i), b)))
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
        @testset "find_all(!=($i), $b)" begin
            @test @inferred(findall(!=(i), m)) == @inferred(findall(!=(i), b))
            @test @inferred(findall(!=(i), s)) == @inferred(findall(!=(i), b))
        end
    end
end

@testset "filter non numerics" begin
    x = Second(1):Second(1):Second(10)
    @test @inferred(find_all(and(>=(Second(1)), <=(Second(3))), x)) == 1:3
end

