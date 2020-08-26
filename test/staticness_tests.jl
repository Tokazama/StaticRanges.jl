
@testset "Staticness" begin
    # as_[mutable/immutable/static]
    for (i,m,s) in ((OneTo(4), OneToMRange(4), OneToSRange(4)),
                    (UnitRange(1, 3), UnitMRange(1, 3), UnitSRange(1, 3)),
                    (StepRange(1, 1, 4), StepMRange(1, 1, 4), StepSRange(1, 1, 4)),
                    (StepRangeLen(1, 1, 4), StepMRangeLen(1, 1, 4), StepSRangeLen(1, 1, 4)),
                    (LinRange(1, 4, 4), LinMRange(1, 4, 4), LinSRange(1, 4, 4)),
                   )
        @testset "as_dynamic($(typeof(i).name))" begin
            i2 = @inferred(as_dynamic(i))
            m2 = @inferred(as_dynamic(m))
            s2 = @inferred(as_dynamic(s))
            @test @inferred(can_change_size(i2))
            @test @inferred(can_change_size(m2))
            @test @inferred(can_change_size(s2))
            @test i2 == m2 == s2
        end

        @testset "as_fixed($(typeof(i).name))" begin
            i2 = @inferred(as_fixed(i))
            m2 = @inferred(as_fixed(m))
            s2 = @inferred(as_fixed(s))
            @test @inferred(is_fixed(i2))
            @test @inferred(is_fixed(m2))
            @test @inferred(is_fixed(s2))
            @test i2 == m2 == s2
        end

        @testset "as_static($(typeof(i).name))" begin
            i2 = as_static(i)
            m2 = as_static(m)
            s2 = as_static(s)
            @test is_static(i2)
            @test is_static(m2)
            @test is_static(s2)
            @test i2 == m2 == s2
        end
    end

    x = @inferred(as_static(SVector(1)))
    @test @inferred(is_static(x))
    @test @inferred(is_fixed(x))
    @test !@inferred(can_change_size(x))

    x = @inferred(as_dynamic(x))
    @test !@inferred(is_static(x))
    @test !@inferred(is_fixed(x))
    @test @inferred(can_change_size(x))

    x = @inferred(as_static(x, Val((1,))))
    @test @inferred(is_static(x))
    @test @inferred(is_fixed(x))
    @test !@inferred(can_change_size(x))

    x = OneTo(10)
    s1 = @inferred(as_static(x, Val((10,))))
    s2 = as_static(x)
    @test is_static(s1)
    @test is_static(s2)

    @test @inferred(axes_type(SVector(1))) <: Tuple{SOneTo{1}}

    @test !@inferred(StaticRanges.has_offset_axes(1:10))
    @test !@inferred(StaticRanges.has_offset_axes(ones(2,2)))
    @test is_fixed(Int)
end

