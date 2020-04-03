
@testset "findfirst" begin
    function typed_findfirst(f, x)
        out = findfirst(f, x)
        if out isa Nothing
            return 0
        else
            return out
        end
    end

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

    
    for (m,s,b) in ((OneToMRange(5), OneToSRange(5), OneTo(5)),
                    (UnitMRange(2, 6), UnitSRange(2, 6), UnitRange(2, 6)),
                    (StepMRange(1, 2, 11), StepSRange(1, 2, 11), StepRange(1, 2, 11)),
                    (StepMRange(11, -2, 1), StepSRange(11, -2, 1), StepRange(11, -2, 1)),
                    (LinMRange(1, 10, 5), LinSRange(1, 10, 5), LinRange(1, 10, 5)),
                    (StepMRangeLen(1, 3, 5), StepSRangeLen(1, 3, 5), StepRangeLen(1, 3, 5)))
        @testset "Type: $(typeof(b))" begin
            for f in (<, >, <=, >=, ==)
                for i1 in (m[1] - step(m), m[1], m[2], m[3], m[4], m[5] + 2step(m))
                    @testset "Comparison: $f" begin
                        @testset "findfirst($f($i1), $b)" begin
                            @test @inferred(typed_findfirst(f(i1), m)) ==
                                  @inferred(catch_nothing(find_first(f(i1), b)))
                            @test @inferred(typed_findfirst(f(i1), s)) ==
                                  @inferred(catch_nothing(find_first(f(i1), b)))
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
                    @testset "findfirst($f($i), $m" begin
                        @test @inferred(typed_findfirst(f(i), m)) == @inferred(catch_nothing(find_first(f(i), b)))
                    end
                    @testset "findfirst($f($i), $s" begin
                        @test @inferred(typed_findfirst(f(i), s)) == @inferred(catch_nothing(find_first(f(i), b)))
                    end
                end
            end
        end
    end
end

@testset "find_firstgt" begin
    one_to = OneToMRange(10)
    @testset "find_firstgt(::Int, ::OneToUnion)" begin
        @test catch_nothing(find_firstgt(11, one_to)) == 0
        @test catch_nothing(find_firstgt(-1, one_to)) == 1
        @test catch_nothing(find_firstgt(2, one_to)) == 3
        @test catch_nothing(find_firstgt(3, one_to)) == 4
    end

    @testset "find_firstgt(::Any, ::OneToUnion)" begin
        @test catch_nothing(find_firstgt(11.0, one_to)) == 0
        @test catch_nothing(find_firstgt(-1.0, one_to)) == 1
        @test catch_nothing(find_firstgt(2.0, one_to)) == 3
        @test catch_nothing(find_firstgt(3.0, one_to)) == 4
        @test catch_nothing(find_firstgt(3.5, one_to)) == 4
    end

    unit_range = 1:10
    @testset "find_firstgt(::Int, ::AbstractUnitRange)" begin
        @test catch_nothing(find_firstgt(11, unit_range)) == 0
        @test catch_nothing(find_firstgt(-1, unit_range)) == 1
        @test catch_nothing(find_firstgt(2, unit_range)) == 3
        @test catch_nothing(find_firstgt(3, unit_range)) == 4
    end

    @testset "find_firstgt(::Any, ::AbstractUnitRange)" begin
        @test catch_nothing(find_firstgt(11.0, unit_range)) == 0
        @test catch_nothing(find_firstgt(-1.0, unit_range)) == 1
        @test catch_nothing(find_firstgt(2.0, unit_range)) == 3
        @test catch_nothing(find_firstgt(3.0, unit_range)) == 4
        @test catch_nothing(find_firstgt(3.5, unit_range)) == 4
    end

    x = collect(1:10)
    @testset "find_firstgt(::Any, ::Any)" begin
        @test catch_nothing(find_firstgt(11.0, x)) == 0
        @test catch_nothing(find_firstgt(-1.0, x)) == 1
        @test catch_nothing(find_firstgt(2.0, x)) == 3
        @test catch_nothing(find_firstgt(3.0, x)) == 4
        @test catch_nothing(find_firstgt(3.5, x)) == 4
    end
end

@testset "find_firstgteq" begin
    one_to = OneToMRange(10)
    @testset "find_firstgteq(::Int, ::OneToUnion)" begin
        @test catch_nothing(find_firstgteq(11, one_to)) == 0
        @test catch_nothing(find_firstgteq(-1, one_to)) == 1
        @test catch_nothing(find_firstgteq(2, one_to)) == 2
        @test catch_nothing(find_firstgteq(3, one_to)) == 3
    end

    @testset "find_firstgteq(::Any, ::OneToUnion)" begin
        @test catch_nothing(find_firstgteq(11.0, one_to)) == 0
        @test catch_nothing(find_firstgteq(-1.0, one_to)) == 1
        @test catch_nothing(find_firstgteq(2.0, one_to)) == 2
        @test catch_nothing(find_firstgteq(3.0, one_to)) == 3
        @test catch_nothing(find_firstgteq(3.5, one_to)) == 4
    end

    unit_range = 1:10
    @testset "find_firstgteq(::Int, ::AbstractUnitRange)" begin
        @test catch_nothing(find_firstgteq(11, unit_range)) == 0
        @test catch_nothing(find_firstgteq(-1, unit_range)) == 1
        @test catch_nothing(find_firstgteq(2, unit_range)) == 2
        @test catch_nothing(find_firstgteq(3, unit_range)) == 3
    end

    @testset "find_firstgteq(::Any, ::AbstractUnitRange)" begin
        @test catch_nothing(find_firstgteq(11.0, unit_range)) == 0
        @test catch_nothing(find_firstgteq(-1.0, unit_range)) == 1
        @test catch_nothing(find_firstgteq(2.0, unit_range)) == 2
        @test catch_nothing(find_firstgteq(3.0, unit_range)) == 3
        @test catch_nothing(find_firstgteq(3.5, unit_range)) == 4
    end

    x = collect(1:10)
    @testset "find_firstgteq(::Any, ::Any)" begin
        @test catch_nothing(find_firstgteq(11.0, x)) == 0
        @test catch_nothing(find_firstgteq(-1.0, x)) == 1
        @test catch_nothing(find_firstgteq(2.0, x)) == 2
        @test catch_nothing(find_firstgteq(3.0, x)) == 3
        @test catch_nothing(find_firstgteq(3.5, x)) == 4
    end
end

@testset "find_firstlt" begin
    one_to = OneToMRange(10)

    x = collect(1:10)
    @testset "find_firstlt(::Any, ::Any)" begin
        @test catch_nothing(find_firstlt(11.0, x)) == 1
        @test catch_nothing(find_firstlt(-1.0, x)) == 0
        @test catch_nothing(find_firstlt(2.0, x)) == 1
        @test catch_nothing(find_firstlt(3.0, x)) == 1
        @test catch_nothing(find_firstlt(3.5, x)) == 1
    end
end

@testset "find_firstlteq" begin
    one_to = OneToMRange(10)

    x = collect(1:10)
    @testset "find_firstlteq(::Any, ::Any)" begin
        @test catch_nothing(find_firstlteq(11.0, x)) == 1
        @test catch_nothing(find_firstlteq(-1.0, x)) == 0
        @test catch_nothing(find_firstlteq(1.0, x)) == 1
        @test catch_nothing(find_firstlteq(3.0, x)) == 1
        @test catch_nothing(find_firstlteq(3.5, x)) == 1
    end
end

# find_first(::Base.Fix2{typeof(>),Int64}, ::StepSRangeLen{Int64,Int64,Int64,1,3,5,1})
#
