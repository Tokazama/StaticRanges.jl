using Base: to_index

@testset "Indexing" begin

    @testset "checkbounds" begin
        @test checkbounds(Bool, a1, CartesianIndex(1))
        @test !checkbounds(Bool, a1, CartesianIndex(5))
        # TODO test checkbounds by key indexing
        Base.checkindex(Bool, a1, [true, true])
    end

    @testset "to_index" begin
        a = Axis(2:10)
        @test to_index(a, 1) == 1
        @test to_index(a, 1:2) == 1:2
    end

end
