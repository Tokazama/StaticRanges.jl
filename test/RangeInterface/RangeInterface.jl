
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


struct Axes{N,T<:Tuple{Vararg{Any,N}}} <: AbstractArray{Int,N}
    axes::T
end
Axes(args...) = Axes(args)

StaticRanges.axes_type(::Type{Axes{N,T}}, i::Int) where {N,T} = T.parameters[i]
Base.ndims(::Type{<:Axes{N}}) where {N} = N

is_static_val(x) = Val(is_static(x))
is_dynamic_val(x) = Val(is_dynamic(x))
is_fixed_val(x) = Val(is_fixed(x))

@testset "axes_type" begin
    axs = Axes(UnitRange(1, 2), UnitRange(1, 2), UnitRange(1, 2));
    @test is_static_val(axs) == Val(false)
    @test is_fixed_val(axs) == Val(true)
    @test is_dynamic_val(axs) == Val(false)

    axs = Axes(UnitSRange(1, 2), UnitSRange(1, 2), UnitSRange(1, 2));
    @test is_static_val(axs) == Val(true)
    @test is_fixed_val(axs) == Val(true)
    @test is_dynamic_val(axs) == Val(false)

    axs = Axes(UnitSRange(1, 2), UnitRange(1, 2), UnitRange(1, 2));
    @test is_static_val(axs) == Val(false)
    @test is_fixed_val(axs) == Val(true)
    @test is_dynamic_val(axs) == Val(false)

    axs = Axes(UnitRange(1, 2), UnitMRange(1, 2), UnitRange(1, 2));
    @test is_static_val(axs) == Val(false)
    @test is_fixed_val(axs) == Val(false)
    @test is_dynamic_val(axs) == Val(true)
end


