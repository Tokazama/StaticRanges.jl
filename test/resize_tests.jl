
using StaticRanges: grow_to, grow_to!

@testset "grow" begin
    @testset "grow_end" begin
        m,f,s = MutableRange(UnitRange(1, 10)), 1:10, static(UnitRange(1:10))
        x = @inferred(grow_end(m, 2))
        @test m == 1:10
        @test x == 1:12

        x = @inferred(grow_end(f, 2))
        @test f == 1:10
        @test x == 1:12

        x = @inferred((s -> grow_end(s, 2))(s))

        @test s == 1:10
        @test x == 1:12
    end

    @testset "grow_end!" begin
        m,f,s = MutableRange(UnitRange(1, 10)), 1:10, static(UnitRange(1, 10))
        x = @inferred(grow_end!(m, 2))
        @test m == 1:12
        @test x == 1:12

        #= FIXME These should have proper error messages
        x = @inferred(grow_end!(f, 2))
        @test f == 1:10
        @test x == 1:12

        x = @inferred((s -> grow_end(s, 2))(s))

        @test s == 1:10
        @test x == 1:12
        =#

        v = Vector{Int}(undef, 10)
        grow_end!(v, 2)
        @test length(v) == 12
    end

    @testset "grow_beg" begin
        m,f,s = mutable(UnitRange(1:10)), 1:10, static(UnitRange(1:10))
        x = @inferred(grow_beg(m, 2))
        @test m == 1:10
        @test x == -1:10

        x = @inferred(grow_beg(f, 2))
        @test f == 1:10
        @test x == -1:10

        x = @inferred((s -> grow_beg(s, 2))(s))
        @test s == 1:10
        @test x == -1:10
    end

    @testset "grow_beg!" begin
        m,f,s = MutableRange(UnitRange(1, 10)), 1:10, static(UnitRange(1, 10))
        x = @inferred(grow_beg!(m, 2))
        @test m == -1:10
        @test x == -1:10

        v = Vector{Int}(undef, 10)
        grow_beg!(v, 2)
        @test length(v) == 12
    end
end

@testset "shrink" begin
    @testset "shrink_beg" begin
        m,f,s = mutable(UnitRange(1:10)), 1:10, static(UnitRange(1:10))
        x = @inferred(StaticRanges.shrink_beg(m, 2))
        @test m == 1:10
        @test x == 3:10

        x = @inferred(shrink_beg(f, 2))
        @test f == 1:10
        @test x == 3:10

        x = @inferred((s -> shrink_beg(s, 2))(s))
        @test s == 1:10
        @test x == 3:10
    end

    @testset "shrink_beg!" begin
        m,f,s = mutable(UnitRange(1:10)), 1:10, static(UnitRange(1:10))
        x = @inferred(shrink_beg!(m, 2))
        @test m == 3:10
        @test x == 3:10

        v = Vector{Int}(undef, 10)
        shrink_beg!(v, 2)
        @test length(v) == 8
    end

    @testset "shrink_end" begin
        m,f,s = mutable(UnitRange(1:10)), 1:10, static(UnitRange(1:10))
        x = @inferred(shrink_end(m, 2))
        @test m == 1:10
        @test x == 1:8

        x = @inferred(shrink_end(f, 2))
        @test f == 1:10
        @test x == 1:8

        x = @inferred((s -> shrink_end(s, 2))(s))
        @test s == 1:10
        @test x == 1:8
    end

    @testset "shrink_end!" begin
        m,f,s = mutable(UnitRange(1:10)), 1:10, static(UnitRange(1:10))
        x = @inferred(shrink_end!(m, 2))
        @test m == 1:8
        @test x == 1:8

        v = Vector{Int}(undef, 10)
        shrink_end!(v, 2)
        @test length(v) == 8
    end
end


@testset "grow_to" begin
    m,f,s = mutable(UnitRange(1, 10)), 1:10, static(UnitRange(1, 10))
    x = @inferred(grow_to(m, 11))
    @test m == 1:10
    @test x == 1:11

    x = @inferred(grow_to(f, 11))
    @test f == 1:10
    @test x == 1:11

    x = (s -> grow_to(s, 11))(s)
    @test s == 1:10
    @test x == 1:11

    x = @inferred(grow_to!(m, 11))
    @test m == 1:11
    @test x == 1:11

    x = @inferred(grow_to!(m, 13))
    @test m == 1:13
    @test x == 1:13
end

#=
@testset "resize_first" begin
    m,f,s = UnitMRange(1, 10), 1:10, UnitSRange(1, 10)
    for (n, new_range) in ((11, 0:10), (9, 2:10), (10, 1:10))
        x = @inferred(resize_first(m, n))
        @test m == 1:10
        @test x == new_range

        x = @inferred(resize_first(f, n))
        @test f == 1:10
        @test x == new_range

        # FIXME This doesn't infer the type properly right now
        x = (s -> resize_first(s, n))(s)
        @test s == 1:10
        @test x == new_range
    end

    x = @inferred(resize_first!(m, 10))
    @test m == 1:10
    @test x == 1:10

    x = @inferred(resize_first!(m, 9))
    @test m == 2:10
    @test x == 2:10

    x = @inferred(resize_first!(m, 10))
    @test m == 1:10
    @test x == 1:10
end

@testset "[next/prev]_type" begin
    @test @inferred(StaticRanges.grow_end(["a"], 1)) == ["a", "b"]
    @test @inferred(StaticRanges.grow_beg(["a"], 1)) == ["`", "a"]
end
=#

