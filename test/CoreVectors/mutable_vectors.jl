
@testset "Mutable vectors" begin
    @testset "StaticMutable" begin
        @testset "constructors" begin
            v = @inferred(StaticMutableVector((1,2,3)))
            @test v isa StaticMutableVector{Int,Int}
            @test StaticMutableVector([1,2,3]) == v
            @test StaticMutableVector{Int}([1,2,3]) == v
            @test StaticMutableVector{Int,Int}([1,2,3]) == v
        end
        @testset "getindex" begin
            v = @inferred(StaticMutableVector(1, 2, 3))
            @test @inferred(v[1]) === 1
            v2 = @inferred(v[1:2])
            @test v2 == 1:2
            @test v2 isa FixedMutableVector{Int,Int}
            v3 = @inferred(v[:])
            @test v3 == 1:3
            @test v3 isa StaticMutableVector{Int,Int}
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
        @testset "getindex" begin
            v = @inferred(FixedMutableVector(1, 2, 3))
            @test @inferred(v[1]) === 1
            v2 = @inferred(v[1:2])
            @test v2 == 1:2
            @test v2 isa FixedMutableVector{Int,Int}
            v3 = @inferred(v[:])
            @test v3 == 1:3
            @test v3 isa FixedMutableVector{Int,Int}
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
        @testset "getindex" begin
            v = @inferred(DynamicMutableVector(1, 2, 3))
            @test @inferred(v[1]) === 1
            v2 = @inferred(v[1:2])
            @test v2 == 1:2
            @test v2 isa DynamicMutableVector{Int,Int}
            v3 = @inferred(v[:])
            @test v3 == 1:3
            @test v3 isa DynamicMutableVector{Int,Int}
        end
    end
end
