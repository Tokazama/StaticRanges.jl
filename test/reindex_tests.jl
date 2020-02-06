
#=
@testset "reindex" begin
    #=
    x, y, z = Axis(1:10, 2:11), Axis(1:10), SimpleAxis(1:10);
    @test reindex(x, collect(1:2:10)) == Axis([1, 3, 5, 7, 9] => 2:6)
    @test reindex(y, collect(1:2:10)) == Axis([1, 3, 5, 7, 9] => Base.OneTo(5))
    @test reindex(z, collect(1:2:10)) == SimpleAxis(1:5)
    =#

    @testset "Axis" begin
        ax1 = Axis(1:10)
        ax2 = Axis(OneTo(10))
        ax3 = Axis(2.0:11.0)
        #=
        @test reindex(ax1, 2) == 2
        @test reindex(ax2, 2) == 2
        @test reindex(ax3, 2) == 2
        @test reindex(ax3, 2.0) == 1
        =#

        sub_ax1 = reindex(ax1, 2:8)
        @test  sub_ax1 == 1:7
        @test keys(sub_ax1) == 2:8

        sub_ax2 = reindex(ax2, 2:8)
        @test sub_ax2 == 1:7
        @test keys(sub_ax2) == 2:8
        @test isa(values(sub_ax2), OneTo)

        sub_ax3 = reindex(ax3, 1:7)
        @test sub_ax3 == 1:7
        sub_ax3 = reindex(ax3, 2.0:8.0)
        @test sub_ax3 == 1:7
        @test keys(sub_ax3) == 2.0:8.0
        @test isa(values(sub_ax3), OneTo)
    end

    @testset "SimpleAxis" begin
        ax1 = SimpleAxis(1:10)
        ax2 = SimpleAxis(OneTo(10))
        #=
        @test reindex(ax1, 2) == 2
        @test reindex(ax2, 2) == 2
        =#

        sub_ax1 = reindex(ax1, 2:8)
        @test sub_ax1 == 1:7
        sub_ax2 = reindex(ax2, 2:8)
        @test sub_ax2 == 1:7
        @test isa(values(sub_ax2), OneTo)
    end
end
=#
