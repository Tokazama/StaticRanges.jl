
@testset "Mutable interface" begin


    @testset "set_ref!" begin
        @test @inferred(set_ref!(StepMRangeLen(1, 1, 10), 2)) == StepMRangeLen(2, 1, 10)
        @test @inferred(set_ref!(StepMRangeLen(1, 1, 10), UInt32(2))) == StepMRangeLen(2, 1, 10)
    end

    @testset "set_offset!" begin
        @test @inferred(set_offset!(StepMRangeLen(1, 1, 10), 2)) == StepMRangeLen(1, 1, 10, 2)
        @test @inferred(set_offset!(StepMRangeLen(1, 1, 10), UInt32(2))) == StepMRangeLen(1, 1, 10, 2)
    end

    @testset "is_static" begin
        @test @inferred(is_static(Any[])) == false
        @test @inferred(is_static(UnitSRange(1, 10))) == true
    end
end

