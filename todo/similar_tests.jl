
@testset "similar tests" begin
    @testset "OneTo" begin
        r = OneToMRange(10)
        @test eltype(@inferred(similar(r, UInt))) <: UInt
        r = as_fixed(r)
        @test eltype(@inferred(similar(r, UInt))) <: UInt
        r = as_static(r)
        @test eltype(@inferred(similar(r, UInt))) <: UInt
    end

    @testset "UnitRange" begin
        r = UnitRange(1,10)
        @test eltype(@inferred(similar(r, UInt))) <: UInt
        r = as_fixed(r)
        @test eltype(@inferred(similar(r, UInt))) <: UInt
        r = as_static(r)
        @test eltype(@inferred(similar(r, UInt))) <: UInt
    end

    @testset "StepRange" begin
        r = StepRange(1,2,10)
        @test eltype(@inferred(similar(r, UInt))) <: UInt
        r = as_fixed(r)
        @test eltype(@inferred(similar(r, UInt))) <: UInt
        r = as_static(r)
        @test eltype(@inferred(similar(r, UInt))) <: UInt
    end

    @testset "StepRangeLen" begin
        r = StepRangeLen(1,2,10)
        @test eltype(@inferred(similar(r, UInt))) <: UInt
        r = as_fixed(r)
        @test eltype(@inferred(similar(r, UInt))) <: UInt
        r = as_static(r)
        @test eltype(@inferred(similar(r, UInt))) <: UInt
    end
end
