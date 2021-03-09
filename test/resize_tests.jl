

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
    end

    @testset "grow_beg" begin
        m,f,s = as_dynamic(UnitRange(1:10)), 1:10, static(UnitRange(1:10))
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
    end
end

@testset "shrink" begin
    @testset "shrink_beg" begin
        m,f,s = as_dynamic(UnitRange(1:10)), 1:10, static(UnitRange(1:10))
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
        m,f,s = as_dynamic(UnitRange(1:10)), 1:10, static(UnitRange(1:10))
        x = @inferred(shrink_beg!(m, 2))
        @test m == 3:10
        @test x == 3:10
    end

    @testset "shrink_beg" begin
        m,f,s = as_dynamic(UnitRange(1:10)), 1:10, static(UnitRange(1:10))
        x = @inferred(shrink_beg(m, 2))
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
        m,f,s = as_dynamic(UnitRange(1:10)), 1:10, static(UnitRange(1:10))
        x = @inferred(shrink_beg!(m, 2))
        @test m == 3:10
        @test x == 3:10
    end
end

#=
@testset "resize_last" begin
    m,f,s = UnitMRange(1, 10), 1:10, UnitSRange(1, 10)
    for (n, new_range) in ((11, 1:11), (9, 1:9), (10, 1:10))
        m,f,s = UnitMRange(1, 10), 1:10, UnitSRange(1, 10)
        x = @inferred(resize_last(m, n))
        @test m == 1:10
        @test x == new_range

        x = @inferred(resize_last(f, n))
        @test f == 1:10
        @test x == new_range

        # FIXME This doesn't infer the type properly right now
        x = (s -> resize_last(s, n))(s)
        @test s == 1:10
        @test x == new_range
    end
    x = @inferred(resize_last!(m, 10))
    @test m == 1:10
    @test x == 1:10

    x = @inferred(resize_last!(m, 9))
    @test m == 1:9
    @test x == 1:9

    x = @inferred(resize_last!(m, 10))
    @test m == 1:10
    @test x == 1:10
end

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

