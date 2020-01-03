using StaticRanges: append_axis!, drop_axes, to_axis, vcat_axes, hcat_axes,
    append_axes, append_axis!, matmul_axes, inverse_axes, covcor_axes, permute_axes,
    reduce_axes, reduce_axis, filter_axes, append_axis

@testset "drop_axes" begin
    axs = (Axis{:a}(1:10), Axis{:b}(1:10), Axis(1:10));
    @test drop_axes(axs, :a) == (Axis{:b}(1:10, OneTo(10)), Axis(1:10, OneTo(10)))
    @test drop_axes(axs, :b) == (Axis{:a}(1:10, OneTo(10)), Axis(1:10, OneTo(10)))
    @test drop_axes(axs, (:a, :b)) == (Axis(1:10, OneTo(10)),)
end

@testset "cat_axes" begin
    @test vcat_axes((Axis{:a}(1:2), Axis{:b}(1:4)), (Axis{:z}(1:2), Axis(1:4))) == (Axis{:a}(1:4, OneTo(4)), Axis{:b}(1:4, OneTo(4)))

    a, b = [1 2 3 4 5], [6 7 8 9 10; 11 12 13 14 15];
    @test vcat_axes(a, b) == axes(vcat(a, b))

    @test hcat_axes((Axis{:a}(1:4), Axis{:b}(1:2)), (Axis{:z}(1:4), Axis(1:2))) == (Axis{:a}(1:4, OneTo(4)), Axis{:b}(1:4, OneTo(4)))

    a, b = [1; 2; 3; 4; 5], [6 7; 8 9; 10 11; 12 13; 14 15]
    @test hcat_axes(a, b) == axes(hcat(a, b))

    #@test cat_axes((Axis{:a}(1:4), Axis{:b}(1:2)), (Axis{:z}(1:4), Axis(1:2)), (:a, :b)) = (Axis{:a}(1:8, OneTo(8)), Axis{:b}(1:4, OneTo(4)))
end

@testset "append_axes" begin
    x, y = Axis(UnitMRange(1, 10)), SimpleAxis(UnitMRange(1, 10))
    @test append_axis(x, y) == Axis(UnitMRange(1:20), OneToMRange(20))
    @test append_axis(y, x) == SimpleAxis(UnitMRange(1:20))
    @test append_axis!(x, y) == Axis(UnitMRange(1:20), OneToMRange(20))
    @test append_axis!(y, x) == SimpleAxis(UnitMRange(1:30))
end

@testset "filter_axes" begin
    axs = (Axis{:a}(1:10), Axis{:b}(1:10), Axis(1:10));
    @test filter_axes(x -> axis_names(x) == :a, axs) == (Axis{:a}(1:10, OneTo(10)),)
    @test filter_axes(x -> length(x) == 10, axs) == (Axis{:a}(1:10, OneTo(10)), Axis{:b}(1:10, OneTo(10)), Axis(1:10, OneTo(10)))
end

@testset "matmul_axes" begin
    axs2, axs1 = (Axis{:b}(1:10), Axis(1:10)), (Axis{:a}(1:10),);

    @test matmul_axes(axs2, axs2) == (Axis{:b}(1:10, OneTo(10)), Axis(1:10, OneTo(10)))
    @test matmul_axes(axs1, axs2) == (Axis{:a}(1:10, OneTo(10)), Axis(1:10, OneTo(10)))
    @test matmul_axes(axs2, axs1) == (Axis{:b}(1:10, OneTo(10)),)
    @test matmul_axes(axs1, axs1) == ()

    @test inverse_axes((Axis{:a}(1:4), Axis{:b}(1:4))) == (Axis{:b}(1:4, OneTo(4)), Axis{:a}(1:4, Base.OneTo(4)))

    @test covcor_axes((Axis{:a}(1:4), Axis{:b}(1:4)), 2) == (Axis{:a}(1:4, OneTo(4)), Axis{:a}(1:4, OneTo(4)))
    @test covcor_axes((Axis{:a}(1:4), Axis{:b}(1:4)), :b) == (Axis{:a}(1:4, OneTo(4)), Axis{:a}(1:4, OneTo(4)))
    @test covcor_axes((Axis{:a}(1:4), Axis{:b}(1:4)), 1) == (Axis{:b}(1:4, OneTo(4)), Axis{:b}(1:4, OneTo(4)))
    @test covcor_axes((Axis{:a}(1:4), Axis{:b}(1:4)), :a) == (Axis{:b}(1:4, OneTo(4)), Axis{:b}(1:4, OneTo(4)))
end


@testset "permute_axes" begin
    @test permute_axes((Axis{:a}(1:10), Axis{:b}(1:10), Axis(1:10)), (:b, 3, :a)) == (Axis{:a}(1:10, OneTo(10)), Axis(1:10, OneTo(10)), Axis{:b}(1:10, OneTo(10)))
    @test permute_axes((Axis(1:4),)) == (Axis(1:1, OneTo(1)), Axis(1:4, OneTo(4)))
    @test permute_axes((Axis{:a}(1:4), Axis{:b}(1:4))) == (Axis{:b}(1:4, OneTo(4)), Axis{:a}(1:4, OneTo(4)))
end


@testset "reduce_axes" begin
    @test reduce_axes((Axis{:a}(1:4), Axis{:b}(1:4)), 2) == (Axis{:a}(1:4, OneTo(4)), Axis{:b}(1:1, OneTo(1)))
    @test reduce_axes((Axis{:a}(1:4), Axis{:b}(1:4)), :a) == (Axis{:a}(1:1, OneTo(1)), Axis{:b}(1:4, OneTo(4)))
    @test reduce_axis(Axis{:a}(1:4)) == Axis{:a}(1:1, OneTo(1))
    @test reduce_axis(1:4) == 1:1
end
