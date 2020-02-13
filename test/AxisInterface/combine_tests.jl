@testset "combine" begin
end

@test Base.Broadcast.broadcast_shape((1:10,), (1:10, 1:10), (1:10,)) == (1:10, 1:10)
@test Broadcast.combine_axes(CartesianIndices((1,)), CartesianIndices((3, 2, 2)), CartesianIndices((3, 2, 2))) ==
        Broadcast.combine_axes(CartesianAxes((1,)), CartesianIndices((3, 2, 2)), CartesianAxes((3, 2, 2)))
@test Broadcast.combine_axes(LinearIndices((1,)), LinearIndices((3, 2, 2)), LinearIndices((3, 2, 2))) ==
        Broadcast.combine_axes(LinearAxes((1,)), CartesianAxes((3, 2, 2)), CartesianAxes((3, 2, 2)))

