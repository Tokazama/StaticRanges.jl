

@testset "AxisIndices" begin
    @testset "CartesianAxes" begin
        cartaxes = CartesianAxes((2.0:5.0, 1:4))
        cartinds = CartesianIndices((1:4, 1:4))
        for (axs, inds) in zip(collect(cartaxes), collect(cartinds))
            @test axs == inds.I
        end

        for (axs, inds) in zip(cartaxes, cartinds)
            @test axs == inds.I
        end

        @test collect(cartaxes) == cartaxes[1:4,1:4]
    end

    @testset "LinearAxes" begin
        linaxes = LinearAxes((2.0:5.0, 1:4))
        lininds = LinearIndices((1:4, 1:4))
        for (axs, inds) in zip(collect(linaxes), collect(lininds))
            @test axs == inds
        end

        for (axs, inds) in zip(linaxes, lininds)
            @test axs == inds
        end
        @test collect(linaxes) == linaxes[1:4,1:4]
    end

    @testset "nextind and prevind" begin
        @test nextind(CartesianAxes((4,)), 2) == 3
        @test nextind(CartesianAxes((2, 3)), (2, 1)) == (1, 2)
        @test prevind(CartesianAxes((4,)), 2) == 1
        @test prevind(CartesianAxes((2, 3)), (2,1)) == (1, 1)
    end


    @test promote_shape(CartesianAxes((3,4,1,1,1)), CartesianAxes((3, 4))) ==
            (Base.OneTo(3), Base.OneTo(4), Base.OneTo(1), Base.OneTo(1), Base.OneTo(1))
end

