
@testset "immutable vectors" begin
    @testset "StaticImmutable" begin
        @testset "constructors" begin
            v = @inferred(StaticImmutableVector((1,2,3)))
            @test v isa StaticImmutableVector{Int,Int}
            @test StaticImmutableVector([1,2,3]) === v
            @test StaticImmutableVector{Int}([1,2,3]) === v
            @test StaticImmutableVector{Int,Int}([1,2,3]) === v
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
    end

end
