@testset "Order tests" begin
    @testset "gtmax" begin
        @test @inferred(gtmax(1:10, 1:11)) == false
        @test @inferred(gtmax(1:11, 1:10)) == true
    end

    @testset "ltmax" begin
        @test @inferred(ltmax(1:10, 1:11)) == true
        @test @inferred(ltmax(1:11, 1:10)) == false
    end

    @testset "eqmax" begin
        @test @inferred(eqmax(1:10, 3:10)) == true
        @test @inferred(eqmax(1:11, 1:10)) == false
    end

    @testset "gtmin" begin
        @test @inferred(gtmin(1:10, 3:11)) == false
        @test @inferred(gtmin(3:11, 1:10)) == true
    end

    @testset "ltmin" begin
        @test @inferred(ltmin(1:10, 3:11)) == true
        @test @inferred(ltmin(3:11, 1:10)) == false
    end

    @testset "eqmin" begin
        @test @inferred(eqmin(3:10, 3:11)) == true
        @test @inferred(eqmin(3:11, 2:10)) == false
    end

    @testset "cmpmin" begin
        @test @inferred(cmpmin(0:10, 3.0:-1.0:1.0)) == -1
    end

    @testset "cmpmax" begin
        @test @inferred(cmpmax(1:10, 3.0:-1.0:1.0)) == 1
    end

    @testset "group_max" begin
        @test @inferred(group_max(1:10, [1,4, 20], 3.0:-1.0:1.0)) == 20
    end

    @testset "group_min" begin
        @test @inferred(group_min(1:10, [1,4, 20], 3.0:-1.0:1.0)) == 1
    end

    @testset "min_of_group_max" begin
        @test @inferred(min_of_group_max(1:10, 3.0:-1.0:1.0)) == min(maximum(1:10), maximum(3.0:-1.0:1.0))
    end

    @testset "max_of_group_min" begin
        @test @inferred(max_of_group_min(1:10, 3.0:-1.0:1.0)) == max(minimum(1:10), minimum(3.0:-1.0:1.0))
    end
end

@testset "Order traits" begin
    x = 1:10
    y = 10:-2:1
    z = [1.5, 1.7, 3.3]
    a = [1, 3, 2]

    @testset "order" begin
        @test @inferred(order(x)) == Forward
        @test order(y) == Reverse
        @test order(z) == Forward
        @test order(a) == Unordered
    end

    @testset "is_before" begin
        @test @inferred(is_before(2, 3, x)) == true
        @test @inferred(is_before(3, 2, x)) == false
        @test @inferred(is_before(1:2, 3:4)) == true
        @test @inferred(is_before(3:4, 1:2)) == false
        @test @inferred(is_before(2:-1:1, 4:-1:3)) == true
        @test @inferred(is_before(4:-1:3, 2:-1:1)) == false
    end

    @testset "is_after" begin
        @test @inferred(is_after(2, 3, x)) == false
        @test @inferred(is_after(3, 2, x)) == true
        @test @inferred(is_after(1:2, 3:4)) == false
        @test @inferred(is_after(3:4, 1:2)) == true
        @test @inferred(is_after(2:-1:1, 4:-1:3)) == false
        @test @inferred(is_after(4:-1:3, 2:-1:1)) == true
    end

    @testset "is_forward" begin
        @test @inferred(is_forward(x)) == true
        @test @inferred(is_forward(y)) == false
        @test @inferred(is_forward(z)) == true
        @test @inferred(is_forward(a)) == false
    end

    @testset "is_reverse" begin
        @test @inferred(is_reverse(x)) == false
        @test @inferred(is_reverse(y)) == true
        @test @inferred(is_reverse(z)) == false
        @test @inferred(is_reverse(a)) == false
    end

    @testset "is_ordered" begin
        @test @inferred(is_ordered(x)) == true
        @test @inferred(is_ordered(y)) == true
        @test @inferred(is_ordered(z)) == true
        @test @inferred(is_ordered(a)) == false
    end

    @testset "is_within" begin
        for (xo,yo,x,y) in ((Forward, Forward, 2:3, 1:10),
                            (Reverse, Reverse, 3:-1:2, 10:-1:1),
                            (Forward, Reverse, 2:3, 10:-1:1),
                            (Reverse, Forward, 3:-1:2, 1:10))
            @test @inferred(is_within(x, y)) == true
            @test @inferred(is_within(x, xo, y, yo)) == true
            @test @inferred(is_within(y, yo, x, xo)) == false
        end
    end

    @testset "is_contiguous" begin
        @test @inferred(is_contiguous(1:3, 3:4)) == true
        @test @inferred(is_contiguous(3:-1:1, 3:4)) == true
        @test @inferred(is_contiguous(3:-1:1, 4:-1:3)) == true
        @test @inferred(is_contiguous(1:3, 4:-1:3)) == true
        @test @inferred(is_contiguous(1:3, 2:4)) == false
    end

    @testset "next_type" begin
        @test next_type("a") == "b"
        @test next_type(:a) == :b
        @test next_type('a') == 'b'
        @test next_type(1) == 2
        @test next_type(1.0) == nextfloat(1.0)
        @test next_type("") == ""
    end

    @testset "prev_type" begin
        @test prev_type("b") == "a"
        @test prev_type(:b) == :a
        @test prev_type('b') == 'a'
        @test prev_type(1) == 0
        @test prev_type(nextfloat(1.0)) == prevfloat(nextfloat(1.0))
        @test prev_type("") == ""
    end

    @testset "is_forward" begin
        @test @inferred(is_forward([1, 2, 3])) == true
        @test @inferred(is_forward(Forward)) == true
        @test @inferred(is_forward(Reverse)) == false
        @test @inferred(is_forward(UnitSRange(1, 10))) == true
    end
    @testset "is_reverse" begin
        @test @inferred(is_reverse([1, 2, 3])) == false
        @test @inferred(is_reverse(Forward)) == false
        @test @inferred(is_reverse(Reverse)) == true
        @test @inferred(is_reverse(UnitSRange(1, 10))) == false
    end
end

#=
@testset "grow" begin
    sv_int = sorted([1,2,3])
    sv_float = sorted([1., 2., 3.])
    @test @inferred(grow_last!(sv_int, 2)) == [1, 2, 3, 4, 5]
    @test @inferred(grow_last!(sv_float, 1)) == [1., 2., 3., nextfloat(3.)]

    sr_int = sorted(mrange(1, 10))
    sr_float = sorted(mrange(1., 10.))
    @test @inferred(grow_last!(sr_int, 2)) == sorted(mrange(1, 12))
    @test @inferred(grow_last!(sr_float, 1)) == sorted(mrange(1., 11.))


    @test @inferred(grow_first!(sv_int, 2)) == [-1, 0, 1, 2, 3, 4, 5]
    @test @inferred(grow_first!(sv_float, 1)) == [prevfloat(1.), 1., 2., 3., nextfloat(3.)]

    @test @inferred(grow_first!(sr_int, 2)) == sorted(mrange(-1, 12))
    @test @inferred(grow_first!(sr_float, 1)) == sorted(mrange(0., 11.))
end

@testset "shrink" begin
    sv = SortedVector([1,2,3])
    @test shrink_last!(sv, 1) == [1,2]
    @test shrink_first!(sv, 1) == [2]
end
=#
