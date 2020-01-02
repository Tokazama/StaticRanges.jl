
@testset "getindex" begin
    @testset "Axis" begin
        ax1 = Axis(1:10)
        ax2 = Axis(OneTo(10))
        ax3 = Axis(2.0:11.0)
        @test getindex(ax1, 2) == 2
        @test getindex(ax2, 2) == 2
        @test getindex(ax3, 2) == 2
        @test getindex(ax3, 2.0) == 1

        @test getindex(ax1, 2:8) == 2:8
        @test getindex(ax2, 2:8) == 2:8
        @test getindex(ax3, 2:8) == 2:8
        @test getindex(ax3, 2.0:8.0) == 1:7
    end

    @testset "SimpleAxis" begin
        ax1 = SimpleAxis(1:10)
        ax2 = SimpleAxis(OneTo(10))
        @test getindex(ax1, 2) == 2
        @test getindex(ax2, 2) == 2

        @test getindex(ax1, 2:8) == 2:8
        @test getindex(ax2, 2:8) == 2:8
    end
end
