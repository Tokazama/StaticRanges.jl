

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
    end

    @testset "CartesianAxes" begin
        linaxes = LinearAxes((2.0:5.0, 1:4))
        lininds = LinearIndices((1:4, 1:4))
        for (axs, inds) in zip(collect(linaxes), collect(lininds))
            @test axs == inds
        end

        for (axs, inds) in zip(linaxes, lininds)
            @test axs == inds
        end
    end
end

