@testset "combine" begin
    for (v1,v2,v3) in ((OneTo(10), OneTo(9), OneTo(10)),
                       (OneTo(10), SimpleAxis(1:9), OneTo(10)),
                       (SimpleAxis(1:10), OneTo(9), OneTo(10)),
                       (OneTo(10), Axis(1:9), OneTo(10)),
                       (Axis(1:10), OneTo(9), OneTo(10)),
                       (OneTo(10), 2:9, 1:10),
                       (1:5, 1:5, 1:5),
                      )

        Base.Broadcast.broadcast_shape((1:10,), (1:10, 1:10), (1:10,))

        @testset "$(v1)-$(v2)" begin
            @test combine_axis(v1, v2) == v3
            @test combine_axis(v2, v1) == v3
        end
        #=
        rv1 = reverse(v1)
        @testset "$(rv1)-$(v2)" begin
            @test combine_axis(rv1, v2) == reverse(v3)
            @test combine_axis(v2, rv1) == combine_axis(v2, reverse(rv1))
        end
        =#
        #=
        @testset "$(v4)-$(v5)" begin
            @test combine(v4, v5) == v6
            @test combine(v4, v5) == v6
        end
        =#
    end
end

@test Broadcast.combine_axes(CartesianIndices((1,)), CartesianIndices((3, 2, 2)), CartesianIndices((3, 2, 2))) ==
        Broadcast.combine_axes(CartesianAxes((1,)), CartesianIndices((3, 2, 2)), CartesianAxes((3, 2, 2)))
@test Broadcast.combine_axes(LinearIndices((1,)), LinearIndices((3, 2, 2)), LinearIndices((3, 2, 2))) ==
        Broadcast.combine_axes(LinearAxes((1,)), CartesianAxes((3, 2, 2)), CartesianAxes((3, 2, 2)))

