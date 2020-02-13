@testset "Indexing" begin
    @testset "AbstractAxis" begin
        x = Axis(1:10)
        @test getindex(x, CartesianIndex(1)) == 1
        @test Base.to_index(x, CartesianIndex(1)) == 1
        @test Base.checkindex(Bool, x, [1,2,3])
        @test !Base.checkindex(Bool, x, [0, 1,2,3])

        # trigger errors when functions return bad indices
        @test_throws BoundsError Base.to_index(Axis(1:10), ==(11))
    end

    @testset "AxisIndices" begin
        x = CartesianAxes((2,2))
        @test getindex(x, 1, :) == CartesianAxes((2,2))[1, 1:2]
        @test getindex(x, :, 1) == CartesianAxes((2,2))[1:2, 1]

        @test getindex(x, CartesianIndex(1, 1)) == CartesianIndex(1,1)
        @test getindex(x, [true, true], :) == CartesianAxes((2,2))
        @test getindex(CartesianAxes((2,)), [CartesianIndex(1)]) == [CartesianIndex(1)]

        @test to_indices(x, axes(x), (CartesianIndex(1),)) == (1,)
        @test to_indices(x, axes(x), (CartesianIndex(1,1),)) == (1, 1)
    end


end
