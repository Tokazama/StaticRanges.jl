
for frange in (mrange, srange)
    @testset "findfirst-$(frange)" begin
        @test findfirst(isequal(7), frange(1, step=2, stop=10)) == 4
        @test findfirst(==(7), frange(1, step=2, stop=10)) == 4
        @test findfirst(==(10), frange(1, step=2, stop=10)) == nothing
        @test findfirst(==(11), frange(1, step=2, stop=10)) == nothing
    end
end

step_range = StepMRange(1,1,4)
lin_range = LinMRange(1,4,4)
oneto_range = OneToMRange(10)

@testset "findfirst" begin
    @test findfirst(isequal(3), step_range) == 3
    @test findfirst(isequal(3), lin_range) == 3
    @test findfirst(isequal(3), oneto_range) == 3
end

@testset "find" begin
    for (m,s,b) in ((OneToMRange(5), OneToSRange(5), OneTo(5)),
                    #(UnitMRange(2, 6), UnitSRange(2, 6), UnitRange(2, 6)),
                    #(StepMRange(1, 2, 11), StepSRange(1, 2, 11), StepRange(1, 2, 11)),
                    #(StepMRange(11, -2, 1), StepSRange(11, -2, 1), StepRange(11, -2, 1)),
                    #(LinMRange(1, 10, 5), LinSRange(1, 10, 5), LinRange(1, 10, 5)),
                    #(StepMRangeLen(1, 3, 5), StepSRangeLen(1, 3, 5), StepRangeLen(1, 3, 5))
                   )
        @testset "Type: $(typeof(b))" begin
            for i in (m[1] - step(m), m[1], m[2], m[3], m[4], m[5], m[5] + step(m), m[5] + 2step(m))
                @testset "Number: $i" begin
                    for f in (<, >, <=, >=, ==)
                        @testset "Comparison: $f" begin
                            @testset "findfirst" begin
                                @test findfirst(f(i), m) == findfirst(f(i), s)
                                @test findfirst(f(i), s) == findfirst(f(i), s)
                            end

                            @testset "findlast" begin
                                @test findlast(f(i), m) == findlast(f(i), b)
                                @test findlast(f(i), s) == findlast(f(i), b)
                            end

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
                            if !isa(b, LinRange)
                                @testset "filter" begin
                                    @test filter(f(i), m) == filter(f(i), b)
                                    @test filter(f(i), s) == filter(f(i), b)
                                end
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
                    @testset "findfirst" begin
                        @test findfirst(f(i), m) == findfirst(f(i), s)
                        @test findfirst(f(i), s) == findfirst(f(i), s)
                    end

                    @testset "findlast" begin
                        @test findlast(f(i), m) == findlast(f(i), b)
                        @test findlast(f(i), s) == findlast(f(i), b)
                    end

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
