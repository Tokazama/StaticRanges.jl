

@testset "grow" begin
    @testset "grow_last" begin
        m,f,s = UnitMRange(1, 10), 1:10, UnitSRange(1, 10)
        x = @inferred(grow_last(m, 2))
        @test m == 1:10
        @test x == 1:12

        x = @inferred(grow_last(f, 2))
        @test f == 1:10
        @test x == 1:12

        x = @inferred((s -> grow_last(s, 2))(s))

        @test s == 1:10
        @test x == 1:12
    end

    @testset "grow_last!" begin
        m,f,s = UnitMRange(1, 10), 1:10, UnitSRange(1, 10)
        x = @inferred(grow_last!(m, 2))
        @test m == 1:12
        @test x == 1:12

        #= FIXME These should have proper error messages
        x = @inferred(grow_last!(f, 2))
        @test f == 1:10
        @test x == 1:12

        x = @inferred((s -> grow_last(s, 2))(s))

        @test s == 1:10
        @test x == 1:12
        =#
    end

    @testset "grow_first" begin
        m,f,s = UnitMRange(1, 10), 1:10, UnitSRange(1, 10)
        x = @inferred(grow_first(m, 2))
        @test m == 1:10
        @test x == -1:10

        x = @inferred(grow_first(f, 2))
        @test f == 1:10
        @test x == -1:10

        x = @inferred((s -> grow_first(s, 2))(s))
        @test s == 1:10
        @test x == -1:10
    end

    @testset "grow_first!" begin
        m,f,s = UnitMRange(1, 10), 1:10, UnitSRange(1, 10)
        x = @inferred(grow_first!(m, 2))
        @test m == -1:10
        @test x == -1:10
    end
end

@testset "shrink" begin
    @testset "shrink_last" begin
        m,f,s = UnitMRange(1, 10), 1:10, UnitSRange(1, 10)
        x = @inferred(shrink_last(m, 2))
        @test m == 1:10
        @test x == 1:8

        x = @inferred(shrink_last(f, 2))
        @test f == 1:10
        @test x == 1:8

        x = @inferred((s -> shrink_last(s, 2))(s))
        @test s == 1:10
        @test x == 1:8
    end

    @testset "shrink_last!" begin
        m,f,s = UnitMRange(1, 10), 1:10, UnitSRange(1, 10)
        x = @inferred(shrink_last!(m, 2))
        @test m == 1:8
        @test x == 1:8
    end

    @testset "shrink_first" begin
        m,f,s = UnitMRange(1, 10), 1:10, UnitSRange(1, 10)
        x = @inferred(shrink_first(m, 2))
        @test m == 1:10
        @test x == 3:10

        x = @inferred(shrink_first(f, 2))
        @test f == 1:10
        @test x == 3:10

        x = @inferred((s -> shrink_first(s, 2))(s))
        @test s == 1:10
        @test x == 3:10
    end

    @testset "shrink_first!" begin
        m,f,s = UnitMRange(1, 10), 1:10, UnitSRange(1, 10)
        x = @inferred(shrink_first!(m, 2))
        @test m == 3:10
        @test x == 3:10
    end
end

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

