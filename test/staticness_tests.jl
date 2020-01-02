@testset "Staticness" begin
    # as_[mutable/immutable/static]
    for (i,m,s) in ((OneTo(4), OneToMRange(4), OneToSRange(4)),
                    (UnitRange(1, 3), UnitMRange(1, 3), UnitSRange(1, 3)),
                    (StepRange(1, 1, 4), StepMRange(1, 1, 4), StepSRange(1, 1, 4)),
                    (StepRangeLen(1, 1, 4), StepMRangeLen(1, 1, 4), StepSRangeLen(1, 1, 4)),
                    (LinRange(1, 4, 4), LinMRange(1, 4, 4), LinSRange(1, 4, 4)),
                    (SimpleAxis(UnitRange(1, 3)), SimpleAxis(UnitMRange(1, 3)), SimpleAxis(UnitSRange(1, 3))),
                    (Axis(UnitRange(1, 3),UnitRange(1, 3)), Axis(UnitMRange(1, 3),UnitMRange(1, 3)), Axis(UnitSRange(1, 3),UnitSRange(1, 3))),
                   )
        @testset "as_dynamic($(typeof(i).name))" begin
            @test is_dynamic(as_dynamic(i)) == true
            @test is_dynamic(as_dynamic(m)) == true
            @test is_dynamic(as_dynamic(s)) == true
        end

        @testset "as_fixed($(typeof(i).name))" begin
            @test is_fixed(as_fixed(i)) == true
            @test is_fixed(as_fixed(m)) == true
            @test is_fixed(as_fixed(s)) == true
        end

        @testset "as_static($(typeof(i).name))" begin
            @test is_static(as_static(i)) == true
            @test is_static(as_static(m)) == true
            @test is_static(as_static(s)) == true
        end
    end
end
