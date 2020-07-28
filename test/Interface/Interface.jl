
using StaticRanges.RangeInterface

static_has_start_field(x) = Val(RangeInterface.has_start_field(x))
static_has_stop_field(x) = Val(RangeInterface.has_stop_field(x))
static_has_step_field(x) = Val(RangeInterface.has_step_field(x))
static_has_offset_field(x) = Val(RangeInterface.has_offset_field(x))
static_has_len_field(x) = Val(RangeInterface.has_len_field(x))
static_has_lendiv_field(x) = Val(RangeInterface.has_lendiv_field(x))

@testset "has_field" begin
    @testset "UnitRange" begin
        x = Base.OneTo(10)
        @test @inferred(static_has_start_field(x)) === Val(false)
        @test @inferred(static_has_step_field(x)) === Val(false)
        @test @inferred(static_has_stop_field(x)) === Val(true)
        @test @inferred(static_has_offset_field(x)) === Val(false)
        @test @inferred(static_has_len_field(x)) === Val(false)
        @test @inferred(static_has_lendiv_field(x)) === Val(false)
    end

    @testset "UnitRange" begin
        x = 1:2
        @test @inferred(static_has_start_field(x)) === Val(true)
        @test @inferred(static_has_step_field(x)) === Val(false)
        @test @inferred(static_has_stop_field(x)) === Val(true)
        @test @inferred(static_has_offset_field(x)) === Val(false)
        @test @inferred(static_has_len_field(x)) === Val(false)
        @test @inferred(static_has_lendiv_field(x)) === Val(false)
    end

    @testset "StepRange" begin
        x = 1:1:2
        @test @inferred(static_has_start_field(x)) === Val(true)
        @test @inferred(static_has_step_field(x)) === Val(true)
        @test @inferred(static_has_stop_field(x)) === Val(true)
        @test @inferred(static_has_offset_field(x)) === Val(false)
        @test @inferred(static_has_len_field(x)) === Val(false)
        @test @inferred(static_has_lendiv_field(x)) === Val(false)
    end

    @testset "StepRange" begin
        x = LinRange(1, 10, 10)
        @test @inferred(static_has_start_field(x)) === Val(true)
        @test @inferred(static_has_step_field(x)) === Val(false)
        @test @inferred(static_has_stop_field(x)) === Val(true)
        @test @inferred(static_has_offset_field(x)) === Val(false)
        @test @inferred(static_has_len_field(x)) === Val(true)
        @test @inferred(static_has_lendiv_field(x)) === Val(true)
    end

    @testset "StepRangeLen" begin
        x = range(1.0, step=1, stop=10)
        @test @inferred(static_has_start_field(x)) === Val(false)
        @test @inferred(static_has_step_field(x)) === Val(true)
        @test @inferred(static_has_stop_field(x)) === Val(false)
        @test @inferred(static_has_offset_field(x)) === Val(true)
        @test @inferred(static_has_len_field(x)) === Val(true)
        @test @inferred(static_has_lendiv_field(x)) === Val(false)
    end

end
  filter test - 1.125, StepMRangeLen{Float64,Base.TwicePrecision{Float64},Base.TwicePrecision{Float64}}      |    1     4  filter test - 1.125, StepMRangeLen{Float64,Base.TwicePrecision{Float64},Base.TwicePrecision{Float64}}      |    1     4


