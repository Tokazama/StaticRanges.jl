
@testset "immutable vectors" begin
    @testset "StaticImmutable" begin
        @testset "constructors" begin
            v = @inferred(StaticImmutableVector((1,2,3)))
            @test v isa StaticImmutableVector{Int,Int}
            @test StaticImmutableVector([1,2,3]) === v
            @test StaticImmutableVector{Int}([1,2,3]) === v
            @test StaticImmutableVector{Int,Int}([1,2,3]) === v
        end
        @testset "getindex" begin
            v = @inferred(StaticImmutableVector(1, 2, 3))
            @test @inferred(v[1]) === 1
            v2 = @inferred(v[1:2])
            @test v2 == 1:2
            @test v2 isa FixedImmutableVector{Int,Int}
            v3 = @inferred(v[:])
            @test v3 == 1:3
            @test v3 isa StaticImmutableVector{Int,Int}
        end
    end

    @testset "FixedImmutable" begin
        @testset "constructors" begin
            v = @inferred(FixedImmutableVector((1,2,3)))
            @test v isa FixedImmutableVector{Int,Int}
            @test @inferred(FixedImmutableVector([1,2,3])) === v
            @test @inferred(FixedImmutableVector{Int}([1,2,3])) === v
            @test @inferred(FixedImmutableVector{Int,Int}([1,2,3])) === v
        end
        @testset "getindex" begin
            v = @inferred(FixedImmutableVector(1, 2, 3))
            @test @inferred(v[1]) === 1
            v2 = @inferred(v[1:2])
            @test v2 == 1:2
            @test v2 isa FixedImmutableVector{Int,Int}
            v3 = @inferred(v[:])
            @test v3 == 1:3
            @test v3 isa FixedImmutableVector{Int,Int}
        end
    end

end
