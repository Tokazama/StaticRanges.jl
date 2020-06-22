
@testset "Mutable vectors" begin
    @testset "StaticMutable" begin
        @testset "constructors" begin
            v = @inferred(StaticMutableVector((1,2,3)))
            @test v isa StaticMutableVector{Int,Int}
            @test StaticMutableVector([1,2,3]) == v
            @test StaticMutableVector{Int}([1,2,3]) == v
            @test StaticMutableVector{Int,Int}([1,2,3]) == v
        end

    end

    @testset "FixedMutable" begin
        @testset "constructors" begin
            v = @inferred(FixedMutableVector((1,2,3)))
            @test v isa FixedMutableVector{Int,Int}
            @test @inferred(FixedMutableVector([1,2,3])) == v
            @test @inferred(FixedMutableVector{Int}([1,2,3])) == v
            @test @inferred(FixedMutableVector{Int,Int}([1,2,3])) == v
        end
    end
    @testset "DynamicMutable" begin
        @testset "constructors" begin
            v = @inferred(DynamicMutableVector(1, 2, 3))
            @test v isa DynamicMutableVector{Int,Int}
            @test @inferred(DynamicMutableVector([1,2,3])) == v
            @test @inferred(DynamicMutableVector{Int}([1,2,3])) == v
            @test @inferred(DynamicMutableVector{Int,Int}([1,2,3])) == v
        end
    end
end
